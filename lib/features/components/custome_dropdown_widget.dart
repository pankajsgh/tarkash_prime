import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// External controller used to open and close a dropdown programmatically.
class SearchableDropdownController {
  VoidCallback? _openCallback;
  VoidCallback? _closeCallback;

  void _attach({
    required VoidCallback onOpen,
    required VoidCallback onClose,
  }) {
    _openCallback = onOpen;
    _closeCallback = onClose;
  }

  void _detach() {
    _openCallback = null;
    _closeCallback = null;
  }

  void open() {
    _openCallback?.call();
  }

  void close() {
    _closeCallback?.call();
  }
}

class SearchableCustomerDropdown<T> extends StatefulWidget {
  const SearchableCustomerDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onSelect,
    required this.onSearch,
    required this.displayString,
    this.hint = 'Select',
    this.borderColor = Colors.transparent,
    this.borderRadius = 6.0,
    this.height = 32,
    this.dataFound = true,
    this.focusNode,
    this.openOnFocus = true,
    this.dropdownController,
  });

  final T? value;
  final List<T> items;

  final ValueChanged<T?> onSelect;
  final ValueChanged<String> onSearch;
  final String Function(T item) displayString;

  final String hint;
  final Color borderColor;
  final double borderRadius;
  final double height;

  final bool dataFound;
  final FocusNode? focusNode;
  final bool openOnFocus;

  final SearchableDropdownController? dropdownController;

  @override
  State<SearchableCustomerDropdown<T>> createState() =>
      _SearchableCustomerDropdownState<T>();
}

class _DropdownManager {
  _DropdownManager._();

  static final _DropdownManager instance = _DropdownManager._();

  _SearchableCustomerDropdownState<dynamic>? _activeDropdown;

  void activate(
      _SearchableCustomerDropdownState<dynamic> dropdown,
      ) {
    if (identical(_activeDropdown, dropdown)) return;

    final previous = _activeDropdown;
    _activeDropdown = dropdown;

    previous?._closeFromManager();
  }

  void deactivate(
      _SearchableCustomerDropdownState<dynamic> dropdown,
      ) {
    if (identical(_activeDropdown, dropdown)) {
      _activeDropdown = null;
    }
  }

  void closeActive() {
    final active = _activeDropdown;
    _activeDropdown = null;
    active?._closeFromManager();
  }
}

