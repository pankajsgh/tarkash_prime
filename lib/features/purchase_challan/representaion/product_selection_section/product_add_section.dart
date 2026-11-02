import 'package:calculation_panel/features/purchase_challan/controller/product_add_controller.dart';
import 'package:calculation_panel/features/purchase_challan/controller/product_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../components/custome_dropdown_widget.dart';
import '../../model/category_model.dart';
import '../../model/color_model.dart';
import '../../model/hsn_model.dart';
import '../../model/party_model.dart';
import '../../model/size_model.dart';
import '../../model/sub_cat_model.dart';
import '../../model/supplier_model.dart';

class CreateProductPopup extends StatefulWidget {
  final String supplierId;
  final Party supplier;
  final ProductController productController;
  final String name;

  const CreateProductPopup({
    super.key,
    required this.supplierId,
    required this.supplier,
    required this.productController,
    required this.name,
  });

  @override
  State<CreateProductPopup> createState() => _CreateProductPopupState();
}

class _CreateProductPopupState extends State<CreateProductPopup> {
  late final CreateProductController controller;

// Top field focus nodes
  late final FocusNode categoryFocusNode;
  late final FocusNode subCategoryFocusNode;
  late final FocusNode brandFocusNode;
  late final FocusNode hsnFocusNode;
  late final FocusNode productNameFocusNode;
  late final FocusNode supplierProductNameFocusNode;

// Attribute row focus nodes
  final Map<int, FocusNode> colorFocusNodes = {};
  final Map<int, FocusNode> qtyFocusNodes = {};
  final Map<int, FocusNode> purchasePriceFocusNodes = {};

  FocusNode _getColorFocusNode(int index) {
    return colorFocusNodes.putIfAbsent(index, () => FocusNode());
  }

  FocusNode _getQtyFocusNode(int index) {
    return qtyFocusNodes.putIfAbsent(index, () => FocusNode());
  }

  FocusNode _getPurchasePriceFocusNode(int index) {
    return purchasePriceFocusNodes.putIfAbsent(index, () => FocusNode());
  }

  @override
  void initState() {
    super.initState();

    categoryFocusNode = FocusNode();
    subCategoryFocusNode = FocusNode();
    brandFocusNode = FocusNode();
    hsnFocusNode = FocusNode();
    productNameFocusNode = FocusNode();
    supplierProductNameFocusNode = FocusNode();

    controller = CreateProductController()..generateProductName();

    controller.supplierNameController.text = widget.name;

    controller.initialize(
      supplier: widget.supplier,
      supplierId: widget.supplierId,
      hsnList: widget.productController.hsnList,
      sizeList: widget.productController.sizeList,
      colorList: widget.productController.colorList,
    );
  }

  @override
  void dispose() {
    categoryFocusNode.dispose();
    subCategoryFocusNode.dispose();
    brandFocusNode.dispose();
    hsnFocusNode.dispose();
    productNameFocusNode.dispose();
    supplierProductNameFocusNode.dispose();

    for (final node in colorFocusNodes.values) {
      node.dispose();
    }

    for (final node in qtyFocusNodes.values) {
      node.dispose();
    }

    for (final node in purchasePriceFocusNodes.values) {
      node.dispose();
    }

    controller.dispose();
    super.dispose();
  }

// ============================================================
// FOCUS MANAGEMENT
// ============================================================

  void _openNextDropdown(FocusNode nextFocusNode) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      nextFocusNode.requestFocus();
    });
  }

  void _moveToNextField(FocusNode nextFocusNode) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      nextFocusNode.requestFocus();
    });
  }

// ============================================================
// BUILD
// ============================================================

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 40,
        vertical: 30,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 1180,
          maxHeight: size.height > 700 ? 560 : size.height - 60,
          minWidth: 850,
        ),
        child: ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            return Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildContent()),
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

  Widget _buildHeader() {
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Color(0xff990044),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.14),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Create New Product',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          _headerCloseButton(),
        ],
      ),
    );
  }

  Widget _headerCloseButton() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        borderRadius: BorderRadius.circular(7),
        onTap: controller.isSaving
            ? null
            : () {
          Navigator.of(context).pop();
        },
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.12),
            borderRadius: BorderRadius.circular(7),
          ),
          child: const Icon(
            Icons.close,
            color: Colors.white,
            size: 19,
          ),
        ),
      ),
    );
  }

// ============================================================
// CONTENT
// ============================================================

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 22, 28, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            icon: Icons.info_outline,
            title: 'Product Information',
          ),
          const SizedBox(height: 12),
          _buildTopFields(),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildSectionTitle(
                icon: Icons.tune,
                title: 'Item Attributes',
              ),
              const SizedBox(width: 10),
              _variantCount(),
              const Spacer(),
              _addAttributeButton(),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(child: _buildAttributeTable()),
          const SizedBox(height: 16),
          _buildBottomButtons(),
        ],
      ),
    );
  }

