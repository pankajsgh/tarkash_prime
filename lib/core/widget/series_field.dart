

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../network/api_path.dart';
import '../network/api_repository.dart';
import '../theme/colors.dart';

class SeriesField extends StatefulWidget {
  final double? width;
  final double? height;
  final SeriesController? controller;
  final Series? initialSeries;
  final String type;
  final String hint;
  final ValueChanged<Series?>? onSelected;
  final String seriesId;
  final bool showHeading;

  const SeriesField({
    super.key,
    this.width,
    this.height,
    this.type = 'Sales',
    this.hint = 'Search Series',
    this.controller,
    this.initialSeries,
    this.onSelected,
    required this.seriesId,
    this.showHeading = true,

  });

  @override
  State<SeriesField> createState() => _SeriesFieldState();
}

class _SeriesFieldState extends State<SeriesField> {
  static const double dropdownWidth = 260;
  static const double optionHeight = 51;

  late final SeriesController _internalController;

  SeriesController get _effectiveController => widget.controller ?? _internalController;

  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<int> _overlayUpdater = ValueNotifier<int>(0);

  List<Series> _seriesList = [];

  Timer? _searchDebounce;

  int _selectedIndex = -1;
  int _requestId = 0;

  bool _isUpdatingText = false;
  bool _isLoading = false;
  bool _hasError = false;
  bool _isOpen = false;
  bool _isDisposed = false;

  String _lastQuery = '';

  @override
  void initState() {
    super.initState();

    _internalController = SeriesController(
      initialSeries: widget.initialSeries,
    );

    if (widget.controller != null &&
        widget.initialSeries != null &&
        widget.controller!.value == null) {
      widget.controller!.selectSeries(widget.initialSeries);
    }

    _setSeriesText();
    _focusNode.addListener(_onFocusChanged);

    _fetchSeries('');
  }

  @override
  void didUpdateWidget(covariant SeriesField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      if (widget.controller != null &&
          widget.initialSeries != null &&
          widget.controller!.value == null) {
        widget.controller!.selectSeries(widget.initialSeries);
      }

      _setSeriesText();
    }

    if (oldWidget.initialSeries != widget.initialSeries &&
        widget.controller == null) {
      _effectiveController.selectSeries(widget.initialSeries);
      _setSeriesText();
    }

