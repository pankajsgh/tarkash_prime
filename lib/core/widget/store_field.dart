import 'dart:async';

import 'package:calculation_panel/core/ulitls/utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../network/api_path.dart';
import '../network/api_repository.dart';
import '../theme/colors.dart';

class StoreField extends StatefulWidget {
  final double? width;
  final double? height;
  final StoreController controller;
  final Store? initialStore;
  final String hint;
  final ValueChanged<Store?>? onSelected;
  final FocusNode? focusNode;

  const StoreField({
    super.key,
    required this.controller,
    this.focusNode,
    this.width,
    this.height,
    this.hint = 'Search Store',
    this.initialStore,
    this.onSelected,
  });

  @override
  State<StoreField> createState() => StoreFieldState();
}

class StoreFieldState extends State<StoreField> {
  static const double dropdownWidth = 260;
  static const double optionHeight = 51;

  final TextEditingController _textController =
  TextEditingController();

  final FocusNode _internalFocusNode = FocusNode();

  FocusNode get _effectiveFocusNode =>
      widget.focusNode ?? _internalFocusNode;

  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<int> _overlayUpdater = ValueNotifier<int>(0);

  List<Store> _stores = [];

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

    _effectiveFocusNode.requestFocus();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _isDisposed) return;

      _openDropdown();
    });
  }

  @override
  void initState() {
    super.initState();

    if (widget.initialStore != null &&
        widget.controller.value == null) {
      widget.controller.selectStore(widget.initialStore);
    }

    _setStoreText();

    _effectiveFocusNode.addListener(_onFocusChanged);

    _fetchStores('');
  }

  @override
  void didUpdateWidget(covariant StoreField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode?.removeListener(_onFocusChanged);
      _effectiveFocusNode.addListener(_onFocusChanged);
    }

    if (oldWidget.controller != widget.controller) {
      _setStoreText();
    }

    if (oldWidget.initialStore != widget.initialStore &&
        widget.controller.value == null) {
      widget.controller.selectStore(widget.initialStore);
      _setStoreText();
    }
  }

// ============================================================
// FETCH STORES
// ============================================================

  Future<void> _fetchStores(String query) async {
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
      final result = await requestStores(query);

      if (!mounted || _isDisposed || request != _requestId) {
        return;
      }

      setState(() {
        _stores = result;
        _isLoading = false;
        _hasError = false;
      });

      final selected = widget.controller.value;

      if (selected != null) {
        for (final store in result) {
          if (store.id == selected.id) {
            if (!identical(selected, store)) {
              widget.controller.selectStore(store);
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
        _stores = [];
      });

      printLog('storeFetchError: $e');

      _refreshOverlay();
    }
  }

  Future<List<Store>> requestStores(String query) async {
    final Map<String, dynamic> requestBody = {
      'search': query,
      'limit': '0',
    };

    final response = await ApiProvider.createServerRequest(
      apiUrl: ApiPath.getStoreList,
      requestBody: requestBody,
      isFormData: true,
    );

    final model = StoreModelResponse.fromJson(
      Map<String, dynamic>.from(response),
    );

    if (model.code == 1 && model.error == true) {
      printLog('storeDebug: $response');
      return model.storeList;
    }

    return [];
  }

  void _setStoreText() {
    final text = widget.controller.value?.store ?? '';

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
        _fetchStores(query);
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

    if (query != _lastQuery || _hasError || _stores.isEmpty) {
      _lastQuery = query;
      _fetchStores(query);
    }

    _refreshOverlay();
  }

  void _onFocusChanged() {
    if (_isDisposed) return;

    if (_effectiveFocusNode.hasFocus) {
      _isOpen = true;

      final query = _textController.text.trim();

      if (query != _lastQuery ||
          _hasError ||
          _stores.isEmpty) {
        _lastQuery = query;
        _fetchStores(query);
      }
    } else {
      _isOpen = false;
      _selectedIndex = -1;
    }

    _refreshOverlay();
  }

// ============================================================
// CLEAR STORE
// ============================================================

  void _clearText() {
    _searchDebounce?.cancel();

    widget.controller.clear();
    widget.onSelected?.call(null);

    _isUpdatingText = true;
    _textController.clear();
    _isUpdatingText = false;

    _selectedIndex = -1;
    _lastQuery = '';
    _isOpen = true;

    _fetchStores('');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _isDisposed) return;

      _effectiveFocusNode.requestFocus();

      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });
  }

