import 'package:calculation_panel/core/ulitls/debouncer.dart';
import 'package:calculation_panel/core/ulitls/utility.dart';

import 'package:calculation_panel/features/purchase_challan/representaion/product_selection_section/product_add_controller.dart';
import 'package:calculation_panel/features/purchase_challan/representaion/product_selection_section/product_add_section.dart';
import 'package:calculation_panel/features/purchase_challan/representaion/product_selection_section/product_auto_complete_cell.dart';
import 'package:calculation_panel/features/purchase_challan/representaion/product_selection_section/product_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/vars/global_vars.dart';
import '../../../../core/widget/toast.dart';
import '../../../components/custome_dropdown_widget.dart';
import '../../model/product_model.dart';
import '../../model/color_model.dart';
import '../../model/hsn_model.dart';
import '../../model/purchase_model.dart';
import '../../model/size_model.dart';
import '../../controller/purchase_controller.dart';
import '../supplier_header/model/supplier_model.dart';

class ProductSelectionSection extends StatefulWidget {

  final PurchaseController controller;
  const ProductSelectionSection({
    super.key,
    required this.controller,
  });

  @override
  State<ProductSelectionSection> createState() => _ProductSelectionSectionState();
}

class _ProductSelectionSectionState extends State<ProductSelectionSection> {
  late ProductController productController;

  int selectedRow = -1;
  static const List<double> _productWidths = [
    42,
    110,
    210,
    110,
    110,
    75,
    100,
    90,
    100,
    90,
    95,
    85,
    105,
    70,
    65,
  ];
  static const List<String> _productHeaders = [
    '#',
    'Brand',
    'Product',
    'Size',
    'Color',
    'Qty',
    'Purchase',
    'MRP',
    'Wholesale',
    'Retail',
    'Extra Disc.',
    'Discount %',
    'Amount',
    'GST %',
    'Action',
  ];
  double get _productTableWidth {
    return _productWidths.fold(
      0,
          (sum, width) => sum + width,
    );
  }

  Debouncer debouncer = Debouncer();

  @override
  void initState() {
    super.initState();
    productController = ProductController()..initialize(GlobalVars.currentData);
  }


