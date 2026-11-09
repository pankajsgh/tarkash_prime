
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../network/api_path.dart';
import '../network/api_repository.dart';
import '../theme/colors.dart';
import '../ulitls/utility.dart';

// ============================================================
// LEAD SOURCE FIELD
// ============================================================

class LeadSourceField extends StatefulWidget {
  final double? width;
  final double? height;
  final LeadSourceController controller;
  final LeadSource? initialLeadSource;
  final String hint;
  final ValueChanged<LeadSource?>? onSelected;
  final FocusNode? focusNode;

  const LeadSourceField({
    super.key,
    required this.controller,
    this.focusNode,
    this.width,
    this.height,
    this.hint = 'Search Lead Source',
    this.initialLeadSource,
    this.onSelected,
  });

  @override
  State<LeadSourceField> createState() => LeadSourceFieldState();
}

class LeadSourceFieldState extends State<LeadSourceField> {
  static const double dropdownWidth = 260;
  static const double optionHeight = 51;

  final TextEditingController _textController =
  TextEditingController();

  final FocusNode _internalFocusNode = FocusNode();

  final ScrollController _scrollController =
  ScrollController();

  final ValueNotifier<int> _overlayUpdater =
  ValueNotifier<int>(0);

  FocusNode get _effectiveFocusNode =>
      widget.focusNode ?? _internalFocusNode;

  // Complete API data
  List<LeadSource> _allLeadSources = [];

  // Filtered dropdown data
  List<LeadSource> _leadSources = [];

  int _selectedIndex = -1;
  int _requestId = 0;

  bool _isUpdatingText = false;
  bool _isLoading = false;
  bool _hasError = false;
  bool _isOpen = false;
  bool _isDisposed = false;

  // ============================================================
  // INIT STATE
  // ============================================================

  @override
  void initState() {
    super.initState();

    if (widget.initialLeadSource != null &&
        widget.controller.value == null) {
      widget.controller.selectLeadSource(
        widget.initialLeadSource,
      );
    }

    _setLeadSourceText();

    _effectiveFocusNode.addListener(_onFocusChanged);

    _fetchLeadSources();
  }

  // ============================================================
  // UPDATE WIDGET
  // ============================================================

  @override
  void didUpdateWidget(covariant LeadSourceField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.focusNode != widget.focusNode) {
      final oldFocusNode =
          oldWidget.focusNode ?? _internalFocusNode;

      oldFocusNode.removeListener(_onFocusChanged);

      _effectiveFocusNode.addListener(_onFocusChanged);
    }

    if (oldWidget.controller != widget.controller) {
      _setLeadSourceText();
    }

