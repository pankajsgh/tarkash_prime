import 'dart:async';

import 'package:calculation_panel/core/ulitls/utility.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../network/api_path.dart';
import '../network/api_repository.dart';
import '../theme/colors.dart';

class RateTypeField extends StatefulWidget {
  final double? width;
  final double? height;
  final RateTypeController controller;
  final RateType? initialRateType;
  final String hint;
  final ValueChanged<RateType?>? onSelected;
  final FocusNode? focusNode;

  const RateTypeField({
    super.key,
    required this.controller,
    this.focusNode,
    this.width,
    this.height,
    this.hint = 'Search Rate Type',
    this.initialRateType,
    this.onSelected,
  });

  @override
  State<RateTypeField> createState() => RateTypeFieldState();
}

class RateTypeFieldState extends State<RateTypeField> {
  static const double dropdownWidth = 260;
  static const double optionHeight = 51;

  late final RateTypeController _internalController;

  RateTypeController get _effectiveController => widget.controller;

  final TextEditingController _textController = TextEditingController();

  final FocusNode _internalFocusNode = FocusNode();

  FocusNode get _effectiveFocusNode =>
      widget.focusNode ?? _internalFocusNode;

  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<int> _overlayUpdater = ValueNotifier<int>(0);

  List<RateType> _rateTypes = [];

  Timer? _searchDebounce;

  int _selectedIndex = -1;
  int _requestId = 0;

  bool _isUpdatingText = false;
  bool _isLoading = false;
  bool _hasError = false;
  bool _isOpen = false;
  bool _isDisposed = false;

  String _lastQuery = '';

  void focusAndOpen() {
    if (!mounted || _isDisposed) return;

    // Request focus first.
    _effectiveFocusNode.requestFocus();

    // Open the dropdown after the focus change.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _isDisposed) return;

      if (!_effectiveFocusNode.hasFocus) {
        _effectiveFocusNode.requestFocus();
      }

      _openDropdown();
    });
  }

  @override
  void initState() {
    super.initState();

    _internalController = RateTypeController(
      initialRateType: widget.initialRateType,
    );

    if (widget.initialRateType != null &&
        widget.controller.value == null) {
      widget.controller.selectRateType(widget.initialRateType);
    }

    _setRateTypeText();

    _effectiveFocusNode.addListener(_onFocusChanged);

    _fetchRateTypes('');
  }

  @override
  void didUpdateWidget(covariant RateTypeField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode?.removeListener(_onFocusChanged);
      _effectiveFocusNode.addListener(_onFocusChanged);
    }

    if (oldWidget.controller != widget.controller) {
      if (widget.initialRateType != null &&
          widget.controller.value == null) {
        widget.controller.selectRateType(widget.initialRateType);
      }

      _setRateTypeText();
    }

    if (oldWidget.initialRateType != widget.initialRateType &&
        widget.controller.value == null) {
      widget.controller.selectRateType(widget.initialRateType);
      _setRateTypeText();
    }
  }

// ============================================================
// FETCH RATE TYPES
// ============================================================

  Future<void> _fetchRateTypes(String query) async {
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
      final result = await requestRateTypes(query);

      if (!mounted || _isDisposed || request != _requestId) {
        return;
      }

      setState(() {
        _rateTypes = result;
        _isLoading = false;
        _hasError = false;
      });

      final selected = _effectiveController.value;

      if (selected != null) {
        for (final rateType in result) {
          if (rateType.id == selected.id) {
            if (selected.name != rateType.name ||
                !identical(selected, rateType)) {
              _effectiveController.selectRateType(rateType);
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
        _rateTypes = [];
      });

      _refreshOverlay();
    }
  }

  Future<List<RateType>> requestRateTypes(String query) async {
    final Map<String, dynamic> requestBody = {
      'search': query,
      'limit': '0',
    };

    final response = await ApiProvider.createServerRequest(
      apiUrl: ApiPath.urlRateType,
      requestBody: requestBody,
      isFormData: true,
    );

    final model = RateTypeModel.fromJson(
      Map<String, dynamic>.from(response),
    );

// Adjust this condition if your API uses a different success convention.
    if (model.code == 1 && model.error == true) {
      printLog('rateTypeDebug: ${response}');
      return model.data;
    }

    return [];
  }

  void _setRateTypeText() {
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
        _fetchRateTypes(query);
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

    if (query != _lastQuery || _hasError || _rateTypes.isEmpty) {
      _lastQuery = query;
      _fetchRateTypes(query);
    }

    _refreshOverlay();
  }

  void _onFocusChanged() {
    if (_isDisposed) return;

    if (_effectiveFocusNode.hasFocus) {
      _isOpen = true;

      final query = _textController.text.trim();

      if (query != _lastQuery || _hasError || _rateTypes.isEmpty) {
        _lastQuery = query;
        _fetchRateTypes(query);
      }
    } else {
      _isOpen = false;
      _selectedIndex = -1;
    }

    _refreshOverlay();
  }

// ============================================================
// CLEAR RATE TYPE
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

    _fetchRateTypes('');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _isDisposed) return;

      _effectiveFocusNode.requestFocus();

      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });
  }

