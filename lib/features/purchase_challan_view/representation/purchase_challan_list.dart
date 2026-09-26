import 'package:calculation_panel/core/database/local_data/party_json.dart';
import 'package:calculation_panel/core/theme/colors.dart';
import 'package:calculation_panel/core/widget/intractive_loder.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../core/vars/global_vars.dart';
import '../../dashboard/data/controller/routes_controller.dart';
import '../controller/purchase_challan_list_controller.dart';
import '../model/purchase_challan_list_model.dart';

// ============================================================
// PURCHASE CHALLAN LIST PAGE
// ============================================================

class PurchaseChallanListPage extends StatefulWidget {
  final RoutesController routesController;

  const PurchaseChallanListPage({
    super.key,
    required this.routesController,
  });

  @override
  State<PurchaseChallanListPage> createState() =>
      _PurchaseChallanListPageState();
}

class _PurchaseChallanListPageState extends State<PurchaseChallanListPage> {
  late final PurchaseChallanListController controller;

  final TextEditingController searchController =
  TextEditingController();

  String searchText = '';

// Expanded challan IDs.
  final Set<String> expandedIds = <String>{};

// ==========================================================
// INIT
// ==========================================================

  @override
  void initState() {
    super.initState();

    GlobalVars.globalRoutes = "/purchaseChallanList";

    controller = PurchaseChallanListController(
      dio: Dio(),
    );

    controller.getAllChallans();

    searchController.addListener(_onSearchChanged);
  }

// ==========================================================
// SEARCH
// ==========================================================

  void _onSearchChanged() {
    if (!mounted) return;

    setState(() {
      searchText = searchController.text.trim().toLowerCase();
    });
  }

  List<PurchaseChallanListModel> get filteredChallans {
    if (searchText.isEmpty) {
      return controller.challans;
    }

    return controller.challans.where((item) {
      return item.challanNo.toLowerCase().contains(searchText) ||
          item.supplierId.toLowerCase().contains(searchText) ||
          item.gstNo.toLowerCase().contains(searchText) ||
          item.lrNo.toLowerCase().contains(searchText) ||
          item.storeName.toLowerCase().contains(searchText) ||
          item.transportName.toLowerCase().contains(searchText) ||
          item.agentName.toLowerCase().contains(searchText) ||
          item.id.toLowerCase().contains(searchText);
    }).toList();
  }

// ==========================================================
// DISPOSE
// ==========================================================

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    controller.dispose();

    super.dispose();
  }

// ==========================================================
// BUILD
// ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F5F7),
      body: SafeArea(
        child: Column(
          children: [
            ListenableBuilder(
              listenable: controller,
              builder: (context, _) {
                return _buildHeader();
              },
            ),
            Expanded(
              child: ListenableBuilder(
                listenable: controller,
                builder: (context, _) {
                  return _buildBody();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

// ==========================================================
// HEADER
// ==========================================================

  Widget _buildHeader() {
    final total = controller.challans.length;
    final filtered = filteredChallans.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        14,
        10,
        14,
        10,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xffDDE1E5),
          ),
        ),
      ),
      child: Row(
        children: [
// --------------------------------------------------
// ICON
// --------------------------------------------------

          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: themeColor,
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              size: 20,
              color: Colors.white,
            ),
          ),

          const SizedBox(width: 10),

// --------------------------------------------------
// TITLE
// --------------------------------------------------

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Purchase Challans',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff191C20),
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    _countBadge(
                      searchText.isEmpty
                          ? total
                          : filtered,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      searchText.isEmpty
                          ? 'records'
                          : 'of $total records',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xff777C82),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

// --------------------------------------------------
// SEARCH
// --------------------------------------------------

          SizedBox(
            width: 290,
            height: 38,
            child: _buildSearchField(),
          ),

          const SizedBox(width: 8),

// --------------------------------------------------
// REFRESH
// --------------------------------------------------

          _headerButton(
            icon: Icons.refresh_rounded,
            tooltip: 'Refresh',
            loading: controller.isLoading,
            onTap: controller.isLoading
                ? null
                : controller.getAllChallans,
          ),

          const SizedBox(width: 8),

// --------------------------------------------------
// NEW CHALLAN
// --------------------------------------------------

          SizedBox(
            height: 38,
            child: ElevatedButton.icon(
              onPressed: _createNewChallan,
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(
                Icons.add_rounded,
                size: 17,
              ),
              label: const Text(
                'New Challan',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

// ==========================================================
// COUNT BADGE
// ==========================================================

  Widget _countBadge(int value) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 2.5,
      ),
      decoration: BoxDecoration(
        color: const Color(0xffEEF0F2),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        '$value',
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: Color(0xff454A50),
        ),
      ),
    );
  }

// ==========================================================
// HEADER BUTTON
// ==========================================================

  Widget _headerButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback? onTap,
    bool loading = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: const Color(0xffF0F1F3),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 38,
            height: 38,
            child: loading
                ? const Padding(
              padding: EdgeInsets.all(11),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xff555A60),
              ),
            )
                : Icon(
              icon,
              size: 19,
              color: const Color(0xff35393E),
            ),
          ),
        ),
      ),
    );
  }

