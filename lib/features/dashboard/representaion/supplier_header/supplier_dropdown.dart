import 'package:calculation_panel/core/theme/colors.dart';
import 'package:calculation_panel/core/widget/widget_updater.dart';
import 'package:calculation_panel/features/dashboard/representaion/supplier_header/model/supplier_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SupplierDropdown extends StatefulWidget {
  final List<Party> suppliers;
  final Party? selectedSupplier;

  final ValueChanged<Party> onSelect;
  final ValueChanged<String> onSearch;

  const SupplierDropdown({
    super.key,
    required this.suppliers,
    required this.selectedSupplier,
    required this.onSelect,
    required this.onSearch,
  });

  @override
  State<SupplierDropdown> createState() =>
      _SupplierDropdownState();
}

class _SupplierDropdownState extends State<SupplierDropdown> {
  static const double dropdownWidth = 260;
  static const double optionHeight = 51;

  final TextEditingController _textController =
  TextEditingController();

  final FocusNode _focusNode = FocusNode();

  final ScrollController _scrollController =
  ScrollController();

  final WidgetUpdater _updater = WidgetUpdater();

  int _selectedIndex = -1;

  bool _isUpdatingText = false;

  // ===========================================================================
  // INIT
  // ===========================================================================

  @override
  void initState() {
    super.initState();

    _setSupplierText();
  }

  // ===========================================================================
  // UPDATE
  // ===========================================================================

  @override
  void didUpdateWidget(
      covariant SupplierDropdown oldWidget,
      ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.selectedSupplier !=
        widget.selectedSupplier) {
      _setSupplierText();
    }

