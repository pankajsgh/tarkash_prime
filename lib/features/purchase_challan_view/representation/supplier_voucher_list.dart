import 'package:calculation_panel/core/database/local_data/party_json.dart';
import 'package:calculation_panel/core/theme/colors.dart';
import 'package:calculation_panel/core/widget/intractive_loder.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../../../core/network/api_path.dart';
import '../../../core/network/api_repository.dart';
import '../../../core/routes/routes.dart';
import '../../../core/vars/global_vars.dart';
import '../../dashboard/data/controller/routes_controller.dart';
import '../../log_detail/view/log_detail_screen.dart';
import '../../purchase_challan/model/purchase_challan_detail_model.dart';
import '../controller/purchase_challan_list_controller.dart';
import '../model/purchase_challan_list_model.dart';
import 'challan_detail_page.dart';
import 'challan_pdf_servies.dart';

// ============================================================
// Supplier Vouchers LIST PAGE
// ============================================================

class SupplierVoucherListPage extends StatefulWidget {
  final RoutesController routesController;

  const SupplierVoucherListPage({super.key, required this.routesController});

  @override
  State<SupplierVoucherListPage> createState() => _SupplierVoucherListPageState();
}

class _SupplierVoucherListPageState extends State<SupplierVoucherListPage> {
  late final PurchaseChallanListController controller;

  final TextEditingController searchController = TextEditingController();

  String searchText = '';

  final Set<String> expandedIds = <String>{};

  // ==========================================================
  // INIT
  // ==========================================================