class _SearchableCustomerDropdownState<T>
    extends State<SearchableCustomerDropdown<T>> {
  late final TextEditingController _controller;

  late FocusNode _focusNode;
  bool _ownsFocusNode = false;

  final LayerLink _layerLink = LayerLink();

  /// Attached to the actual field so the popup width matches it exactly.
  final GlobalKey _fieldKey = GlobalKey();

  OverlayEntry? _overlayEntry;

  late final ValueNotifier<List<T>> _itemsNotifier;
  late final ValueNotifier<int> _highlightedNotifier;

  bool _ignoreTextChange = false;
  bool _syncScheduled = false;

  bool get _isOpen => _overlayEntry != null;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(
      text: _getValueText(widget.value),
    );

    _focusNode = widget.focusNode ?? FocusNode();
    _ownsFocusNode = widget.focusNode == null;

    _itemsNotifier = ValueNotifier<List<T>>(
      List<T>.from(widget.items),
    );

    _highlightedNotifier = ValueNotifier<int>(
      widget.items.isEmpty ? -1 : 0,
    );

    _focusNode.addListener(_onFocusChanged);
    _controller.addListener(_onTextChanged);

    _attachDropdownController();
  }

  String _getValueText(T? value) {
    if (value == null) return '';
    return widget.displayString(value);
  }

  void _attachDropdownController() {
    widget.dropdownController?._attach(
      onOpen: () {
        if (!mounted) return;

        if (widget.dataFound && _itemsNotifier.value.isNotEmpty) {
          _openDropdown();
        } else {
          widget.onSearch(_controller.text);
        }
      },
      onClose: _closeDropdown,
    );
  }

  @override
  void didUpdateWidget(
      covariant SearchableCustomerDropdown<T> oldWidget,
      ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.dropdownController != widget.dropdownController) {
      oldWidget.dropdownController?._detach();
      _attachDropdownController();
    }

    if (oldWidget.focusNode != widget.focusNode) {
      _focusNode.removeListener(_onFocusChanged);

      if (_ownsFocusNode) {
        _focusNode.dispose();
      }

      _focusNode = widget.focusNode ?? FocusNode();
      _ownsFocusNode = widget.focusNode == null;

      _focusNode.addListener(_onFocusChanged);

      _schedulePostFrame(() {
        if (_focusNode.hasFocus) {
          _onFocusChanged();
        }
      });
    }

    if (oldWidget.value != widget.value) {
      final newText = _getValueText(widget.value);

      if (_controller.text != newText) {
        _ignoreTextChange = true;

        _controller.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(
            offset: newText.length,
          ),
        );

        _ignoreTextChange = false;
      }
    }

    if (oldWidget.dataFound != widget.dataFound && !widget.dataFound) {
      _schedulePostFrame(_closeDropdown);
    }

    _scheduleItemsSync();
  }

  void _schedulePostFrame(VoidCallback callback) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      callback();
    });
  }

  void _scheduleItemsSync() {
    if (_syncScheduled) return;

    _syncScheduled = true;

    _schedulePostFrame(() {
      _syncScheduled = false;

      final newItems = List<T>.from(widget.items);

      // Update popup items even when the original list reference is unchanged.
      _itemsNotifier.value = newItems;

      // Keep the highlighted index valid.
      final currentIndex = _highlightedNotifier.value;

      if (newItems.isEmpty) {
        _highlightedNotifier.value = -1;
        _closeDropdown();
        return;
      }

      if (!widget.dataFound) {
        _closeDropdown();
        return;
      }

      if (currentIndex < 0 || currentIndex >= newItems.length) {
        _highlightedNotifier.value = 0;
      }

      if (_focusNode.hasFocus && widget.openOnFocus && !_isOpen) {
        _openDropdown(callSearch: false);
      } else if (_isOpen) {
        // Refresh an already-open popup.
        _overlayEntry?.markNeedsBuild();
      }
    });
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      if (!widget.openOnFocus) return;

      _DropdownManager.instance.activate(this);

      if (widget.dataFound && _itemsNotifier.value.isNotEmpty) {
        _openDropdown(callSearch: false);
      } else {
        _closeDropdown();
        widget.onSearch(_controller.text);
      }
    } else {
      _closeDropdown();
      _DropdownManager.instance.deactivate(this);
    }
  }

  void _onTextChanged() {
    if (_ignoreTextChange) return;

    widget.onSearch(_controller.text);

    _highlightedNotifier.value =
    _itemsNotifier.value.isEmpty ? -1 : 0;

    if (widget.dataFound && _itemsNotifier.value.isNotEmpty) {
      if (_focusNode.hasFocus && !_isOpen) {
        _openDropdown(callSearch: false);
      } else {
        _overlayEntry?.markNeedsBuild();
      }
    } else {
      _closeDropdown();
    }
  }

  void _openDropdown({bool callSearch = true}) {
    if (!mounted || !widget.dataFound) {
      _closeDropdown();
      return;
    }

    if (_itemsNotifier.value.isEmpty) {
      _closeDropdown();
      return;
    }

    if (_isOpen) {
      _overlayEntry?.markNeedsBuild();
      return;
    }

    _DropdownManager.instance.activate(this);

    _highlightedNotifier.value =
    _itemsNotifier.value.isEmpty ? -1 : 0;

    final overlay = Overlay.of(context);

    _overlayEntry = OverlayEntry(
      builder: (overlayContext) {
        return Positioned.fill(
          child: Stack(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  _closeDropdown();

                  if (_focusNode.hasFocus) {
                    _focusNode.unfocus();
                  }
                },
                child: const SizedBox.expand(),
              ),

              CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: Offset(0, widget.height + 5),
                child: Material(
                  color: Colors.transparent,
                  child: SizedBox(
                    width: _getDropdownWidth(),
                    child: ValueListenableBuilder<List<T>>(
                      valueListenable: _itemsNotifier,
                      builder: (context, items, child) {
                        if (!widget.dataFound || items.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        return ValueListenableBuilder<int>(
                          valueListenable: _highlightedNotifier,
                          builder: (
                              context,
                              highlightedIndex,
                              child,
                              ) {
                            return _buildPopup(
                              items,
                              highlightedIndex,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    overlay.insert(_overlayEntry!);

    if (mounted) {
      setState(() {});
    }

    if (callSearch) {
      widget.onSearch(_controller.text);
    }
  }

  void _closeDropdown() {
    final entry = _overlayEntry;
    if (entry == null) return;

    _overlayEntry = null;

    entry.remove();
    entry.dispose();

    _highlightedNotifier.value = -1;

    if (mounted) {
      setState(() {});
    }
  }

  void _closeFromManager() {
    _closeDropdown();

    if (_focusNode.hasFocus) {
      _focusNode.unfocus();
    }
  }

  KeyEventResult _handleKeyEvent(
      FocusNode node,
      KeyEvent event,
      ) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    if (!_isOpen) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown ||
          event.logicalKey == LogicalKeyboardKey.enter) {
        if (!widget.dataFound || _itemsNotifier.value.isEmpty) {
          return KeyEventResult.handled;
        }

        _DropdownManager.instance.activate(this);
        _openDropdown(callSearch: false);

        return KeyEventResult.handled;
      }

      return KeyEventResult.ignored;
    }

    final items = _itemsNotifier.value;

    if (items.isEmpty || !widget.dataFound) {
      _closeDropdown();
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      var index = _highlightedNotifier.value;

      index = index < items.length - 1 ? index + 1 : 0;

      _highlightedNotifier.value = index;
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      var index = _highlightedNotifier.value;

      index = index > 0 ? index - 1 : items.length - 1;

      _highlightedNotifier.value = index;
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.enter) {
      final index = _highlightedNotifier.value;

      if (index >= 0 && index < items.length) {
        _selectItem(items[index]);
      }

      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.escape) {
      _closeDropdown();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  void _selectItem(T item) {
    final text = widget.displayString(item);

    _ignoreTextChange = true;

    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(
        offset: text.length,
      ),
    );

    _ignoreTextChange = false;

    widget.onSelect(item);

    _closeDropdown();
    _DropdownManager.instance.deactivate(this);

    _focusNode.unfocus();
  }

  Widget _buildPopup(
      List<T> items,
      int highlightedIndex,
      ) {
    if (!widget.dataFound || items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      // Fill the measured width of the text field.
      width: double.infinity,
      constraints: const BoxConstraints(
        maxHeight: 300,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(
          color: const Color(0xffD6D6D6),
        ),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 4),
        shrinkWrap: true,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final selected = item == widget.value;
          final highlighted = index == highlightedIndex;
          final text = widget.displayString(item);

          return MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) {
              _highlightedNotifier.value = index;
            },
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: (event) {
                // Select on left mouse click only.
                if (event.kind == PointerDeviceKind.mouse &&
                    event.buttons == kPrimaryButton) {
                  _selectItem(item);
                }
              },
              child: InkWell(
                onTap: () {
                  // Supports touch and other tap interactions.
                  _selectItem(item);
                },
                child: Container(
                  width: double.infinity,
                  height: 34,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  color: highlighted
                      ? const Color(0xffedf3ff)
                      : selected
                      ? const Color(0xffEEF2FF)
                      : Colors.transparent,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          text,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: highlighted || selected
                                ? const Color(0xff5d8aef)
                                : const Color(0xff334155),
                            fontWeight: highlighted || selected
                                ? FontWeight.w400
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                      if (selected)
                        const Icon(
                          Icons.check,
                          size: 16,
                          color: Color(0xff2563EB),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Reads the rendered width of the actual field.
  double _getDropdownWidth() {
    final renderObject =
    _fieldKey.currentContext?.findRenderObject();

    if (renderObject is RenderBox && renderObject.hasSize) {
      return renderObject.size.width;
    }

    return 250;
  }

  @override
  void dispose() {
    _DropdownManager.instance.deactivate(this);

    widget.dropdownController?._detach();

    _overlayEntry?.remove();
    _overlayEntry?.dispose();
    _overlayEntry = null;

    _focusNode.removeListener(_onFocusChanged);
    _controller.removeListener(_onTextChanged);

    _itemsNotifier.dispose();
    _highlightedNotifier.dispose();

    if (_ownsFocusNode) {
      _focusNode.dispose();
    }

    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color textLight = Color(0xff94A3B8);

    return CompositedTransformTarget(
      link: _layerLink,
      child: SizedBox(
        key: _fieldKey,
        height: widget.height,
        child: Focus(
          onKeyEvent: _handleKeyEvent,
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            textAlign: TextAlign.start,
            textAlignVertical: TextAlignVertical.center,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xff334155),
            ),
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: const Color(0xffF8FAFC),
              constraints: BoxConstraints(
                minHeight: widget.height,
                maxHeight: widget.height,
              ),
              contentPadding: const EdgeInsets.only(
                left: 8,
                right: 4,
              ),
              hintText: widget.hint,
              hintStyle: const TextStyle(
                fontSize: 11,
                color: textLight,
              ),
              suffixIcon: IgnorePointer(
                child: Icon(
                  _isOpen
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 18,
                  color: const Color(0xffCCCCCC),
                ),
              ),
              suffixIconConstraints: BoxConstraints(
                minWidth: 32,
                maxWidth: 32,
                minHeight: widget.height,
                maxHeight: widget.height,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                borderSide: BorderSide(
                  color: widget.borderColor,
                  width: 1.3,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                borderSide: BorderSide(
                  color: widget.borderColor,
                  width: 1.3,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                borderSide: BorderSide(
                  color: Colors.blue.shade200,
                  width: 1.3,
                ),
              ),
              disabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }
}