    // Do NOT call setState here.
    // Just rebuild the parent-controlled widget normally.
  }

  // ===========================================================================
  // SET SUPPLIER TEXT
  // ===========================================================================

  void _setSupplierText() {
    final text =
        widget.selectedSupplier?.company ?? '';

    if (_textController.text == text) {
      return;
    }

    _isUpdatingText = true;

    _textController.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(
        offset: text.length,
      ),
    );

    _isUpdatingText = false;
  }

  // ===========================================================================
  // TEXT CHANGED
  // ===========================================================================

  void _onTextChanged(String value) {
    if (!mounted || _isUpdatingText) {
      return;
    }

    // Reset keyboard highlight.
    _selectedIndex = -1;

    // ---------------------------------------------------------------
    // IMPORTANT
    // No setState() here.
    // No controller listener.
    // No markNeedsBuild() during build.
    // ---------------------------------------------------------------

    widget.onSearch(value.trim());

    // Update only the dropdown overlay.
    _updater.update();

    // Scroll back to beginning after search.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });
  }

  // ===========================================================================
  // OPEN DROPDOWN
  // ===========================================================================

  void _openDropdown() {
    if (!mounted) return;

    _selectedIndex = -1;

    // Empty search means load all suppliers.
    if (_textController.text.trim().isEmpty) {
      widget.onSearch('');
    }

    _updater.update();
  }

  // ===========================================================================
  // CLEAR BUTTON
  // ===========================================================================

  void _clearText() {
    if (!mounted) return;

    _isUpdatingText = true;

    _textController.clear();

    _isUpdatingText = false;

    _selectedIndex = -1;

    // Ask parent for all suppliers.
    widget.onSearch('');

    // Rebuild dropdown.
    _updater.update();

    // Keep focus inside TextField.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _focusNode.requestFocus();

      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });
  }

  // ===========================================================================
  // SELECT
  // ===========================================================================

  void _selectSupplier(Party supplier) {
    final text = supplier.company;

    _isUpdatingText = true;

    _textController.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(
        offset: text.length,
      ),
    );

    _isUpdatingText = false;

    widget.onSelect(supplier);

    _selectedIndex = -1;

    _focusNode.unfocus();

    _updater.update();
  }

  // ===========================================================================
  // KEYBOARD
  // ===========================================================================

  KeyEventResult _handleKey(
      FocusNode node,
      KeyEvent event,
      ) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    final suppliers = widget.suppliers;

    // =======================================================================
    // ESCAPE
    // =======================================================================

    if (event.logicalKey ==
        LogicalKeyboardKey.escape) {
      _focusNode.unfocus();

      _selectedIndex = -1;

      _updater.update();

      return KeyEventResult.handled;
    }

    // =======================================================================
    // ENTER
    // =======================================================================

    if (event.logicalKey ==
        LogicalKeyboardKey.enter) {
      if (suppliers.isEmpty) {
        return KeyEventResult.handled;
      }

      if (_selectedIndex >= 0 &&
          _selectedIndex < suppliers.length) {
        _selectSupplier(
          suppliers[_selectedIndex],
        );
      }

      return KeyEventResult.handled;
    }

    // =======================================================================
    // DOWN
    // =======================================================================

    if (event.logicalKey ==
        LogicalKeyboardKey.arrowDown) {
      if (suppliers.isEmpty) {
        return KeyEventResult.handled;
      }

      if (_selectedIndex <
          suppliers.length - 1) {
        _selectedIndex++;
      } else {
        _selectedIndex = 0;
      }

      _updater.update();

      _scrollToSelected();

      return KeyEventResult.handled;
    }

    // =======================================================================
    // UP
    // =======================================================================

    if (event.logicalKey ==
        LogicalKeyboardKey.arrowUp) {
      if (suppliers.isEmpty) {
        return KeyEventResult.handled;
      }

      if (_selectedIndex > 0) {
        _selectedIndex--;
      } else {
        _selectedIndex =
            suppliers.length - 1;
      }

      _updater.update();

      _scrollToSelected();

      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  // ===========================================================================
  // SCROLL SELECTED ITEM
  // ===========================================================================

  void _scrollToSelected() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (!_scrollController.hasClients) {
        return;
      }

      final suppliers = widget.suppliers;

      if (suppliers.isEmpty) {
        return;
      }

      if (_selectedIndex < 0 ||
          _selectedIndex >= suppliers.length) {
        return;
      }

      final position =
          _scrollController.position;

      final currentOffset =
          position.pixels;

      final viewportHeight =
          position.viewportDimension;

      final itemTop =
          _selectedIndex * optionHeight;

      final itemBottom =
          itemTop + optionHeight;

      double targetOffset =
          currentOffset;

      // Item is above viewport.
      if (itemTop < currentOffset) {
        targetOffset = itemTop;
      }

      // Item is below viewport.
      else if (
      itemBottom >
          currentOffset +
              viewportHeight) {
        targetOffset =
            itemBottom -
                viewportHeight;
      }

      targetOffset =
          targetOffset.clamp(
            0.0,
            position.maxScrollExtent,
          );

      if ((targetOffset -
          currentOffset)
          .abs() <
          0.5) {
        return;
      }

      _scrollController.animateTo(
        targetOffset,
        duration:
        const Duration(
          milliseconds: 80,
        ),
        curve: Curves.easeOut,
      );
    });
  }

  // ===========================================================================
  // INPUT DECORATION
  // ===========================================================================

  InputDecoration _decoration() {
    final border =
    OutlineInputBorder(
      borderRadius:
      BorderRadius.circular(8),
      borderSide:
      const BorderSide(
        color: borderColor,
      ),
    );

    return InputDecoration(
      hintText:
      'Search supplier...',

      hintStyle:
      const TextStyle(
        fontSize: 11,
        color: textLight,
      ),

      prefixIcon:
      const Icon(
        Icons.storefront_outlined,
        size: 17,
        color: textLight,
      ),

      suffixIcon:
      _textController.text
          .isNotEmpty
          ? IconButton(
        onPressed:
        _clearText,
        icon:
        const Icon(
          Icons.close_rounded,
          size: 17,
          color:
          textLight,
        ),
      )
          : const Icon(
        Icons
            .keyboard_arrow_down_rounded,
        size: 18,
        color: textLight,
      ),

      filled: true,

      fillColor:
      const Color(0xffF8FAFC),

      contentPadding:
      const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 9,
      ),

      isDense: true,

      border: border,

      enabledBorder: border,

      focusedBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(8),
        borderSide:
        const BorderSide(
          color:
          Color(0xff3B82F6),
          width: 1.3,
        ),
      ),
    );
  }

  // ===========================================================================
  // DROPDOWN
  // ===========================================================================

  Widget _dropdown() {
    final suppliers =
        widget.suppliers;

    if (suppliers.isEmpty) {
      return _emptyDropdown();
    }

    return Material(
      elevation: 8,
      color: Colors.white,
      borderRadius:
      BorderRadius.circular(8),
      clipBehavior:
      Clip.antiAlias,
      child: SizedBox(
        width: dropdownWidth,

        // Same idea as ProductAutoCompleteCell.
        height: suppliers.length > 7
            ? 360
            : suppliers.length *
            optionHeight,

        child:
        ListView.separated(
          controller:
          _scrollController,

          padding:
          EdgeInsets.zero,

          physics:
          const ClampingScrollPhysics(),

          itemCount:
          suppliers.length,

          separatorBuilder:
              (_, __) {
            return const Divider(
              height: 1,
              color:
              Color(0xffE2E8F0),
            );
          },

          itemBuilder:
              (context, index) {
            return _supplierItem(
              suppliers[index],
              index,
            );
          },
        ),
      ),
    );
  }

  // ===========================================================================
  // SUPPLIER ITEM
  // ===========================================================================

  Widget _supplierItem(
      Party supplier,
      int index,
      ) {
    return ListenableBuilder(
      listenable: _updater,
      builder:
          (context, _) {
        final selected =
            _selectedIndex ==
                index;

        return SizedBox(
          height: optionHeight,

          child: MouseRegion(
            cursor:
            SystemMouseCursors.click,

            onEnter: (_) {
              if (_selectedIndex ==
                  index) {
                return;
              }

              _selectedIndex =
                  index;

              _updater.update();
            },

            child: InkWell(
              onTap: () {
                _selectedIndex =
                    index;

                _selectSupplier(
                  supplier,
                );
              },

              child: Container(
                padding:
                const EdgeInsets
                    .symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),

                color: selected
                    ? const Color(
                  0xffEEF2FF,
                )
                    : Colors.transparent,

                child: Row(
                  children: [
                    _avatar(
                      supplier,
                    ),

                    const SizedBox(
                      width: 10,
                    ),

                    Expanded(
                      child:
                      _supplierDetails(
                        supplier,
                      ),
                    ),

                    const SizedBox(
                      width: 8,
                    ),

                    if (selected)
                      const Icon(
                        Icons
                            .keyboard_return_rounded,
                        size: 13,
                        color:
                        Color(0xff3B82F6),
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

  // ===========================================================================
  // SUPPLIER DETAILS
  // ===========================================================================

  Widget _supplierDetails(
      Party supplier,
      ) {
    return Column(
      mainAxisAlignment:
      MainAxisAlignment.center,
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          supplier.company,
          maxLines: 1,
          overflow:
          TextOverflow.ellipsis,
          style:
          const TextStyle(
            fontSize: 12,
            fontWeight:
            FontWeight.w600,
            color: textDark,
          ),
        ),

        const SizedBox(
          height: 2,
        ),

        Text(
          supplier.name,
          maxLines: 1,
          overflow:
          TextOverflow.ellipsis,
          style:
          const TextStyle(
            fontSize: 10,
            color: Color(
              0xff64748B,
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // AVATAR
  // ===========================================================================

  Widget _avatar(
      Party supplier,
      ) {
    final letter =
    supplier.name.isNotEmpty
        ? supplier.name
        .substring(0, 1)
        .toUpperCase()
        : '?';

    return Container(
      width: 32,
      height: 32,
      alignment:
      Alignment.center,

      decoration:
      BoxDecoration(
        color:
        const Color(
          0xffEAF2FF,
        ),
        borderRadius:
        BorderRadius.circular(
          8,
        ),
      ),

      child: Text(
        letter,
        style:
        const TextStyle(
          color: blue,
          fontSize: 13,
          fontWeight:
          FontWeight.w800,
        ),
      ),
    );
  }

  // ===========================================================================
  // EMPTY
  // ===========================================================================

  Widget _emptyDropdown() {
    return Material(
      elevation: 8,
      color: Colors.white,
      borderRadius:
      BorderRadius.circular(8),
      child: Container(
        width: dropdownWidth,
        height: 90,
        alignment:
        Alignment.center,

        child: const Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 25,
              color:
              Color(0xffCBD5E1),
            ),

            SizedBox(
              height: 6,
            ),

            Text(
              'No supplier found',
              style:
              TextStyle(
                fontSize: 11,
                color:
                Color(0xff64748B),
                fontWeight:
                FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    return SizedBox(
      width: dropdownWidth,
      height: 36,

      child: RawAutocomplete<Party>(
        key: ValueKey(
          'supplier-autocomplete',
        ),

        textEditingController:
        _textController,

        focusNode:
        _focusNode,

        displayStringForOption:
            (supplier) =>
        supplier.company,

        // =====================================================================
        // OPTIONS
        // =====================================================================

        optionsBuilder:
            (TextEditingValue value) {
          // IMPORTANT:
          // No local search/filter here.
          //
          // SupplierController controls the list.
          //
          // When empty:
          // onSearch('') -> parent loads all suppliers.
          //
          // When typing:
          // onSearch(value) -> parent searches suppliers.

          return widget.suppliers;
        },

        // =====================================================================
        // SELECTED
        // =====================================================================

        onSelected:
            (Party supplier) {
          _selectSupplier(
            supplier,
          );
        },

        // =====================================================================
        // FIELD
        // =====================================================================

        fieldViewBuilder: (
            context,
            textController,
            focusNode,
            onFieldSubmitted,
            ) {
          return Focus(
            onKeyEvent:
            _handleKey,

            child: TextField(
              controller:
              textController,

              focusNode:
              focusNode,

              onTap:
              _openDropdown,

              onChanged:
              _onTextChanged,

              style:
              const TextStyle(
                fontSize: 12,
                color: textDark,
              ),

              decoration:
              _decoration(),
            ),
          );
        },

        // =====================================================================
        // OPTIONS VIEW
        // =====================================================================

        optionsViewBuilder: (
            context,
            onSelected,
            options,
            ) {
          final suppliers =
          options.toList();

          if (suppliers.isEmpty) {
            return const SizedBox.shrink();
          }

          // Do NOT change selectedIndex here.
          //
          // This builder can run during Flutter build.
          // Changing state here can cause:
          //
          // setState() or markNeedsBuild() called during build.

          return Align(
            alignment:
            Alignment.topLeft,

            child: _dropdown(),
          );
        },
      ),
    );
  }

  // ===========================================================================
  // DISPOSE
  // ===========================================================================

  @override
  void dispose() {
    _textController.dispose();

    _focusNode.dispose();

    _scrollController.dispose();

    super.dispose();
  }
}