  @override
  void initState() {
    super.initState();

    GlobalVars.globalRoutes = Routes.supplierVoucherScreen;

    controller = PurchaseChallanListController(listApi: ApiPath.supplierVoucherListApi);

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
      backgroundColor: const Color(0xffF3F5F7),
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
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xffDEE2E6))),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 900;

          if (compact) {
            return Column(
              children: [
                Row(
                  children: [
                    _buildHeaderIcon(),
                    const SizedBox(width: 9),
                    Expanded(child: _buildHeaderTitle(total, filtered)),
                    const SizedBox(width: 7),
                    _headerButton(
                      icon: Icons.refresh_rounded,
                      tooltip: 'Refresh',
                      loading: controller.isLoading,
                      onTap: controller.isLoading
                          ? null
                          : controller.getAllChallans,
                    ),
                    const SizedBox(width: 6),
                    _newChallanButton(compact: true),
                  ],
                ),
                const SizedBox(height: 7),
                SizedBox(
                  width: double.infinity,
                  height: 36,
                  child: _buildSearchField(),
                ),
              ],
            );
          }

          return Row(
            children: [
              _buildHeaderIcon(),
              const SizedBox(width: 9),
              Expanded(child: _buildHeaderTitle(total, filtered)),
              const SizedBox(width: 12),
              SizedBox(width: 260, height: 36, child: _buildSearchField()),
              const SizedBox(width: 6),
              _headerButton(
                icon: Icons.refresh_rounded,
                tooltip: 'Refresh',
                loading: controller.isLoading,
                onTap: controller.isLoading ? null : controller.getAllChallans,
              ),
              const SizedBox(width: 6),
              _newChallanButton(),
            ],
          );
        },
      ),
    );
  }

  // ==========================================================
  // HEADER ICON
  // ==========================================================

  Widget _buildHeaderIcon() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: themeColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.receipt_long_rounded,
        size: 19,
        color: Colors.white,
      ),
    );
  }

  // ==========================================================
  // HEADER TITLE
  // ==========================================================

  Widget _buildHeaderTitle(int total, int filtered) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Supplier Vouchers',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xff202328),
          ),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            _countBadge(searchText.isEmpty ? total : filtered),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                searchText.isEmpty ? 'records' : 'of $total records',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff858A90),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ==========================================================
  // COUNT BADGE
  // ==========================================================

  Widget _countBadge(int value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xffEEF1F3),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        '$value',
        style: const TextStyle(
          fontSize: 8.5,
          fontWeight: FontWeight.w700,
          color: Color(0xff4C5258),
        ),
      ),
    );
  }

  // ==========================================================
  // NEW CHALLAN BUTTON
  // ==========================================================

  Widget _newChallanButton({bool compact = false}) {
    return SizedBox(
      height: 36,
      child: ElevatedButton.icon(
        onPressed: _createNewChallan,
        style: ElevatedButton.styleFrom(
          backgroundColor: themeColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: compact ? 9 : 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
        ),
        icon: const Icon(Icons.add_rounded, size: 16),
        label: compact
            ? const Text(
                'New',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
              )
            : const Text(
                'New Challan',
                style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700),
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
        color: const Color(0xffF0F2F4),
        borderRadius: BorderRadius.circular(7),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(7),
          child: SizedBox(
            width: 36,
            height: 36,
            child: loading
                ? const Padding(
                    padding: EdgeInsets.all(10),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xff555A60),
                    ),
                  )
                : Icon(icon, size: 18, color: const Color(0xff3D4247)),
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
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: const Color(0xffD9DDE2)),
      ),
      child: TextField(
        controller: searchController,
        style: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w500,
          color: Color(0xff292D32),
        ),
        decoration: InputDecoration(
          hintText: 'Search challan, supplier, GST, LR...',
          hintStyle: const TextStyle(fontSize: 10.5, color: Color(0xff969BA1)),
          prefixIcon: const Icon(
            Icons.search_rounded,
            size: 17,
            color: Color(0xff777C82),
          ),
          suffixIcon: searchText.isNotEmpty
              ? IconButton(
                  onPressed: searchController.clear,
                  splashRadius: 15,
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 15,
                    color: Color(0xff777C82),
                  ),
                )
              : null,
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 9,
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // BODY
  // ==========================================================

  Widget _buildBody() {
    if (controller.isLoading && controller.challans.isEmpty) {
      return InteractiveLoadingView();
    }

    if (controller.errorMessage != null && controller.challans.isEmpty) {
      return _buildError();
    }

    final data = filteredChallans;

    if (data.isEmpty) {
      return _buildEmpty();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: data.length,
        itemBuilder: (context, index) {
          return _buildChallanCard(data[index], index);
        },
      ),
    );
  }

  // ==========================================================
  // CHALLAN CARD
  // ==========================================================

  Widget _buildChallanCard(PurchaseChallanListModel challan, int index) {
    final isExpanded = expandedIds.contains(challan.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: isExpanded
              ? themeColor.withValues(alpha: .35)
              : const Color(0xffE0E3E7),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .025),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _buildCompactRow(challan, index, isExpanded),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        if (width < 760) {
          return _buildSmallCompactRow(challan, index, isExpanded);
        }

        return Container(
          constraints: const BoxConstraints(minHeight: 68),
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
          child: Row(
            children: [
              _indexBox(index),
              const SizedBox(width: 8),

              Expanded(flex: 3, child: _buildMainInfo(challan)),

              const SizedBox(width: 10),

              SizedBox(
                width: 80,
                child: _compactInfo(
                  Icons.storefront_outlined,
                  'Store',
                  challan.storeName,
                ),
              ),

              const SizedBox(width: 10),

              SizedBox(
                width: 160,
                child: _compactInfo(
                  Icons.local_shipping_outlined,
                  'Transport',
                  challan.transportName,
                ),
              ),

              const SizedBox(width: 20),

              SizedBox(
                width: 48,
                child: _compactInfo(
                  Icons.inventory_2_outlined,
                  'Items',
                  '${challan.itemCount}',
                ),
              ),

              const SizedBox(width: 10),

              _buildStatus(challan.status),

              const SizedBox(width: 10),

              SizedBox(
                width: 100,
                child: _buildGrandTotalCompact(challan.grandTotal),
              ),

              const SizedBox(width: 9),

              _buildActions(challan, isExpanded),
            ],
          ),
        );
      },
    );
  }

  // ==========================================================
  // SMALL COMPACT ROW
  // ==========================================================

  Widget _buildSmallCompactRow(
    PurchaseChallanListModel challan,
    int index,
    bool isExpanded,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(9, 8, 8, 8),
      child: Row(
        children: [
          _indexBox(index),
          const SizedBox(width: 8),

          Expanded(child: _buildMainInfo(challan)),

          const SizedBox(width: 8),

          _buildStatus(challan.status),

          const SizedBox(width: 8),

          _buildGrandTotalCompact(challan.grandTotal),

          const SizedBox(width: 7),

          _buildExpandButton(challan.id, isExpanded),
        ],
      ),
    );
  }

  // ==========================================================
  // INDEX BOX
  // ==========================================================

  Widget _indexBox(int index) {
    return Container(
      width: 27,
      height: 27,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xffF0F2F4),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '${index + 1}',
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: Color(0xff70757B),
        ),
      ),
    );
  }

  // ==========================================================
  // MAIN INFO
  // ==========================================================

  Widget _buildMainInfo(PurchaseChallanListModel challan) {

    final supplier = challan.supplierName ?? '';

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
                    : '#${challan.referenceNo}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff292D32),
                ),
              ),
            ),
            const SizedBox(width: 6),
            _statusBadge('PURCHASE'),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 11,
              color: Color(0xff858A90),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                _formatDate(challan.challanDate),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff656A70),
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.person_outline_rounded,
              size: 12,
              color: Color(0xff858A90),
            ),
            const SizedBox(width: 3),
            Flexible(
              child: Text(
                supplier.isEmpty ? 'Supplier -' : supplier,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 9.5,
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

  // ==========================================================
  // COMPACT INFO
  // ==========================================================

  Widget _compactInfo(IconData icon, String label, String value) {
    final displayValue = value.trim().isEmpty ? '-' : value.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Icon(icon, size: 11, color: const Color(0xff858A90)),
            const SizedBox(width: 3),
            Flexible(
              child: Text(
                label.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 7,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .2,
                  color: Color(0xff999EA4),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          displayValue,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            color: Color(0xff41464C),
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // STATUS
  // ==========================================================

  Widget _buildStatus(String status) {
    final value = status.trim().toLowerCase();

    Color backgroundColor;
    Color borderColor;
    Color textColor;
    Color dotColor;
    String label;
    IconData icon;

    switch (value) {
      case 'completed':
        backgroundColor = const Color(0xffEAF7EF);
        borderColor = const Color(0xffCBEAD6);
        textColor = const Color(0xff27804A);
        dotColor = const Color(0xff2E9B57);
        label = 'Completed';
        icon = Icons.check_circle_outline_rounded;
        break;

      case 'cancel':
      case 'cancelled':
      case 'canceled':
        backgroundColor = const Color(0xffFDECEC);
        borderColor = const Color(0xffF3C6C6);
        textColor = const Color(0xffC62828);
        dotColor = const Color(0xffD32F2F);
        label = 'Cancelled';
        icon = Icons.cancel_outlined;
        break;

      case 'pending':
      default:
        backgroundColor = const Color(0xffFFF5E6);
        borderColor = const Color(0xffF3D9A8);
        textColor = const Color(0xffA96812);
        dotColor = const Color(0xffD88A18);
        label = 'Pending';
        icon = Icons.schedule_outlined;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 11,
            color: dotColor,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // GRAND TOTAL COMPACT
  // ==========================================================

  Widget _buildGrandTotalCompact(double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'GRAND TOTAL',
          maxLines: 1,
          style: TextStyle(
            fontSize: 7,
            fontWeight: FontWeight.w700,
            color: Color(0xff92979D),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          _money(value),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: Color(0xff25292D),
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
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2.5),
      decoration: BoxDecoration(
        color: const Color(0xffEEF0F2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 6.5,
          fontWeight: FontWeight.w700,
          letterSpacing: .25,
          color: Color(0xff666B71),
        ),
      ),
    );
  }

  // ==========================================================
  // ACTIONS
  // ==========================================================

  Widget _buildActions(PurchaseChallanListModel challan, bool isExpanded) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _actionButton(
          icon: Icons.visibility_outlined,
          tooltip: 'View',
          onTap: () => _openChallan(challan),
        ),
        const SizedBox(width: 6),
        _actionButton(
          icon: Icons.edit_outlined,
          tooltip: 'Edit',
          onTap: () => _editChallan(challan),
        ),
        const SizedBox(width: 6),
        _actionButton(
          icon: Icons.print_outlined,
          tooltip: 'Print',
          onTap: () => openChallanPdf(challan),
        ),
        const SizedBox(width: 6),
        _buildExpandButton(challan.id, isExpanded),
      ],
    );
  }

  // ==========================================================
  // EXPAND BUTTON
  // ==========================================================

  Widget _buildExpandButton(String id, bool isExpanded) {
    return Tooltip(
      message: isExpanded ? 'Collapse' : 'Show details',
      child: Material(
        color: isExpanded ? themeColor : const Color(0xffF0F2F4),
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: () => _toggleExpanded(id),
          borderRadius: BorderRadius.circular(6),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isExpanded ? themeColor : const Color(0xffD9DDE2),
              ),
            ),
            child: AnimatedRotation(
              turns: isExpanded ? .5 : 0,
              duration: const Duration(milliseconds: 180),
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 19,
                color: isExpanded ? Colors.white : const Color(0xff4D5258),
              ),
            ),
          ),
        ),
      ),
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
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xffDDE1E5)),
            ),
            child: Icon(icon, size: 14, color: const Color(0xff4A4F55)),
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // DELETE CHALLAN
  // ==========================================================

  Future<void> _deleteChallan(PurchaseChallanListModel challan) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 22,
                color: Color(0xffD32F2F),
              ),
              SizedBox(width: 8),
              Text(
                'Delete Challan?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to delete challan '
            '${challan.challanNo}?\n\n'
            'All items and extra charges will also be deleted.',
            style: const TextStyle(fontSize: 12.5, height: 1.4),
          ),
          actions: [
            OutlinedButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              icon: const Icon(Icons.delete_outline, size: 16),
              label: const Text('Delete'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffD32F2F),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 22,
              vertical: 20,
            ),
            content: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
                const SizedBox(width: 14),
                const Text(
                  'Deleting challan...',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff3D4247),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    try {
      final result = await controller.deleteChallan(challan.id, apiPath: ApiPath.deleteSupplierVoucherApi,);

      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (!mounted) return;

      if (result == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Challan deleted successfully'),
            duration: Duration(seconds: 2),
          ),
        );

        await controller.getAllChallans();
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete challan: $e'),
          backgroundColor: const Color(0xffD32F2F),
        ),
      );
    }
  }

  // ==========================================================
  // CANCEL CHALLAN
  // ==========================================================

  Future<void> _cancelChallan(PurchaseChallanListModel challan) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 22,
                color: Color(0xffD32F2F),
              ),
              SizedBox(width: 8),
              Text(
                'Cancel Challan?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to cancel challan '
            '${challan.challanNo}?',
            style: const TextStyle(fontSize: 12.5, height: 1.4),
          ),
          actions: [
            OutlinedButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Keep'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              icon: null,
              label: const Text('Cancel Challan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 22,
              vertical: 20,
            ),
            content: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
                const SizedBox(width: 14),
                const Text(
                  'Cancelling challan...',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff3D4247),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    try {
      final result = await controller.cancelChallan(challan.id);

      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (!mounted) return;

      if (result == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Challan cancelled successfully'),
            duration: Duration(seconds: 2),
          ),
        );

        await controller.getAllChallans();
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to cancel challan: $e'),
          backgroundColor: const Color(0xffD32F2F),
        ),
      );
    }
  }

  // ==========================================================
  // EXPANDED DATA
  // ==========================================================

  Widget _buildExpandedData(PurchaseChallanListModel challan) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
      decoration: const BoxDecoration(
        color: Color(0xffF8F9FA),
        border: Border(top: BorderSide(color: Color(0xffE1E4E7))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --------------------------------------------------
          // TITLE
          // --------------------------------------------------

          Row(
            children: [
              Container(
                width: 27,
                height: 27,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xffE0E3E6)),
                ),
                child: const Icon(
                  Icons.article_outlined,
                  size: 14,
                  color: Color(0xff5D6369),
                ),
              ),
              const SizedBox(width: 7),
              const Text(
                'Challan Details',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff363B40),
                ),
              ),
              const Spacer(),
              _smallIdBadge(challan.id),
            ],
          ),

          const SizedBox(height: 9),

          // --------------------------------------------------
          // INFORMATION
          // --------------------------------------------------
          Wrap(
            spacing: 7,
            runSpacing: 7,
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
              _detailBox('GST No.', challan.gstNo, Icons.badge_outlined),
              _detailBox('LR No.', challan.lrNo, Icons.local_shipping_outlined),
              _detailBox(
                'LR Date',
                _formatDate(challan.lrDate),
                Icons.calendar_month_outlined,
              ),
              _detailBox('Store', challan.storeName, Icons.storefront_outlined),
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

            ],
          ),

          // --------------------------------------------------
          // AMOUNT TITLE
          // --------------------------------------------------
          _sectionTitle(Icons.calculate_outlined, 'Amount Summary'),

          const SizedBox(height: 7),

          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              _amountBox('Goods Value', challan.valueOfGood),
              _amountBox(
                'Additional Discount',
                challan.additionalDiscountTotal,
                isDiscount: true,
              ),
              _amountBox('Additional Charges', challan.additionalChargeValue),
              _amountBox(
                'Final Discount',
                challan.finalDiscount,
                isDiscount: true,
              ),
              _amountBox('Taxable Amount', challan.taxableAmount),
              _amountBox('SGST', challan.sgst),
              _amountBox('CGST', challan.cgst),
              _amountBox('IGST', challan.igst),
              _grandTotalBox(challan.grandTotal),
            ],
          ),

          // --------------------------------------------------
          // REMARK
          // --------------------------------------------------
          if (challan.remark.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            _sectionTitle(Icons.notes_outlined, 'Remark'),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xffE0E3E6)),
              ),
              child: Text(
                challan.remark,
                style: const TextStyle(
                  fontSize: 10,
                  height: 1.35,
                  color: Color(0xff4E5359),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],

          const SizedBox(height: 10),

          // --------------------------------------------------
          // FOOTER
          // --------------------------------------------------
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _dateInfo('Created', challan.createdAt),
                        ),
                        Expanded(
                          child: _dateInfo('Updated', challan.updatedAt),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if(challan.status=="pending")
                        Expanded(child: _cancelButton(challan)),
                        const SizedBox(width: 7),
                        Expanded(child: _deleteButton(challan)),
                      ],
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  _dateInfo('Created', challan.createdAt),
                  const SizedBox(width: 18),
                  _dateInfo('Updated', challan.updatedAt),
                  const Spacer(),
                  if(challan.status=="pending")
                  _cancelButton(challan),
                  const SizedBox(width: 7),
                  _deleteButton(challan),
                  const SizedBox(width: 7),
                  _logButton(challan)
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // ID BADGE
  // ==========================================================

  Widget _smallIdBadge(String id) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xffEEF0F2),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        'ID: $id',
        style: const TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.w700,
          color: Color(0xff858A90),
        ),
      ),
    );
  }

  // ==========================================================
  // CANCEL BUTTON
  // ==========================================================

  Widget _cancelButton(PurchaseChallanListModel challan) {
    return SizedBox(
      width: 120,
      height: 33,
      child: OutlinedButton.icon(
        onPressed: () {
          if (challan != null) {
            _cancelChallan(challan);
          }
        },
        icon: const Icon(Icons.cancel_outlined, size: 15),
        label: const Text(
          'Cancel Challan',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xff2563EB),
          side: const BorderSide(color: Color(0xff93B4F5)),
          backgroundColor: const Color(0xffF5F8FF),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Future<void> _showChallanLogs(
      PurchaseChallanListModel challan,
      ) async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.all(20),
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: SizedBox(
            width: 900,
            height: MediaQuery.of(dialogContext).size.height * 0.85,
            child: LogListScreen(
              invId: challan.id.toString(),
              challanNo: challan.challanNo,
              title: challan.referenceNo,
            ),
          ),
        );
      },
    );
  }

  // ==========================================================
  // DELETE BUTTON
  // ==========================================================

  Widget _deleteButton(PurchaseChallanListModel challan) {
    return SizedBox(
      width: 120,
      height: 33,
      child: OutlinedButton.icon(
        onPressed: () {
          if (challan != null) {
            _deleteChallan(challan);
          }
        },
        icon: const Icon(Icons.delete_outline_rounded, size: 15),
        label: const Text(
          'Delete Challan',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xffD32F2F),
          side: const BorderSide(color: Color(0xffE57373)),
          backgroundColor: const Color(0xffFFF5F5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _logButton(PurchaseChallanListModel challan) {
    return SizedBox(
      width: 120,
      height: 33,
      child: OutlinedButton.icon(
        onPressed: () {
          if (challan != null) {
            _showChallanLogs(challan);
          }
        },
        icon: const Icon(Icons.history_rounded, size: 15),
        label: const Text(
          'Challan Logs',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF3267D5),
          side: const BorderSide(color: Color(0xFF90CAF9)),
          backgroundColor: const Color(0xFFF3F7FF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }



  // ==========================================================
  // DETAIL BOX
  // ==========================================================

  Widget _detailBox(String title, String value, IconData icon) {
    final displayValue = value.trim().isEmpty ? '-' : value.trim();

    return Container(
      width: 156,
      constraints: const BoxConstraints(minHeight: 42),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xffE0E3E6)),
      ),
      child: Row(
        children: [
          Container(
            width: 25,
            height: 25,
            decoration: BoxDecoration(
              color: const Color(0xffF0F2F4),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Icon(icon, size: 13, color: const Color(0xff666C72)),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 7.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xff969BA1),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  displayValue,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 9.5,
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

  Widget _sectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xff5F656B)),
        const SizedBox(width: 5),
        Text(
          title,
          style: const TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            color: Color(0xff4A4F55),
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // AMOUNT BOX
  // ==========================================================

  Widget _amountBox(String title, double value, {bool isDiscount = false}) {
    return Container(
      width: 135,
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xffE0E3E6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 7.5,
              fontWeight: FontWeight.w600,
              color: Color(0xff92979D),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${isDiscount ? '-' : ''}${_money(value)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
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
      width: 155,
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        color: themeColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          const Icon(Icons.payments_outlined, size: 17, color: Colors.white70),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'GRAND TOTAL',
                  style: TextStyle(
                    fontSize: 7,
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
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
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

  Widget _dateInfo(String title, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.schedule_outlined, size: 11, color: Color(0xff999EA4)),
        const SizedBox(width: 4),
        Text(
          '$title: ',
          style: const TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w700,
            color: Color(0xff92979D),
          ),
        ),
        Flexible(
          child: Text(
            value.isEmpty ? '-' : value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w600,
              color: Color(0xff656A70),
            ),
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
    widget.routesController.setRoute(Routes.supplierVoucherSubmitScreen);
  }

  // ==========================================================
  // VIEW
  // ==========================================================

  Future<PurchaseChallanDetails?> getPreviousData(String id)async {
    Map<String, dynamic> requestBody = {};
    requestBody['id'] = id;

    var response = await ApiProvider.createServerRequest(
      apiUrl: ApiPath.supplierVoucherDetailApi,
      requestBody: requestBody,
      isFormData: true,
    );

    if (response['status'] != null && response['status']) {
      try {

        PurchaseChallanDetails purchaseChallanDetails = PurchaseChallanDetails.fromJson(response['data']);


        return purchaseChallanDetails;
      } catch (e) {
        print(e);
      }
    }
    return null;
  }


  Future<void> _openChallan(PurchaseChallanListModel challan) async {
    final challanDetails = await getPreviousData(challan.id);

    if (!mounted || challanDetails == null) return;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.all(20),
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: SizedBox(
            width: 1200,
            height: MediaQuery.of(context).size.height * 0.9,
            child: PurchaseChallanDetailsScreen(
              challan: challanDetails,
              title: 'Supplier Voucher',
            ),
          ),
        );
      },
    );
  }
  // ==========================================================
  // EDIT
  // ==========================================================

  Future<void> openChallanPdf(PurchaseChallanListModel challan) async {
    final challanDetails = await getPreviousData(challan.id);

    if (!mounted || challanDetails == null) return;

    final pdfBytes = await PurchaseChallanPdfService().buildChallanPdf(
      challanDetails,
    );

    await Printing.layoutPdf(
      onLayout: (_) async => pdfBytes,
    );

    await Printing.layoutPdf(
      onLayout: (_) async => pdfBytes,
    );
  }

  void _editChallan(PurchaseChallanListModel challan) {
    widget.routesController.setRoute(
      Routes.supplierVoucherSubmitScreen,
      data: {'id': challan.id},
    );
  }

  // ==========================================================
  // PRINT
  // ==========================================================

  void _printChallan(PurchaseChallanListModel challan) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Print challan #${challan.challanNo}'),
        duration: const Duration(milliseconds: 900),
      ),
    );
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
        constraints: const BoxConstraints(maxWidth: 340),
        margin: const EdgeInsets.all(18),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: const Color(0xffE1E4E8)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xffFDECEC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                color: Color(0xffD33A3A),
                size: 23,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Unable to load challans',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: Color(0xff25282C),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              controller.errorMessage ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10.5,
                height: 1.35,
                color: Color(0xff777C82),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: controller.getAllChallans,
              icon: const Icon(Icons.refresh_rounded, size: 15),
              label: const Text(
                'Try Again',
                style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700),
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
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xffE0E3E7)),
            ),
            child: Icon(
              isSearching
                  ? Icons.search_off_rounded
                  : Icons.receipt_long_outlined,
              size: 25,
              color: const Color(0xff70757B),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            isSearching ? 'No Supplier Vouchers found' : 'No Supplier Vouchers',
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: Color(0xff25282C),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isSearching
                ? 'Try another search keyword.'
                : 'Supplier Vouchers will appear here.',
            style: const TextStyle(fontSize: 10.5, color: Color(0xff777C82)),
          ),
          if (!isSearching) ...[
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _createNewChallan,
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
              icon: const Icon(Icons.add_rounded, size: 15),
              label: const Text(
                'Create Challan',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