    if (oldWidget.type != widget.type) {
      _lastQuery = '';
      _fetchSeries(_textController.text.trim());
    }
  }

  // ============================================================
  // FETCH SERIES
  // ============================================================

  Future<void> _fetchSeries(String query) async {
    if (_isDisposed) return;

    final request = ++_requestId;

    if (mounted) {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
    }

    _refreshOverlay();

    try {
      final result = await requestSeries(query);

      if (!mounted || _isDisposed || request != _requestId) {
        return;
      }

      setState(() {
        _seriesList = result;
        _isLoading = false;
        _hasError = false;
      });

      final selected = _effectiveController.value;

      if (selected != null) {
        for (final series in result) {
          if (series.id == selected.id) {
            if (!identical(selected, series)) {
              _effectiveController.selectSeries(series);
            }
            break;
          }
        }
      }

      _refreshOverlay();
    } catch (e) {
      if (!mounted || _isDisposed || request != _requestId) {
        return;
      }

      setState(() {
        _isLoading = false;
        _hasError = true;
        _seriesList = [];
      });

      _refreshOverlay();
    }
  }

  Future<List<Series>> requestSeries(String query) async {
    final Map<String, dynamic> requestBody = {
      'id': widget.seriesId,
      'search': query,
      'limit': '0',
    };

    final response = await ApiProvider.createServerRequest(
      apiUrl: ApiPath.urlSeriesList,
      requestBody: requestBody,
      isFormData: true,
    );

    if (response['error'] == true) {
      final model = SeriesModel.fromJson(
        Map<String, dynamic>.from(response),
      );

      return model.data;
    }

    return [];
  }

  void _setSeriesText() {
    final text = _effectiveController.value?.name ?? '';

    if (_textController.text == text) return;

    _isUpdatingText = true;

    _textController.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );

    _isUpdatingText = false;
  }

  // ============================================================
  // TEXT SEARCH
  // ============================================================

  void _onTextChanged(String value) {
    if (_isUpdatingText || _isDisposed) return;

    _selectedIndex = -1;
    _isOpen = true;

    final query = value.trim();

    _searchDebounce?.cancel();

    if (query == _lastQuery && !_isLoading) {
      _refreshOverlay();
      return;
    }

    _searchDebounce = Timer(
      const Duration(milliseconds: 300),
          () {
        if (!mounted || _isDisposed) return;

        _lastQuery = query;
        _fetchSeries(query);
      },
    );

    _refreshOverlay();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.jumpTo(0);
    });
  }

  // ============================================================
  // OPEN DROPDOWN
  // ============================================================

  void _openDropdown() {
    _isOpen = true;
    _selectedIndex = -1;

    final query = _textController.text.trim();

    if (query != _lastQuery || _hasError) {
      _lastQuery = query;
      _fetchSeries(query);
    }

    _refreshOverlay();
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      _isOpen = false;
      _selectedIndex = -1;
      _refreshOverlay();
    }
  }

  // ============================================================
  // CLEAR SERIES
  // ============================================================

  void _clearText() {
    _searchDebounce?.cancel();

    _effectiveController.clear();
    widget.onSelected?.call(null);

    _isUpdatingText = true;
    _textController.clear();
    _isUpdatingText = false;

    _selectedIndex = -1;
    _lastQuery = '';
    _isOpen = true;

    _fetchSeries('');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _focusNode.requestFocus();

      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });
  }

  // ============================================================
  // SELECT SERIES
  // ============================================================

  void _selectSeries(Series series) {
    _searchDebounce?.cancel();

    _isUpdatingText = true;

    _textController.value = TextEditingValue(
      text: series.name,
      selection: TextSelection.collapsed(
        offset: series.name.length,
      ),
    );

    _isUpdatingText = false;

    _effectiveController.selectSeries(series);
    widget.onSelected?.call(series);

    _selectedIndex = -1;
    _isOpen = false;

    _focusNode.unfocus();
    _refreshOverlay();
  }

  // ============================================================
  // KEYBOARD NAVIGATION
  // ============================================================

  KeyEventResult _handleKey(
      FocusNode node,
      KeyEvent event,
      ) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    if (event.logicalKey == LogicalKeyboardKey.escape) {
      _isOpen = false;
      _selectedIndex = -1;
      _focusNode.unfocus();
      _refreshOverlay();

      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.enter) {
      if (_selectedIndex >= 0 &&
          _selectedIndex < _seriesList.length) {
        _selectSeries(_seriesList[_selectedIndex]);
      }

      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (_seriesList.isEmpty) {
        return KeyEventResult.handled;
      }

      _isOpen = true;

      _selectedIndex = _selectedIndex >= _seriesList.length - 1
          ? 0
          : _selectedIndex + 1;

      _refreshOverlay();
      _scrollToSelected();

      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (_seriesList.isEmpty) {
        return KeyEventResult.handled;
      }

      _isOpen = true;

      _selectedIndex = _selectedIndex <= 0
          ? _seriesList.length - 1
          : _selectedIndex - 1;

      _refreshOverlay();
      _scrollToSelected();

      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  void _scrollToSelected() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;

      if (_selectedIndex < 0 ||
          _selectedIndex >= _seriesList.length) {
        return;
      }

      final position = _scrollController.position;

      final itemTop = _selectedIndex * optionHeight;
      final itemBottom = itemTop + optionHeight;

      double target = position.pixels;

      if (itemTop < position.pixels) {
        target = itemTop;
      } else if (itemBottom >
          position.pixels + position.viewportDimension) {
        target = itemBottom - position.viewportDimension;
      }

      target = target.clamp(0.0, position.maxScrollExtent);

      if ((target - position.pixels).abs() < 0.5) return;

      _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 80),
        curve: Curves.easeOut,
      );
    });
  }

  void _refreshOverlay() {
    if (!_isDisposed) {
      _overlayUpdater.value++;
    }
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _decoration() {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: borderColor),
    );

    return InputDecoration(
      hintText: '${widget.hint}...',
      hintStyle: const TextStyle(
        fontSize: 11,
        color: textLight,
      ),
      prefixIcon: const Icon(
        Icons.list_alt_rounded,
        size: 17,
        color: textLight,
      ),
      suffixIcon: _textController.text.isNotEmpty
          ? IconButton(
        onPressed: _clearText,
        icon: const Icon(
          Icons.close_rounded,
          size: 17,
          color: textLight,
        ),
      )
          : const Icon(
        Icons.keyboard_arrow_down_rounded,
        size: 18,
        color: textLight,
      ),
      filled: true,
      fillColor: const Color(0xffF8FAFC),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 9,
      ),
      isDense: true,
      border: border,
      enabledBorder: border,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: Color(0xff3B82F6),
          width: 1.3,
        ),
      ),
    );
  }

  // ============================================================
  // DROPDOWN
  // ============================================================

  Widget _dropdown() {
    if (_isLoading) {
      return _messageDropdown(
        icon: null,
        message: 'Searching series...',
        showProgress: true,
      );
    }

    if (_hasError) {
      return _messageDropdown(
        icon: Icons.refresh_rounded,
        message: 'Unable to load series. Click to retry.',
        onTap: () => _fetchSeries(_textController.text.trim()),
      );
    }

    if (_seriesList.isEmpty) {
      return _messageDropdown(
        icon: Icons.search_off_rounded,
        message: 'No series found',
      );
    }

    return Material(
      elevation: 8,
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: dropdownWidth,
        height: _seriesList.length > 7
            ? 360
            : _seriesList.length * optionHeight,
        child: ListView.separated(
          controller: _scrollController,
          padding: EdgeInsets.zero,
          physics: const ClampingScrollPhysics(),
          itemCount: _seriesList.length,
          separatorBuilder: (_, __) => const Divider(
            height: 1,
            color: Color(0xffE2E8F0),
          ),
          itemBuilder: (context, index) {
            return _seriesItem(_seriesList[index], index);
          },
        ),
      ),
    );
  }

  Widget _messageDropdown({
    required IconData? icon,
    required String message,
    bool showProgress = false,
    VoidCallback? onTap,
  }) {
    return Material(
      elevation: 8,
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: dropdownWidth,
          height: 90,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (showProgress)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                else if (icon != null)
                  Icon(
                    icon,
                    size: 25,
                    color: const Color(0xffCBD5E1),
                  ),
                const SizedBox(height: 6),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xff64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SERIES OPTION
  // ============================================================

  Widget _seriesItem(Series series, int index) {
    return ValueListenableBuilder<int>(
      valueListenable: _overlayUpdater,
      builder: (context, _, __) {
        final selected = _selectedIndex == index;

        return SizedBox(
          height: optionHeight,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) {
              if (_selectedIndex == index) return;

              _selectedIndex = index;
              _refreshOverlay();
            },
            child: InkWell(
              onTap: () => _selectSeries(series),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                color: selected
                    ? const Color(0xffEEF2FF)
                    : Colors.transparent,
                child: Row(
                  children: [
                    _avatar(series),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _seriesDetails(series),
                    ),
                    const SizedBox(width: 8),
                    if (selected)
                      const Icon(
                        Icons.keyboard_return_rounded,
                        size: 13,
                        color: Color(0xff3B82F6),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _seriesDetails(Series series) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          series.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: textDark,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          series.voucherType,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xff64748B),
          ),
        ),
      ],
    );
  }

  Widget _avatar(Series series) {
    final letter = series.name.trim().isNotEmpty
        ? series.name.trim().substring(0, 1).toUpperCase()
        : '?';

    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xffEAF2FF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        letter,
        style: const TextStyle(
          color: blue,
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if(widget.showHeading)
        Text(
          widget.hint,
          style: const TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w600,
            color: textMedium,
          ),
        ),
        if(widget.showHeading)
        const SizedBox(height: 6),
        ValueListenableBuilder<Series?>(
          valueListenable: _effectiveController,
          builder: (context, selectedSeries, _) {
            return SizedBox(
              width: widget.width ?? dropdownWidth,
              height: widget.height ?? 36,
              child: RawAutocomplete<Series>(
                textEditingController: _textController,
                focusNode: _focusNode,
                displayStringForOption: (series) => series.name,
                optionsBuilder: (TextEditingValue value) {
                  // Search results are provided by the API.
                  return _seriesList;
                },
                onSelected: _selectSeries,
                fieldViewBuilder: (
                    context,
                    textController,
                    focusNode,
                    onFieldSubmitted,
                    ) {
                  return Focus(
                    onKeyEvent: _handleKey,
                    child: TextField(
                      controller: textController,
                      focusNode: focusNode,
                      onTap: _openDropdown,
                      onChanged: _onTextChanged,
                      style: const TextStyle(
                        fontSize: 12,
                        color: textDark,
                      ),
                      decoration: _decoration(),
                    ),
                  );
                },
                optionsViewBuilder: (context, onSelected, options) {
                  return ValueListenableBuilder<int>(
                    valueListenable: _overlayUpdater,
                    builder: (context, _, __) {
                      if (!_isOpen || !_focusNode.hasFocus) {
                        return const SizedBox.shrink();
                      }

                      return Align(
                        alignment: Alignment.topLeft,
                        child: _dropdown(),
                      );
                    },
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _isDisposed = true;
    _requestId++;

    _searchDebounce?.cancel();
    _focusNode.removeListener(_onFocusChanged);

    _textController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    _overlayUpdater.dispose();

    if (widget.controller == null) {
      _internalController.dispose();
    }

    super.dispose();
  }
}

///series controller
class SeriesController extends ValueNotifier<Series?> {
  SeriesController({Series? initialSeries}) : super(initialSeries);

  Series? get selectedSeries => value;

  void selectSeries(Series? series) {
    value = series;
  }

  void clear() {
    value = null;
  }
}

///series model
class SeriesModel {
  final int code;
  final bool error;
  final String message;
  final List<Series> data;

  SeriesModel({
    required this.code,
    required this.error,
    required this.message,
    required this.data,
  });

  factory SeriesModel.fromJson(Map<String, dynamic> json) {
    return SeriesModel(
      code: json['code'] ?? 0,
      error: json['error'] ?? false,
      message: json['message']?.toString() ?? '',
      data: (json['data'] as List?)
          ?.map((e) => Series.fromJson(
        Map<String, dynamic>.from(e),
      ))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'error': error,
      'message': message,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}

class Series {
  final String id;
  final String name;
  final String voucherType;
  final String store;

  Series({
    required this.id,
    required this.name,
    required this.voucherType,
    required this.store,
  });

  factory Series.fromJson(Map<String, dynamic> json) {
    return Series(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      voucherType: json['voucher_type']?.toString() ?? '',
      store: json['store']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'voucher_type': voucherType,
      'store': store,
    };
  }
}