// ==========================================================
// SEARCH FIELD
// ==========================================================

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xffF7F8F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xffD9DDE2),
        ),
      ),
      child: TextField(
        controller: searchController,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xff292D32),
        ),
        decoration: InputDecoration(
          hintText:
          'Search challan, supplier, GST, LR...',
          hintStyle: const TextStyle(
            fontSize: 11,
            color: Color(0xff969BA1),
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            size: 18,
            color: Color(0xff777C82),
          ),
          suffixIcon: searchText.isNotEmpty
              ? IconButton(
            onPressed: searchController.clear,
            splashRadius: 16,
            padding: EdgeInsets.zero,
            icon: const Icon(
              Icons.close_rounded,
              size: 16,
              color: Color(0xff777C82),
            ),
          )
              : null,
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 10,
          ),
        ),
      ),
    );
  }

// ==========================================================
// BODY
// ==========================================================

  Widget _buildBody() {
    if (controller.isLoading &&
        controller.challans.isEmpty) {
      return InteractiveLoadingView();
    }

    if (controller.errorMessage != null &&
        controller.challans.isEmpty) {
      return _buildError();
    }

    final data = filteredChallans;

    if (data.isEmpty) {
      return _buildEmpty();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        12,
        12,
        12,
        14,
      ),
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: data.length,
        itemBuilder: (context, index) {
          return _buildChallanCard(
            data[index],
            index,
          );
        },
      ),
    );
  }

// ==========================================================
// CHALLAN CARD
// ==========================================================

  Widget _buildChallanCard(
      PurchaseChallanListModel challan,
      int index,
      ) {
    final isExpanded =
    expandedIds.contains(challan.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isExpanded
              ? const Color(0xffC9CDD2)
              : const Color(0xffE0E3E7),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _buildCompactRow(
            challan,
            index,
            isExpanded,
          ),

          AnimatedCrossFade(
            duration: const Duration(
              milliseconds: 220,
            ),
            firstCurve: Curves.easeOut,
            secondCurve: Curves.easeIn,
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: _buildExpandedData(challan),
          ),
        ],
      ),
    );
  }

// ==========================================================
// COMPACT ROW
// ==========================================================

  Widget _buildCompactRow(
      PurchaseChallanListModel challan,
      int index,
      bool isExpanded,
      ) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 74,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      child: Row(
        children: [
// --------------------------------------------------
// NUMBER
// --------------------------------------------------

          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xffF0F2F4),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xff70757B),
              ),
            ),
          ),

          const SizedBox(width: 9),

// --------------------------------------------------
// MAIN INFORMATION
// --------------------------------------------------

          Expanded(
            flex: 3,
            child: _buildMainInfo(challan),
          ),

          const SizedBox(width: 14),

