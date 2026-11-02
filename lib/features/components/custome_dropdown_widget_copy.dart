import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    this.borderRadius = 4.0,
    this.height = 31,
    this.dataFound = true,
    this.focusNode,
    this.openOnFocus = true,
  });

  final FocusNode? focusNode;
  final bool openOnFocus;

  final T? value;

  final bool dataFound;

  /// Items received from API.
  final List<T> items;

  /// Called when user selects an item.
  final ValueChanged<T?> onSelect;

  /// Called whenever user types.
  final ValueChanged<String> onSearch;

  /// Converts model to text.
  final String Function(T item) displayString;

  final Color borderColor;
  final double borderRadius;
  final String hint;
  final double height;

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
    if (_activeDropdown == dropdown) {
      return;
    }

    final previous = _activeDropdown;

    _activeDropdown = dropdown;

// Close previous dropdown.
    previous?._closeFromManager();
  }

  void deactivate(
      _SearchableCustomerDropdownState<dynamic> dropdown,
      ) {
    if (_activeDropdown == dropdown) {
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

  OverlayEntry? _overlayEntry;

  late final ValueNotifier<List<T>> _itemsNotifier;
  late final ValueNotifier<int> _highlightedNotifier;

  bool _ignoreTextChange = false;

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
  }

  String _getValueText(T? value) {
    if (value == null) {
      return '';
    }

    return widget.displayString(value);
  }

  @override
  void didUpdateWidget(
      covariant SearchableCustomerDropdown<T> oldWidget,
      ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.focusNode != widget.focusNode) {
      _focusNode.removeListener(_onFocusChanged);

      if (_ownsFocusNode) {
        _focusNode.dispose();
      }

      _focusNode = widget.focusNode ?? FocusNode();
      _ownsFocusNode = widget.focusNode == null;

      _focusNode.addListener(_onFocusChanged);

      if (_focusNode.hasFocus) {
        _onFocusChanged();
      }
    }

    if (oldWidget.value != widget.value) {
      final String newText = _getValueText(widget.value);

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

    if (oldWidget.dataFound != widget.dataFound) {
      if (!widget.dataFound) {
        _closeDropdown();
      }
    }

    if (oldWidget.items != widget.items) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }

        final List<T> newItems = List<T>.from(widget.items);

        _itemsNotifier.value = newItems;

        _highlightedNotifier.value =
        newItems.isEmpty ? -1 : 0;

        if (newItems.isEmpty || !widget.dataFound) {
          _closeDropdown();
          return;
        }


        if (_focusNode.hasFocus && !_isOpen) {
          _openDropdown(
            callSearch: false,
          );
        }
      });
    }
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
    if (_ignoreTextChange) {
      return;
    }


    widget.onSearch(_controller.text);

    _highlightedNotifier.value =
    _itemsNotifier.value.isEmpty ? -1 : 0;
  }

  void _openDropdown({
    bool callSearch = true,
  }) {

    if (!widget.dataFound) {
      _closeDropdown();
      return;
    }

    if (_itemsNotifier.value.isEmpty) {
      _closeDropdown();
      return;
    }

    if (_isOpen) {
      return;
    }

    _DropdownManager.instance.activate(this);

    _highlightedNotifier.value =
    _itemsNotifier.value.isEmpty ? -1 : 0;

    final OverlayState overlay = Overlay.of(context);

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
                offset: Offset(
                  0,
                  widget.height + 5,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: ValueListenableBuilder<List<T>>(
                    valueListenable: _itemsNotifier,
                    builder: (
                        context,
                        items,
                        child,
                        ) {
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
    final OverlayEntry? entry = _overlayEntry;

    if (entry == null) {
      return;
    }

    _overlayEntry = null;

    entry.remove();

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
        if (!widget.dataFound ||
            _itemsNotifier.value.isEmpty) {
          return KeyEventResult.handled;
        }

        _DropdownManager.instance.activate(this);

        _openDropdown(
          callSearch: false,
        );

        return KeyEventResult.handled;
      }

      return KeyEventResult.ignored;
    }

    final List<T> items = _itemsNotifier.value;


    if (items.isEmpty || !widget.dataFound) {
      _closeDropdown();
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      int index = _highlightedNotifier.value;

      if (index < items.length - 1) {
        index++;
      } else {
        index = 0;
      }

      _highlightedNotifier.value = index;

      return KeyEventResult.handled;
    }

// ========================================================================
// ARROW UP
// ========================================================================

    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      int index = _highlightedNotifier.value;

      if (index > 0) {
        index--;
      } else {
        index = items.length - 1;
      }

      _highlightedNotifier.value = index;

      return KeyEventResult.handled;
    }

// ========================================================================
// ENTER
// ========================================================================

    if (event.logicalKey == LogicalKeyboardKey.enter) {
      final int index = _highlightedNotifier.value;

      if (index >= 0 && index < items.length) {
        _selectItem(items[index]);
      }

      return KeyEventResult.handled;
    }

// ========================================================================
// ESCAPE
// ========================================================================

    if (event.logicalKey == LogicalKeyboardKey.escape) {
      _closeDropdown();

      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

// ==========================================================================
// SELECT
// ==========================================================================

  void _selectItem(T item) {
    final String text = widget.displayString(item);

// ------------------------------------------------------------------------
// Prevent API search while filling selected value.
// ------------------------------------------------------------------------

    _ignoreTextChange = true;

    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(
        offset: text.length,
      ),
    );

    _ignoreTextChange = false;

// ------------------------------------------------------------------------
// Send model to parent.
// ------------------------------------------------------------------------

    widget.onSelect(item);

// ------------------------------------------------------------------------
// Close.
// ------------------------------------------------------------------------

    _closeDropdown();

    _DropdownManager.instance.deactivate(this);

// ------------------------------------------------------------------------
// Remove focus.
// ------------------------------------------------------------------------

    _focusNode.unfocus();
  }

// ==========================================================================
// POPUP
// ==========================================================================

  Widget _buildPopup(
      List<T> items,
      int highlightedIndex,
      ) {
// ========================================================================
// FINAL SAFETY CHECK
//
// This function itself can NEVER create a "No data found" widget.
// ========================================================================

    if (!widget.dataFound || items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: _getDropdownWidth(),
      constraints: const BoxConstraints(
        maxHeight: 300,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: const Color(0xffD6D6D6),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(
          vertical: 4,
        ),
        shrinkWrap: true,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final T item = items[index];

          final bool selected = item == widget.value;

          final bool highlighted =
              index == highlightedIndex;

          final String text =
          widget.displayString(item);

          return MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) {
              _highlightedNotifier.value = index;
            },
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: (event) {
// Only handle LEFT mouse button.
                if (event.kind == PointerDeviceKind.mouse &&
                    event.buttons == kPrimaryButton) {
                  _selectItem(item);
                }
              },
              child: Container(
                width: double.infinity,
                height: 34,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                ),
                color: highlighted
                    ? const Color(0xffDBEAFE)
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
                              ? const Color(0xff2563EB)
                              : const Color(0xff334155),
                          fontWeight: highlighted || selected
                              ? FontWeight.w600
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
          );
        },
      ),
    );
  }

