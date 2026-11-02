
import 'dart:async';
import 'package:calculation_panel/core/ulitls/utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../features/purchase_challan/model/party_model.dart';
import '../network/api_path.dart';
import '../network/api_repository.dart';
import '../theme/colors.dart';

class SupplierController extends ValueNotifier<Party?> {
  SupplierController({Party? initialSupplier}) : super(initialSupplier);

  Party? get selectedSupplier => value;

  void selectSupplier(Party? supplier) {
    value = supplier;
  }

  void clear() {
    value = null;
  }
}

class SupplierField extends StatefulWidget {
  final double? width;
  final double? height;

  final SupplierController? controller;
  final Party? initialSupplier;
  final String type, hint;
  final ValueChanged<Party?>? onSelected;

  const SupplierField({
    super.key,
    this.width,
    this.height,
    this.type='1',
    this.hint='Search Supplier',
    this.controller,
    this.initialSupplier,
    this.onSelected,
  });

  @override
  State<SupplierField> createState() => SupplierFieldState();
}

class SupplierFieldState extends State<SupplierField> {
  static const double dropdownWidth = 260;
  static const double optionHeight = 51;

  late final SupplierController _internalController;

  SupplierController get _effectiveController =>
      widget.controller ?? _internalController;

  final TextEditingController _textController =
  TextEditingController();

  final FocusNode _focusNode = FocusNode();

  final ScrollController _scrollController = ScrollController();

  final ValueNotifier<int> _overlayUpdater = ValueNotifier<int>(0);