// ============================================================
// SELECT STORE
// ============================================================

  void _selectStore(Store store) {
    _searchDebounce?.cancel();

    _isUpdatingText = true;

    _textController.value = TextEditingValue(
      text: store.store,
      selection: TextSelection.collapsed(
        offset: store.store.length,
      ),
    );

    _isUpdatingText = false;

    widget.controller.selectStore(store);
    widget.onSelected?.call(store);

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
          _selectedIndex < _stores.length) {
        _selectStore(_stores[_selectedIndex]);
      }

      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (_stores.isEmpty) {
        return KeyEventResult.handled;
      }

      _isOpen = true;

      _selectedIndex = _selectedIndex >= _stores.length - 1
          ? 0
          : _selectedIndex + 1;

      _refreshOverlay();
      _scrollToSelected();

      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (_stores.isEmpty) {
        return KeyEventResult.handled;
      }

      _isOpen = true;

      _selectedIndex = _selectedIndex <= 0
          ? _stores.length - 1
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
          _selectedIndex >= _stores.length) {
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
        Icons.store_outlined,
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
        message: 'Searching stores...',
        showProgress: true,
      );
    }

    if (_hasError) {
      return _messageDropdown(
        icon: Icons.refresh_rounded,
        message: 'Unable to load stores. Click to retry.',
        onTap: () => _fetchStores(
          _textController.text.trim(),
        ),
      );
    }

    if (_stores.isEmpty) {
      return _messageDropdown(
        icon: Icons.search_off_rounded,
        message: 'No store found',
      );
    }

    return Material(
      elevation: 8,
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: dropdownWidth,
        height: _stores.length > 7
            ? 360
            : _stores.length * optionHeight,
        child: ListView.separated(
          controller: _scrollController,
          padding: EdgeInsets.zero,
          physics: const ClampingScrollPhysics(),
          itemCount: _stores.length,
          separatorBuilder: (_, __) => const Divider(
            height: 1,
            color: Color(0xffE2E8F0),
          ),
          itemBuilder: (context, index) {
            return _storeItem(_stores[index], index);
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
// STORE OPTION
// ============================================================

  Widget _storeItem(Store store, int index) {
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
              onTap: () => _selectStore(store),
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
                    _avatar(store),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _storeDetails(store),
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

  Widget _storeDetails(Store store) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          store.store,
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
          '${store.shortName} • ID: ${store.id}',
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

  Widget _avatar(Store store) {
    final letter = store.shortName.trim().isNotEmpty
        ? store.shortName.trim().substring(0, 1).toUpperCase()
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
        ValueListenableBuilder<Store?>(
          valueListenable: widget.controller,
          builder: (context, selectedStore, _) {
            return SizedBox(
              width: widget.width ?? dropdownWidth,
              height: widget.height ?? 36,
              child: RawAutocomplete<Store>(
                textEditingController: _textController,
                focusNode: _effectiveFocusNode,
                displayStringForOption: (store) => store.store,
                optionsBuilder: (TextEditingValue value) {
                  return _stores;
                },
                onSelected: _selectStore,
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
    _textController.dispose();
    _scrollController.dispose();
    _overlayUpdater.dispose();

    super.dispose();
  }
}

class StoreController extends ValueNotifier<Store?> {
  StoreController({Store? initialStore}) : super(initialStore);

  Store? get selectedStore => value;

  void selectStore(Store? store) {
    value = store;
  }

  void clear() {
    value = null;
  }
}

class StoreModelResponse {
  final int code;
  final bool error;
  final String nums;
  final String totalData;
  final String msg;
  final List<Store> storeList;

  StoreModelResponse({
    required this.code,
    required this.error,
    required this.nums,
    required this.totalData,
    required this.msg,
    required this.storeList,
  });

  factory StoreModelResponse.fromJson(Map<String, dynamic> json) {
    return StoreModelResponse(
      code: int.tryParse('${json['code'] ?? 0}') ?? 0,
      error: json['error'] == true,
      nums: json['nums']?.toString() ?? '0',
      totalData: json['TotalData']?.toString() ?? '0',
      msg: json['msg']?.toString() ?? '',
      storeList: (json['StoreList'] as List?)
          ?.map(
            (e) => Store.fromJson(
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
      'nums': nums,
      'TotalData': totalData,
      'msg': msg,
      'StoreList': storeList.map((e) => e.toJson()).toList(),
    };
  }
}

class Store {
  final String id;
  final String store;
  final String shortName;

  Store({
    required this.id,
    required this.store,
    required this.shortName,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id']?.toString() ?? '',
      store: json['Store']?.toString() ?? '',
      shortName: json['ShortName']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'Store': store,
      'ShortName': shortName,
    };
  }
}