// ============================================================
// SECTION TITLE
// ============================================================

  Widget _buildSectionTitle({
    required IconData icon,
    required String title,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: const Color(0xff990044),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xff1E293B),
          ),
        ),
      ],
    );
  }

  Widget _variantCount() {
    final count = controller.attributes.length;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: const Color(0xffF1F5F9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$count ${count == 1 ? 'variant' : 'variants'}',
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Color(0xff64748B),
        ),
      ),
    );
  }

// ============================================================
// TOP FIELDS
// ============================================================

  Widget _buildTopFields() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _dropdownCategoryField(
                label: 'Category',
                value: controller.selectedCategory,
                onChanged: controller.setCategory,
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: _dropdownSubCategoryField(
                label: 'Sub-Category',
                value: controller.selectedSubCategory,
                onChanged: controller.setSubCategory,
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: _dropdownBrandField(
                label: 'Brand',
                value: controller.selectedBrand,
                items: controller.brands,
                onChanged: controller.setBrand,
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: _dropdownHsnField(
                label: 'HSN',
                value: controller.selectedHsn,
                items: controller.filteredHsnCodes,
                onSelect: controller.setHsn,
                onChanged: (value) {
                  controller.searchHsn(value);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _textField(
                label: 'Product Name',
                controller: controller.productNameController,
                hint: 'Enter product name',
                focusNode: productNameFocusNode,
                onSubmitted: (_) {
                  _moveToNextField(supplierProductNameFocusNode);
                },
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: _textField(
                label: 'Supplier Product Name',
                controller: controller.supplierNameController,
                hint: 'Enter supplier product name',
                focusNode: supplierProductNameFocusNode,
              ),
            ),
          ],
        ),
      ],
    );
  }

// ============================================================
// TEXT FIELD
// ============================================================

  Widget _textField({
    required String label,
    required TextEditingController controller,
    String? hint,
    FocusNode? focusNode,
    ValueChanged<String>? onSubmitted,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label),
        const SizedBox(height: 7),
        TextField(
          controller: controller,
          focusNode: focusNode,
          onSubmitted: onSubmitted,
          textInputAction: onSubmitted != null
              ? TextInputAction.next
              : TextInputAction.done,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xff1E293B),
          ),
          decoration: _inputDecoration(hint: hint),
        ),
      ],
    );
  }

  Widget _fieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Color(0xff475569),
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontSize: 12,
        color: Color(0xff94A3B8),
      ),
      filled: true,
      fillColor: const Color(0xffF8FAFC),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 12,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(
          color: Color(0xffE2E8F0),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(
          color: Color(0xffE2E8F0),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(
          color: Color(0xff990044),
          width: 1.2,
        ),
      ),
    );
  }

// ============================================================
// CATEGORY
// ============================================================

  Widget _dropdownCategoryField({
    required String label,
    required CategoryModel? value,
    required ValueChanged<CategoryModel?> onChanged,
  }) {


    return _dropdownWrapper(
      label: label,
      child: SearchableCustomerDropdown<CategoryModel>(
        value: value,
        items: controller.categoryList,
        focusNode: categoryFocusNode,
        borderColor: const Color(0xffE2E8F0),
        onSearch: (value) {
          controller.getCategoryList(
            value ?? '',
            supplierId: widget.supplierId,
          );
        },
        displayString: (item) => item.category,
        onSelect: (value) {
          onChanged(value);

          if (value != null) {
            _openNextDropdown(subCategoryFocusNode);
          }
        },
      ),
    );
  }

// ============================================================
// SUB CATEGORY
// ============================================================

  Widget _dropdownSubCategoryField({
    required String label,
    required SubCategoryModel? value,
    required ValueChanged<SubCategoryModel?> onChanged,
  }) {
    return _dropdownWrapper(
      label: label,
      child: SearchableCustomerDropdown<SubCategoryModel>(
        value: value,
        items: controller.subCategoryList,
        focusNode: subCategoryFocusNode,
        borderColor: const Color(0xffE2E8F0),
        onSearch: (value) {
          controller.getSubCategoryList(value ?? '');
        },
        displayString: (item) => item.subcategory,
        onSelect: (value) {
          onChanged(value);

          if (value != null) {
            _openNextDropdown(brandFocusNode);
          }
        },
      ),
    );
  }