// ==========================================================================
// WIDTH
// ==========================================================================

  double _getDropdownWidth() {
    final RenderBox? renderBox =
    context.findRenderObject() as RenderBox?;

    if (renderBox == null) {
      return 250;
    }

    return renderBox.size.width;
  }

// ==========================================================================
// DISPOSE
// ==========================================================================

  @override
  void dispose() {
// ------------------------------------------------------------------------
// Remove from global manager.
// ------------------------------------------------------------------------

    _DropdownManager.instance.deactivate(this);

// ------------------------------------------------------------------------
// Remove overlay.
// ------------------------------------------------------------------------

    _overlayEntry?.remove();
    _overlayEntry = null;

// ------------------------------------------------------------------------
// Listeners.
// ------------------------------------------------------------------------

    _focusNode.removeListener(
      _onFocusChanged,
    );

    _controller.removeListener(
      _onTextChanged,
    );

// ------------------------------------------------------------------------
// Dispose.
// ------------------------------------------------------------------------

    _itemsNotifier.dispose();
    _highlightedNotifier.dispose();

    if (_ownsFocusNode) {
      _focusNode.dispose();
    }
    _controller.dispose();

    super.dispose();
  }

// ==========================================================================
// BUILD
// ==========================================================================

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: SizedBox(
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
                fontSize: 13,
                color: Color(0xffCBD5E1),
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
                borderRadius: BorderRadius.circular(
                  widget.borderRadius,
                ),
                borderSide: BorderSide(
                  color: widget.borderColor,
                  width: 1.3,
                ),
              ),

              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  widget.borderRadius,
                ),
                borderSide: BorderSide(
                  color: widget.borderColor,
                  width: 1.3,
                ),
              ),

              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  widget.borderRadius,
                ),
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

