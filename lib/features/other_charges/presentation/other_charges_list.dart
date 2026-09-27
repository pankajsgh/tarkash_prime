import 'package:calculation_panel/core/theme/colors.dart';
import 'package:flutter/material.dart';

import '../../../core/vars/global_vars.dart';
import '../data/model/other_charge_model.dart';
import '../data/other_chagres_controller.dart';
import 'other_chagres_screen.dart';

class OtherChargeListScreen extends StatefulWidget {
  const OtherChargeListScreen({super.key});

  @override
  State<OtherChargeListScreen> createState() =>
      _OtherChargeListScreenState();
}

class _OtherChargeListScreenState extends State<OtherChargeListScreen> {
// ===========================================================================
// COLORS
// ===========================================================================

  static const Color backgroundColor = Color(0xFFF6F8FB);
  static const Color cardColor = Colors.white;

  static const Color textColor = Color(0xFF101828);
  static const Color secondaryText = Color(0xFF667085);
  static const Color mutedText = Color(0xFF98A2B3);

  static const Color headerColor = Color(0xFFF8FAFC);
  static const Color border = Color(0xFFE4E7EC);
  static const Color divider = Color(0xFFEAECF0);

  static const Color green = Color(0xFF12B76A);
  static const Color greenDark = Color(0xFF027A48);
  static const Color greenBg = Color(0xFFECFDF3);

  static const Color red = Color(0xFFF04438);
  static const Color redDark = Color(0xFFB42318);
  static const Color redBg = Color(0xFFFEF3F2);

  static const Color blue = Color(0xFF2E6FDE);
  static const Color blueDark = Color(0xFF175CD3);
  static const Color blueBg = Color(0xFFEFF8FF);

  static const Color purple = Color(0xFF7F56D9);
  static const Color purpleBg = Color(0xFFF4F3FF);

// ===========================================================================
// CONTROLLER
// ===========================================================================

  late OtherChargeController controller;

  bool isLoading = false;

  final TextEditingController searchController =
  TextEditingController();

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
// LOAD DATA
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
          content: Text(
            'Failed to load charges: $e',
            style: const TextStyle(fontSize: 12),
          ),
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

// ===========================================================================
// ADD
// ===========================================================================