// ============================================================
// BRAND
// ============================================================

  Widget _dropdownBrandField({
    required String label,
    required BrandItem? value,
    required List<BrandItem> items,
    required ValueChanged<BrandItem?> onChanged,
  }) {
    return _dropdownWrapper(
      label: label,
      child: SearchableCustomerDropdown<BrandItem>(
        value: value,
        items: items,
        focusNode: brandFocusNode,
        borderColor: const Color(0xffE2E8F0),
        onSearch: (_) {},
        displayString: (item) => item.brand,
        onSelect: (value) {
          onChanged(value);

          if (value != null) {
            _openNextDropdown(hsnFocusNode);
          }
        },
      ),
    );
  }

// ============================================================
// HSN
// ============================================================

  Widget _dropdownHsnField({
    required String label,
    required HsnModel? value,
    required List<HsnModel> items,
    required ValueChanged<String> onChanged,
    required ValueChanged<HsnModel?> onSelect,
  }) {
    return _dropdownWrapper(
      label: label,
      child: SearchableCustomerDropdown<HsnModel>(
        value: value,
        items: items,
        focusNode: hsnFocusNode,
        borderColor: const Color(0xffE2E8F0),
        onSearch: onChanged,
        displayString: (item) => item.hsnCode,
        onSelect: (value) {
          onSelect(value);

          if (value != null) {
            _openNextDropdown(productNameFocusNode);
          }
        },
      ),
    );
  }

  Widget _dropdownWrapper({
    required String label,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label),
        const SizedBox(height: 7),
        SizedBox(
          height: 42,
          child: child,
        ),
      ],
    );
  }

// ============================================================
// ATTRIBUTE TABLE
// ============================================================

  Widget _buildAttributeTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color(0xffE2E8F0),
        ),
        borderRadius: BorderRadius.circular(7),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _buildTableHeader(),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: controller.attributes.length,
              itemBuilder: (context, index) {
                return _buildAttributeRow(
                  index,
                  controller.attributes[index],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      height: 32,
      decoration: const BoxDecoration(
        color: Color(0xffF8FAFC),
      ),
      child: const Row(
        children: [
          _HeaderCell(title: 'SIZE', flex: 3),
          _HeaderCell(title: 'COLOR', flex: 3),
          _HeaderCell(title: 'QTY', flex: 1),
          _HeaderCell(title: 'PURCHASE PRICE', flex: 2),
          _HeaderCell(title: '', flex: 1),
        ],
      ),
    );
  }

  Widget _buildAttributeRow(int index, ProductAttribute item) {
    final isLast = index == controller.attributes.length - 1;

    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: index.isEven ? Colors.white : const Color(0xffFAFBFC),
        border: Border(
          bottom: isLast
              ? BorderSide.none
              : const BorderSide(color: Color(0xffEEF2F7)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: _sizeField(index, item),
          ),
          Expanded(
            flex: 3,
            child: _colorField(index, item),
          ),
          Expanded(
            flex: 1,
            child: _qtyTextField(
              initialValue: item.quantity,
              hint: 'Qty',
              focusNode: _getQtyFocusNode(index),
              onChanged: (value) {
                controller.setQuantity(index, value);
              },
              onSubmitted: (_) {
                _moveToNextField(_getPurchasePriceFocusNode(index));
              },
            ),
          ),
          Expanded(
            flex: 2,
            child: _priceTextField(
              initialValue: item.purchasePrice,
              hint: '₹ 0.00',
              focusNode: _getPurchasePriceFocusNode(index),
              onChanged: (value) {
                controller.setPurchasePrice(index, value);
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(child: _deleteButton(index)),
          ),
        ],
      ),
    );
  }

// ============================================================
// SIZE
// ============================================================

  Widget _sizeField(int index, ProductAttribute item) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 8,
      ),
      child: SearchableCustomerDropdown<SizeModel>(
        value: item.size,
        items: controller.sizes,
        borderColor: const Color(0xffE2E8F0),
        onSearch: (_) {},
        displayString: (item) => item.sizeName,
        onSelect: (value) {
          controller.setSize(index, value);

          if (value != null) {
            _openNextDropdown(_getColorFocusNode(index));
          }
        },
      ),
    );
  }

// ============================================================
// COLOR
// ============================================================

  Widget _colorField(int index, ProductAttribute item) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 8,
      ),
      child: SearchableCustomerDropdown<ColorModel>(
        value: item.color,
        items: controller.colors,
        focusNode: _getColorFocusNode(index),
        borderColor: const Color(0xffE2E8F0),
        onSearch: (_) {},
        displayString: (item) => item.colorName,
        onSelect: (value) {
          controller.setColor(index, value);

          if (value != null) {
            _moveToNextField(_getQtyFocusNode(index));
          }
        },
      ),
    );
  }

