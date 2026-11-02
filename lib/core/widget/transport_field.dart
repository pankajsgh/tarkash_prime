
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../features/purchase_challan/model/transport_model.dart';
import '../network/api_path.dart';
import '../network/api_repository.dart';
import '../theme/colors.dart';
import '../ulitls/utility.dart';

// Use your existing project imports for:
// ApiProvider, ApiPath, printLog, borderColor, textLight,
// textMedium, textDark, and blue.

class TransportField extends StatefulWidget {
  final double? width;
  final double? height;
  final TransportController controller;
  final TransportModel? initialTransport;
  final String hint;
  final ValueChanged<TransportModel?>? onSelected;
  final FocusNode? focusNode;

  const TransportField({
    super.key,
    required this.controller,
    this.width,
    this.height,
    this.initialTransport,
    this.hint = 'Search Transport',
    this.onSelected,
    this.focusNode,
  });

  @override
  State<TransportField> createState() => TransportFieldState();
}

class TransportFieldState extends State<TransportField> {
  static const double dropdownWidth = 260;
  static const double optionHeight = 58;

  final TextEditingController _textController =
  TextEditingController();

  final FocusNode _internalFocusNode = FocusNode();

  FocusNode get _effectiveFocusNode =>
      widget.focusNode ?? _internalFocusNode;

  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<int> _overlayUpdater = ValueNotifier<int>(0);

  List<TransportModel> _transports = [];

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

    if (widget.initialTransport != null &&
        widget.controller.value == null) {
      widget.controller.selectTransport(widget.initialTransport);
    }

    _setTransportText();
    _effectiveFocusNode.addListener(_onFocusChanged);

    _fetchTransports('');
  }

  @override
  void didUpdateWidget(covariant TransportField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode?.removeListener(_onFocusChanged);
      _effectiveFocusNode.addListener(_onFocusChanged);
    }

    if (oldWidget.controller != widget.controller) {
      if (widget.initialTransport != null &&
          widget.controller.value == null) {
        widget.controller.selectTransport(widget.initialTransport);
      }

      _setTransportText();
    }

    if (oldWidget.initialTransport != widget.initialTransport &&
        widget.controller.value == null) {
      widget.controller.selectTransport(widget.initialTransport);
      _setTransportText();
    }
  }

// ============================================================
// API
// ============================================================

  Future<List<TransportModel>> requestTransports(String query) async {
    final response = await ApiProvider.createServerRequest(
      apiUrl: ApiPath.getTransportList,
      requestBody: {
        'search': query,
        'limit': '0',
      },
      isFormData: true,
    );

    final model = TransportResponse.fromJson(
      Map<String, dynamic>.from(response),
    );

    if (model.code == 1 && model.error == true) {
      return model.transportList;
    }

    return [];
  }

  Future<void> _fetchTransports(String query) async {
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
      final result = await requestTransports(query);

      if (!mounted || _isDisposed || request != _requestId) {
        return;
      }

      setState(() {
        _transports = result;
        _isLoading = false;
        _hasError = false;
      });

      final selected = widget.controller.value;

      if (selected != null) {
        for (final transport in result) {
          if (transport.id == selected.id) {
            if (!identical(selected, transport)) {
              widget.controller.selectTransport(transport);
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
        _transports = [];
      });

      printLog('transportFetchError: $e');
      _refreshOverlay();
    }
  }

  void _setTransportText() {
    final text = widget.controller.value?.transport ?? '';

    if (_textController.text == text) return;

    _isUpdatingText = true;

    _textController.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );

    _isUpdatingText = false;
  }

// ============================================================
// SEARCH
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
        _fetchTransports(query);
      },
    );

    _refreshOverlay();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.jumpTo(0);
    });
  }

// ============================================================
// OPEN / FOCUS
// ============================================================

  void _openDropdown() {
    _isOpen = true;
    _selectedIndex = -1;

    final query = _textController.text.trim();

    if (query != _lastQuery || _hasError || _transports.isEmpty) {
      _lastQuery = query;
      _fetchTransports(query);
    }

    _refreshOverlay();
  }

  void _onFocusChanged() {
    if (_isDisposed) return;

    if (_effectiveFocusNode.hasFocus) {
      _openDropdown();
    } else {
      _isOpen = false;
      _selectedIndex = -1;
    }

    _refreshOverlay();
  }

// ============================================================
// CLEAR
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

    _fetchTransports('');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _isDisposed) return;

      _effectiveFocusNode.requestFocus();

      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });
  }

// ============================================================
// SELECT
// ============================================================

  void _selectTransport(TransportModel transport) {
    if (_isDisposed) return;

    _searchDebounce?.cancel();

    _isUpdatingText = true;

    _textController.value = TextEditingValue(
      text: transport.transport,
      selection: TextSelection.collapsed(
        offset: transport.transport.length,
      ),
    );

    _isUpdatingText = false;

    widget.controller.selectTransport(transport);

    _selectedIndex = -1;
    _isOpen = false;
    _refreshOverlay();

    widget.onSelected?.call(transport);

    _effectiveFocusNode.unfocus();
  }

