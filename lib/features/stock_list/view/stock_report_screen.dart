import 'package:flutter/material.dart';
import '../../../core/routes/routes.dart';
import '../../../core/vars/global_vars.dart';
import '../controller/stock_report_controller.dart';
import '../model/stock_report_model.dart';

class StockReportScreen extends StatefulWidget {
  const StockReportScreen({super.key});

  @override
  State<StockReportScreen> createState() => _StockReportScreenState();
}

class _StockReportScreenState extends State<StockReportScreen> {
  static const Color primary = Color(0xFF3267D5);
  static const Color primaryLight = Color(0xFFEDF3FF);
  static const Color background = Color(0xFFF4F6FA);
  static const Color textDark = Color(0xFF202B3C);
  static const Color textMuted = Color(0xFF778397);
  static const Color borderColor = Color(0xFFE7EBF2);
  static const Color green = Color(0xFF16876B);
  static const Color orange = Color(0xFFE99A35);
  static const Color red = Color(0xFFD94D4D);

  late final StockReportController controller;
  final TextEditingController searchController = TextEditingController();

  String? selectedBarcode;

  @override
  void initState() {
    super.initState();

    GlobalVars.globalRoutes = Routes.stockListScreen;
    controller = StockReportController();
  }

  @override
  void dispose() {
    controller.dispose();
    searchController.dispose();
    super.dispose();
  }

  void _selectBarcode(StockListModel item) {
    setState(() {
      selectedBarcode = item.barcode;
    });
  }

