import 'package:calculation_panel/features/product_list/view/product_parm_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/routes/routes.dart';
import '../../../core/vars/global_vars.dart';
import '../../purchase_challan/model/product_model.dart';
import '../controller/product_list_controller.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({
    super.key,
  });

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late final ProductListController controller;

  final ScrollController scrollController = ScrollController();

  bool isShowPram = false;
  String selectedProduct = '';

  String barcodePrefix = '';
  String productPrefix = '';

  @override
  void initState() {
    super.initState();

    GlobalVars.globalRoutes = Routes.productListScreen;
    controller = ProductListController();

    scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      controller.fetchProducts(
        refresh: true,
      );
    });

    _loadBarcodeSettings();
  }

  // ============================================================
  // LOAD SETTINGS
  // ============================================================

  Future<void> _loadBarcodeSettings() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      barcodePrefix = prefs.getString(barcodePrefixKey) ?? 'PRD';

      productPrefix = prefs.getString(productPrefixKey) ?? 'BL';
    });
  }

  // ============================================================
  // SCROLL
  // ============================================================

  void _onScroll() {
    if (!scrollController.hasClients) {
      return;
    }

    final position = scrollController.position;

    if (position.pixels >=
        position.maxScrollExtent - 250) {
      controller.loadMore();
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();

    controller.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    if (isShowPram) {
      return ProductParameterScreen(
        productId: selectedProduct,
        callBack: () {
          if (!mounted) return;

          setState(() {
            isShowPram = false;
            selectedProduct = '';
          });
        },
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xffF5F6F8),
      body: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          return Column(
            children: [
              _buildHeader(),
              _buildToolbar(),
              Expanded(
                child: _buildBody(),
              ),
              _buildFooter(),
            ],
          );
        },
      ),
    );
  }

  // ============================================================
  // SAVE BARCODE PREFIX
  // ============================================================

  Future<void> _saveBarcodePrefix(
      String prefix,
      ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      barcodePrefixKey,
      prefix,
    );

    if (!mounted) return;

    setState(() {
      barcodePrefix = prefix;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Barcode prefix saved: $prefix',
        ),
        backgroundColor: const Color(0xff16A34A),
      ),
    );
  }

  // ============================================================
  // SAVE PRODUCT PREFIX
  // ============================================================

  Future<void> _saveProductPrefix(
      String prefix,
      ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      productPrefixKey,
      prefix,
    );

    if (!mounted) return;

    setState(() {
      productPrefix = prefix;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Product prefix saved: $prefix',
        ),
        backgroundColor: const Color(0xff16A34A),
      ),
    );
  }

  // ============================================================
  // SAVE BOTH PREFIXES
  // ============================================================

  Future<void> _savePrefixes({
    required String product,
    required String barcode,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      productPrefixKey,
      product,
    );

    await prefs.setString(
      barcodePrefixKey,
      barcode,
    );

    if (!mounted) return;

    setState(() {
      productPrefix = product;
      barcodePrefix = barcode;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Product settings saved successfully',
        ),
        backgroundColor: Color(0xff16A34A),
      ),
    );
  }

  // ============================================================
  // SETTINGS
  // ============================================================

  Future<void> _openSettings() async {
    final TextEditingController productController =
    TextEditingController(
      text: productPrefix,
    );

    final TextEditingController barcodeController =
    TextEditingController(
      text: barcodePrefix,
    );

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(
                Icons.settings_outlined,
                size: 21,
                color: Color(0xff990044),
              ),
              SizedBox(width: 9),
              Text(
                'Product Settings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 380,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                // ==================================================
                // PRODUCT PREFIX
                // ==================================================

                const Text(
                  'Product Prefix',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff334155),
                  ),
                ),

                const SizedBox(height: 7),

                TextField(
                  controller: productController,
                  autofocus: true,
                  textCapitalization:
                  TextCapitalization.characters,
                  inputFormatters: [
                    UpperCaseTextFormatter(),
                    FilteringTextInputFormatter.allow(
                      RegExp(r'[A-Z]'),
                    ),
                  ],
                  maxLength: 10,
                  decoration: _prefixDecoration(
                    hintText: 'Example: BL',
                    icon: Icons.inventory_2_outlined,
                  ),
                ),

                const SizedBox(height: 14),

                // ==================================================
                // BARCODE PREFIX
                // ==================================================

                const Text(
                  'Barcode Prefix',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff334155),
                  ),
                ),

                const SizedBox(height: 7),

                TextField(
                  controller: barcodeController,
                  textCapitalization:
                  TextCapitalization.characters,
                  inputFormatters: [
                    UpperCaseTextFormatter(),
                    FilteringTextInputFormatter.allow(
                      RegExp(r'[A-Z]'),
                    ),
                  ],
                  maxLength: 10,
                  decoration: _prefixDecoration(
                    hintText: 'Example: PRD',
                    icon: Icons.qr_code_2,
                  ),
                ),
                const SizedBox(height: 12),


                MultipleBarcodeToggle(),

                const SizedBox(height: 8),

                // ==================================================
                // EXAMPLE
                // ==================================================

                const Text(
                  'Example',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xff94A3B8),
                  ),
                ),

                const SizedBox(height: 5),

                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: productController,
                  builder: (
                      context,
                      productValue,
                      child,
                      ) {
                    return ValueListenableBuilder<
                        TextEditingValue>(
                      valueListenable: barcodeController,
                      builder: (
                          context,
                          barcodeValue,
                          child,
                          ) {
                        final product =
                        productValue.text.trim().isEmpty
                            ? 'BL'
                            : productValue.text
                            .trim()
                            .toUpperCase();

                        final barcode =
                        barcodeValue.text.trim().isEmpty
                            ? 'PRD'
                            : barcodeValue.text
                            .trim()
                            .toUpperCase();

                        return Container(
                          width: double.infinity,
                          padding:
                          const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color:
                            const Color(0xffF8FAFC),
                            borderRadius:
                            BorderRadius.circular(6),
                            border: Border.all(
                              color:
                              const Color(0xffE2E8F0),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Product: ${product}000001',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight:
                                  FontWeight.w600,
                                  color:
                                  Color(0xff334155),
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Barcode: ${barcode}000001',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight:
                                  FontWeight.w600,
                                  color:
                                  Color(0xff334155),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'Cancel',
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                const Color(0xff990044),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final product =
                productController.text
                    .trim()
                    .toUpperCase();

                final barcode =
                barcodeController.text
                    .trim()
                    .toUpperCase();

                if (product.isEmpty) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please enter product prefix',
                      ),
                    ),
                  );

                  return;
                }

                if (barcode.isEmpty) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please enter barcode prefix',
                      ),
                    ),
                  );

                  return;
                }

                Navigator.pop(
                  dialogContext,
                  {
                    'product': product,
                    'barcode': barcode,
                  },
                );
              },
              child: const Text(
                'Save',
              ),
            ),
          ],
        );
      },
    );

    productController.dispose();
    barcodeController.dispose();

    if (result == null) {
      return;
    }

    final product =
        result['product']?.trim() ?? '';

    final barcode =
        result['barcode']?.trim() ?? '';

    if (product.isEmpty || barcode.isEmpty) {
      return;
    }

    await _savePrefixes(
      product: product,
      barcode: barcode,
    );
  }

  // ============================================================
  // PREFIX INPUT DECORATION
  // ============================================================

  InputDecoration _prefixDecoration({
    required String hintText,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: Icon(
        icon,
        size: 19,
      ),
      counterText: '',
      filled: true,
      fillColor: const Color(0xffF8FAFC),
      contentPadding:
      const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 11,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: const BorderSide(
          color: Color(0xffE2E8F0),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: const BorderSide(
          color: Color(0xffE2E8F0),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: const BorderSide(
          color: Color(0xff990044),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(
        horizontal: 22,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xffE5E7EB),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color:
              const Color(0xff990044)
                  .withOpacity(.08),
              borderRadius:
              BorderRadius.circular(7),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              size: 18,
              color: Color(0xff990044),
            ),
          ),

          const SizedBox(width: 11),

          const Text(
            'Products',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xff1E293B),
            ),
          ),

          const SizedBox(width: 9),

          _countBadge(),

          const Spacer(),

          // ======================================================
          // PRODUCT PREFIX
          // ======================================================

          if (productPrefix.isNotEmpty)
            _prefixBadge(
              icon: Icons.inventory_2_outlined,
              value: productPrefix,
            ),

          const SizedBox(width: 6),

          // ======================================================
          // BARCODE PREFIX
          // ======================================================

          if (barcodePrefix.isNotEmpty)
            _prefixBadge(
              icon: Icons.qr_code_2,
              value: barcodePrefix,
            ),

          const SizedBox(width: 5),

          // ======================================================
          // SETTINGS
          // ======================================================

          IconButton(
            tooltip: 'Settings',
            onPressed: _openSettings,
            icon: const Icon(
              Icons.settings_outlined,
              size: 20,
              color: Color(0xff475569),
            ),
          ),

          // ======================================================
          // REFRESH
          // ======================================================

          _refreshButton(),
        ],
      ),
    );
  }

  Widget _prefixBadge({
    required IconData icon,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: const Color(0xffF8FAFC),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: const Color(0xffE2E8F0),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: const Color(0xff64748B),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xff475569),
            ),
          ),
        ],
      ),
    );
  }

  Widget _countBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: const Color(0xffF1F5F9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '${controller.totalData}',
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Color(0xff64748B),
        ),
      ),
    );
  }

  Widget _refreshButton() {
    return IconButton(
      tooltip: 'Refresh',
      onPressed: controller.isLoading
          ? null
          : controller.refresh,
      icon: controller.isLoading
          ? const SizedBox(
        width: 17,
        height: 17,
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      )
          : const Icon(
        Icons.refresh,
        size: 20,
      ),
    );
  }

  // ============================================================
  // TOOLBAR
  // ============================================================

  Widget _buildToolbar() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(
        horizontal: 22,
        vertical: 10,
      ),
      color: Colors.white,
      child: Row(
        children: [
          SizedBox(
            width: 330,
            height: 40,
            child: TextField(
              controller:
              controller.searchController,
              style: const TextStyle(
                fontSize: 13,
              ),
              decoration: InputDecoration(
                hintText:
                'Search product, supplier, HSN...',
                hintStyle: const TextStyle(
                  fontSize: 12,
                  color: Color(0xff94A3B8),
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  size: 19,
                  color: Color(0xff64748B),
                ),
                suffixIcon: controller
                    .searchController
                    .text
                    .isNotEmpty
                    ? IconButton(
                  onPressed:
                  controller.clearSearch,
                  icon: const Icon(
                    Icons.close,
                    size: 17,
                  ),
                )
                    : null,
                filled: true,
                fillColor:
                const Color(0xffF8FAFC),
                contentPadding:
                const EdgeInsets.symmetric(
                  horizontal: 12,
                ),
                border: _searchBorder(),
                enabledBorder:
                _searchBorder(),
                focusedBorder:
                _searchFocusedBorder(),
              ),
            ),
          ),

          const Spacer(),

          if (controller.isLoadingMore)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
        ],
      ),
    );
  }

  OutlineInputBorder _searchBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(
        color: Color(0xffE2E8F0),
      ),
    );
  }

  OutlineInputBorder _searchFocusedBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(
        color: Color(0xff990044),
      ),
    );
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget _buildBody() {
    if (controller.isLoading &&
        controller.products.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (controller.errorMessage.isNotEmpty &&
        controller.products.isEmpty) {
      return _buildError();
    }

    if (controller.products.isEmpty) {
      return _buildEmpty();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        22,
        0,
        22,
        12,
      ),
      child: _buildTable(),
    );
  }

  // ============================================================
  // TABLE
  // ============================================================

  Widget _buildTable() {
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
            child: Scrollbar(
              controller: scrollController,
              thumbVisibility: true,
              interactive: true,
              notificationPredicate:
                  (notification) {
                return notification.metrics.axis ==
                    Axis.vertical;
              },
              child: ListView.builder(
                controller: scrollController,
                physics:
                const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount:
                controller.products.length +
                    (controller.isLoadingMore
                        ? 1
                        : 0),
                itemBuilder:
                    (context, index) {
                  if (index >=
                      controller.products.length) {
                    return _buildLoadingRow();
                  }

                  return _buildProductRow(
                    controller.products[index],
                    index,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TABLE HEADER
  // ============================================================

  Widget _buildTableHeader() {
    return Container(
      height: 38,
      color: const Color(0xffF8FAFC),
      child: Row(
        children: [
          _headerCell('ID', 1),
          _headerCell('PRODUCT', 3),
          _headerCell('SUPPLIER ID', 2),
          _headerCell('SUPPLIER', 3),
          _headerCell(
            'SUPPLIER PRODUCT',
            3,
          ),
          _headerCell('CATEGORY', 2),
          _headerCell(
            'SUB CATEGORY',
            3,
          ),
          _headerCell('HSN', 2),
          _headerCell('BRAND', 2),
          _headerCell('CREATED', 3),
          _headerCell('UPDATED', 3),
          _headerCell('ACTIONS', 2),
        ],
      ),
    );
  }

  Widget _headerCell(
      String title,
      int flex,
      ) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding:
        const EdgeInsets.symmetric(
          horizontal: 10,
        ),
        child: Align(
          alignment:
          Alignment.centerLeft,
          child: Text(
            title,
            maxLines: 1,
            overflow:
            TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 9,
              fontWeight:
              FontWeight.w700,
              letterSpacing: .4,
              color:
              Color(0xff64748B),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PRODUCT ROW
  // ============================================================

  Widget _buildProductRow(
      ProductModelItem item,
      int index,
      ) {
    return Container(
      constraints:
      const BoxConstraints(
        minHeight: 54,
      ),
      decoration: BoxDecoration(
        color: index.isEven
            ? Colors.white
            : const Color(0xffFCFCFD),
        border: const Border(
          bottom: BorderSide(
            color: Color(0xffEEF2F7),
          ),
        ),
      ),
      child: Row(
        children: [
          _bodyCell(
            item.id,
            flex: 1,
            bold: true,
          ),

          _productCell(item),

          _bodyCell(
            item.supplierId,
            flex: 2,
          ),

          _bodyCell(
            item.supplierName,
            flex: 3,
          ),

          _bodyCell(
            item.supplierProductName,
            flex: 3,
          ),

          _bodyCell(
            item.category,
            flex: 2,
          ),

          _bodyCell(
            item.subCategory,
            flex: 3,
          ),

          _bodyCell(
            item.hsnCode?.name,
            flex: 2,
          ),

          _bodyCell(
            item.brand?.name,
            flex: 2,
          ),

          _bodyCell(
            _formatDateTime(
              item.createdAt,
            ),
            flex: 3,
          ),

          _bodyCell(
            _formatDateTime(
              item.updatedAt,
            ),
            flex: 3,
          ),

          _actionCell(item),
        ],
      ),
    );
  }

  // ============================================================
  // PRODUCT CELL
  // ============================================================

  Widget _productCell(
      ProductModelItem item,
      ) {
    return Expanded(
      flex: 3,
      child: InkWell(
        onTap: () {
          final id = item.id ?? '';

          if (id.isEmpty) {
            return;
          }

          setState(() {
            selectedProduct = id;
            isShowPram = true;
          });
        },
        child: Padding(
          padding:
          const EdgeInsets.symmetric(
            horizontal: 10,
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color:
                  const Color(0xff990044)
                      .withOpacity(.07),
                  borderRadius:
                  BorderRadius.circular(5),
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  size: 15,
                  color:
                  Color(0xff990044),
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  _value(item.name),
                  maxLines: 2,
                  overflow:
                  TextOverflow.ellipsis,
                  style:
                  const TextStyle(
                    fontSize: 12,
                    fontWeight:
                    FontWeight.w600,
                    color:
                    Color(0xff1E293B),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ACTION CELL
  // ============================================================

  Widget _actionCell(
      ProductModelItem item,
      ) {
    return Expanded(
      flex: 2,
      child: Padding(
        padding:
        const EdgeInsets.symmetric(
          horizontal: 6,
          vertical: 4,
        ),
        child: Row(
          mainAxisAlignment:
          MainAxisAlignment.start,
          children: [
            IconButton(
              tooltip: 'Edit',
              onPressed: () {
                _onEditProduct(item);
              },
              icon: const Icon(
                Icons.edit_outlined,
                size: 18,
                color: Color(0xff2563EB),
              ),
              padding: EdgeInsets.zero,
              constraints:
              const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
            ),

            IconButton(
              tooltip: 'Delete',
              onPressed: () {
                _onDeleteProduct(item);
              },
              icon: const Icon(
                Icons.delete_outline,
                size: 18,
                color: Color(0xffDC2626),
              ),
              padding: EdgeInsets.zero,
              constraints:
              const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EDIT
  // ============================================================

  void _onEditProduct(
      ProductModelItem item,
      ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          'Edit product: ${_value(item.name)}',
        ),
      ),
    );
  }

  // ============================================================
  // DELETE
  // ============================================================

  void _onDeleteProduct(
      ProductModelItem item,
      ) {
    bool isDeleting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
              context,
              setDialogState,
              ) {
            return AlertDialog(
              title: const Text(
                'Delete Product',
              ),
              content: isDeleting
                  ? const SizedBox(
                width: 300,
                child: Column(
                  mainAxisSize:
                  MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 32,
                      height: 32,
                      child:
                      CircularProgressIndicator(
                        strokeWidth: 3,
                        color:
                        Color(0xff990044),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Deleting product...',
                      style: TextStyle(
                        fontSize: 13,
                        color:
                        Color(0xff64748B),
                      ),
                    ),
                  ],
                ),
              )
                  : Text(
                'Are you sure you want to delete '
                    '"${_value(item.name)}"?',
              ),
              actions: isDeleting
                  ? null
                  : [
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                    );
                  },
                  child: const Text(
                    'Cancel',
                  ),
                ),
                ElevatedButton(
                  style:
                  ElevatedButton.styleFrom(
                    backgroundColor:
                    const Color(
                      0xffDC2626,
                    ),
                    foregroundColor:
                    Colors.white,
                  ),
                  onPressed: () async {
                    setDialogState(() {
                      isDeleting = true;
                    });

                    final bool success =
                    await controller
                        .deleteProduct(
                      productId:
                      item.id.toString(),
                    );

                    if (!mounted) {
                      return;
                    }

                    if (success) {
                      if (Navigator.canPop(
                          dialogContext)) {
                        Navigator.pop(
                          dialogContext,
                        );
                      }

                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Product deleted successfully',
                          ),
                          backgroundColor:
                          Color(
                            0xff16A34A,
                          ),
                        ),
                      );

                      return;
                    }

                    setDialogState(() {
                      isDeleting = false;
                    });

                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(
                      SnackBar(
                        content: Text(
                          controller
                              .errorMessage
                              .isNotEmpty
                              ? controller
                              .errorMessage
                              : 'Unable to delete product',
                        ),
                        backgroundColor:
                        const Color(
                          0xffDC2626,
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'Delete',
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ============================================================
  // BODY CELL
  // ============================================================

  Widget _bodyCell(
      String? text, {
        required int flex,
        bool bold = false,
        Color? textColor,
        TextAlign textAlign =
            TextAlign.left,
      }) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding:
        const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 7,
        ),
        child: Align(
          alignment: textAlign ==
              TextAlign.center
              ? Alignment.center
              : Alignment.centerLeft,
          child: Text(
            _value(text),
            maxLines: 2,
            overflow:
            TextOverflow.ellipsis,
            textAlign: textAlign,
            style: TextStyle(
              fontSize: 11,
              fontWeight: bold
                  ? FontWeight.w600
                  : FontWeight.w500,
              color: textColor ??
                  const Color(
                    0xff263449,
                  ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  String _value(String? value) {
    if (value == null ||
        value.trim().isEmpty) {
      return '-';
    }

    return value.trim();
  }

  String _formatDateTime(
      String? value,
      ) {
    if (value == null ||
        value.trim().isEmpty) {
      return '-';
    }

    final text = value.trim();

    if (text.length >= 19) {
      return text.substring(0, 19);
    }

    return text;
  }

  // ============================================================
  // LOADING ROW
  // ============================================================

  Widget _buildLoadingRow() {
    return Container(
      height: 50,
      alignment: Alignment.center,
      child: const SizedBox(
        width: 18,
        height: 18,
        child:
        CircularProgressIndicator(
          strokeWidth: 2,
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize:
        MainAxisSize.min,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 42,
            color:
            Colors.grey.shade400,
          ),
          const SizedBox(height: 10),
          const Text(
            'No products found',
            style: TextStyle(
              fontSize: 14,
              fontWeight:
              FontWeight.w600,
              color:
              Color(0xff475569),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Try changing your search.',
            style: TextStyle(
              fontSize: 12,
              color:
              Color(0xff94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize:
        MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline,
            size: 40,
            color:
            Color(0xffDC2626),
          ),
          const SizedBox(height: 10),
          Text(
            controller.errorMessage,
            textAlign:
            TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color:
              Color(0xff64748B),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed:
            controller.refresh,
            child: const Text(
              'Retry',
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FOOTER
  // ============================================================

  Widget _buildFooter() {
    return Container(
      height: 42,
      padding:
      const EdgeInsets.symmetric(
        horizontal: 22,
      ),
      decoration:
      const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color:
            Color(0xffE5E7EB),
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            controller.products.isEmpty
                ? '0 products'
                : 'Showing ${controller.showingCount} '
                'of ${controller.totalData} products',
            style:
            const TextStyle(
              fontSize: 11,
              color:
              Color(0xff64748B),
            ),
          ),

          const Spacer(),

          if (controller.hasMore)
            const Text(
              'Scroll to load more',
              style:
              TextStyle(
                fontSize: 11,
                color:
                Color(0xff94A3B8),
              ),
            ),
        ],
      ),
    );
  }
}

// ================================================================
// UPPER CASE FORMATTER
// ================================================================

class UpperCaseTextFormatter
    extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final upperText =
    newValue.text.toUpperCase();

    return newValue.copyWith(
      text: upperText,
      selection:
      TextSelection.collapsed(
        offset: upperText.length,
      ),
      composing:
      TextRange.empty,
    );
  }
}



class MultipleBarcodeToggle extends StatefulWidget {
  final ValueChanged<bool>? onChanged;

  const MultipleBarcodeToggle({
    super.key,
    this.onChanged,
  });

  @override
  State<MultipleBarcodeToggle> createState() =>
      _MultipleBarcodeToggleState();
}

class _MultipleBarcodeToggleState
    extends State<MultipleBarcodeToggle> {
  static const Color primaryColor = Color(0xFF3267D5);
  bool _isEnabled = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _loadSetting();
  }

  Future<void> _loadSetting() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getBool(multiBarcodeStorageKey) ?? false;

    if (!mounted) return;

    setState(() {
      _isEnabled = value;
      _isLoading = false;
    });

    widget.onChanged?.call(value);
  }

  Future<void> _updateSetting(bool value) async {
    setState(() {
      _isEnabled = value;
    });

    widget.onChanged?.call(value);

    try {
      final prefs = await SharedPreferences.getInstance();

      final saved = await prefs.setBool(multiBarcodeStorageKey, value);

      if (!saved && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to save barcode setting'),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save barcode setting'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isEnabled
              ? primaryColor.withValues(alpha: 0.35)
              : const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.qr_code_2_rounded,
              color: primaryColor,
              size: 25,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Multiple Barcode Pricing',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF202938),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isEnabled
                      ? 'Different prices for each barcode'
                      : 'Enable different prices per barcode',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (_isLoading)
            const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: primaryColor,
              ),
            )
          else
            Switch.adaptive(
              value: _isEnabled,
              activeTrackColor: primaryColor,
              onChanged: _updateSetting,
            ),
        ],
      ),
    );
  }
}
