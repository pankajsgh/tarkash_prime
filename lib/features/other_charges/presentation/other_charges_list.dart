import 'package:calculation_panel/core/theme/colors.dart';
import 'package:flutter/material.dart';
import '../../../core/vars/global_vars.dart';
import '../../dashboard/presentaion/erp_top_header.dart';
import '../data/model/other_charge_model.dart';
import '../data/other_chagres_controller.dart';
import 'other_chagres_screen.dart';

class OtherChargeListScreen extends StatefulWidget {
  const OtherChargeListScreen({super.key});

  @override
  State<OtherChargeListScreen> createState() => _OtherChargeListScreenState();
}

class _OtherChargeListScreenState extends State<OtherChargeListScreen> {
  // ===========================================================================
  // COLORS
  // ===========================================================================

  static const Color backgroundColor = Color(0xFFF5F7FA);
  static const Color textColor = Color(0xFF101828);
  static const Color secondaryText = Color(0xFF667085);
  // static const Color borderColor = Color(0xFFE4E7EC);
  static const Color headerColor = Color(0xFFF8FAFC);
  static const Color green = Color(0xFF12B76A);
  static const Color greenBg = Color(0xFFECFDF3);
  static const Color red = Color(0xFFF04438);
  static const Color redBg = Color(0xFFFEF3F2);
  static const Color blue = Color(0xFF2E6FDE);
  static const Color blueBg = Color(0xFFEFF8FF);

  // ===========================================================================
  // CONTROLLER
  // ===========================================================================

  late OtherChargeController controller;

  bool isLoading = false;

  final TextEditingController searchController = TextEditingController();

  String selectedFilter = 'All';

  // ===========================================================================
  // INIT
  // ===========================================================================

  @override
  void initState() {
    super.initState();
    GlobalVars.globalRoutes = "/otherChargeScreen";
    controller = OtherChargeController();
    _loadData();
  }

  // ===========================================================================
  // LOAD
  // ===========================================================================

  Future<void> _loadData() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      await controller.loadOtherCharges('');

      if (!mounted) return;

