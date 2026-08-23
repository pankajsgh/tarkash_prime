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
  });

  final T? value;

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

/// ===============================================================
/// GLOBAL ACTIVE DROPDOWN MANAGER
/// ===============================================================
///
/// Only ONE SearchableCustomerDropdown can have an overlay open.
///
/// Example:
///
/// Dropdown A -> open
/// Dropdown B -> focus
///             -> A closes
///             -> B opens
///
/// This also works if the widget is used in multiple
/// ProductSelectionSection / SupplierSelectionSection etc.
/// ===============================================================

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
  late final FocusNode _focusNode;

  final LayerLink _layerLink = LayerLink();

  OverlayEntry? _overlayEntry;

  late final ValueNotifier<List<T>> _itemsNotifier;
  late final ValueNotifier<int> _highlightedNotifier;

  bool _ignoreTextChange = false;

  bool get _isOpen => _overlayEntry != null;

  // ===============================================================
  // INIT
  // ===============================================================

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(
      text: _getValueText(widget.value),
    );

    _focusNode = FocusNode();

    _itemsNotifier = ValueNotifier<List<T>>(
      List<T>.from(widget.items),
    );

    _highlightedNotifier = ValueNotifier<int>(
      widget.items.isEmpty ? -1 : 0,
    );

    _focusNode.addListener(_onFocusChanged);
    _controller.addListener(_onTextChanged);
  }

  // ===============================================================
  // VALUE TEXT
  // ===============================================================

  String _getValueText(T? value) {
    if (value == null) {
      return '';
    }

    return widget.displayString(value);
  }

  // ===============================================================
  // PARENT UPDATE
  // ===============================================================

  @override
  void didUpdateWidget(
      covariant SearchableCustomerDropdown<T> oldWidget,
      ) {
    super.didUpdateWidget(oldWidget);

    // -------------------------------------------------------------
    // Selected value changed
    // -------------------------------------------------------------

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

    // -------------------------------------------------------------
    // API returned new items
    // -------------------------------------------------------------

    if (oldWidget.items != widget.items) {
      print("this is good4477");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _itemsNotifier.value = List<T>.from(widget.items);

        _highlightedNotifier.value =
        widget.items.isEmpty ? -1 : 0;
      });

    }
  }

  // ===============================================================
  // FOCUS
  // ===============================================================

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      // -----------------------------------------------------------
      // Tell global manager:
      //
      // "I am now the active dropdown."
      //
      // Manager will close the previous dropdown.
      // -----------------------------------------------------------

      _DropdownManager.instance.activate(this);

      _openDropdown();
    } else {
      // -----------------------------------------------------------
      // VERY IMPORTANT
      //
      // If focus leaves this field because user:
      //
      // - presses TAB
      // - clicks another field
      // - clicks another dropdown
      // - clicks elsewhere
      //
      // close this overlay.
      // -----------------------------------------------------------

      _closeDropdown();

      _DropdownManager.instance.deactivate(this);
    }
  }

  // ===============================================================
  // TEXT CHANGE
  // ===============================================================

  void _onTextChanged() {
    if (_ignoreTextChange) {
      return;
    }

    if (!_isOpen) {
      return;
    }

    // -------------------------------------------------------------
    // NO LOCAL FILTER
    //
    // Every text change goes to API.
    // -------------------------------------------------------------

    widget.onSearch(_controller.text);

    _highlightedNotifier.value =
    _itemsNotifier.value.isEmpty ? -1 : 0;
  }

  // ===============================================================
  // OPEN
  // ===============================================================

  void _openDropdown() {
    if (_isOpen) {
      return;
    }

    // -------------------------------------------------------------
    // Make this dropdown the global active dropdown.
    // -------------------------------------------------------------

    _DropdownManager.instance.activate(this);

    _highlightedNotifier.value =
    _itemsNotifier.value.isEmpty ? -1 : 0;

    final OverlayState overlay = Overlay.of(context);

    _overlayEntry = OverlayEntry(
      builder: (overlayContext) {
        return Positioned.fill(
          child: Stack(
            children: [
              // ===================================================
              // OUTSIDE CLICK
              // ===================================================

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

              // ===================================================
              // POPUP
              // ===================================================

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
                      return ValueListenableBuilder<int>(
                        valueListenable:
                        _highlightedNotifier,
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

    // -------------------------------------------------------------
    // Initial API call
    // -------------------------------------------------------------

    widget.onSearch(_controller.text);
  }

  // ===============================================================
  // CLOSE
  // ===============================================================

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

  // ===============================================================
  // CLOSE FROM GLOBAL MANAGER
  // ===============================================================

  void _closeFromManager() {
    _closeDropdown();

    if (_focusNode.hasFocus) {
      _focusNode.unfocus();
    }
  }

  // ===============================================================
  // KEYBOARD
  // ===============================================================

  KeyEventResult _handleKeyEvent(
      FocusNode node,
      KeyEvent event,
      ) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    // =============================================================
    // OPEN WITH ENTER / ARROW DOWN
    // =============================================================

    if (!_isOpen) {
      if (event.logicalKey ==
          LogicalKeyboardKey.arrowDown ||
          event.logicalKey ==
              LogicalKeyboardKey.enter) {
        _DropdownManager.instance.activate(this);

        _openDropdown();

        return KeyEventResult.handled;
      }

      return KeyEventResult.ignored;
    }

    final List<T> items = _itemsNotifier.value;

    // =============================================================
    // ARROW DOWN
    // =============================================================

    if (event.logicalKey ==
        LogicalKeyboardKey.arrowDown) {
      if (items.isEmpty) {
        return KeyEventResult.handled;
      }

      int index = _highlightedNotifier.value;

      if (index < items.length - 1) {
        index++;
      } else {
        index = 0;
      }

      _highlightedNotifier.value = index;

      return KeyEventResult.handled;
    }

    // =============================================================
    // ARROW UP
    // =============================================================

    if (event.logicalKey ==
        LogicalKeyboardKey.arrowUp) {
      if (items.isEmpty) {
        return KeyEventResult.handled;
      }

      int index = _highlightedNotifier.value;

      if (index > 0) {
        index--;
      } else {
        index = items.length - 1;
      }

      _highlightedNotifier.value = index;

      return KeyEventResult.handled;
    }

    // =============================================================
    // ENTER
    // =============================================================

    if (event.logicalKey ==
        LogicalKeyboardKey.enter) {
      final int index =
          _highlightedNotifier.value;

      if (items.isNotEmpty &&
          index >= 0 &&
          index < items.length) {
        _selectItem(items[index]);
      }

      return KeyEventResult.handled;
    }

    // =============================================================
    // ESCAPE
    // =============================================================

    if (event.logicalKey ==
        LogicalKeyboardKey.escape) {
      _closeDropdown();

      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  // ===============================================================
  // SELECT
  // ===============================================================

  void _selectItem(T item) {
    final String text =
    widget.displayString(item);

    // -------------------------------------------------------------
    // Prevent API search while filling selected value.
    // -------------------------------------------------------------

    _ignoreTextChange = true;

    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(
        offset: text.length,
      ),
    );

    _ignoreTextChange = false;

    // -------------------------------------------------------------
    // Send model to parent.
    // -------------------------------------------------------------

    widget.onSelect(item);

    // -------------------------------------------------------------
    // Close.
    // -------------------------------------------------------------

    _closeDropdown();

    _DropdownManager.instance.deactivate(this);

    // -------------------------------------------------------------
    // Remove focus.
    // -------------------------------------------------------------

    _focusNode.unfocus();
  }

  // ===============================================================
  // POPUP
  // ===============================================================

  Widget _buildPopup(
      List<T> items,
      int highlightedIndex,
      ) {
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
      child: items.isEmpty
          ? const SizedBox(
        height: 80,
        child: Center(
          child: Text(
            'No results found',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xff94A3B8),
            ),
          ),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 4),
        shrinkWrap: true,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final T item = items[index];

          final bool selected = item == widget.value;
          final bool highlighted = index == highlightedIndex;

          final String text = widget.displayString(item);

          return MouseRegion(
            cursor: SystemMouseCursors.click,

            onEnter: (_) {
              _highlightedNotifier.value = index;
            },

            child: Listener(
              behavior: HitTestBehavior.opaque,

              onPointerDown: (event) {
                // Only handle LEFT mouse button
                if (event.kind == PointerDeviceKind.mouse &&
                    event.buttons == kPrimaryButton) {
                  debugPrint('LEFT CLICKED: $text');

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

  // ===============================================================
  // WIDTH
  // ===============================================================

  double _getDropdownWidth() {
    final RenderBox? renderBox =
    context.findRenderObject() as RenderBox?;

    if (renderBox == null) {
      return 250;
    }

    return renderBox.size.width;
  }

  // ===============================================================
  // DISPOSE
  // ===============================================================

  @override
  void dispose() {
    // -------------------------------------------------------------
    // If this is currently active, remove it from manager.
    // -------------------------------------------------------------

    _DropdownManager.instance.deactivate(this);

    _overlayEntry?.remove();
    _overlayEntry = null;

    _focusNode.removeListener(
      _onFocusChanged,
    );

    _controller.removeListener(
      _onTextChanged,
    );

    _itemsNotifier.dispose();
    _highlightedNotifier.dispose();

    _focusNode.dispose();
    _controller.dispose();

    super.dispose();
  }

  // ===============================================================
  // BUILD
  // ===============================================================

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child:SizedBox(
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
      )
    );
  }
}