// --------------------------------------------------
// STORE
// --------------------------------------------------

          SizedBox(
            width: 135,
            child: _compactInfo(
              Icons.storefront_outlined,
              'Store',
              challan.storeName,
            ),
          ),

          const SizedBox(width: 14),

// --------------------------------------------------
// TRANSPORT
// --------------------------------------------------

          SizedBox(
            width: 155,
            child: _compactInfo(
              Icons.local_shipping_outlined,
              'Transport',
              challan.transportName,
            ),
          ),

          const SizedBox(width: 14),

// --------------------------------------------------
// ITEMS
// --------------------------------------------------

          SizedBox(
            width: 60,
            child: _compactInfo(
              Icons.inventory_2_outlined,
              'Items',
              '${challan.itemCount}',
            ),
          ),

          const SizedBox(width: 14),

// --------------------------------------------------
// GRAND TOTAL
// --------------------------------------------------

          SizedBox(
            width: 115,
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.end,
              mainAxisAlignment:
              MainAxisAlignment.center,
              children: [
                const Text(
                  'GRAND TOTAL',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    color: Color(0xff92979D),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _money(challan.grandTotal),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

// --------------------------------------------------
// ACTIONS
// --------------------------------------------------

          _buildActions(
            challan,
            isExpanded,
          ),
        ],
      ),
    );
  }

// ==========================================================
// MAIN INFO
// ==========================================================

  Widget _buildMainInfo(
      PurchaseChallanListModel challan,
      ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                challan.challanNo.isEmpty
                    ? 'No Challan No.'
                    : '#${challan.challanNo}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(width: 7),

            _statusBadge('PURCHASE'),
          ],
        ),

        const SizedBox(height: 5),

        Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 12,
              color: Color(0xff858A90),
            ),
            const SizedBox(width: 5),
            Text(
              _formatDate(challan.challanDate),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xff656A70),
              ),
            ),
            const SizedBox(width: 12),
            const Icon(
              Icons.person_outline_rounded,
              size: 13,
              color: Color(0xff858A90),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                challan.supplierId.isEmpty
                    ? 'Supplier -'
                    : 'Supplier ${getSupplierName(challan.supplierId)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xff656A70),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String getSupplierName(String id) {
    final list = partyJson['PartyList'] as List<dynamic>?;

    if (list == null || id.trim().isEmpty) {
      return '';
    }

    final party = list.cast<Map<String, dynamic>>().firstWhere(
          (e) => e['id']?.toString() == id.toString(),
      orElse: () => <String, dynamic>{},
    );

    return party['company']?.toString() ?? '';
  }

// ==========================================================
// COMPACT INFO
// ==========================================================

  Widget _compactInfo(
      IconData icon,
      String label,
      String value,
      ) {
    final displayValue =
    value.trim().isEmpty ? '-' : value.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 12,
              color: const Color(0xff858A90),
            ),
            const SizedBox(width: 4),
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 7.5,
                fontWeight: FontWeight.w600,
                letterSpacing: .3,
                color: Color(0xff999EA4),
              ),
            ),
          ],
        ),

        const SizedBox(height: 4),

        Text(
          displayValue,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: Color(0xff41464C),
          ),
        ),
      ],
    );
  }

// ==========================================================
// STATUS BADGE
// ==========================================================

  Widget _statusBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: const Color(0xffEEF0F2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 7,
          fontWeight: FontWeight.w600,
          letterSpacing: .3,
          color: Color(0xff666B71),
        ),
      ),
    );
  }