  Future<void> _addNewCharge() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.fromLTRB(
            16,
            45,
            16,
            20,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * .88,
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
            45,
            16,
            20,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * .88,
            child: CreateOtherChargeScreen(
              chargeData: charge,
            ),
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
    final confirmed = await _showDeleteConfirmation(charge);

    if (!confirmed) return;

    try {
      final result = await controller.deleteOtherCharge(
        id: charge.id.toString(),
      );

      if (!mounted) return;

      if (result == true) {
        await _loadData();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Charge deleted successfully',
              style: TextStyle(fontSize: 12),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to delete charge: $e',
            style: const TextStyle(fontSize: 12),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

// ===========================================================================
// DELETE CONFIRMATION
// ===========================================================================

  Future<bool> _showDeleteConfirmation(
      OtherChargeModel charge,
      ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: const Text(
            'Delete Charge?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          content: Text(
            'Are you sure you want to delete "${_displayValue(charge.chargeName)}"?',
            style: const TextStyle(
              fontSize: 12,
              color: secondaryText,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 12,
                  color: secondaryText,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: red,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
              child: const Text(
                'Delete',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );

    return result ?? false;
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
// FILTERED DATA
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
      body: RefreshIndicator(
        color: themeColor,
        onRefresh: _loadData,
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
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
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

        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              18,
              16,
              18,
              16,
            ),
            child: Column(
              children: [
                _buildTopControls(),

                const SizedBox(height: 14),

                _buildSummary(),

                const SizedBox(height: 14),

                Expanded(
                  child: _buildTable(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

// ===========================================================================
// TOP HEADER
// ===========================================================================

  Widget _buildTopHeader() {
    return Container(
      height: 64,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: border,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: Row(
        children: [
// ICON
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

          const SizedBox(width: 12),

// TITLE
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Other Charges',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Manage charges & calculations',
                style: TextStyle(
                  fontSize: 10,
                  color: secondaryText,
                ),
              ),
            ],
          ),

          const Spacer(),

// REFRESH
          Tooltip(
            message: 'Refresh',
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isLoading ? null : _loadData,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: border,
                    ),
                  ),
                  child: AnimatedRotation(
                    turns: isLoading ? 1 : 0,
                    duration: const Duration(
                      milliseconds: 500,
                    ),
                    child: const Icon(
                      Icons.refresh_rounded,
                      size: 19,
                      color: secondaryText,
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

// ADD BUTTON
          SizedBox(
            height: 38,
            child: ElevatedButton.icon(
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
                backgroundColor: themeColor,
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
// SEARCH
        Expanded(
          child: Container(
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: border,
              ),
            ),
            child: TextField(
              controller: searchController,
              onChanged: (_) {
                setState(() {});
              },
              style: const TextStyle(
                fontSize: 11.5,
                color: textColor,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  size: 19,
                  color: mutedText,
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
                    color: mutedText,
                  ),
                )
                    : null,
                hintText:
                'Search charge, print name, HSN, type...',
                hintStyle: const TextStyle(
                  fontSize: 11,
                  color: mutedText,
                ),
                contentPadding:
                const EdgeInsets.symmetric(
                  vertical: 11,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

// FILTER LABEL
        const Text(
          'Status:',
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: secondaryText,
          ),
        ),

        const SizedBox(width: 7),

        _buildFilterButton('All'),
        const SizedBox(width: 5),
        _buildFilterButton('Active'),
        const SizedBox(width: 5),
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
        duration: const Duration(milliseconds: 160),
        height: 36,
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
        ),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? themeColor
              : Colors.white,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(
            color: selected
                ? themeColor
                : border,
          ),
        ),
        child: Text(
          value,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: selected
                ? Colors.white
                : secondaryText,
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
        .where(
          (element) => element.isActive == '1',
    )
        .length;

    final inactive = total - active;

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            icon: Icons.receipt_long_outlined,
            title: 'Total Charges',
            value: total.toString(),
            iconBackground:
            const Color(0xFFF2F4F7),
            iconColor:
            const Color(0xFF475467),
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _buildSummaryCard(
            icon:
            Icons.check_circle_outline_rounded,
            title: 'Active',
            value: active.toString(),
            iconBackground: greenBg,
            iconColor: green,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _buildSummaryCard(
            icon: Icons.cancel_outlined,
            title: 'Inactive',
            value: inactive.toString(),
            iconBackground: redBg,
            iconColor: red,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _buildSummaryCard(
            icon: Icons.filter_list_rounded,
            title: 'Showing',
            value: filteredCharges.length
                .toString(),
            iconBackground: blueBg,
            iconColor: blue,
          ),
        ),
      ],
    );
  }

// ===========================================================================
// SUMMARY CARD
// ===========================================================================

  Widget _buildSummaryCard({
    required IconData icon,
    required String title,
    required String value,
    required Color iconBackground,
    required Color iconColor,
  }) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
      ),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
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
            mainAxisAlignment:
            MainAxisAlignment.center,
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 9.5,
                  color: secondaryText,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
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
// TABLE
// ===========================================================================

  Widget _buildTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: border,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Scrollbar(
        thumbVisibility: true,
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
                      : Scrollbar(
                    thumbVisibility: true,
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount:
                      filteredCharges.length,
                      itemBuilder:
                          (context, index) {
                        final charge =
                        filteredCharges[
                        index];

                        return _buildTableRow(
                          charge,
                          index,
                        );
                      },
                    ),
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
      height: 42,
      decoration: const BoxDecoration(
        color: headerColor,
        border: Border(
          bottom: BorderSide(
            color: border,
          ),
        ),
      ),
      child: Row(
        children: [
          _headerCell(
            '#',
            50,
            center: true,
          ),

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
            color: divider,
          ),
        ),
      ),
      child: Text(
        title.toUpperCase(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: .2,
          color: secondaryText,
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
    final bool isActive =
        charge.isActive == '1';

    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: () => _editCharge(charge),
        hoverColor: const Color(0xFFF9FAFB),
        child: Container(
          height: 48,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: divider,
              ),
            ),
          ),
          child: Row(
            children: [
              _dataCell(
                (index + 1).toString(),
                50,
                center: true,
                color: mutedText,
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

              _natureCell(
                charge.chargeNature,
                115,
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
            color: divider,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: purpleBg,
              borderRadius:
              BorderRadius.circular(7),
            ),
            child: const Icon(
              Icons.receipt_outlined,
              size: 15,
              color: purple,
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Text(
              _displayValue(value),
              maxLines: 1,
              overflow:
              TextOverflow.ellipsis,
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
// TYPE CELL
// ===========================================================================

  Widget _typeCell(
      String? value,
      double width,
      ) {
    final text = _displayValue(value);

    final bool isPercentage =
    text.toLowerCase().contains(
      'percentage',
    );

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
            color: divider,
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
          borderRadius:
          BorderRadius.circular(5),
          border: Border.all(
            color: isPercentage
                ? const Color(0xFFB2DDFF)
                : border,
          ),
        ),
        child: Text(
          text,
          maxLines: 1,
          overflow:
          TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 8.5,
            fontWeight: FontWeight.w700,
            color: isPercentage
                ? blueDark
                : const Color(0xFF475467),
          ),
        ),
      ),
    );
  }

// ===========================================================================
// NATURE CELL
// ===========================================================================

  Widget _natureCell(
      String? value,
      double width,
      ) {
    final text = _displayValue(value);

    final bool isDeduction =
        text.toLowerCase() == 'deduction';

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
            color: divider,
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 5,
        ),
        decoration: BoxDecoration(
          color: isDeduction
              ? greenBg
              : redBg,
          borderRadius:
          BorderRadius.circular(5),
          border: Border.all(
            color: isDeduction
                ? const Color(0xFFA6F4C5)
                : const Color(0xFFFECDCA),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isDeduction
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              size: 11,
              color: isDeduction
                  ? greenDark
                  : redDark,
            ),

            const SizedBox(width: 4),

            Text(
              text,
              maxLines: 1,
              overflow:
              TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 8.5,
                fontWeight: FontWeight.w700,
                color: isDeduction
                    ? greenDark
                    : redDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

// ===========================================================================
// VALUE CELL
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
            color: divider,
          ),
        ),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow:
        TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 10,
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
    return Container(
      width: width,
      height: double.infinity,
      alignment: center
          ? Alignment.center
          : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
      ),
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(
            color: divider,
          ),
        ),
      ),
      child: Text(
        _displayValue(value),
        maxLines: 1,
        overflow:
        TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 9.5,
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
            color: divider,
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 5,
        ),
        decoration: BoxDecoration(
          color:
          isActive ? greenBg : redBg,
          borderRadius:
          BorderRadius.circular(5),
          border: Border.all(
            color: isActive
                ? const Color(0xFFA6F4C5)
                : const Color(0xFFFECDCA),
          ),
        ),
        child: Row(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            Container(
              width: 5,
              height: 5,
              decoration:
              BoxDecoration(
                color: isActive
                    ? green
                    : red,
                shape:
                BoxShape.circle,
              ),
            ),

            const SizedBox(width: 5),

            Text(
              isActive
                  ? 'Active'
                  : 'Inactive',
              style: TextStyle(
                fontSize: 8.5,
                fontWeight:
                FontWeight.w700,
                color: isActive
                    ? greenDark
                    : redDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

// ===========================================================================
// ACTION CELL
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
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [
          _actionButton(
            icon: Icons.edit_outlined,
            tooltip: 'Edit',
            onTap: () =>
                _editCharge(charge),
          ),

          const SizedBox(width: 5),

          PopupMenuButton<String>(
            padding: EdgeInsets.zero,
            tooltip: 'More actions',
            icon: const Icon(
              Icons.more_horiz_rounded,
              size: 19,
              color: secondaryText,
            ),
            shape:
            RoundedRectangleBorder(
              borderRadius:
              BorderRadius.circular(8),
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
        borderRadius:
        BorderRadius.circular(6),
        child: InkWell(
          onTap: onTap,
          borderRadius:
          BorderRadius.circular(6),
          child: Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius:
              BorderRadius.circular(6),
              border: Border.all(
                color: border,
              ),
            ),
            child: Icon(
              icon,
              size: 15,
              color:
              const Color(0xFF475467),
            ),
          ),
        ),
      ),
    );
  }

// ===========================================================================
// NO SEARCH RESULT
// ===========================================================================

  Widget _buildNoSearchResult() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color:
              const Color(0xFFF2F4F7),
              borderRadius:
              BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.search_off_rounded,
              color: secondaryText,
              size: 24,
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
              fontSize: 10.5,
              color: secondaryText,
            ),
          ),
        ],
      ),
    );
  }

// ===========================================================================
// EMPTY STATE
// ===========================================================================

  Widget _buildEmptyState() {
    return ListView(
      physics:
      const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height:
          MediaQuery.sizeOf(context)
              .height *
              .65,
          child: Center(
            child: Column(
              mainAxisSize:
              MainAxisSize.min,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration:
                  BoxDecoration(
                    color:
                    const Color(
                      0xFFF2F4F7,
                    ),
                    borderRadius:
                    BorderRadius.circular(
                      17,
                    ),
                  ),
                  child: const Icon(
                    Icons
                        .receipt_long_outlined,
                    size: 32,
                    color: mutedText,
                  ),
                ),

                const SizedBox(height: 15),

                const Text(
                  'No other charges found',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                    FontWeight.w600,
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

                const SizedBox(height: 17),

                ElevatedButton.icon(
                  onPressed:
                  _addNewCharge,
                  icon: const Icon(
                    Icons.add_rounded,
                    size: 17,
                  ),
                  label: const Text(
                    'Add New Charge',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight:
                      FontWeight.w600,
                    ),
                  ),
                  style:
                  ElevatedButton.styleFrom(
                    backgroundColor:
                    themeColor,
                    foregroundColor:
                    Colors.white,
                    elevation: 0,
                    padding:
                    const EdgeInsets
                        .symmetric(
                      horizontal: 15,
                      vertical: 11,
                    ),
                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(
                        7,
                      ),
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
// DISPLAY VALUE
// ===========================================================================

  String _displayValue(String? value) {
    if (value == null ||
        value.trim().isEmpty) {
      return '-';
    }

    return value.trim();
  }
}