      setState(() {});
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load charges: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }


  Future<void> _addNewCharge() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.fromLTRB(
            16,
            50, // 👈 top padding
            16,
            20,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.88,
            child: const CreateOtherChargeScreen(),
          ),
        );
      },
    );

    if (result == true) {
      await _loadData();
    }
  }

  // ===========================================================================
  // EDIT
  // ===========================================================================

  Future<void> _editCharge(OtherChargeModel charge) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.fromLTRB(
            16,
            50, // 👈 top padding
            16,
            20,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.88,
            child:  CreateOtherChargeScreen(chargeData: charge,),
          ),
        );
      },
    );

    if (result == true) {
      await _loadData();
    }
  }

  // ===========================================================================
  // DELETE
  // ===========================================================================

  Future<void> _deleteCharge(OtherChargeModel charge) async {

    final result = await controller.deleteOtherCharge(
       id: charge.id.toString(),
    );

    if (result == true) {
      await _loadData();
    }


    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Delete API is not connected yet.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ===========================================================================
  // DISPOSE
  // ===========================================================================

  @override
  void dispose() {
    searchController.dispose();
    controller.dispose();

    super.dispose();
  }

  // ===========================================================================
  // FILTER DATA
  // ===========================================================================

  List<OtherChargeModel> get filteredCharges {
    final query = searchController.text.trim().toLowerCase();

    return controller.allCharges.where((charge) {
      final bool active = charge.isActive == '1';

      final bool statusMatch = switch (selectedFilter) {
        'Active' => active,
        'Inactive' => !active,
        _ => true,
      };

      if (!statusMatch) {
        return false;
      }

      if (query.isEmpty) {
        return true;
      }

      final searchableText = [
        charge.chargeName,
        charge.printName,
        charge.chargeType,
        charge.chargeNature,
        charge.defaultValue,
        charge.calculationType,
        charge.appliedOn,
        charge.distributionMethod,
        charge.taxTreatment,
        charge.hsn,
      ].join(' ').toLowerCase();

      return searchableText.contains(query);
    }).toList();
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      // ========================================================================
      // APP BAR
      // ========================================================================


      // ========================================================================
      // BODY
      // ========================================================================

      body: RefreshIndicator(
        onRefresh: _loadData,
        color: Colors.black,
        child: _buildBody(),
      ),
    );
  }

  // ===========================================================================
  // BODY
  // ===========================================================================

  Widget _buildBody() {
    if (isLoading && controller.allCharges.isEmpty) {
      return const Center(
        child: SizedBox(
          width: 26,
          height: 26,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Colors.black,
          ),
        ),
      );
    }

    if (controller.allCharges.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        _buildTopHeader(),
        _buildTopControls(),
        const SizedBox(height: 12),

        _buildSummary(),

        const SizedBox(height: 12),

        Expanded(
          child: _buildTable(),
        ),
      ],
    );
  }

  Widget _buildTopHeader() {
    return Container(
      height: 56,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.only(
        left: 18,
        right: 16,
      ),
      child: Row(
        children: [
          // ============================================================
          // ICON
          // ============================================================
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: themeColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              size: 18,
              color: Colors.white,
            ),
          ),

          const SizedBox(width: 10),

          // ============================================================
          // TITLE
          // ============================================================
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Other Charges',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Manage charges & calculations',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: secondaryText,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),

          // ============================================================
          // REFRESH
          // ============================================================
          IconButton(
            tooltip: 'Refresh',
            onPressed: isLoading ? null : _loadData,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
            icon: AnimatedRotation(
              turns: isLoading ? 1 : 0,
              duration: const Duration(milliseconds: 500),
              child: const Icon(
                Icons.refresh_rounded,
                size: 21,
              ),
            ),
          ),

          const SizedBox(width: 4),

          // ============================================================
          // ADD NEW BUTTON
          // ============================================================
          SizedBox(
            height: 38,
            child: ElevatedButton.icon(
              onPressed: _addNewCharge,
              icon: const Icon(
                Icons.add_rounded,
                size: 17,
              ),
              label: const Text(
                'Add New',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor ,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  // ===========================================================================
  // TOP CONTROLS
  // ===========================================================================

  Widget _buildTopControls() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: borderColor,
              ),
            ),
            child: TextField(
              controller: searchController,
              onChanged: (_) {
                setState(() {});
              },
              style: const TextStyle(
                fontSize: 12,
                color: textColor,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  size: 19,
                  color: Color(0xFF98A2B3),
                ),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                  onPressed: () {
                    searchController.clear();
                    setState(() {});
                  },
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 17,
                    color: Color(0xFF98A2B3),
                  ),
                )
                    : null,
                hintText: 'Search charge, print name, HSN...',
                hintStyle: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF98A2B3),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 10),

        _buildFilterButton('All'),
        const SizedBox(width: 6),
        _buildFilterButton('Active'),
        const SizedBox(width: 6),
        _buildFilterButton('Inactive'),
      ],
    );
  }

  // ===========================================================================
  // FILTER BUTTON
  // ===========================================================================

  Widget _buildFilterButton(String value) {
    final bool selected = selectedFilter == value;

    return InkWell(
      onTap: () {
        setState(() {
          selectedFilter = value;
        });
      },
      borderRadius: BorderRadius.circular(7),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 38,
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
        ),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? themeColor : Colors.white,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(
            color: selected ? themeColor : borderColor,
          ),
        ),
        child: Text(
          value,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : secondaryText,
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // SUMMARY
  // ===========================================================================

  Widget _buildSummary() {
    final total = controller.allCharges.length;

    final active = controller.allCharges
        .where((element) => element.isActive == '1')
        .length;

    final inactive = total - active;

    return Container(
      height: 66,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryItem(
              icon: Icons.receipt_long_outlined,
              title: 'Total Charges',
              value: total.toString(),
              iconBackground: const Color(0xFFF2F4F7),
              iconColor: const Color(0xFF475467),
            ),
          ),

          _summaryDivider(),

          Expanded(
            child: _buildSummaryItem(
              icon: Icons.check_circle_outline_rounded,
              title: 'Active',
              value: active.toString(),
              iconBackground: greenBg,
              iconColor: green,
            ),
          ),

          _summaryDivider(),

          Expanded(
            child: _buildSummaryItem(
              icon: Icons.cancel_outlined,
              title: 'Inactive',
              value: inactive.toString(),
              iconBackground: redBg,
              iconColor: red,
            ),
          ),

          _summaryDivider(),

          Expanded(
            child: _buildSummaryItem(
              icon: Icons.filter_list_rounded,
              title: 'Showing',
              value: filteredCharges.length.toString(),
              iconBackground: blueBg,
              iconColor: blue,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // SUMMARY ITEM
  // ===========================================================================

  Widget _buildSummaryItem({
    required IconData icon,
    required String title,
    required String value,
    required Color iconBackground,
    required Color iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 18,
              color: iconColor,
            ),
          ),

          const SizedBox(width: 10),

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 10,
                  color: secondaryText,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // DIVIDER
  // ===========================================================================

  Widget _summaryDivider() {
    return Container(
      width: 1,
      height: 34,
      color: borderColor,
    );
  }

  // ===========================================================================
  // TABLE
  // ===========================================================================

  Widget _buildTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: const Color(0xFFD0D5DD),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Scrollbar(
        thumbVisibility: true,
        notificationPredicate: (_) => true,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: 1580,
            child: Column(
              children: [
                _buildTableHeader(),

                Expanded(
                  child: filteredCharges.isEmpty
                      ? _buildNoSearchResult()
                      : ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: filteredCharges.length,
                    itemBuilder: (context, index) {
                      final charge = filteredCharges[index];

                      return _buildTableRow(
                        charge,
                        index,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // TABLE HEADER
  // ===========================================================================

  Widget _buildTableHeader() {
    return Container(
      height: 44,
      decoration: const BoxDecoration(
        color: headerColor,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFD0D5DD),
          ),
        ),
      ),
      child: Row(
        children: [
          _headerCell('#', 50, center: true),

          _headerCell(
            'Charge Name',
            185,
          ),

          _headerCell(
            'Print Name',
            150,
          ),

          _headerCell(
            'Type',
            110,
          ),

          _headerCell(
            'Nature',
            115,
          ),

          _headerCell(
            'Default Value',
            120,
          ),

          _headerCell(
            'Calculation',
            125,
          ),

          _headerCell(
            'Applied On',
            125,
          ),

          _headerCell(
            'Distribution',
            135,
          ),

          _headerCell(
            'Tax Treatment',
            120,
          ),

          _headerCell(
            'HSN',
            90,
          ),

          _headerCell(
            'Status',
            100,
            center: true,
          ),

          _headerCell(
            'Action',
            115,
            center: true,
            isLast: true,
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // HEADER CELL
  // ===========================================================================

  Widget _headerCell(
      String title,
      double width, {
        bool center = false,
        bool isLast = false,
      }) {
    return Container(
      width: width,
      height: double.infinity,
      alignment: center
          ? Alignment.center
          : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
      ),
      decoration: isLast
          ? null
          : const BoxDecoration(
        border: Border(
          right: BorderSide(
            color: Color(0xFFEAECF0),
          ),
        ),
      ),
      child: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Color(0xFF475467),
        ),
      ),
    );
  }

  // ===========================================================================
  // TABLE ROW
  // ===========================================================================

  Widget _buildTableRow(
      OtherChargeModel charge,
      int index,
      ) {
    final bool isActive = charge.isActive == '1';

    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: () => _editCharge(charge),
        hoverColor: const Color(0xFFF8FAFC),
        child: Container(
          height: 46,
          decoration:  BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Color(0xFFEAECF0),
              ),
            ),
          ),
          child: Row(
            children: [
              _dataCell(
                (index + 1).toString(),
                50,
                center: true,
                color: const Color(0xFF98A2B3),
                bold: true,
              ),

              _chargeNameCell(
                charge.chargeName,
                185,
              ),

              _dataCell(
                charge.printName,
                150,
                muted: true,
              ),

              _typeCell(
                charge.chargeType,
                110,
              ),

              _dataCellNature(
                charge.chargeNature,
                115,
                color: Colors.white
              ),

              _valueCell(
                charge.defaultValue,
                120,
              ),

              _dataCell(
                charge.calculationType,
                125,
              ),

              _dataCell(
                charge.appliedOn,
                125,
              ),

              _dataCell(
                charge.distributionMethod,
                135,
              ),

              _dataCell(
                charge.taxTreatment,
                120,
                muted: true,
              ),

              _dataCell(
                charge.hsn,
                90,
              ),

              _statusCell(
                isActive,
                100,
              ),

              _actionCell(
                charge,
                115,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // CHARGE NAME
  // ===========================================================================

  Widget _chargeNameCell(
      String? value,
      double width,
      ) {
    final displayValue = _displayValue(value);

    return Container(
      width: width,
      height: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
      ),
      alignment: Alignment.centerLeft,
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(
            color: Color(0xFFEAECF0),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F7),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.receipt_outlined,
              size: 15,
              color: Color(0xFF667085),
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Text(
              displayValue,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // TYPE
  // ===========================================================================

  Widget _typeCell(
      String? value,
      double width,
      ) {
    final text = _displayValue(value);

    final bool isPercentage =
    text.toLowerCase().contains('percentage');

    return Container(
      width: width,
      height: double.infinity,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
      ),
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(
            color: Color(0xFFEAECF0),
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 7,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: isPercentage
              ? blueBg
              : const Color(0xFFF2F4F7),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: isPercentage
                ? const Color(0xFFB2DDFF)
                : borderColor,
          ),
        ),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: isPercentage
                ? const Color(0xFF175CD3)
                : const Color(0xFF475467),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // VALUE
  // ===========================================================================

  Widget _valueCell(
      String? value,
      double width,
      ) {
    final text = _displayValue(value);

    return Container(
      width: width,
      height: double.infinity,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
      ),
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(
            color: Color(0xFFEAECF0),
          ),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  // ===========================================================================
  // DATA CELL
  // ===========================================================================

  Widget _dataCell(
      String? value,
      double width, {
        bool center = false,
        bool bold = false,
        bool muted = false,
        Color? color,
      }) {
    final displayValue = _displayValue(value);

    return Container(
      width: width,
      height: double.infinity,
      alignment: center
          ? Alignment.center
          : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
      ),
      decoration: BoxDecoration(

        border: const Border(
          right: BorderSide(
            color: Color(0xFFEAECF0),
          ),
        ),
      ),
      child: Text(
        displayValue,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 10,
          fontWeight: bold
              ? FontWeight.w600
              : FontWeight.w400,
          color: color ??
              (muted
                  ? secondaryText
                  : const Color(0xFF475467)),
        ),
      ),
    );
  }

  Widget _dataCellNature(
      String? value,
      double width, {
        bool center = false,
        bool bold = true,
        bool muted = false,
        Color? color,
      }) {
    final displayValue = _displayValue(value);

    return Container(
      width: width,
      height: double.infinity,
      alignment: center
          ? Alignment.center
          : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
      ),
      decoration: BoxDecoration(
        border: const Border(
          right: BorderSide(
            color: Color(0xFFEAECF0),
          ),
        ),
      ),
      child: Container(
       decoration: BoxDecoration(
         borderRadius: BorderRadius.circular(8),
         color: value=="Deduction"? Colors.green: Colors.redAccent,
       ),

        padding: const EdgeInsets.all(6.0),
        child: Text(
          displayValue,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11,
            fontWeight: bold
                ? FontWeight.w600
                : FontWeight.w400,
            color: color ??
                (muted
                    ? secondaryText
                    : const Color(0xFF475467)),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // STATUS
  // ===========================================================================

  Widget _statusCell(
      bool isActive,
      double width,
      ) {
    return Container(
      width: width,
      height: double.infinity,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
      ),
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(
            color: Color(0xFFEAECF0),
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 5,
        ),
        decoration: BoxDecoration(
          color: isActive ? greenBg : redBg,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: isActive
                ? const Color(0xFFA6F4C5)
                : const Color(0xFFFECDCA),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: isActive ? green : red,
                shape: BoxShape.circle,
              ),
            ),

            const SizedBox(width: 5),

            Text(
              isActive ? 'Active' : 'Inactive',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: isActive
                    ? const Color(0xFF027A48)
                    : const Color(0xFFB42318),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // ACTION
  // ===========================================================================

  Widget _actionCell(
      OtherChargeModel charge,
      double width,
      ) {
    return Container(
      width: width,
      height: double.infinity,
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _actionButton(
            icon: Icons.edit_outlined,
            tooltip: 'Edit',
            onTap: () => _editCharge(charge),
          ),

          const SizedBox(width: 5),

          PopupMenuButton<String>(
            padding: EdgeInsets.zero,
            tooltip: 'More actions',

            icon: const Icon(
              Icons.more_horiz_rounded,
              size: 19,
              color: Color(0xFF667085),
            ),

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),

            onSelected: (value) {
              switch (value) {
                case 'edit':
                  _editCharge(charge);
                  break;

                case 'delete':
                  _deleteCharge(charge);
                  break;
              }
            },

            itemBuilder: (context) {
              return const [
                PopupMenuItem<String>(
                  value: 'edit',
                  height: 40,
                  child: Row(
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        size: 17,
                      ),
                      SizedBox(width: 9),
                      Text(
                        'Edit',
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'delete',
                  height: 40,
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_outline_rounded,
                        size: 17,
                        color: red,
                      ),
                      SizedBox(width: 9),
                      Text(
                        'Delete',
                        style: TextStyle(
                          fontSize: 12,
                          color: red,
                        ),
                      ),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // ACTION BUTTON
  // ===========================================================================

  Widget _actionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            width: 31,
            height: 31,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: borderColor,
              ),
            ),
            child: Icon(
              icon,
              size: 16,
              color: const Color(0xFF475467),
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // EMPTY SEARCH
  // ===========================================================================

  Widget _buildNoSearchResult() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.search_off_rounded,
              color: Color(0xFF667085),
              size: 23,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'No matching charges',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),

          const SizedBox(height: 4),

          const Text(
            'Try another search or filter.',
            style: TextStyle(
              fontSize: 11,
              color: secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // EMPTY
  // ===========================================================================

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.sizeOf(context).height * .55,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F4F7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.receipt_long_outlined,
                    size: 30,
                    color: Color(0xFF98A2B3),
                  ),
                ),

                const SizedBox(height: 14),

                const Text(
                  'No other charges found',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),

                const SizedBox(height: 5),

                const Text(
                  'Add a new charge to get started',
                  style: TextStyle(
                    fontSize: 11,
                    color: secondaryText,
                  ),
                ),

                const SizedBox(height: 16),

                ElevatedButton.icon(
                  onPressed: _addNewCharge,
                  icon: const Icon(
                    Icons.add_rounded,
                    size: 17,
                  ),
                  label: const Text(
                    'Add New Charge',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 11,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // VALUE HELPER
  // ===========================================================================

  String _displayValue(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '-';
    }

    return value.trim();
  }
}