// ==========================================================
// ACTIONS
// ==========================================================

  Widget _buildActions(
      PurchaseChallanListModel challan,
      bool isExpanded,
      ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
// ----------------------------------------------------
// VIEW
// ----------------------------------------------------

        _actionButton(
          icon: Icons.visibility_outlined,
          tooltip: 'View',
          onTap: () => _openChallan(challan),
        ),

        const SizedBox(width: 5),

// ----------------------------------------------------
// EDIT
// ----------------------------------------------------

        _actionButton(
          icon: Icons.edit_outlined,
          tooltip: 'Edit',
          onTap: () => _editChallan(challan),
        ),

        const SizedBox(width: 5),

// ----------------------------------------------------
// PRINT
// ----------------------------------------------------

        _actionButton(
          icon: Icons.print_outlined,
          tooltip: 'Print',
          onTap: () => _printChallan(challan),
        ),

        const SizedBox(width: 7),

// ----------------------------------------------------
// EXPAND
// ----------------------------------------------------

        Tooltip(
          message: isExpanded
              ? 'Collapse'
              : 'Show full details',
          child: Material(
            color: isExpanded
                ?  themeColor
                : const Color(0xffF0F2F4),
            borderRadius: BorderRadius.circular(7),
            child: InkWell(
              onTap: () => _toggleExpanded(challan.id),
              borderRadius: BorderRadius.circular(7),
              child: AnimatedContainer(
                duration: const Duration(
                  milliseconds: 180,
                ),
                width: 34,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                    color: isExpanded
                        ? const Color(0xff202328)
                        : const Color(0xffD9DDE2),
                  ),
                ),
                child: AnimatedRotation(
                  turns: isExpanded ? .5 : 0,
                  duration: const Duration(
                    milliseconds: 180,
                  ),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: isExpanded
                        ? Colors.white
                        : const Color(0xff4D5258),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

// ==========================================================
// ACTION BUTTON
// ==========================================================

  Widget _actionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: const Color(0xffF4F5F6),
        borderRadius: BorderRadius.circular(7),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(7),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7),
              border: Border.all(
                color: const Color(0xffDDE1E5),
              ),
            ),
            child: Icon(
              icon,
              size: 15,
              color: const Color(0xff4A4F55),
            ),
          ),
        ),
      ),
    );
  }

// ==========================================================
// EXPANDED DATA
// ==========================================================

  Widget _buildExpandedData(
      PurchaseChallanListModel challan,
      ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        16,
        13,
        16,
        14,
      ),
      decoration: const BoxDecoration(
        color: Color(0xffF8F9FA),
        border: Border(
          top: BorderSide(
            color: Color(0xffE1E4E7),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
// --------------------------------------------------
// DETAILS TITLE
// --------------------------------------------------

          Row(
            children: [
              const Icon(
                Icons.article_outlined,
                size: 16,
                color: Color(0xff5D6369),
              ),
              const SizedBox(width: 6),
              const Text(
                'Challan Details',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff363B40),
                ),
              ),
              const Spacer(),
              Text(
                'ID: ${challan.id}',
                style: const TextStyle(
                  fontSize: 9,
                  color: Color(0xff92979D),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 11),

// --------------------------------------------------
// INFORMATION GRID
// --------------------------------------------------

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _detailBox(
                'Challan No.',
                challan.challanNo,
                Icons.receipt_long_outlined,
              ),
              _detailBox(
                'Challan Date',
                _formatDate(challan.challanDate),
                Icons.calendar_today_outlined,
              ),
              _detailBox(
                'Supplier ID',
                challan.supplierId,
                Icons.person_outline_rounded,
              ),
              _detailBox(
                'GST No.',
                challan.gstNo,
                Icons.badge_outlined,
              ),
              _detailBox(
                'LR No.',
                challan.lrNo,
                Icons.local_shipping_outlined,
              ),
              _detailBox(
                'LR Date',
                _formatDate(challan.lrDate),
                Icons.calendar_month_outlined,
              ),
              _detailBox(
                'Store',
                challan.storeName,
                Icons.storefront_outlined,
              ),
              _detailBox(
                'Transport',
                challan.transportName,
                Icons.local_shipping_outlined,
              ),
              _detailBox(
                'Agent',
                challan.agentName,
                Icons.person_outline_rounded,
              ),
              _detailBox(
                'Item Count',
                '${challan.itemCount}',
                Icons.inventory_2_outlined,
              ),
            ],
          ),

          const SizedBox(height: 12),

// --------------------------------------------------
// AMOUNT SECTION
// --------------------------------------------------

          _sectionTitle(
            Icons.calculate_outlined,
            'Amount Summary',
          ),

          const SizedBox(height: 8),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _amountBox(
                'Goods Value',
                challan.valueOfGood,
              ),
              _amountBox(
                'Additional Discount',
                challan.additionalDiscountTotal,
                isDiscount: true,
              ),
              _amountBox(
                'Additional Charges',
                challan.additionalChargeValue,
              ),
              _amountBox(
                'Final Discount',
                challan.finalDiscount,
                isDiscount: true,
              ),
              _amountBox(
                'Taxable Amount',
                challan.taxableAmount,
              ),
              _amountBox(
                'SGST',
                challan.sgst,
              ),
              _amountBox(
                'CGST',
                challan.cgst,
              ),
              _amountBox(
                'IGST',
                challan.igst,
              ),
              _grandTotalBox(
                challan.grandTotal,
              ),
            ],
          ),