  Future<void> openCreateProductPopup(
      BuildContext context,
      String text,
      int index,
      ) async {
    final supplier = widget.controller.selectSupplier;

    if (supplier == null || supplier.id.isEmpty) {
      return;
    }

    final value =
    await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return CreateProductPopup(
          supplierId: supplier.id,
          supplier: supplier,
          productController: productController,
          name: text,
        );
      },
    );

    if (!mounted) {
      return;
    }

    if (value != null) {

      var data = ProductModel(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          name: value['product_name']?? '',
          hsnTaxSlab: value['hsncode']!=null && value['hsncode'] is HsnModel ? value['hsncode']!.hsnTaxSlab: null,
          brand: value['brand']!=null && value['brand'] is BrandItem ? BrandModel(id: value['brand']!.id,name: value['brand']!.brand): null
      );

      if(value['attributes'] is List<ProductAttribute>)
      {
        List<ProductAttribute>  attributeList =  value['attributes'];
        for(var x in attributeList )
        {
          widget.controller.addItem;
          widget.controller.items[index].priceController.text = x.purchasePrice;
          widget.controller.items[index].product = data;
          widget.controller.items[index].productId = data.id;
          // widget.controller.items[index].size = x.size;
          // widget.controller.items[index].color = x.color;
          widget.controller.items[index].setDiscountedAmount();
          widget.controller.selectProduct(
              widget.controller.items[index],
              data,
              qty:x.quantity
          );
        }
      }


      widget.controller.update();
    }
  }

  // ============================================================
  // Build mathod
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return _buildProductsCard();
  }

  Widget _buildProductsCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              18,
              12,
              18,
              8,
            ),
            child: Row(
              children: [
                _sectionTitle(
                  Icons.inventory_2_outlined,
                  'Products',
                ),

                const SizedBox(width: 10),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xffF1F5F9),
                    borderRadius:
                    BorderRadius.circular(15),
                  ),
                  child:  ListenableBuilder(
                      listenable: widget.controller.updateSummery,
                      builder: (context,_){
                        return Text(
                          '${widget.controller.items.length} Items',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xff475569),
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }),


                ),

                const SizedBox(width: 8),

                Container(
                  decoration: BoxDecoration(
                    borderRadius:
                    BorderRadius.circular(8),
                    color: Colors.blue,
                  ),
                  height: 24,
                  width: 24,
                  child: InkWell(
                    onTap: widget.controller.addItem,
                    child: const Center(
                      child: Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 150,
                      height: 32,
                      child: TextField(
                        controller: widget.controller.applyDiscountController,
                        keyboardType:
                        const TextInputType
                            .numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Bill Discount(%)',
                          hintStyle:
                          const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          contentPadding:
                          const EdgeInsets.symmetric(
                            horizontal: 8,
                          ),
                          border:
                          OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(4),
                            borderSide:
                            const BorderSide(
                              color: Colors.grey,
                            ),
                          ),
                          enabledBorder:
                          OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(4),
                            borderSide:
                            const BorderSide(
                              color: Color(0xFFD0D0D0),
                            ),
                          ),
                          focusedBorder:
                          OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(4),
                            borderSide:
                            const BorderSide(
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        style:
                        const TextStyle(
                          fontSize: 12,
                        ),
                        onSubmitted: (String value){
                          widget.controller.applyDiscountAll();
                        },
                      ),
                    ),

                    const SizedBox(width: 6),

                    SizedBox(
                      height: 32,
                      child: ElevatedButton(
                        onPressed: () {
                          widget.controller.applyDiscountAll();
                        },
                        style:
                        ElevatedButton.styleFrom(
                          padding:
                          const EdgeInsets.symmetric(
                            horizontal: 12,
                          ),
                          minimumSize: Size.zero,
                          backgroundColor:
                          const Color(0xFF3E4A59),
                          foregroundColor:
                          Colors.white,
                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(4),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Apply',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight:
                            FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: _buildProductTable(),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TABLE
  // ============================================================

  Widget _buildProductTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const ClampingScrollPhysics(),
      child: SizedBox(
        width: _productTableWidth,
        child: ListenableBuilder(
          listenable: widget.controller.updateSummery,
          builder: (context, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _productHeader(),
                ...List.generate(
                  widget.controller.items.length,
                      (index) {
                    final item = widget.controller.items[index];
                    // _stateFor(item);
                    return _productRow(
                      index,
                      item,
                    );
                  },
                ),

                if (widget.controller.items.isEmpty)
                  _emptyProducts(),

                const SizedBox(height: 6),
              ],
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _productHeader() {
    return SizedBox(
      width: _productTableWidth,
      height: 36,
      child: Row(
        children: List.generate(
          _productHeaders.length,
              (index) {
            return _headerCell(
              _productHeaders[index],
              _productWidths[index],
            );
          },
        ),
      ),
    );
  }

  Widget _headerCell(
      String title,
      double width,
      ) {
    return Container(
      width: width,
      height: 36,
      decoration:  BoxDecoration(
        color: Color(0xffF8FAFC),
        border: Border(
          right: BorderSide(
            color: Color(0xffE2E8F0),
          ),
          bottom: BorderSide(
            color: Color(0xffE2E8F0),
          ),
          top: BorderSide(
              color: Color(0xffE2E8F0)),
          left:  BorderSide(
              color:title == "#"? Color(0xffE2E8F0): Colors.transparent),
        ),
      ),
      alignment:
      title == "Product" || title == "Brand"
          ? Alignment.centerLeft
          : Alignment.center,
      padding:
      const EdgeInsets.symmetric(horizontal: 10),
      child: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: textMedium,
        ),
      ),
    );
  }

  // ============================================================
  // PRODUCT ROW
  // ============================================================

  Widget _productRow(
      int index,
      PurchaseItem item,
      ) {
    final bool selected =
        selectedRow == index;

    return SizedBox(
      width: _productTableWidth,
      height: 30,
      child: GestureDetector(
        behavior:
        HitTestBehavior.opaque,
        onTap: () {
          if (selectedRow != index) {
            selectedRow = index;
            widget.controller.update();
          }
        },
        child: Row(
          children: [
            _gridTextCell(
              '#${index + 1}',
              _productWidths[0],
              alignment:
              Alignment.center,
              backgroundColor:
              selected
                  ? const Color(
                0xffEFF6FF,
              )
                  : Colors.white,
              textColor: textLight,
            ),

            _gridEditCell(
              item.brandController,
              _productWidths[1],
              hint: 'Brand',
              selected: selected,
            ),

            ProductAutoCompleteCell(
              item: item,
              width:  _productWidths[2],
              controller: widget.controller,
              callback: (String value){
                if(value.isNotEmpty) {
                  openCreateProductPopup(context, value, index);
                }},
            ),

            _tableCellCustomer(
              width: _productWidths[3],
              padding: EdgeInsets.zero,
              child: ListenableBuilder(listenable: productController,
                  builder: (context, _){
                    return SearchableCustomerDropdown<SizeModel>(
                        value: item.product?.size,
                        items: productController.sizeList,
                        onSearch: (String? value){
                          if(value!=null)
                          {
                            productController.getSizeList(value,);
                          }
                        },

                        displayString: (SizeModel item) {
                          return item.sizeName;
                        },

                        onSelect: (SizeModel? value){
                          if(value!=null)
                          {
                            if(item.product!=null)
                            {
                              item.product!.size = value;
                              productController.notifyListeners();
                            }
                          }
                        }
                    );
                  }),
            ),

            _tableCellCustomer(
              width: _productWidths[4],
              padding: EdgeInsets.zero,
              child: ListenableBuilder(listenable: productController,
                  builder: (context, _){
                    return SearchableCustomerDropdown<ColorModel>(
                        value: item.product?.color,
                        items: productController.colorList,

                        onSearch: (String? value){
                          if(value!=null)
                          {
                            productController.getCategoryList(value!, supplierId: widget.controller.selectSupplier!.id);
                          }
                        },

                        displayString: (ColorModel item) {
                          return item.colorName;
                        },

                        onSelect: (ColorModel? value){
                          if(value!=null)
                          {
                            if(item.product!=null)
                            {
                              item.product!.color = value;
                              productController.notifyListeners();
                            }

                          }
                        }
                    );
                  }),
            ),

            _gridNumberCell(
                item.quantityController,
                _productWidths[5],
                selected: selected,
                onChanged: (String value){
                  if(value.isNotEmpty)
                  {
                    if(item.product!=null)
                    {
                      item.product!.qty =value;
                    }
                    widget.controller.update();
                  }
                }
            ),

            _gridNumberCell(
                item.priceController,
                _productWidths[6],
                selected: selected,
                onChanged: (String value){
                  if(item.product==null && (item.product!.size==null || item.product!.color==null))
                  {
                    item.priceController.clear();
                    showMessage("Select Size and color", ToastType.info);
                    return;
                  }
                  if (value.isNotEmpty) {
                    item.setDiscountedAmount();
                    widget.controller.update();
                  }
                }
            ),

            _gridNumberCell(
              item.mrpRateController,
              _productWidths[7],
              selected: selected,
            ),

            _gridNumberCell(
              item.wholesaleRateController,
              _productWidths[8],
              selected: selected,
            ),

            _gridNumberCell(
              item.retailRateController,
              _productWidths[9],
              selected: selected,
            ),

            _gridTextCell(
              item.extraCharge.toStringAsFixed(2),
              _productWidths[10],
              alignment:
              Alignment.centerRight,
              bold: false,
              backgroundColor:
              selected
                  ? const Color(
                0xffEFF6FF,
              )
                  : Colors.white,
            ),


            _gridNumberCell(
                item.discountController,
                _productWidths[11],
                selected: selected,
                onChanged:(String value) {
                  if (value.isNotEmpty) {
                    item.setDiscountedAmount();
                    widget.controller.update();
                  }
                }
            ),

            _gridTextCell(
              item.getFinalPriceAfterDiscount.toStringAsFixed(2),
              _productWidths[12],
              alignment:
              Alignment.centerRight,
              bold: true,
              backgroundColor:
              selected
                  ? const Color(
                0xffEFF6FF,
              )
                  : Colors.white,
            ),

            _gridTextCell(
              item.getGST,
              _productWidths[13],
              alignment:
              Alignment.centerRight,
              bold: true,
              backgroundColor:
              selected
                  ? const Color(
                0xffEFF6FF,
              )
                  : Colors.white,
            ),

            _gridActionCell(
              index,
              selected,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TABLE CELL
  // ============================================================


  Widget _tableCellCustomer({
    required double width,
    required Widget child,
    Alignment alignment =
        Alignment.centerLeft,
    EdgeInsets padding =
    const EdgeInsets.symmetric(
      horizontal: 7,
    ),
  }) {
    return Container(
      width: width,
      height: 34,
      padding: padding,
      alignment: alignment,
      decoration:
      const BoxDecoration(
        border: Border(
          right: BorderSide(
            color:
            Color(0xffE2E8F0),
          ),
          bottom: BorderSide(
            color:
            Color(0xffE2E8F0),
          ),
        ),
      ),
      child: child,
    );
  }

  // ============================================================
  // ACTION CELL
  // ============================================================

  Widget _gridActionCell(
      int index,
      bool selected,
      ) {
    return Container(
      width: _productWidths[14],
      height: 34,
      decoration:
      BoxDecoration(
        color: selected
            ? const Color(
          0xffEFF6FF,
        )
            : Colors.white,
        border:
        const Border(
          right: BorderSide(
            color:
            Color(0xffE5E7EB),
          ),
          bottom: BorderSide(
            color:
            Color(0xffE5E7EB),
          ),
        ),
      ),
      alignment: Alignment.center,
      child: IconButton(
        padding: EdgeInsets.zero,
        constraints:
        const BoxConstraints(
          minWidth: 28,
          minHeight: 28,
        ),
        splashRadius: 15,
        onPressed: () {

          widget.controller.removeItem(index);

          if (selectedRow == index) {
            selectedRow = -1;
          } else if (selectedRow > index) {
            selectedRow--;
          }

          widget.controller.update();
        },
        icon: const Icon(
          Icons.delete_outline_rounded,
          size: 17,
          color:
          Color(0xffEF4444),
        ),
        tooltip: 'Remove',
      ),
    );
  }

  // ============================================================
  // EDIT CELL
  // ============================================================

  Widget _gridEditCell(
      TextEditingController controller,
      double width, {
        String? hint,
        bool selected = false,
      }) {
    return Container(
      width: width,
      height: 34,
      decoration:
      BoxDecoration(
        color: selected
            ? const Color(
          0xffEFF6FF,
        )
            : Colors.white,
        border:
        const Border(
          right: BorderSide(
            color:
            Color(0xffE5E7EB),
          ),
          bottom: BorderSide(
            color:
            Color(0xffE5E7EB),
          ),
        ),
      ),
      child: TextField(
        controller: controller,
        maxLines: 1,
        textAlignVertical:
        TextAlignVertical.center,
        style:
        const TextStyle(
          fontSize: 11,
          color: textDark,
        ),
        decoration:
        InputDecoration(
          hintText: hint,
          hintStyle:
          const TextStyle(
            fontSize: 11,
            color:
            Color(0xffCBD5E1),
          ),
          border:
          InputBorder.none,
          isDense: true,
          contentPadding:
          const EdgeInsets.symmetric(
            horizontal: 9,
            vertical: 7,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // NUMBER CELL
  // ============================================================

  Widget _gridNumberCell(
      TextEditingController controller,
      double width, {
        bool selected = false,
        ValueChanged<String>? onChanged
      }) {
    return Container(
      width: width,
      height: 34,
      decoration:
      BoxDecoration(
        color: selected
            ? const Color(
          0xffEFF6FF,
        )
            : Colors.white,
        border:
        const Border(
          right: BorderSide(
            color:
            Color(0xffE5E7EB),
          ),
          bottom: BorderSide(
            color:
            Color(0xffE5E7EB),
          ),
        ),
      ),
      child: TextField(
        controller: controller,
        maxLines: 1,
        textAlign:
        TextAlign.right,
        textAlignVertical:
        TextAlignVertical.center,
        keyboardType:
        const TextInputType
            .numberWithOptions(
          decimal: true,
        ),
        style:
        const TextStyle(
          fontSize: 11,
          color: textDark,
        ),
        decoration:
        const InputDecoration(
          border:
          InputBorder.none,
          isDense: true,
          contentPadding:
          EdgeInsets.symmetric(
            horizontal: 9,
            vertical: 7,
          ),
        ),

        onChanged: (String? value){
          if(onChanged!=null)
          {
            debouncer.run(() {
              onChanged(value!);
            });
          }
        },
      ),
    );
  }

  // ============================================================
  // TEXT CELL
  // ============================================================

  Widget _gridTextCell(
      String text,
      double width, {
        Alignment alignment =
            Alignment.centerLeft,
        bool bold = false,
        Color? backgroundColor,
        Color? textColor,
      }) {
    return Container(
      width: width,
      height: 34,
      decoration:
      BoxDecoration(
        color:
        backgroundColor ??
            Colors.white,
        border:
        const Border(
          bottom: BorderSide(
            color:
            Color(0xffE5E7EB),
          ),
          // left: BorderSide(
          //     color: Color(0xffE2E8F0)
          // ),
          right:  BorderSide(
              color: Color(0xffE2E8F0)
          ),
        ),
      ),
      padding:
      const EdgeInsets.symmetric(
        horizontal: 9,
      ),
      alignment: alignment,
      child: Text(
        text,
        maxLines: 1,
        overflow:
        TextOverflow.ellipsis,
        style:
        TextStyle(
          fontSize: 11,
          fontWeight:
          bold
              ? FontWeight.w700
              : FontWeight.w500,
          color:
          textColor ??
              textDark,
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _emptyProducts() {
    return const SizedBox(
      height: 130,
      child: Center(
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              Icons
                  .inventory_2_outlined,
              size: 34,
              color:
              Color(0xffCBD5E1),
            ),
            SizedBox(height: 8),
            Text(
              'No products added',
              style:
              TextStyle(
                fontSize: 13,
                color:
                Color(0xff64748B),
                fontWeight:
                FontWeight.w600,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Click "Add Product" to start',
              style:
              TextStyle(
                fontSize: 11,
                color:
                Color(0xff94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _sectionTitle(
      IconData icon,
      String title,
      ) {
    return Row(
      children: [
        Container(
          height: 26,
          width: 26,
          decoration:
          BoxDecoration(
            color:
            const Color(
              0xffEAF2FF,
            ),
            borderRadius:
            BorderRadius.circular(
              9,
            ),
          ),
          child: Icon(
            icon,
            size: 14,
            color: blue,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style:
          const TextStyle(
            fontSize: 14,
            fontWeight:
            FontWeight.w600,
            color:
            Color(0xff1E293B),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // CARD
  // ============================================================

  Widget _card({
    required Widget child,
  }) {
    return Container(
      decoration:
      BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(
          14,
        ),
        border: Border.all(
          color:
          const Color(
            0xffE6EBF2,
          ),
        ),
        boxShadow:
        const [
          BoxShadow(
            color:
            Color(0x08000000),
            blurRadius: 15,
            offset:
            Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

