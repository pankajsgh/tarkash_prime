import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../model/product_model.dart';
import '../../model/purchase_model.dart';
import '../../controller/purchase_controller.dart';

class ProductAutoCompleteCell extends StatefulWidget {
  final PurchaseItem item;
  final double width;
  final PurchaseController controller;
  final Function(String) callback;

  const ProductAutoCompleteCell({
    super.key,
    required this.item,
    required this.width,
    required this.controller,
    required this.callback,
  });

  @override
  State<ProductAutoCompleteCell> createState() =>
      _ProductAutoCompleteCellState();
}

class _ProductAutoCompleteCellState
    extends State<ProductAutoCompleteCell> {
  static const double _optionHeight = 45;

  final Map<PurchaseItem, ProductAutocompleteState> _states = {};

  ProductAutocompleteState _stateFor(PurchaseItem item) {
    return _states.putIfAbsent(
      item,
      ProductAutocompleteState.new,
    );
  }

  @override
  void dispose() {
    for (final state in _states.values) {
      state.dispose();
    }

    _states.clear();

    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // SCROLL
  // ---------------------------------------------------------------------------

  void _scrollToSelected(ProductAutocompleteState state) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final controller = state.scrollController;

      // The autocomplete popup may not have attached its ListView yet.
      if (!controller.hasClients) return;

      final index = state.selectedIndex;

      if (index < 0 || index >= state.options.length) {
        return;
      }

      final position = controller.position;

      final currentOffset = position.pixels;
      final viewportHeight = position.viewportDimension;

      final itemTop = index * _optionHeight;
      final itemBottom = itemTop + _optionHeight;

      double targetOffset = currentOffset;

      if (itemTop < currentOffset) {
        targetOffset = itemTop;
      } else if (itemBottom > currentOffset + viewportHeight) {
        targetOffset = itemBottom - viewportHeight;
      }

      targetOffset = targetOffset.clamp(
        0.0,
        position.maxScrollExtent,
      );

      if ((targetOffset - currentOffset).abs() < 0.5) {
        return;
      }

      controller.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 80),
        curve: Curves.easeOut,
      );
    });
  }

  // ---------------------------------------------------------------------------
  // CREATE NEW PRODUCT
  // ---------------------------------------------------------------------------

  void _createProduct(String text) {
    final supplier = widget.controller.selectSupplier;

    if (supplier == null || supplier.id.isEmpty) {
      return;
    }

    widget.item.productPrice = 0;
    widget.item.quantityController.text = '1';
    widget.item.priceController.text = '0';
    widget.item.mrpRateController.text = '0';
    widget.item.wholesaleRateController.text = '0';
    widget.item.retailRateController.text = '0';
    widget.item.discountController.text = '0';
    widget.item.product = null;

    widget.controller.update();
    widget.callback(text);
  }

  // ---------------------------------------------------------------------------
  // SELECT PRODUCT
  // ---------------------------------------------------------------------------

  void _selectProduct(
      ProductAutocompleteState state,
      ProductModel product,
      ) {
    widget.controller.selectProduct(
      widget.item,
      product,
    );

    state.reset();

    widget.controller.update();
  }

  // ---------------------------------------------------------------------------
  // KEYBOARD
  // ---------------------------------------------------------------------------

  KeyEventResult _handleKey(
      ProductAutocompleteState state,
      FocusNode focusNode,
      TextEditingController textController,
      KeyEvent event,
      ) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    final products = state.options;

    // ESC
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      state.selectedIndex = -1;
      focusNode.unfocus();
      widget.controller.update();

      return KeyEventResult.handled;
    }

    // ENTER
    if (event.logicalKey == LogicalKeyboardKey.enter) {
      if (state.selectedIndex >= 0 &&
          state.selectedIndex < products.length) {
        _selectProduct(
          state,
          products[state.selectedIndex],
        );

        focusNode.unfocus();

        return KeyEventResult.handled;
      }

      _createProduct(textController.text);

      return KeyEventResult.handled;
    }

    if (products.isEmpty) {
      return KeyEventResult.ignored;
    }

    // ARROW DOWN
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (state.selectedIndex < products.length - 1) {
        state.selectedIndex++;
      } else {
        state.selectedIndex = 0;
      }

      widget.controller.update();
      _scrollToSelected(state);

      return KeyEventResult.handled;
    }

    // ARROW UP
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (state.selectedIndex > 0) {
        state.selectedIndex--;
      } else {
        state.selectedIndex = products.length - 1;
      }

      widget.controller.update();
      _scrollToSelected(state);

      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  // ---------------------------------------------------------------------------
  // PRODUCT FIELD
  // ---------------------------------------------------------------------------

  Widget _field(
      ProductAutocompleteState state,
      TextEditingController textController,
      FocusNode focusNode,
      ) {
    return Focus(
      onKeyEvent: (node, event) {
        return _handleKey(
          state,
          focusNode,
          textController,
          event,
        );
      },
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.blue.shade100,
          ),
          borderRadius: BorderRadius.circular(3),
        ),
        child: TextField(
          controller: textController,
          focusNode: focusNode,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xff334155),
          ),
          decoration: const InputDecoration(
            hintText: 'Select product',
            hintStyle: TextStyle(
              fontSize: 13,
              color: Color(0xffCBD5E1),
            ),
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // PRODUCT ITEM
  // ---------------------------------------------------------------------------

  Widget _productItem(
      ProductModel product,
      int index,
      ProductAutocompleteState state,
      AutocompleteOnSelected<ProductModel> onSelected,
      ) {
    final selected = state.selectedIndex == index;

    return SizedBox(
      height: _optionHeight,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) {
          if (state.selectedIndex == index) return;

          state.selectedIndex = index;
          widget.controller.update();
        },
        child: InkWell(
          onTap: () {
            state.selectedIndex = index;
            onSelected(product);
          },
          child: Container(
            color: selected
                ? const Color(0xffEEF2FF)
                : Colors.transparent,
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            child: Row(
              children: [
                const SizedBox(width: 2),

                Expanded(
                  child: _productDetails(product),
                ),

                const SizedBox(width: 8),

                if ((product.brand?.name ?? '').isNotEmpty)
                  _brand(product),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _productDetails(ProductModel product) {
    final hasCategory =
        (product.category ?? '').isNotEmpty;

    final hasHsn =
        (product.hsnCode?.name ?? '').isNotEmpty;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.name ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xff1E293B),
          ),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            if (hasCategory)
              Flexible(
                child: Text(
                  product.category!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xff64748B),
                  ),
                ),
              ),
            if (hasCategory && hasHsn)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: Text(
                  '•',
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xffCBD5E1),
                  ),
                ),
              ),
            if (hasHsn)
              Text(
                'HSN ${product.hsnCode!.name}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xff64748B),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _brand(ProductModel product) {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 100,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: const Color(0xffF1F5F9),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        product.brand!.name!,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: Color(0xff475569),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final state = _stateFor(widget.item);

    return SizedBox(
      width: widget.width,
      height: 52,
      child: RawAutocomplete<ProductModel>(
        key: ValueKey(
          'product-autocomplete-${widget.item.hashCode}',
        ),
        textEditingController: widget.item.nameController,
        focusNode: widget.item.articleFocusNode,
        displayStringForOption: (product) {
          return product.name ?? '';
        },

        // ---------------------------------------------------------------------
        // SEARCH
        // ---------------------------------------------------------------------

        optionsBuilder: (TextEditingValue value) async {
          final query = value.text.trim();

          if (query.isEmpty) {
            state.reset();
            return const <ProductModel>[];
          }

          final requestId = ++state.requestId;

          state.selectedIndex = -1;

          final result =
          await widget.controller.getProductList(query);

          if (requestId != state.requestId) {
            return const <ProductModel>[];
          }

          if (widget.item.nameController.text.trim() !=
              query) {
            return const <ProductModel>[];
          }

          state.options = List<ProductModel>.from(result);

          state.selectedIndex = -1;

          return state.options;
        },

        // ---------------------------------------------------------------------
        // SELECTED
        // ---------------------------------------------------------------------

        onSelected: (product) {
          _selectProduct(
            state,
            product,
          );
        },

        // ---------------------------------------------------------------------
        // FIELD
        // ---------------------------------------------------------------------

        fieldViewBuilder: (
            context,
            textController,
            focusNode,
            onFieldSubmitted,
            ) {
          return _field(
            state,
            textController,
            focusNode,
          );
        },

        // ---------------------------------------------------------------------
        // OPTIONS
        // ---------------------------------------------------------------------

        optionsViewBuilder: (
            context,
            onSelected,
            options,
            ) {
          final products = options.toList();

          if (products.isEmpty) {
            return const SizedBox.shrink();
          }

          state.options = products;

          if (state.selectedIndex >= products.length) {
            state.selectedIndex = products.length - 1;
          }

          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 8,
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              clipBehavior: Clip.antiAlias,
              child: SizedBox(
                width: 500,
                height: products.length > 7
                    ? 360
                    : products.length * _optionHeight,
                child: ListView.separated(
                  controller: state.scrollController,
                  padding: EdgeInsets.zero,
                  physics: const ClampingScrollPhysics(),
                  itemCount: products.length,
                  separatorBuilder: (_, __) {
                    return const Divider(
                      height: 1,
                      color: Color(0xffE2E8F0),
                    );
                  },
                  itemBuilder: (context, index) {
                    return _productItem(
                      products[index],
                      index,
                      state,
                      onSelected,
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// =============================================================================
// AUTOCOMPLETE STATE
// =============================================================================

class ProductAutocompleteState {
  List<ProductModel> options = [];

  int selectedIndex = -1;

  int requestId = 0;

  final ScrollController scrollController =
  ScrollController();

  void reset() {
    options.clear();
    selectedIndex = -1;
    requestId++;

    if (scrollController.hasClients) {
      scrollController.jumpTo(0);
    }
  }

  void dispose() {
    scrollController.dispose();
  }
}