
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../controller/product_parm_controller.dart';

class ProductParameterScreen extends StatefulWidget {
  final String productId;
  final GestureTapCallback callBack;

  const ProductParameterScreen({
    super.key,
    this.productId = '',
    required this.callBack,
  });

  @override
  State<ProductParameterScreen> createState() =>
      _ProductParameterScreenState();
}

class _ProductParameterScreenState extends State<ProductParameterScreen> {
  static const Color primary = Color(0xFF3267D5);
  static const Color dark = Color(0xFF263247);
  static const Color muted = Color(0xFF7C8799);
  static const Color border = Color(0xFFE5EAF2);
  static const Color background = Color(0xFFF5F7FB);
  static const Color green = Color(0xFF23865B);
  static const Color orange = Color(0xFFD88B27);

  late ProductParameterController controller;

  final ScrollController verticalController = ScrollController();
  final ScrollController horizontalController = ScrollController();
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    controller = ProductParameterController(
      dio: Dio(),
      productId: widget.productId,
    );

    verticalController.addListener(_onScroll);
    controller.fetchProductParameters();
  }

  void _onScroll() {
    if (!verticalController.hasClients) return;

    if (verticalController.position.extentAfter < 250 &&
        controller.hasMore &&
        !controller.isLoading &&
        !controller.isLoadingMore) {
      controller.loadMore();
    }
  }

  @override
  void dispose() {
    verticalController.removeListener(_onScroll);
    verticalController.dispose();
    horizontalController.dispose();
    searchController.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: controller,
          builder: (context, child) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(),
                  const SizedBox(height: 18),
                  Row(
                    children: [

                      Expanded(child: _searchBar(),),
                      const SizedBox(width: 18),
                      Expanded(child: _summaryCards()),


                    ],
                  ),

                  const SizedBox(height: 14),
                  Expanded(child: _content()),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // HEADER
  // ------------------------------------------------------------

  Widget _header() {
    final bool showingAll = controller.productId.trim().isEmpty;

    return Row(
      children: [
        InkWell(
          onTap: (){
            widget.callBack();
          },
          child: Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.arrow_back,
              color: primary,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              const Text(
                'Product Parameters',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: dark,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                showingAll
                    ? 'Manage product sizes, colors and prices'
                    : 'Product ID: ${controller.productId}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: muted,
                ),
              ),
            ],
          ),
        ),
        if (!showingAll)
          _headerButton(
            icon: Icons.grid_view_rounded,
            label: 'Show All',
            onTap: () {
              searchController.clear();
              controller.clearSearch();
              controller.showAllProducts();
            },
          )
        else if (widget.productId.trim().isNotEmpty)
          _headerButton(
            icon: Icons.filter_alt_outlined,
            label: 'Current Product',
            onTap: () {
              searchController.clear();
              controller.clearSearch();
              controller.setProductFilter(widget.productId);
            },
          ),
        const SizedBox(width: 8),
        _iconButton(
          icon: Icons.refresh_rounded,
          tooltip: 'Refresh',
          onTap: () => controller.refresh(),
        ),
      ],
    );
  }

  Widget _headerButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 17),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: border),
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9),
          ),
        ),
      ),
    );
  }

  Widget _iconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(9),
          child: Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              border: Border.all(color: border),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: primary, size: 20),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // SUMMARY CARDS
  // ------------------------------------------------------------

  Widget _summaryCards() {
    final int total = controller.total;
    final int loaded = controller.items.length;
    final int remaining = total > loaded ? total - loaded : 0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double cardWidth = (constraints.maxWidth - 24) / 3;

        return Row(
          children: [
            SizedBox(
              width: cardWidth,
              child: _summaryCard(
                title: 'Total Parameters',
                value: total.toString(),
                icon: Icons.dataset_outlined,
                color: primary,
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: cardWidth,
              child: _summaryCard(
                title: 'Loaded Records',
                value: loaded.toString(),
                icon: Icons.check_circle_outline_rounded,
                color: green,
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: cardWidth,
              child: _summaryCard(
                title: 'Remaining',
                value: remaining.toString(),
                icon: Icons.more_horiz_rounded,
                color: orange,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _summaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            height: 38,
            width: 35,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: muted,
                  ),
                ),
                Spacer(),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: dark,
                  ),
                ),
                SizedBox(width: 12,)
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // SEARCH
  // ------------------------------------------------------------

  Widget _searchBar() {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: searchController,
        onChanged: controller.setSearch,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: dark,
        ),
        decoration: InputDecoration(
          hintText: 'Search product, barcode, size, color or ID...',
          hintStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: muted,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: muted,
            size: 21,
          ),
          suffixIcon: searchController.text.isNotEmpty
              ? IconButton(
            tooltip: 'Clear search',
            onPressed: () {
              searchController.clear();
              controller.clearSearch();
            },
            icon: const Icon(
              Icons.close_rounded,
              size: 18,
              color: muted,
            ),
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 13),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // CONTENT
  // ------------------------------------------------------------

  Widget _content() {
    if (controller.isLoading && controller.items.isEmpty) {
      return _loadingView();
    }

    if ( controller.errorMessage!=null && controller.errorMessage!.isNotEmpty && controller.items.isEmpty) {
      return _messageView(
        icon: Icons.cloud_off_outlined,
        title: 'Unable to load parameters',
        message: controller.errorMessage?? '',
        actionLabel: 'Try Again',
        onAction: controller.refresh,
      );
    }

    if (controller.filteredItems.isEmpty) {
      return _messageView(
        icon: Icons.inventory_2_outlined,
        title: 'No parameters found',
        message: searchController.text.isNotEmpty
            ? 'Try another search keyword.'
            : 'There are no product parameters to display.',
        actionLabel: searchController.text.isNotEmpty
            ? 'Clear Search'
            : 'Refresh',
        onAction: () {
          if (searchController.text.isNotEmpty) {
            searchController.clear();
            controller.clearSearch();
          } else {
            controller.refresh();
          }
        },
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double tableWidth =
        constraints.maxWidth > 1500
            ? constraints.maxWidth
            : 1500;

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _tableHeader(),
              Expanded(
                child: Scrollbar(
                  controller: verticalController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: verticalController,
                    child: Scrollbar(
                      controller: horizontalController,
                      thumbVisibility: true,
                      notificationPredicate: (notification) =>
                      notification.metrics.axis == Axis.horizontal,
                      child: SingleChildScrollView(
                        controller: horizontalController,
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: tableWidth,
                          child: _table(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              _tableFooter(),
            ],
          ),
        );
      },
    );
  }

  Widget _tableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 13,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFFAFBFE),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(12),
        ),
        border: Border(
          bottom: BorderSide(color: border),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.table_rows_outlined,
            size: 18,
            color: primary,
          ),
          const SizedBox(width: 9),
          const Text(
            'Parameter List',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: dark,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${controller.filteredItems.length}',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: primary,
              ),
            ),
          ),
          const Spacer(),
          const Icon(
            Icons.swipe_outlined,
            size: 15,
            color: muted,
          ),
          const SizedBox(width: 5),
          const Text(
            'Scroll to view all columns',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: muted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _table() {
    final items = controller.filteredItems;

    return DataTable(
      horizontalMargin: 16,
      columnSpacing: 22,
      dataRowMinHeight: 54,
      dataRowMaxHeight: 62,
      headingRowHeight: 48,
      dividerThickness: 0.6,
      headingRowColor: WidgetStateProperty.all(
        const Color(0xFFF5F7FC),
      ),
      headingTextStyle: const TextStyle(
        color: Color(0xFF647187),
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
      ),
      dataTextStyle: const TextStyle(
        color: dark,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
      columns: const [
        DataColumn(label: Text('ID')),
        DataColumn(label: Text('PRODUCT ID')),
        DataColumn(label: Text('PRODUCT NAME')),
        DataColumn(label: Text('SIZE')),
        DataColumn(label: Text('COLOR')),
        DataColumn(label: Text('BARCODE')),
        DataColumn(label: Text('PURCHASE')),
        DataColumn(label: Text('B2B PRICE')),
        DataColumn(label: Text('B2C PRICE')),
        DataColumn(label: Text('MRP')),
        DataColumn(label: Text('STATUS')),
        DataColumn(label: Text('ACTION')),
      ],
      rows: List.generate(items.length, (index) {
        final item = items[index];

        return DataRow(
          color: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.hovered)) {
              return const Color(0xFFEEF4FF);
            }
            return index.isEven
                ? Colors.white
                : const Color(0xFFFCFDFF);
          }),
          cells: [
            DataCell(_cellText(item.id)),
            DataCell(_cellText(item.productId)),
            DataCell(
              SizedBox(
                width: 150,
                child: Text(
                  item.productName.isEmpty ? '-' : item.productName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: dark,
                  ),
                ),
              ),
            ),
            DataCell(_cellText(item.sizeName)),
            DataCell(_cellText(item.colorName)),
            DataCell(
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4FA),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.barcode.isEmpty ? '-' : item.barcode,
                  style: const TextStyle(
                    color: Color(0xFF41516A),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            DataCell(_priceText(item.purchasePrice)),
            DataCell(_priceText(item.b2bPrice)),
            DataCell(_priceText(item.b2cPrice)),
            DataCell(_priceText(item.mrp)),
            DataCell(_statusChip(item.status)),
            DataCell(
              Tooltip(
                message: 'Edit parameter',
                child: Material(
                  color: primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: () => _showEditDialog(item),
                    borderRadius: BorderRadius.circular(8),
                    child: const SizedBox(
                      height: 34,
                      width: 38,
                      child: Icon(
                        Icons.edit_outlined,
                        size: 17,
                        color: primary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _cellText(String value) {
    return Text(
      value.isEmpty ? '-' : value,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: dark,
      ),
    );
  }

  Widget _priceText(String value) {
    return Text(
      value.isEmpty ? '0.00' : value,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: dark,
      ),
    );
  }

  Widget _statusChip(String status) {
    final bool active = status.toLowerCase() == '1' ||
        status.toLowerCase() == 'active' ||
        status.toLowerCase() == 'true';

    final Color color = active ? green : muted;
    final String label = active ? 'Active' : 'Inactive';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 6,
            width: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // FOOTER
  // ------------------------------------------------------------

  Widget _tableFooter() {
    final int total = controller.total;
    final int loaded = controller.items.length;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFFAFBFE),
        border: Border(
          top: BorderSide(color: border),
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 16,
            color: muted,
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              'Showing $loaded of $total records',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: muted,
              ),
            ),
          ),
          if (controller.isLoadingMore) ...[
            const SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: primary,
              ),
            ),
            const SizedBox(width: 9),
            const Text(
              'Loading...',
              style: TextStyle(
                fontSize: 12,
                color: muted,
                fontWeight: FontWeight.w400,
              ),
            ),
          ] else if (controller.hasMore)
            OutlinedButton.icon(
              onPressed: controller.loadMore,
              icon: const Icon(Icons.add_rounded, size: 17),
              label: const Text(
                'Load More',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: primary,
                side: BorderSide(
                  color: primary.withValues(alpha: 0.3),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            )
          else
            const Text(
              'All records loaded',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: green,
              ),
            ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // LOADING / EMPTY / ERROR
  // ------------------------------------------------------------

  Widget _loadingView() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 34,
              width: 34,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: primary,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Loading product parameters...',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: muted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _messageView({
    required IconData icon,
    required String title,
    required String message,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 62,
                width: 62,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: primary,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: dark,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: muted,
                ),
              ),
              const SizedBox(height: 18),
              OutlinedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.refresh_rounded, size: 17),
                label: Text(
                  actionLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primary,
                  side: const BorderSide(color: border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // EDIT DIALOG
  // ------------------------------------------------------------

  Future<void> _showEditDialog(dynamic item) async {
    final purchaseController =
    TextEditingController(text: item.purchasePrice);
    final b2bController = TextEditingController(text: item.b2bPrice);
    final b2cController = TextEditingController(text: item.b2cPrice);
    final mrpController = TextEditingController(text: item.mrp);

    String selectedStatus = item.status.toLowerCase() == '0' ||
        item.status.toLowerCase() == 'inactive' ||
        item.status.toLowerCase() == 'false'
        ? '0'
        : '1';

    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return Dialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                height: 42,
                                width: 42,
                                decoration: BoxDecoration(
                                  color: primary.withValues(alpha: 0.09),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.edit_note_rounded,
                                  color: primary,
                                  size: 23,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Edit Parameter',
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w500,
                                        color: dark,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Update prices and status',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        color: muted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () =>
                                    Navigator.pop(dialogContext),
                                icon: const Icon(
                                  Icons.close_rounded,
                                  color: muted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _readOnlyInfo(
                            'Barcode',
                            item.barcode.isEmpty ? '-' : item.barcode,
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              Expanded(
                                child: _priceField(
                                  controller: purchaseController,
                                  label: 'Purchase Price',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _priceField(
                                  controller: mrpController,
                                  label: 'MRP',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: _priceField(
                                  controller: b2bController,
                                  label: 'B2B Price',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _priceField(
                                  controller: b2cController,
                                  label: 'B2C Price',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Status',
                            style: TextStyle(
                              fontSize: 12,
                              color: muted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: background,
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: Row(
                              children: [
                                _statusOption(
                                  label: 'Active',
                                  value: '1',
                                  selected: selectedStatus == '1',
                                  onTap: () {
                                    setDialogState(
                                          () => selectedStatus = '1',
                                    );
                                  },
                                ),
                                _statusOption(
                                  label: 'Inactive',
                                  value: '0',
                                  selected: selectedStatus == '0',
                                  onTap: () {
                                    setDialogState(
                                          () => selectedStatus = '0',
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 22),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () =>
                                      Navigator.pop(dialogContext),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 13,
                                    ),
                                    foregroundColor: muted,
                                    side: const BorderSide(color: border),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(9),
                                    ),
                                  ),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    final updatedItem = item.copyWith(
                                      purchasePrice:
                                      purchaseController.text.trim(),
                                      b2bPrice: b2bController.text.trim(),
                                      b2cPrice: b2cController.text.trim(),
                                      mrp: mrpController.text.trim(),
                                      status: selectedStatus,
                                    );

                                    controller.updateItem(updatedItem);
                                    Navigator.pop(dialogContext);
                                  },
                                  icon: const Icon(
                                    Icons.check_rounded,
                                    size: 17,
                                  ),
                                  label: const Text(
                                    'Apply Changes',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primary,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 13,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(9),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    } finally {
      purchaseController.dispose();
      b2bController.dispose();
      b2cController.dispose();
      mrpController.dispose();
    }
  }

  Widget _readOnlyInfo(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.qr_code_2_rounded,
            color: primary,
            size: 20,
          ),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: muted,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: dark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: dark,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: muted,
        ),
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: primary, width: 1.2),
        ),
      ),
    );
  }

  Widget _statusOption({
    required String label,
    required String value,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: selected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(7),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(7),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 11),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7),
              border: selected
                  ? Border.all(color: border)
                  : null,
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: selected ? primary : muted,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