  List<Party> _suppliers = [];

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _isDisposed) return;

      _focusNode.requestFocus();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _isDisposed) return;

        if (!_focusNode.hasFocus) {
          _focusNode.requestFocus();
        }

        _openDropdown();
        _refreshOverlay();
      });
    });
  }

  @override
  void initState() {
    super.initState();

    _internalController = SupplierController(
      initialSupplier: widget.initialSupplier,
    );

    if (widget.controller != null &&
        widget.initialSupplier != null &&
        widget.controller!.value == null) {
      widget.controller!.selectSupplier(widget.initialSupplier);
    }

    _setSupplierText();

    _focusNode.addListener(_onFocusChanged);

    // Fetch the initial supplier list.
    _fetchSuppliers('');
  }

  @override
  void didUpdateWidget(covariant SupplierField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      if (widget.controller != null &&
          widget.initialSupplier != null &&
          widget.controller!.value == null) {
        widget.controller!.selectSupplier(widget.initialSupplier);
      }

      _setSupplierText();
    }

    if (oldWidget.initialSupplier != widget.initialSupplier &&
        widget.controller == null) {
      _effectiveController.selectSupplier(widget.initialSupplier);
      _setSupplierText();
    }

    _fetchSuppliers(_textController.text.trim());
  }

  Future<void> _fetchSuppliers(String query) async {
    printLog('custDebug004: $query');
    if (_isDisposed) return;

    final int request = ++_requestId;

    if (mounted) {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
    }

    _refreshOverlay();

    try {
      printLog('custDebug005: $query');
      final List<Party> result = await requestSuppliers(query);

      if (!mounted || _isDisposed || request != _requestId) {
        return;
      }

      setState(() {
        _suppliers = result;
        _isLoading = false;
        _hasError = false;
      });

      // Replace the selected object with the fetched instance when available.
      final selected = _effectiveController.value;

      if (selected != null) {
        for (final party in result) {
          if (party.id == selected.id) {
            if (!identical(selected, party)) {
              _effectiveController.selectSupplier(party);
            }
            break;
          }
        }
      }

      _refreshOverlay();
    } catch (_) {
      if (!mounted || _isDisposed || request != _requestId) {
        return;
      }

      setState(() {
        _isLoading = false;
        _hasError = true;
        _suppliers = [];
      });

      _refreshOverlay();
    }
  }

  Future<List<Party>> requestSuppliers(String query) async {
    try {
      final Map<String, dynamic> requestBody = {
        'PartyType': widget.type,
        'search': query,
        'limit': '0',
      };
      printLog('custDebug006: $query');
      final response = await ApiProvider.createServerRequest(
        apiUrl: ApiPath.getPartyList,
        requestBody: requestBody,
        isFormData: true,
      );

      print(response);

      if (response['error'] == true) {
        final data = PartyModel.fromJson(response);
        return data.partyList;
      }

      return <Party>[];
    } catch (e) {
      print('Error fetching suppliers: $e');
      rethrow;
    }
  }

  void _setSupplierText() {
    final text = _effectiveController.value?.company ?? '';

    if (_textController.text == text) return;

    _isUpdatingText = true;

    _textController.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );

    _isUpdatingText = false;
  }

  // ==========================================================================
  // TEXT SEARCH
  // ==========================================================================

  void _onTextChanged(String value) {
    printLog('custDebug001: $value');
    if (_isUpdatingText || _isDisposed) return;

    _selectedIndex = -1;
    _isOpen = true;

    final query = value.trim();

    _searchDebounce?.cancel();
    printLog('custDebug002: $value');
    // Avoid unnecessary API calls for the same query.
    if (query == _lastQuery && _isLoading == false) {
      _refreshOverlay();
      return;
    }

    _searchDebounce = Timer(
      const Duration(milliseconds: 300),
          () {
            printLog('custDebug003: $value');
        if (!mounted || _isDisposed) return;

        _lastQuery = query;
        _fetchSuppliers(query);
      },
    );

    _refreshOverlay();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;

      _scrollController.jumpTo(0);
    });
  }

  // ==========================================================================
  // OPEN DROPDOWN
  // ==========================================================================

  void _openDropdown() {
    _isOpen = true;
    _selectedIndex = -1;

    final query = _textController.text.trim();

    if (query != _lastQuery || _hasError) {
      _lastQuery = query;
      _fetchSuppliers(query);
    }

    _refreshOverlay();
  }

  void _onFocusChanged() {
    if (!mounted || _isDisposed) return;

    if (_focusNode.hasFocus) {
      _openDropdown();
    } else {
      _isOpen = false;
      _selectedIndex = -1;
      _refreshOverlay();
    }
  }

  // ==========================================================================
  // CLEAR SUPPLIER
  // ==========================================================================

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

    _fetchSuppliers('');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _focusNode.requestFocus();

      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });
  }

  // ==========================================================================
  // SELECT SUPPLIER
  // ==========================================================================

  void _selectSupplier(Party supplier) {
    if (_isDisposed) return;

    _searchDebounce?.cancel();

    _isUpdatingText = true;

    _textController.value = TextEditingValue(
      text: supplier.company,
      selection: TextSelection.collapsed(
        offset: supplier.company.length,
      ),
    );

    _isUpdatingText = false;

    _effectiveController.selectSupplier(supplier);

    _selectedIndex = -1;
    _isOpen = false;
    _refreshOverlay();

    // Trigger the next field before removing focus from this field.
    widget.onSelected?.call(supplier);

    _focusNode.unfocus();
  }

  // ==========================================================================
  // KEYBOARD NAVIGATION
  // ==========================================================================

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
          _selectedIndex < _suppliers.length) {
        _selectSupplier(_suppliers[_selectedIndex]);
      }

      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (_suppliers.isEmpty) return KeyEventResult.handled;

      _isOpen = true;

      _selectedIndex = _selectedIndex >= _suppliers.length - 1
          ? 0
          : _selectedIndex + 1;

      _refreshOverlay();
      _scrollToSelected();

      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (_suppliers.isEmpty) return KeyEventResult.handled;

      _isOpen = true;

      _selectedIndex = _selectedIndex <= 0
          ? _suppliers.length - 1
          : _selectedIndex - 1;

      _refreshOverlay();
      _scrollToSelected();

      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  // ==========================================================================
  // SCROLL TO KEYBOARD SELECTION
  // ==========================================================================

  void _scrollToSelected() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;

      if (_selectedIndex < 0 ||
          _selectedIndex >= _suppliers.length) {
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

  // ==========================================================================
  // INPUT DECORATION — SAME STYLE AS ORIGINAL
  // ==========================================================================

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
        Icons.storefront_outlined,
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

  // ==========================================================================
  // DROPDOWN POPUP — SAME DIMENSIONS AND STYLING
  // ==========================================================================

  Widget _dropdown() {
    if (_isLoading) {
      return _messageDropdown(
        icon: null,
        message: 'Searching suppliers...',
        showProgress: true,
      );
    }

    if (_hasError) {
      return _messageDropdown(
        icon: Icons.refresh_rounded,
        message: 'Unable to load suppliers. Click to retry.',
        onTap: () => _fetchSuppliers(_textController.text.trim()),
      );
    }

    if (_suppliers.isEmpty) {
      return _messageDropdown(
        icon: Icons.search_off_rounded,
        message: 'No supplier found',
      );
    }

    return Material(
      elevation: 8,
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: dropdownWidth,
        height: _suppliers.length > 7
            ? 360
            : _suppliers.length * optionHeight,
        child: ListView.separated(
          controller: _scrollController,
          padding: EdgeInsets.zero,
          physics: const ClampingScrollPhysics(),
          itemCount: _suppliers.length,
          separatorBuilder: (_, __) => const Divider(
            height: 1,
            color: Color(0xffE2E8F0),
          ),
          itemBuilder: (context, index) {
            return _supplierItem(_suppliers[index], index);
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
                    child: CircularProgressIndicator(strokeWidth: 2),
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

  // ==========================================================================
  // SUPPLIER OPTION
  // ==========================================================================

  Widget _supplierItem(Party supplier, int index) {
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
              onTap: () => _selectSupplier(supplier),
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
                    _avatar(supplier),
                    const SizedBox(width: 10),
                    Expanded(child: _supplierDetails(supplier)),
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

  Widget _supplierDetails(Party supplier) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          supplier.company,
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
          supplier.name,
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

  Widget _avatar(Party supplier) {
    final letter = supplier.name.trim().isNotEmpty
        ? supplier.name.trim().substring(0, 1).toUpperCase()
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

  // ==========================================================================
  // BUILD
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
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
        ValueListenableBuilder<Party?>(
          valueListenable: _effectiveController,
          builder: (context, selectedSupplier, _) {
            return SizedBox(
              width: widget.width ?? dropdownWidth,
              height: widget.height ?? 36,
              child: RawAutocomplete<Party>(
                textEditingController: _textController,
                focusNode: _focusNode,
                displayStringForOption: (party) => party.company,

                optionsBuilder: (TextEditingValue value) {
                  // The API controls the result list; no local filtering.
                  return _suppliers;
                },

                onSelected: _selectSupplier,

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
        )
      ],
    );
  }

  // ==========================================================================
  // DISPOSE
  // ==========================================================================

  @override
  void dispose() {
    _isDisposed = true;
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

class PartyModel {
  final int code;
  final bool error;
  final String nums;
  final String totalData;
  final String msg;
  final List<Party> partyList;

  PartyModel({
    required this.code,
    required this.error,
    required this.nums,
    required this.totalData,
    required this.msg,
    required this.partyList,
  });

  factory PartyModel.fromJson(Map<String, dynamic> json) {
    return PartyModel(
      code: json['code'] ?? 0,
      error: json['error'] ?? false,
      nums: json['nums']?.toString() ?? '',
      totalData: json['TotalData']?.toString() ?? '',
      msg: json['msg']?.toString() ?? '',
      partyList: (json['PartyList'] as List?)
          ?.map((e) => Party.fromJson(e))
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
      'PartyList': partyList.map((e) => e.toJson()).toList(),
    };
  }
}