// ============================================================
// QUANTITY
// ============================================================

  Widget _qtyTextField({
    required String initialValue,
    required String hint,
    required ValueChanged<String> onChanged,
    FocusNode? focusNode,
    ValueChanged<String>? onSubmitted,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 8,
      ),
      child: TextFormField(
        initialValue: initialValue,
        focusNode: focusNode,
        onChanged: onChanged,
        onFieldSubmitted: onSubmitted,
        textInputAction: TextInputAction.next,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: _tableInputDecoration(hint),
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Color(0xff334155),
        ),
      ),
    );
  }

// ============================================================
// PURCHASE PRICE
// ============================================================

  Widget _priceTextField({
    required String initialValue,
    required String hint,
    required ValueChanged<String> onChanged,
    FocusNode? focusNode,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 8,
      ),
      child: TextFormField(
        initialValue: initialValue,
        focusNode: focusNode,
        onChanged: onChanged,
        textInputAction: TextInputAction.done,
        textAlign: TextAlign.right,
        keyboardType: const TextInputType.numberWithOptions(
          decimal: true,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.allow(
            RegExp(r'^\d*\.?\d*'),
          ),
        ],
        decoration: _tableInputDecoration(hint),
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Color(0xff334155),
        ),
      ),
    );
  }

  InputDecoration _tableInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontSize: 12,
        color: Color(0xff94A3B8),
      ),
      filled: true,
      fillColor: const Color(0xffF8FAFC),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 10,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: const BorderSide(
          color: Color(0xffE2E8F0),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: const BorderSide(
          color: Color(0xffE2E8F0),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: const BorderSide(
          color: Color(0xff990044),
          width: 1.2,
        ),
      ),
    );
  }

// ============================================================
// DELETE
// ============================================================

  Widget _deleteButton(int index) {
    final disabled = controller.attributes.length <= 1;

    return Tooltip(
      message: disabled
          ? 'At least one attribute is required'
          : 'Remove attribute',
      child: IconButton(
        onPressed: disabled
            ? null
            : () {
          controller.removeAttribute(index);
        },
        icon: const Icon(
          Icons.delete_outline,
          size: 19,
        ),
        color: const Color(0xffDC2626),
        disabledColor: const Color(0xffCBD5E1),
        splashRadius: 20,
      ),
    );
  }

// ============================================================
// ADD ATTRIBUTE
// ============================================================

  Widget _addAttributeButton() {
    return OutlinedButton.icon(
      onPressed: controller.isSaving ? null : controller.addAttribute,
      icon: const Icon(Icons.add, size: 17),
      label: const Text('Add Attribute'),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xff990044),
        disabledForegroundColor: const Color(0xffCBD5E1),
        side: const BorderSide(color: Color(0xff990044)),
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 4,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }

// ============================================================
// BOTTOM BUTTONS
// ============================================================

  Widget _buildBottomButtons() {
    return Row(
      children: [
        const Icon(
          Icons.info_outline,
          size: 15,
          color: Color(0xff94A3B8),
        ),
        const SizedBox(width: 6),
        const Text(
          'Make sure all product details are correct before creating.',
          style: TextStyle(
            fontSize: 11,
            color: Color(0xff64748B),
          ),
        ),
        const Spacer(),
        OutlinedButton(
          onPressed: controller.isSaving
              ? null
              : () {
            Navigator.of(context).pop();
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xff475569),
            disabledForegroundColor: const Color(0xffCBD5E1),
            side: const BorderSide(color: Color(0xffCBD5E1)),
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 13,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 10),
        ElevatedButton.icon(
          onPressed: controller.isSaving ? null : _save,
          icon: controller.isSaving
              ? const SizedBox(
            width: 17,
            height: 17,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.white,
              ),
            ),
          )
              : const Icon(Icons.check, size: 17),
          label: Text(
            controller.isSaving ? 'Creating...' : 'Create Product',
          ),
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: const Color(0xff990044),
            disabledBackgroundColor: const Color(0xffC47A9D),
            foregroundColor: Colors.white,
            disabledForegroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 13,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
      ],
    );
  }

// ============================================================
// SAVE FLOW
// ============================================================

  Future<void> _save() async {
    if (controller.isSaving) return;

    FocusScope.of(context).unfocus();

    final validationMessage = controller.validate();

    if (validationMessage != null) {
      _showError(validationMessage);
      return;
    }

    final success = await controller.saveProduct();

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop(controller.toJson());
      return;
    }

    _showError(
      controller.errorMessage.isNotEmpty
          ? controller.errorMessage
          : 'Unable to create product. Please try again.',
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xffDC2626),
          content: Text(message),
        ),
      );
  }
}

// ============================================================
// HEADER CELL
// ============================================================

class _HeaderCell extends StatelessWidget {
  final String title;
  final int flex;

  const _HeaderCell({
    required this.title,
    required this.flex,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xff64748B),
              letterSpacing: .5,
            ),
          ),
        ),
      ),
    );
  }
}