// ============================================================
// KEYBOARD
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
          _selectedIndex < _transports.length) {
        _selectTransport(_transports[_selectedIndex]);
      }

      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (_transports.isEmpty) return KeyEventResult.handled;

      _isOpen = true;

      _selectedIndex = _selectedIndex >= _transports.length - 1
          ? 0
          : _selectedIndex + 1;

      _refreshOverlay();
      _scrollToSelected();

      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (_transports.isEmpty) return KeyEventResult.handled;

      _isOpen = true;

      _selectedIndex = _selectedIndex <= 0
          ? _transports.length - 1
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
          _selectedIndex >= _transports.length) {
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
// DECORATION
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
        Icons.local_shipping_outlined,
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
        message: 'Searching transports...',
        showProgress: true,
      );
    }

    if (_hasError) {
      return _messageDropdown(
        icon: Icons.refresh_rounded,
        message: 'Unable to load transports. Click to retry.',
        onTap: () => _fetchTransports(
          _textController.text.trim(),
        ),
      );
    }

    if (_transports.isEmpty) {
      return _messageDropdown(
        icon: Icons.search_off_rounded,
        message: 'No transport found',
      );
    }

    return Material(
      elevation: 8,
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: dropdownWidth,
        height: _transports.length > 6
            ? 348
            : _transports.length * optionHeight,
        child: ListView.separated(
          controller: _scrollController,
          padding: EdgeInsets.zero,
          physics: const ClampingScrollPhysics(),
          itemCount: _transports.length,
          separatorBuilder: (_, __) => const Divider(
            height: 1,
            color: Color(0xffE2E8F0),
          ),
          itemBuilder: (context, index) {
            return _transportItem(_transports[index], index);
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

// ============================================================
// TRANSPORT ITEM
// ============================================================

  Widget _transportItem(TransportModel transport, int index) {
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
              onTap: () => _selectTransport(transport),
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
                    _avatar(transport),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _transportDetails(transport),
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

  Widget _transportDetails(TransportModel transport) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          transport.transport,
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
          [
            if (transport.owner.trim().isNotEmpty) transport.owner,
            if (transport.mobile.trim().isNotEmpty) transport.mobile,
            if (transport.location.trim().isNotEmpty) transport.location,
          ].join(' • '),
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

  Widget _avatar(TransportModel transport) {
    final name = transport.transport.trim();
    final letter = name.isNotEmpty ? name[0].toUpperCase() : '?';

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
        ValueListenableBuilder<TransportModel?>(
          valueListenable: widget.controller,
          builder: (context, selectedTransport, _) {
            return SizedBox(
              width: widget.width ?? dropdownWidth,
              height: widget.height ?? 36,
              child: RawAutocomplete<TransportModel>(
                textEditingController: _textController,
                focusNode: _effectiveFocusNode,
                displayStringForOption: (transport) =>
                transport.transport,
                optionsBuilder: (TextEditingValue value) {
                  return _transports;
                },
                onSelected: _selectTransport,
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

class TransportController extends ValueNotifier<TransportModel?> {
  TransportController({TransportModel? initialTransport})
      : super(initialTransport);

  TransportModel? get selectedTransport => value;

  void selectTransport(TransportModel? transport) {
    value = transport;
  }

  void clear() {
    value = null;
  }
}

// class TransportResponse {
//   final int code;
//   final bool error;
//   final String nums;
//   final String totalData;
//   final String msg;
//   final List<TransportModel> transportList;
//
//   TransportResponse({
//     required this.code,
//     required this.error,
//     required this.nums,
//     required this.totalData,
//     required this.msg,
//     required this.transportList,
//   });
//
//   factory TransportResponse.fromJson(Map<String, dynamic> json) {
//     return TransportResponse(
//       code: json['code'] ?? 0,
//       error: json['error'] ?? false,
//       nums: json['nums']?.toString() ?? '',
//       totalData: json['TotalData']?.toString() ?? '',
//       msg: json['msg']?.toString() ?? '',
//       transportList: (json['TransportList'] as List<dynamic>?)
//           ?.map(
//             (e) => TransportModel.fromJson(
//           e as Map<String, dynamic>,
//         ),
//       )
//           .toList() ??
//           [],
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'code': code,
//       'error': error,
//       'nums': nums,
//       'TotalData': totalData,
//       'msg': msg,
//       'TransportList': transportList
//           .map((e) => e.toJson())
//           .toList(),
//     };
//   }
// }
//
// class TransportModel {
//   final String id;
//   final String transport;
//   final String owner;
//   final String mobile;
//   final String location;
//   final String address;
//
//   TransportModel({
//     required this.id,
//     required this.transport,
//     required this.owner,
//     required this.mobile,
//     required this.location,
//     required this.address,
//   });
//
//   factory TransportModel.fromJson(Map<String, dynamic> json) {
//     return TransportModel(
//       id: json['id']?.toString() ?? '',
//       transport: json['transport']?.toString() ?? '',
//       owner: json['owner']?.toString() ?? '',
//       mobile: json['mobile']?.toString() ?? '',
//       location: json['Location']?.toString() ?? '',
//       address: json['address']?.toString() ?? '',
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'transport': transport,
//       'owner': owner,
//       'mobile': mobile,
//       'Location': location,
//       'address': address,
//     };
//   }
// }