    if (oldWidget.initialLeadSource !=
        widget.initialLeadSource &&
        widget.controller.value == null) {
      widget.controller.selectLeadSource(
        widget.initialLeadSource,
      );

      _setLeadSourceText();
    }
  }

  // ============================================================
  // FOCUS AND OPEN
  // ============================================================

  void focusAndOpen() {
    if (!mounted || _isDisposed) return;

    _effectiveFocusNode.requestFocus();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _isDisposed) return;

      _openDropdown();
    });
  }

  void _openDropdown() {
    if (_isDisposed) return;

    _isOpen = true;
    _selectedIndex = -1;

    if (_hasError) {
      _fetchLeadSources();
    } else {
      _onTextChanged(_textController.text);
    }

    _refreshOverlay();
  }

  void _onFocusChanged() {
    if (_isDisposed) return;

    if (_effectiveFocusNode.hasFocus) {
      _isOpen = true;

      if (_hasError) {
        _fetchLeadSources();
      } else {
        _onTextChanged(_textController.text);
      }
    } else {
      _isOpen = false;
      _selectedIndex = -1;
    }

    _refreshOverlay();
  }

  // ============================================================
  // FETCH LEAD SOURCES
  // ============================================================

  Future<void> _fetchLeadSources() async {
    if (_isDisposed || _isLoading) return;

    final request = ++_requestId;

    if (mounted) {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
    }

    _refreshOverlay();

    try {
      final result = await requestLeadSources();

      if (!mounted ||
          _isDisposed ||
          request != _requestId) {
        return;
      }

      setState(() {
        // Save complete API response.
        _allLeadSources = List<LeadSource>.from(result);

        // Display complete data initially.
        _leadSources = List<LeadSource>.from(result);

        _isLoading = false;
        _hasError = false;
      });

      // Restore selected item using ID.
      final selected = widget.controller.value;

      if (selected != null) {
        for (final source in _allLeadSources) {
          if (source.id == selected.id) {
            widget.controller.selectLeadSource(source);
            break;
          }
        }
      }

      // Apply search if text already exists.
      if (_textController.text.trim().isNotEmpty) {
        _onTextChanged(_textController.text);
      }

      print('========== LEAD SOURCE FETCH ==========');
      print('TOTAL RECORDS: ${_allLeadSources.length}');
      print(
        'SOURCES: ${_allLeadSources.map((e) => e.sourceName).toList()}',
      );

      _refreshOverlay();
    } catch (e, stackTrace) {
      if (!mounted ||
          _isDisposed ||
          request != _requestId) {
        return;
      }

      setState(() {
        _isLoading = false;
        _hasError = true;
        _allLeadSources = [];
        _leadSources = [];
      });

      printLog('leadSourceFetchError: $e');
      print(stackTrace);

      _refreshOverlay();
    }
  }

  // ============================================================
  // API REQUEST
  // ============================================================

  Future<List<LeadSource>> requestLeadSources() async {
    final response = await ApiProvider.createServerRequest(
      apiUrl: ApiPath.getLeadSourceList,
      // requestBody: {},
      // isFormData: true,
    );

    print('========== LEAD SOURCE API ==========');
    print('API RESPONSE: $response');

    final model = LeadSourceModel.fromJson(
      Map<String, dynamic>.from(response),
    );

    print('API CODE: ${model.code}');
    print('API ERROR: ${model.error}');
    print('API MESSAGE: ${model.message}');
    print('API DATA COUNT: ${model.data.length}');

    // Your existing API convention uses error=true for success.
    if ((model.code == 200 || model.code == 1) &&
        model.error == true) {
      return model.data;
    }

    throw Exception(
      model.message.isNotEmpty
          ? model.message
          : 'Unable to fetch lead sources',
    );
  }

  // ============================================================
  // SET SELECTED TEXT
  // ============================================================

  void _setLeadSourceText() {
    final text =
        widget.controller.value?.sourceName ?? '';

    if (_textController.text == text) return;

    _isUpdatingText = true;

    _textController.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(
        offset: text.length,
      ),
    );

    _isUpdatingText = false;
  }

  // ============================================================
  // LOCAL SEARCH
  // ============================================================

  void _onTextChanged(String value) {
    if (_isUpdatingText || _isDisposed) return;

    final query = value.trim().toLowerCase();

    _selectedIndex = -1;
    _isOpen = true;

    if (query.isEmpty) {
      // Restore all API records.
      _leadSources =
      List<LeadSource>.from(_allLeadSources);
    } else {
      // Filter complete cached data.
      _leadSources = _allLeadSources.where((source) {
        return source.sourceName
            .toLowerCase()
            .contains(query) ||
            source.id.toLowerCase().contains(query) ||
            source.status.toLowerCase().contains(query);
      }).toList();
    }

    _refreshOverlay();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          _isDisposed ||
          !_scrollController.hasClients) {
        return;
      }

      _scrollController.jumpTo(0);
    });
  }

  // ============================================================
  // CLEAR LEAD SOURCE
  // ============================================================

  void _clearText() {
    widget.controller.clear();

    widget.onSelected?.call(null);

    _isUpdatingText = true;
    _textController.clear();
    _isUpdatingText = false;

    _selectedIndex = -1;
    _isOpen = true;

    // Restore full API list.
    _leadSources =
    List<LeadSource>.from(_allLeadSources);

    _refreshOverlay();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _isDisposed) return;

      _effectiveFocusNode.requestFocus();

      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });
  }

  // ============================================================
  // SELECT LEAD SOURCE
  // ============================================================

  void _selectLeadSource(LeadSource source) {
    if (_isDisposed) return;

    _isUpdatingText = true;

    _textController.value = TextEditingValue(
      text: source.sourceName,
      selection: TextSelection.collapsed(
        offset: source.sourceName.length,
      ),
    );

    _isUpdatingText = false;

    widget.controller.selectLeadSource(source);

    widget.onSelected?.call(source);

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
          _selectedIndex < _leadSources.length) {
        _selectLeadSource(
          _leadSources[_selectedIndex],
        );
      }

      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (_leadSources.isEmpty) {
        return KeyEventResult.handled;
      }

      _isOpen = true;

      _selectedIndex =
      _selectedIndex >= _leadSources.length - 1
          ? 0
          : _selectedIndex + 1;

      _refreshOverlay();
      _scrollToSelected();

      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (_leadSources.isEmpty) {
        return KeyEventResult.handled;
      }

      _isOpen = true;

      _selectedIndex = _selectedIndex <= 0
          ? _leadSources.length - 1
          : _selectedIndex - 1;

      _refreshOverlay();
      _scrollToSelected();

      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  // ============================================================
  // SCROLL TO SELECTED
  // ============================================================

  void _scrollToSelected() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          _isDisposed ||
          !_scrollController.hasClients) {
        return;
      }

      if (_selectedIndex < 0 ||
          _selectedIndex >= _leadSources.length) {
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

      target = target.clamp(
        0.0,
        position.maxScrollExtent,
      );

      if ((target - position.pixels).abs() < 0.5) {
        return;
      }

      _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 80),
        curve: Curves.easeOut,
      );
    });
  }

  // ============================================================
  // REFRESH OVERLAY
  // ============================================================

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
      borderSide: const BorderSide(
        color: borderColor,
      ),
    );

    return InputDecoration(
      hintText: '${widget.hint}...',
      hintStyle: const TextStyle(
        fontSize: 11,
        color: textLight,
      ),
      prefixIcon: const Icon(
        Icons.campaign_outlined,
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
        message: 'Loading lead sources...',
        showProgress: true,
      );
    }

    if (_hasError) {
      return _messageDropdown(
        icon: Icons.refresh_rounded,
        message: 'Unable to load lead sources. Click to retry.',
        onTap: _fetchLeadSources,
      );
    }

    if (_leadSources.isEmpty) {
      return _messageDropdown(
        icon: Icons.search_off_rounded,
        message: 'No lead source found',
      );
    }

    return Material(
      elevation: 8,
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: dropdownWidth,
        height: _leadSources.length > 7
            ? 360
            : _leadSources.length * optionHeight,
        child: ListView.separated(
          controller: _scrollController,
          padding: EdgeInsets.zero,
          physics: const ClampingScrollPhysics(),
          itemCount: _leadSources.length,
          separatorBuilder: (_, __) => const Divider(
            height: 1,
            color: Color(0xffE2E8F0),
          ),
          itemBuilder: (context, index) {
            return _leadSourceItem(
              _leadSources[index],
              index,
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // MESSAGE DROPDOWN
  // ============================================================

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
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
            ),
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
  // LEAD SOURCE ITEM
  // ============================================================

  Widget _leadSourceItem(
      LeadSource source,
      int index,
      ) {
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
              onTap: () => _selectLeadSource(source),
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
                    _avatar(source),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _leadSourceDetails(source),
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

  // ============================================================
  // LEAD SOURCE DETAILS
  // ============================================================

  Widget _leadSourceDetails(LeadSource source) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          source.sourceName,
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
          'ID: ${source.id}',
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

  // ============================================================
  // AVATAR
  // ============================================================

  Widget _avatar(LeadSource source) {
    final letter = source.sourceName.trim().isNotEmpty
        ? source.sourceName
        .trim()
        .substring(0, 1)
        .toUpperCase()
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
        ValueListenableBuilder<LeadSource?>(
          valueListenable: widget.controller,
          builder: (context, selectedSource, _) {
            return SizedBox(
              width: widget.width ?? dropdownWidth,
              height: widget.height ?? 36,
              child: RawAutocomplete<LeadSource>(
                textEditingController: _textController,
                focusNode: _effectiveFocusNode,
                displayStringForOption: (source) =>
                source.sourceName,
                optionsBuilder: (TextEditingValue value) {
                  return _leadSources;
                },
                onSelected: _selectLeadSource,
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
                optionsViewBuilder: (
                    context,
                    onSelected,
                    options,
                    ) {
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

    _effectiveFocusNode.removeListener(_onFocusChanged);

    _internalFocusNode.dispose();
    _textController.dispose();
    _scrollController.dispose();
    _overlayUpdater.dispose();

    super.dispose();
  }
}

// ============================================================
// LEAD SOURCE CONTROLLER
// ============================================================

class LeadSourceController extends ValueNotifier<LeadSource?> {
  LeadSourceController({
    LeadSource? initialLeadSource,
  }) : super(initialLeadSource);

  LeadSource? get selectedLeadSource => value;

  void selectLeadSource(LeadSource? source) {
    value = source;
  }

  void clear() {
    value = null;
  }
}

// ============================================================
// LEAD SOURCE MODEL
// ============================================================

class LeadSourceModel {
  final int code;
  final bool error;
  final String message;
  final List<LeadSource> data;

  LeadSourceModel({
    required this.code,
    required this.error,
    required this.message,
    required this.data,
  });

  factory LeadSourceModel.fromJson(
      Map<String, dynamic> json,
      ) {
    final rawData = json['data'];

    return LeadSourceModel(
      code: int.tryParse(
        '${json['code'] ?? 0}',
      ) ??
          0,
      error: json['error'] == true ||
          json['error'] == 1 ||
          json['error'] == 'true' ||
          json['error'] == '1',
      message: json['message']?.toString() ??
          json['msg']?.toString() ??
          '',
      data: rawData is List
          ? rawData
          .whereType<Map>()
          .map(
            (e) => LeadSource.fromJson(
          Map<String, dynamic>.from(e),
        ),
      )
          .toList()
          : [],
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

// ============================================================
// LEAD SOURCE DATA
// ============================================================

class LeadSource {
  final String id;
  final String sourceName;
  final String status;
  final String createdAt;
  final String updatedAt;

  LeadSource({
    required this.id,
    required this.sourceName,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LeadSource.fromJson(
      Map<String, dynamic> json,
      ) {
    return LeadSource(
      id: json['id']?.toString() ?? '',
      sourceName: json['source_name']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'source_name': sourceName,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