// ============================================================
// SELECT RATE TYPE
// ============================================================

  void _selectRateType(RateType rateType) {
    _searchDebounce?.cancel();

    _isUpdatingText = true;

    _textController.value = TextEditingValue(
      text: rateType.name,
      selection: TextSelection.collapsed(
        offset: rateType.name.length,
      ),
    );

    _isUpdatingText = false;

    _effectiveController.selectRateType(rateType);
    widget.onSelected?.call(rateType);

    _selectedIndex = -1;
    _isOpen = false;

    _effectiveFocusNode.unfocus();
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
      _effectiveFocusNode.unfocus();
      _refreshOverlay();

      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.enter) {
      if (_selectedIndex >= 0 &&
          _selectedIndex < _rateTypes.length) {
        _selectRateType(_rateTypes[_selectedIndex]);
      }

      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (_rateTypes.isEmpty) {
        return KeyEventResult.handled;
      }

      _isOpen = true;

      _selectedIndex = _selectedIndex >= _rateTypes.length - 1
          ? 0
          : _selectedIndex + 1;

      _refreshOverlay();
      _scrollToSelected();

      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (_rateTypes.isEmpty) {
        return KeyEventResult.handled;
      }

      _isOpen = true;

      _selectedIndex = _selectedIndex <= 0
          ? _rateTypes.length - 1
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
          _selectedIndex >= _rateTypes.length) {
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
        Icons.price_change_outlined,
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
        message: 'Searching rate types...',
        showProgress: true,
      );
    }

    if (_hasError) {
      return _messageDropdown(
        icon: Icons.refresh_rounded,
        message: 'Unable to load rate types. Click to retry.',
        onTap: () => _fetchRateTypes(
          _textController.text.trim(),
        ),
      );
    }

    if (_rateTypes.isEmpty) {
      return _messageDropdown(
        icon: Icons.search_off_rounded,
        message: 'No rate type found',
      );
    }

    return Material(
      elevation: 8,
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: dropdownWidth,
        height: _rateTypes.length > 7
            ? 360
            : _rateTypes.length * optionHeight,
        child: ListView.separated(
          controller: _scrollController,
          padding: EdgeInsets.zero,
          physics: const ClampingScrollPhysics(),
          itemCount: _rateTypes.length,
          separatorBuilder: (_, __) => const Divider(
            height: 1,
            color: Color(0xffE2E8F0),
          ),
          itemBuilder: (context, index) {
            return _rateTypeItem(_rateTypes[index], index);
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
// RATE TYPE OPTION
// ============================================================

  Widget _rateTypeItem(RateType rateType, int index) {
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
              onTap: () => _selectRateType(rateType),
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
                    _avatar(rateType),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _rateTypeDetails(rateType),
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

  Widget _rateTypeDetails(RateType rateType) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          rateType.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: textDark,
          ),
        ),
      ],
    );
  }

  Widget _avatar(RateType rateType) {
    final letter = rateType.name.trim().isNotEmpty
        ? rateType.name.trim().substring(0, 1).toUpperCase()
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
        Text(
          widget.hint,
          style: const TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w600,
            color: textMedium,
          ),
        ),
        const SizedBox(height: 6),
        ValueListenableBuilder<RateType?>(
          valueListenable: _effectiveController,
          builder: (context, selectedRateType, _) {
            return SizedBox(
              width: widget.width ?? dropdownWidth,
              height: widget.height ?? 36,
              child: RawAutocomplete<RateType>(
                textEditingController: _textController,
                focusNode: _effectiveFocusNode,
                displayStringForOption: (rateType) => rateType.name,
                optionsBuilder: (TextEditingValue value) {
                  return _rateTypes;
                },
                onSelected: _selectRateType,
                fieldViewBuilder: (
                    context,
                    textController,
                    fieldFocusNode,
                    onFieldSubmitted,
                    ) {
                  return Focus(
                    onKeyEvent: _handleKey,
                    child: TextField(
                      controller: textController,
                      focusNode: fieldFocusNode,
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
                      if (!_isOpen ||
                          !_effectiveFocusNode.hasFocus) {
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
    _effectiveFocusNode.removeListener(_onFocusChanged);

    _internalFocusNode.dispose();
    _internalController.dispose();
    _textController.dispose();
    _scrollController.dispose();
    _overlayUpdater.dispose();

    super.dispose();
  }
}

class RateTypeController extends ValueNotifier<RateType?> {
  RateTypeController({RateType? initialRateType})
      : super(initialRateType);

  RateType? get selectedRateType => value;

  void selectRateType(RateType? rateType) {
    value = rateType;
  }

  void clear() {
    value = null;
  }
}

class RateTypeModel {
  final int code;
  final bool error;
  final String message;
  final List<RateType> data;

  RateTypeModel({
    required this.code,
    required this.error,
    required this.message,
    required this.data,
  });

  factory RateTypeModel.fromJson(Map<String, dynamic> json) {
    return RateTypeModel(
      code: int.tryParse('${json['code'] ?? 0}') ?? 0,
      error: json['error'] == true,
      message: json['message']?.toString() ?? '',
      data: (json['data'] as List?)
          ?.map(
            (e) => RateType.fromJson(
          Map<String, dynamic>.from(e),
        ),
      )
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

class RateType {
  final String id;
  final String name;

  RateType({
    required this.id,
    required this.name,
  });

  factory RateType.fromJson(Map<String, dynamic> json) {
    return RateType(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