// --------------------------------------------------
// REMARK
// --------------------------------------------------

          if (challan.remark.trim().isNotEmpty) ...[
            const SizedBox(height: 12),

            _sectionTitle(
              Icons.notes_outlined,
              'Remark',
            ),

            const SizedBox(height: 7),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(7),
                border: Border.all(
                  color: const Color(0xffE0E3E6),
                ),
              ),
              child: Text(
                challan.remark,
                style: const TextStyle(
                  fontSize: 10.5,
                  height: 1.4,
                  color: Color(0xff4E5359),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],

          const SizedBox(height: 12),

// --------------------------------------------------
// CREATED / UPDATED
// --------------------------------------------------

          Row(
            children: [
              _dateInfo(
                'Created',
                challan.createdAt,
              ),
              const SizedBox(width: 20),
              _dateInfo(
                'Updated',
                challan.updatedAt,
              ),
            ],
          ),
        ],
      ),
    );
  }

// ==========================================================
// DETAIL BOX
// ==========================================================

  Widget _detailBox(
      String title,
      String value,
      IconData icon,
      ) {
    final displayValue =
    value.trim().isEmpty ? '-' : value.trim();

    return Container(
      width: 190,
      constraints: const BoxConstraints(
        minHeight: 52,
      ),
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: const Color(0xffE0E3E6),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 27,
            height: 27,
            decoration: BoxDecoration(
              color: const Color(0xffF0F2F4),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              size: 14,
              color: const Color(0xff666C72),
            ),
          ),

          const SizedBox(width: 7),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              mainAxisAlignment:
              MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    color: Color(0xff969BA1),
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  displayValue,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xff3E4348),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

// ==========================================================
// SECTION TITLE
// ==========================================================

  Widget _sectionTitle(
      IconData icon,
      String title,
      ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 15,
          color: const Color(0xff5F656B),
        ),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Color(0xff4A4F55),
          ),
        ),
      ],
    );
  }

// ==========================================================
// AMOUNT BOX
// ==========================================================

  Widget _amountBox(
      String title,
      double value, {
        bool isDiscount = false,
      }) {
    return Container(
      width: 145,
      height: 52,
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: const Color(0xffE0E3E6),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w600,
              color: Color(0xff92979D),
            ),
          ),

          const SizedBox(height: 3),

          Text(
            '${isDiscount ? '-' : ''}${_money(value)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDiscount
                  ? const Color(0xffA85B5B)
                  : const Color(0xff3D4247),
            ),
          ),
        ],
      ),
    );
  }