  Future<void> _refresh() async {
    await controller.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            _buildPageHeader(),
            Expanded(
              child: ListenableBuilder(
                listenable: controller,
                builder: (context, child) {
                  final items = controller.filteredItems;

                  StockListModel? selectedItem;

                  for (final item in items) {
                    if (item.barcode == selectedBarcode) {
                      selectedItem = item;
                      break;
                    }
                  }

                  selectedItem ??= items.isNotEmpty ? items.first : null;

                  return RefreshIndicator(
                    color: primary,
                    backgroundColor: Colors.white,
                    onRefresh: _refresh,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 14),
                      children: [
                        _buildSearchBar(),
                        const SizedBox(height: 10),
                        _buildSummaryCards(),
                        const SizedBox(height: 12),
                        _buildWorkspace(
                          items: items,
                          selectedItem: selectedItem,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PAGE HEADER
  // ============================================================

  Widget _buildPageHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 12, 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: borderColor),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
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
                  'Stock Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textDark,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Barcode-wise stock register',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: textMuted,
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: background,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              onTap: _refresh,
              borderRadius: BorderRadius.circular(10),
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(
                  Icons.refresh_rounded,
                  color: primary,
                  size: 21,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SEARCH
  // ============================================================

  Widget _buildSearchBar() {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: TextField(
        controller: searchController,
        onChanged: controller.setSearch,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: textDark,
        ),
        decoration: InputDecoration(
          hintText: 'Search barcode, challan or stock...',
          hintStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: textMuted,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            size: 21,
            color: textMuted,
          ),
          suffixIcon: searchController.text.isEmpty
              ? null
              : IconButton(
            onPressed: () {
              searchController.clear();
              controller.setSearch('');
              setState(() {});
            },
            icon: const Icon(
              Icons.close_rounded,
              size: 18,
              color: textMuted,
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 13,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SUMMARY CARDS
  // ============================================================

  Widget _buildSummaryCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 500;
        final gap = 8.0;
        final cardWidth = (constraints.maxWidth - gap * 2) / 3;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            SizedBox(
              width: cardWidth,
              child: _summaryCard(
                title: 'Barcodes',
                value: '${controller.totalRecords}',
                icon: Icons.qr_code_2_rounded,
                color: primary,
                compact: compact,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _summaryCard(
                title: 'Total Stock',
                value: '${controller.totalStock}',
                icon: Icons.inventory_2_outlined,
                color: green,
                compact: compact,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _summaryCard(
                title: 'Entries',
                value: '${controller.totalEntries}',
                icon: Icons.receipt_long_outlined,
                color: orange,
                compact: compact,
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
    required bool compact,
  }) {
    return Container(
      padding: EdgeInsets.all(compact ? 8 : 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: color),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: textMuted,
              ),
            ),),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              value,
              key: ValueKey(value),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: compact ? 13 : 14,
                fontWeight: FontWeight.w600,
                color: textDark,
              ),
            ),
          ),
          SizedBox(width: 12,)
        ],
      ),
    );
  }

  // ============================================================
  // MASTER / DETAIL WORKSPACE
  // ============================================================

  Widget _buildWorkspace({
    required List<StockListModel> items,
    required StockListModel? selectedItem,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 850;

        if (wide) {
          return SizedBox(
            height: 520,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 285,
                  child: _buildBarcodePanel(
                    items: items,
                    selectedItem: selectedItem,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildDetailsPanel(selectedItem),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 270,
              child: _buildBarcodePanel(
                items: items,
                selectedItem: selectedItem,
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 430,
              child: _buildDetailsPanel(selectedItem),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // LEFT: BARCODE LIST
  // ============================================================

  Widget _buildBarcodePanel({
    required List<StockListModel> items,
    required StockListModel? selectedItem,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(11, 10, 10, 9),
            child: Row(
              children: [
                Container(
                  width: 33,
                  height: 33,
                  decoration: BoxDecoration(
                    color: primaryLight,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(
                    Icons.qr_code_scanner_rounded,
                    size: 18,
                    color: primary,
                  ),
                ),
                const SizedBox(width: 9),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Barcode List',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: textDark,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Select to view stock details',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w400,
                          color: textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                _countPill('${items.length}'),
              ],
            ),
          ),
          const Divider(height: 1, color: borderColor),
          Expanded(
            child: items.isEmpty
                ? _buildEmptyState(
              icon: Icons.qr_code_2_rounded,
              title: 'No barcodes found',
              message: 'Try changing your search.',
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 6),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final selected =
                    item.barcode == selectedItem?.barcode;

                return _buildBarcodeItem(
                  item: item,
                  selected: selected,
                  onTap: () => _selectBarcode(item),
                );
              },
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFFFAFBFD),
              border: Border(
                top: BorderSide(color: borderColor),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.touch_app_outlined,
                  size: 15,
                  color: textMuted,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    selectedItem == null
                        ? 'Select a barcode'
                        : 'Selected: ${selectedItem.barcode}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarcodeItem({
    required StockListModel item,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      margin: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: selected ? primaryLight : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: selected ? primary : borderColor,
          width: selected ? 1.3 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 4,
                  height: 42,
                  decoration: BoxDecoration(
                    color: selected ? primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFFDCE7FF)
                        : background,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(
                    Icons.qr_code_2_rounded,
                    size: 20,
                    color: selected ? primary : textMuted,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.barcode.isEmpty
                            ? 'Unknown barcode'
                            : item.barcode,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: selected ? primary : textDark,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${item.details.length} stock entries',
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w400,
                          color: textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${item.totalStocks}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: green,
                      ),
                    ),
                    const Text(
                      'Stock',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w400,
                        color: textMuted,
                      ),
                    ),
                  ],
                ),
                if (selected) ...[
                  const SizedBox(width: 5),
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 16,
                    color: primary,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // RIGHT: SELECTED BARCODE DETAILS
  // ============================================================

  Widget _buildDetailsPanel(StockListModel? item) {
    if (item == null) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
        ),
        child: _buildEmptyState(
          icon: Icons.inventory_2_outlined,
          title: 'Select a barcode',
          message: 'Its stock entries will appear here.',
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _buildDetailHeader(item),
          _buildDetailStats(item),
          const Divider(height: 1, color: borderColor),
          Padding(
            padding: const EdgeInsets.fromLTRB(11, 9, 11, 7),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Stock Entries',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: textDark,
                    ),
                  ),
                ),
                _countPill('${item.details.length} entries'),
              ],
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: item.details.isEmpty
                  ? _buildEmptyState(
                key: ValueKey('empty-${item.barcode}'),
                icon: Icons.receipt_long_outlined,
                title: 'No stock entries',
                message: 'There are no details for this barcode.',
              )
                  : ListView.separated(
                key: ValueKey('details-${item.barcode}'),
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                itemCount: item.details.length,
                separatorBuilder: (_, __) =>
                const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final detail = item.details[index];

                  return _buildStockEntry(
                    index: index,
                    billDate: detail.billDate.toString(),
                    challanNo: detail.challanNo.toString(),
                    storeId: detail.storeId.toString(),
                    stocks: detail.stocks.toString(),
                    typesFor: detail.typesFor.toString(),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailHeader(StockListModel item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF3267D5),
            Color(0xFF467DE5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'BARCODE DETAILS',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.7,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  item.barcode.isEmpty
                      ? 'Unknown barcode'
                      : item.barcode,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${item.totalStocks}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Text(
                  'Total stock',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 9,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailStats(StockListModel item) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: _miniStat(
              icon: Icons.receipt_long_outlined,
              label: 'Entries',
              value: '${item.details.length}',
              color: primary,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: _miniStat(
              icon: Icons.add_box_outlined,
              label: 'Stock quantity',
              value: '${item.totalStocks}',
              color: green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(icon, size: 19, color: color),
          const SizedBox(width: 9),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w400,
                    color: textMuted,
                  ),
                ),
                Spacer(),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STOCK ENTRY CARD
  // ============================================================

  Widget _buildStockEntry({
    required int index,
    required String billDate,
    required String challanNo,
    required String storeId,
    required String stocks,
    required String typesFor,
  }) {
    final isPurchase =
    typesFor.toLowerCase().contains('purchase');

    final typeColor = isPurchase ? green : orange;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(11),
        onTap: () {
          _showEntryDetails(
            index: index,
            billDate: billDate,
            challanNo: challanNo,
            storeId: storeId,
            stocks: stocks,
            typesFor: typesFor,
          );
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFCFDFE),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 29,
                    height: 29,
                    decoration: BoxDecoration(
                      color: primaryLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.receipt_long_outlined,
                      size: 16,
                      color: primary,
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          challanNo.isEmpty ||
                              challanNo == 'null'
                              ? 'Challan unavailable'
                              : 'Challan $challanNo',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: textDark,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          billDate.isEmpty || billDate == 'null'
                              ? 'Date unavailable'
                              : billDate,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w400,
                            color: textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE7F6EF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Qty: $stocks',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: green,
                      ),
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Divider(height: 1, color: borderColor),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.store_outlined,
                    size: 15,
                    color: textMuted,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      'Store: ${storeId.isEmpty || storeId == 'null' ? '-' : storeId}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: textMuted,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.09),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      typesFor.isEmpty || typesFor == 'null'
                          ? 'Other'
                          : typesFor.replaceAll('_', ' '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        color: typeColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 17,
                    color: textMuted,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ENTRY POPUP
  // ============================================================

  void _showEntryDetails({
    required int index,
    required String billDate,
    required String challanNo,
    required String storeId,
    required String stocks,
    required String typesFor,
  }) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: primaryLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.receipt_long_outlined,
                          color: primary,
                        ),
                      ),
                      const SizedBox(width: 11),
                      const Expanded(
                        child: Text(
                          'Stock Entry Details',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: textDark,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 20,
                          color: textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _entryInfoRow('Entry number', '${index + 1}'),
                        _entryInfoRow('Bill date', billDate),
                        _entryInfoRow('Challan number', challanNo),
                        _entryInfoRow('Store ID', storeId),
                        _entryInfoRow('Stock quantity', stocks),
                        _entryInfoRow('Transaction type', typesFor),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Close',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _entryInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: textMuted,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value.isEmpty || value == 'null' ? '-' : value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SHARED COMPONENTS
  // ============================================================

  Widget _countPill(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: primaryLight,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        value,
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: primary,
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    Key? key,
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      key: key,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                icon,
                size: 27,
                color: textMuted,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textDark,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}