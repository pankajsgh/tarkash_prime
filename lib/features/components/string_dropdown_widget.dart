import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SearchableDropdown extends StatefulWidget {
  const SearchableDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint = 'Select',
    this.height = 31,
  });

  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String hint;
  final double height;

  @override
  State<SearchableDropdown> createState() =>
      _SearchableDropdownState();
}

class _SearchableDropdownState
    extends State<SearchableDropdown> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  final LayerLink _layerLink = LayerLink();

  OverlayEntry? _overlayEntry;

  List<String> _filteredItems = [];

  int _highlightedIndex = -1;

  bool get _isOpen => _overlayEntry != null;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(
      text: widget.value ?? '',
    );

    _focusNode = FocusNode();

    _focusNode.addListener(_onFocusChanged);
    _controller.addListener(_onTextChanged);

    _filteredItems = List<String>.from(
      widget.items,
    );
  }

  @override
  void didUpdateWidget(
      covariant SearchableDropdown oldWidget,
      ) {
    super.didUpdateWidget(oldWidget);

    // -----------------------------------------
    // VALUE CHANGED FROM PARENT
    // -----------------------------------------

    if (oldWidget.value != widget.value &&
        widget.value != _controller.text) {
      final value = widget.value ?? '';

      _controller.value = TextEditingValue(
        text: value,
        selection: TextSelection.collapsed(
          offset: value.length,
        ),
      );
    }

    // -----------------------------------------
    // ITEMS CHANGED
    // -----------------------------------------

    if (oldWidget.items != widget.items) {
      _filteredItems = _filterItems(
        _controller.text,
      );

      if (_highlightedIndex >=
          _filteredItems.length) {
        _highlightedIndex =
        _filteredItems.isEmpty ? -1 : 0;
      }

      _overlayEntry?.markNeedsBuild();
    }
  }

  // =========================================================
  // FOCUS
  // =========================================================

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      _openDropdown();
    } else {
      Future.delayed(
        const Duration(milliseconds: 100),
            () {
          if (!_focusNode.hasFocus && mounted) {
            _closeDropdown();
          }
        },
      );
    }
  }

  // =========================================================
  // SEARCH
  // =========================================================

  void _onTextChanged() {
    if (!_isOpen) {
      return;
    }

    _filteredItems = _filterItems(
      _controller.text,
    );

    _highlightedIndex =
    _filteredItems.isEmpty ? -1 : 0;

    _overlayEntry?.markNeedsBuild();
  }

  List<String> _filterItems(String query) {
    final text = query.trim().toLowerCase();

    if (text.isEmpty) {
      return List<String>.from(
        widget.items,
      );
    }

    return widget.items.where((item) {
      return item.toLowerCase().contains(text);
    }).toList();
  }

  // =========================================================
  // OPEN DROPDOWN
  // =========================================================

  void _openDropdown() {
    if (_isOpen) {
      _overlayEntry?.markNeedsBuild();
      return;
    }

    _filteredItems = _filterItems(
      _controller.text,
    );

    _highlightedIndex =
    _filteredItems.isEmpty ? -1 : 0;

    final overlay = Overlay.of(context);

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned.fill(
          child: Stack(
            children: [
              // -----------------------------------------
              // OUTSIDE CLICK
              // -----------------------------------------

              GestureDetector(
                behavior:
                HitTestBehavior.translucent,
                onTap: () {
                  _focusNode.unfocus();
                },
                child: const SizedBox.expand(),
              ),

              // -----------------------------------------
              // DROPDOWN
              // -----------------------------------------

              CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: Offset(
                  0,
                  widget.height + 5,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: _buildPopup(),
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
  }

  // =========================================================
  // CLOSE DROPDOWN
  // =========================================================

  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;

    _highlightedIndex = -1;

    if (mounted) {
      setState(() {});
    }
  }

  // =========================================================
  // KEYBOARD HANDLING
  // =========================================================

  KeyEventResult _handleKeyEvent(
      FocusNode node,
      KeyEvent event,
      ) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    // -----------------------------------------
    // OPEN WITH ARROW DOWN / ENTER
    // -----------------------------------------

    if (!_isOpen) {
      if (event.logicalKey ==
          LogicalKeyboardKey.arrowDown ||
          event.logicalKey ==
              LogicalKeyboardKey.enter) {
        _openDropdown();

        return KeyEventResult.handled;
      }

      return KeyEventResult.ignored;
    }

    // -----------------------------------------
    // ARROW DOWN
    // -----------------------------------------

    if (event.logicalKey ==
        LogicalKeyboardKey.arrowDown) {
      if (_filteredItems.isEmpty) {
        return KeyEventResult.handled;
      }

      setState(() {
        if (_highlightedIndex <
            _filteredItems.length - 1) {
          _highlightedIndex++;
        } else {
          _highlightedIndex = 0;
        }
      });

      _overlayEntry?.markNeedsBuild();

      return KeyEventResult.handled;
    }

    // -----------------------------------------
    // ARROW UP
    // -----------------------------------------

    if (event.logicalKey ==
        LogicalKeyboardKey.arrowUp) {
      if (_filteredItems.isEmpty) {
        return KeyEventResult.handled;
      }

      setState(() {
        if (_highlightedIndex > 0) {
          _highlightedIndex--;
        } else {
          _highlightedIndex =
              _filteredItems.length - 1;
        }
      });

      _overlayEntry?.markNeedsBuild();

      return KeyEventResult.handled;
    }

    // -----------------------------------------
    // ENTER
    // -----------------------------------------

    if (event.logicalKey ==
        LogicalKeyboardKey.enter) {
      if (_filteredItems.isNotEmpty &&
          _highlightedIndex >= 0 &&
          _highlightedIndex <
              _filteredItems.length) {
        _selectItem(
          _filteredItems[_highlightedIndex],
        );
      }

      return KeyEventResult.handled;
    }

    // -----------------------------------------
    // ESCAPE
    // -----------------------------------------

    if (event.logicalKey ==
        LogicalKeyboardKey.escape) {
      _focusNode.unfocus();

      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  // =========================================================
  // SELECT ITEM
  // =========================================================

  void _selectItem(String value) {
    _controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(
        offset: value.length,
      ),
    );

    widget.onChanged(value);

    _closeDropdown();

    _focusNode.unfocus();
  }

  // =========================================================
  // DROPDOWN POPUP
  // =========================================================

  Widget _buildPopup() {
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
      child: _filteredItems.isEmpty
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
        padding:
        const EdgeInsets.symmetric(
          vertical: 4,
        ),
        shrinkWrap: true,
        itemCount: _filteredItems.length,
        itemBuilder: (
            context,
            index,
            ) {
          final item =
          _filteredItems[index];

          final bool selected =
              item == widget.value;

          final bool highlighted =
              index == _highlightedIndex;

          return InkWell(
            onTap: () {
              _selectItem(item);
            },
            child: Container(
              height: 34,
              padding:
              const EdgeInsets.symmetric(
                horizontal: 10,
              ),
              color: highlighted
                  ? const Color(
                0xffDBEAFE,
              )
                  : selected
                  ? const Color(
                0xffEEF2FF,
              )
                  : Colors.transparent,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item,
                      maxLines: 1,
                      overflow:
                      TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: highlighted ||
                            selected
                            ? const Color(
                          0xff2563EB,
                        )
                            : const Color(
                          0xff334155,
                        ),
                        fontWeight:
                        highlighted ||
                            selected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ),

                  if (selected)
                    const Icon(
                      Icons.check,
                      size: 16,
                      color:
                      Color(0xff2563EB),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // =========================================================
  // WIDTH
  // =========================================================

  double _getDropdownWidth() {
    final renderBox =
    context.findRenderObject()
    as RenderBox?;

    if (renderBox == null) {
      return 250;
    }

    return renderBox.size.width;
  }

  // =========================================================
  // DISPOSE
  // =========================================================

  @override
  void dispose() {
    _overlayEntry?.remove();

    _focusNode.removeListener(
      _onFocusChanged,
    );

    _controller.removeListener(
      _onTextChanged,
    );

    _focusNode.dispose();
    _controller.dispose();

    super.dispose();
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xff1E293B),
          ),
        ),

        const SizedBox(height: 10),

        CompositedTransformTarget(
          link: _layerLink,
          child: SizedBox(
            height: widget.height,
            child: Focus(
              onKeyEvent: _handleKeyEvent,
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xff334155),
                ),
                decoration:
                InputDecoration(
                  hintText: widget.hint,
                  hintStyle:
                  const TextStyle(
                    fontSize: 13,
                    color: Color(0xffCBD5E1),
                  ),

                  suffixIcon: Icon(
                    _isOpen
                        ? Icons
                        .keyboard_arrow_up
                        : Icons
                        .keyboard_arrow_down,
                    size: 18,
                    color:
                    const Color(0xffCCCCCC),
                  ),

                  suffixIconConstraints:
                  const BoxConstraints(
                    minWidth: 32,
                    minHeight: 31,
                  ),

                  contentPadding:
                  const EdgeInsets
                      .symmetric(
                    horizontal: 8,
                    vertical: 0,
                  ),

                  isDense: true,

                  border:
                  OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(
                      5,
                    ),
                    borderSide:
                    const BorderSide(
                      color:
                      Color(0xffD6D6D6),
                    ),
                  ),

                  enabledBorder:
                  OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(
                      5,
                    ),
                    borderSide:
                    const BorderSide(
                      color:
                      Color(0xffD6D6D6),
                    ),
                  ),

                  focusedBorder:
                  OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(
                      5,
                    ),
                    borderSide:
                    const BorderSide(
                      color:
                      Color(0xff3B82F6),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}