// ==========================================================
// GRAND TOTAL BOX
// ==========================================================

  Widget _grandTotalBox(double value) {
    return Container(
      width: 170,
      height: 52,
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
      ),
      decoration: BoxDecoration(
        color: themeColor,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.payments_outlined,
            size: 18,
            color: Colors.white70,
          ),

          const SizedBox(width: 7),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              mainAxisAlignment:
              MainAxisAlignment.center,
              children: [
                const Text(
                  'GRAND TOTAL',
                  style: TextStyle(
                    fontSize: 7.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white60,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  _money(value),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

// ==========================================================
// DATE INFO
// ==========================================================

  Widget _dateInfo(
      String title,
      String value,
      ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.schedule_outlined,
          size: 12,
          color: Color(0xff999EA4),
        ),
        const SizedBox(width: 5),
        Text(
          '$title: ',
          style: const TextStyle(
            fontSize: 8.5,
            fontWeight: FontWeight.w700,
            color: Color(0xff92979D),
          ),
        ),
        Text(
          value.isEmpty ? '-' : value,
          style: const TextStyle(
            fontSize: 8.5,
            fontWeight: FontWeight.w600,
            color: Color(0xff656A70),
          ),
        ),
      ],
    );
  }

// ==========================================================
// TOGGLE EXPAND
// ==========================================================

  void _toggleExpanded(String id) {
    setState(() {
      if (expandedIds.contains(id)) {
        expandedIds.remove(id);
      } else {
        expandedIds.add(id);
      }
    });
  }

// ==========================================================
// CREATE NEW
// ==========================================================

  void _createNewChallan() {
    widget.routesController.setRoute(
      "/purchasePage",
    );
  }

// ==========================================================
// VIEW
// ==========================================================

  void _openChallan(
      PurchaseChallanListModel challan,
      ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'View challan #${challan.challanNo}',
        ),
        duration: const Duration(
          milliseconds: 900,
        ),
      ),
    );

// TODO:
// Open challan details page.
  }

// ==========================================================
// EDIT
// ==========================================================

  void _editChallan(
      PurchaseChallanListModel challan,
      ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Edit challan #${challan.challanNo}',
        ),
        duration: const Duration(
          milliseconds: 900,
        ),
      ),
    );

// TODO:
// Navigate to edit purchase challan.
  }

// ==========================================================
// PRINT
// ==========================================================

  void _printChallan(
      PurchaseChallanListModel challan,
      ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Print challan #${challan.challanNo}',
        ),
        duration: const Duration(
          milliseconds: 900,
        ),
      ),
    );

// TODO:
// Add PDF / print logic.
  }

// ==========================================================
// DATE FORMAT
// ==========================================================

  String _formatDate(String value) {
    if (value.trim().isEmpty) {
      return '-';
    }

    if (value.contains(' ')) {
      return value.split(' ').first;
    }

    return value;
  }

// ==========================================================
// MONEY
// ==========================================================

  String _money(double value) {
    return '₹${value.toStringAsFixed(2)}';
  }

// ==========================================================
// ERROR
// ==========================================================

  Widget _buildError() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 360,
        ),
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xffE1E4E8),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xffFDECEC),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                color: Color(0xffD33A3A),
                size: 25,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'Unable to load challans',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xff25282C),
              ),
            ),

            const SizedBox(height: 5),

            Text(
              controller.errorMessage ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                height: 1.4,
                color: Color(0xff777C82),
              ),
            ),

            const SizedBox(height: 14),

            OutlinedButton.icon(
              onPressed: controller.getAllChallans,
              icon: const Icon(
                Icons.refresh_rounded,
                size: 16,
              ),
              label: const Text(
                'Try Again',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

// ==========================================================
// EMPTY
// ==========================================================

  Widget _buildEmpty() {
    final isSearching = searchText.isNotEmpty;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: const Color(0xffE0E3E7),
              ),
            ),
            child: Icon(
              isSearching
                  ? Icons.search_off_rounded
                  : Icons.receipt_long_outlined,
              size: 27,
              color: const Color(0xff70757B),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            isSearching
                ? 'No challans found'
                : 'No purchase challans',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xff25282C),
            ),
          ),

          const SizedBox(height: 5),

          Text(
            isSearching
                ? 'Try another search keyword.'
                : 'Purchase challans will appear here.',
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xff777C82),
            ),
          ),

          if (!isSearching) ...[
            const SizedBox(height: 14),

            ElevatedButton.icon(
              onPressed: _createNewChallan,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff17191C),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
              icon: const Icon(
                Icons.add_rounded,
                size: 16,
              ),
              label: const Text(
                'Create Challan',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

