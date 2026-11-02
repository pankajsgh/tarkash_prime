import 'package:calculation_panel/core/vars/global_vars.dart';
import 'package:calculation_panel/features/party_list/view/party_update.dart';
import 'package:flutter/material.dart';

import '../../../core/routes/routes.dart';
import '../../purchase_challan/model/party_model.dart';
import '../controller/party_list_controller.dart';

class PartyListScreen extends StatefulWidget {
  const PartyListScreen({super.key});

  @override
  State<PartyListScreen> createState() => _PartyListScreenState();
}

class _PartyListScreenState extends State<PartyListScreen> {
  late final PartyListController controller;

  String? expandedPartyId;
  bool isOpenEdit = false;
  Party? selectedParty;

  static const Color primary = Color(0xFF3267D5);
  static const Color background = Color(0xFFF5F7FB);
  static const Color textDark = Color(0xFF202938);
  static const Color textMuted = Color(0xFF7B8494);
  static const Color borderColor = Color(0xFFE5EAF2);
  static const Color lightBlue = Color(0xFFF0F5FF);

  @override
  void initState() {
    super.initState();
    GlobalVars.globalRoutes = Routes.accountScreen;
    controller = PartyListController();
    controller.loadParties(refresh: true);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: isOpenEdit
            ? PartyUpdateWidget(
          key: ValueKey(selectedParty?.id ?? 'new-party'),
          party: selectedParty,
          onCancel: _closeEditParty,
          onSaved: _onPartySaved,
        )
            : Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Column(
            children: [
              _header(),
              const SizedBox(height: 20),
              _toolbar(),
              const SizedBox(height: 16),
              Expanded(
                child: ListenableBuilder(
                  listenable: controller,
                  builder: (context, _) => _buildTable(),
                ),
              ),
              const SizedBox(height: 10),
              _footer(),
            ],
          ),
        ),
      ),
    );
  }

// ============================================================
// HEADER
// ============================================================

  Widget _header() {
    return Row(
      children: [
        Container(
          height: 46,
          width: 46,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF477DE5), Color(0xFF2859C5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: primary.withValues(alpha: 0.20),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.groups_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 13),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Party Management',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: textDark,
                  letterSpacing: -0.4,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Manage and view your party information',
                style: TextStyle(
                  fontSize: 11,
                  color: textMuted,
                ),
              ),
            ],
          ),
        ),
        OutlinedButton.icon(
          onPressed: () => _openEditParty(),
          icon: const Icon(Icons.add_rounded, size: 17),
          label: const Text('Add Party'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: primary,
            minimumSize: const Size(110, 39),
            padding: const EdgeInsets.symmetric(horizontal: 13),
            side: BorderSide.none,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 9),
        _iconButton(
          icon: Icons.refresh_rounded,
          tooltip: 'Refresh parties',
          onPressed: controller.refresh,
        ),
      ],
    );
  }

  Widget _iconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 39,
            width: 42,
            decoration: BoxDecoration(
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: primary, size: 19),
          ),
        ),
      ),
    );
  }

// ============================================================
// TOOLBAR
// ============================================================

  Widget _toolbar() {
    return Row(
      children: [
        Container(
          width: 390,
          height: 41,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor),
          ),
          child: TextField(
            controller: controller.searchController,
            onChanged: controller.onSearchChanged,
            style: const TextStyle(
              fontSize: 12,
              color: textDark,
            ),
            decoration: InputDecoration(
              hintText: 'Search code, company, mobile, GST...',
              hintStyle: const TextStyle(
                fontSize: 11,
                color: Color(0xFFADB5C3),
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                size: 19,
                color: primary,
              ),
              suffixIcon: ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller.searchController,
                builder: (context, value, _) {
                  if (value.text.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return IconButton(
                    tooltip: 'Clear search',
                    onPressed: () {
                      controller.searchController.clear();
                      controller.onSearchChanged('');
                    },
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: textMuted,
                    ),
                  );
                },
              ),
              filled: true,
              fillColor: Colors.transparent,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 10,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(width: 9),
        OutlinedButton.icon(
          onPressed: controller.refresh,
          icon: const Icon(Icons.sync_rounded, size: 16),
          label: const Text('Reload'),
          style: OutlinedButton.styleFrom(
            foregroundColor: primary,
            backgroundColor: Colors.white,
            minimumSize: const Size(90, 41),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            side: const BorderSide(color: borderColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Spacer(),
        Container(
          height: 41,
          padding: const EdgeInsets.symmetric(horizontal: 13),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                height: 25,
                width: 25,
                decoration: BoxDecoration(
                  color: lightBlue,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.people_alt_outlined,
                  color: primary,
                  size: 15,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Total parties',
                style: TextStyle(
                  fontSize: 11,
                  color: textMuted,
                ),
              ),
              const SizedBox(width: 9),
              Text(
                '${controller.totalData}',
                style: const TextStyle(
                  fontSize: 14,
                  color: textDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

// ============================================================
// TABLE
// ============================================================

  Widget _buildTable() {
    if (controller.isLoading && controller.parties.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: primary,
          strokeWidth: 2.5,
        ),
      );
    }

    if (controller.errorMessage.isNotEmpty &&
        controller.parties.isEmpty) {
      return _emptyState(
        icon: Icons.cloud_off_outlined,
        title: 'Unable to load parties',
        subtitle: controller.errorMessage,
        onRetry: controller.refresh,
      );
    }

    if (controller.parties.isEmpty) {
      return _emptyState(
        icon: Icons.person_search_rounded,
        title: 'No parties found',
        subtitle: 'Try searching with a different keyword.',
        onRetry: controller.refresh,
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1C3150).withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _tableHeader(),
          Expanded(
            child: ListView.builder(
              itemCount: controller.parties.length,
              itemBuilder: (context, index) {
                final party = controller.parties[index];
                final expanded =
                    expandedPartyId == party.id.toString();

                return Column(
                  children: [
                    _partyRow(
                      party: party,
                      index: index,
                      expanded: expanded,
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeInOut,
                      alignment: Alignment.topCenter,
                      child: expanded
                          ? _expandedDetails(party)
                          : const SizedBox.shrink(),
                    ),
                  ],
                );
              },
            ),
          ),
          if (controller.isLoadingMore)
            const LinearProgressIndicator(
              minHeight: 2,
              color: primary,
              backgroundColor: Color(0xFFE7EDFC),
            ),
          if (controller.errorMessage.isNotEmpty &&
              controller.parties.isNotEmpty)
            _loadError(),
        ],
      ),
    );
  }

  Widget _tableHeader() {
    return Container(
      height: 42,
      decoration: const BoxDecoration(
        color: Color(0xFFF3F6FB),
        border: Border(
          bottom: BorderSide(color: borderColor),
        ),
      ),
      child: Row(
        children: [
          _headerCell('', 42),
          _headerCell('CODE', 90),
          _headerCell('COMPANY / PARTY NAME', 270, flex: 3),
          _headerCell('PARTY TYPE', 125),
          _headerCell('MOBILE', 125),
          _headerCell('GST NUMBER', 155),
          _headerCell('CITY', 125),
          _headerCell('STATE', 130),
          _headerCell('DISCOUNT', 90),
          _headerCell('DETAILS', 75),
        ],
      ),
    );
  }

  Widget _headerCell(String text, double width, {int flex = 0}) {
    final child = Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 9,
          color: Color(0xFF7A8699),
          fontWeight: FontWeight.w700,
          letterSpacing: 0.55,
        ),
      ),
    );

    return flex > 0
        ? Expanded(flex: flex, child: child)
        : SizedBox(width: width, child: child);
  }

  Widget _partyRow({
    required Party party,
    required int index,
    required bool expanded,
  }) {
    final company = _value(party.company);
    final name = _value(party.name);
    final code = _value(party.customerCode);
    final mobile = _value(party.mobile);
    final gst = _value(party.gstNo);
    final city = _value(party.city?.name);
    final state = _value(party.state?.name);
    final discount = _value(party.discount);

    final partyType = party.partyTypeName;

    return Material(
      color: expanded
          ? const Color(0xFFEDF3FF)
          : index.isEven
          ? Colors.white
          : const Color(0xFFFCFDFF),
      child: InkWell(
        onTap: () {
          setState(() {
            expandedPartyId =
            expanded ? null : party.id.toString();
          });
        },
        hoverColor: const Color(0xFFF0F5FF),
        child: Container(
          constraints: const BoxConstraints(minHeight: 52),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFFEDF0F5)),
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 42,
                child: Icon(
                  expanded
                      ? Icons.keyboard_arrow_down_rounded
                      : Icons.chevron_right_rounded,
                  size: 20,
                  color: expanded ? primary : const Color(0xFF9AA5B5),
                ),
              ),
              _bodyCell(code, 90, isCode: true),
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        company.isNotEmpty ? company : name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: textDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (company.isNotEmpty &&
                          name.isNotEmpty &&
                          company.toLowerCase() != name.toLowerCase())
                        Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10,
                              color: textMuted,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              _partyTypeCell(partyType),
              _bodyCell(mobile, 125),
              _bodyCell(gst, 155),
              _bodyCell(city, 125),
              _bodyCell(state, 130),
              SizedBox(
                width: 90,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: discount.isEmpty
                      ? const Text(
                    '—',
                    style: TextStyle(
                      fontSize: 11,
                      color: textMuted,
                    ),
                  )
                      : Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F7EF),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: const Color(0xFFD4F0E0),
                      ),
                    ),
                    child: Text(
                      '$discount%',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF168354),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 75,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      expanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 19,
                      color: primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _partyTypeCell(String value) {
    final isSupplier = value == 'Supplier';

    return SizedBox(
      width: 125,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: isSupplier
                  ? const Color(0xFFFFF4E5)
                  : const Color(0xFFEAF2FF),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 10,
                color: isSupplier
                    ? const Color(0xFFAD6A0A)
                    : const Color(0xFF3267D5),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _bodyCell(
      String value,
      double width, {
        bool isCode = false,
      }) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 8,
        ),
        child: Text(
          value.isEmpty ? '—' : value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 10.5,
            color: isCode ? primary : textDark,
            fontWeight: isCode ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

// ============================================================
// EXPANDED DETAILS
// ============================================================

  Widget _expandedDetails(Party party) {
    final brands = party.brandList;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 17, 22, 18),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFE),
        border: Border(
          bottom: BorderSide(color: Color(0xFFDCE6FA)),
          left: BorderSide(color: Color(0xFFB7CCF8), width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 31,
                width: 31,
                decoration: BoxDecoration(
                  color: const Color(0xFFE7EEFF),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  color: primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 9),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Party Details',
                    style: TextStyle(
                      color: textDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Complete party information',
                    style: TextStyle(
                      fontSize: 10,
                      color: textMuted,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () => _openEditParty(party: party),
                icon: const Icon(Icons.edit_rounded, size: 14),
                label: const Text('Edit Party'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primary,
                  backgroundColor: Colors.white,
                  minimumSize: const Size(100, 33),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  side: const BorderSide(color: Color(0xFFD5E0F4)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
          _detailSection(
            title: 'GENERAL INFORMATION',
            icon: Icons.person_outline_rounded,
            children: [
              _detail('Company', party.company),
              _detail('Contact Person', party.name),
              _detail('Customer Code', party.customerCode),
              _detail('Party Type', party.partyTypeName),
              _detail('Mobile Number', party.mobile),
              _detail('GST Number', party.gstNo),
              _detail('Discount', party.discount),
            ],
          ),
          const SizedBox(height: 16),
          _detailSection(
            title: 'PRICING & MARGINS',
            icon: Icons.percent_rounded,
            children: [
              _detail('MRP Margin', party.mrp),
              _detail('Wholesale Margin', party.wholesale),
              _detail('Retail Margin', party.retail),
            ],
          ),
          const SizedBox(height: 16),
          _detailSection(
            title: 'LOCATION & ADDRESS',
            icon: Icons.location_on_outlined,
            children: [
              _detail('City', party.city?.name),
              _detail('State', party.state?.name),
              _detail('Pincode', party.pincode),
              _detail('Address', party.address, width: 360),
              _detail('Agency', party.agency?.name),
              _detail('Transport', party.transport?.name),
            ],
          ),
          if (brands != null && brands.isNotEmpty) ...[
            const SizedBox(height: 17),
            _detailSection(
              title: 'ASSIGNED BRANDS',
              icon: Icons.sell_outlined,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: brands
                        .where(
                          (brand) => _value(brand.brand).isNotEmpty,
                    )
                        .map<Widget>(
                          (brand) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE9EFFF),
                          border: Border.all(
                            color: const Color(0xFFD8E3FF),
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          brand.brand,
                          style: const TextStyle(
                            fontSize: 10,
                            color: primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                        .toList(),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _detailSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: primary),
              const SizedBox(width: 7),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 9,
                  color: textMuted,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Wrap(
            spacing: 25,
            runSpacing: 15,
            children: children,
          ),
        ],
      ),
    );
  }

  Widget _detail(
      String label,
      String? value, {
        double width = 175,
      }) {
    final text = _value(value);
    if (text.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              color: textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              color: textDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

// ============================================================
// FOOTER
// ============================================================

  Widget _footer() {
    return Row(
      children: [
        Container(
          height: 27,
          width: 27,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Icon(
            Icons.table_rows_rounded,
            size: 14,
            color: textMuted,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${controller.parties.length} records loaded',
          style: const TextStyle(
            fontSize: 10,
            color: textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        if (controller.isLoadingMore)
          const Row(
            children: [
              SizedBox(
                height: 13,
                width: 13,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: primary,
                ),
              ),
              SizedBox(width: 8),
              Text(
                'Loading more...',
                style: TextStyle(fontSize: 10, color: primary),
              ),
            ],
          )
        else if (controller.parties.length < controller.totalData)
          TextButton.icon(
            onPressed: controller.loadMore,
            icon: const Icon(Icons.expand_more_rounded, size: 17),
            label: const Text('Load next records'),
            style: TextButton.styleFrom(
              foregroundColor: primary,
              textStyle: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        else
          const Text(
            'All records loaded',
            style: TextStyle(
              fontSize: 10,
              color: textMuted,
            ),
          ),
      ],
    );
  }

  Widget _loadError() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      color: const Color(0xFFFFF7EA),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: 17,
            color: Color(0xFF9A5B00),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              controller.errorMessage,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF80520D),
              ),
            ),
          ),
          TextButton(
            onPressed: controller.loadMore,
            child: const Text(
              'Retry',
              style: TextStyle(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

// ============================================================
// EMPTY STATE
// ============================================================

  Widget _emptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onRetry,
  }) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 35,
          vertical: 30,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 66,
              width: 66,
              decoration: BoxDecoration(
                color: lightBlue,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, size: 31, color: primary),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                color: textDark,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: textMuted,
              ),
            ),
            const SizedBox(height: 15),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Try again'),
              style: OutlinedButton.styleFrom(
                foregroundColor: primary,
                side: const BorderSide(color: borderColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

// ============================================================
// ACTIONS - EXISTING FUNCTIONALITY PRESERVED
// ============================================================

  String _value(dynamic value) => value?.toString().trim() ?? '';

  void _openEditParty({Party? party}) {
    setState(() {
      selectedParty = party;
      isOpenEdit = true;
    });
  }

  void _closeEditParty() {
    if (!mounted) return;

    setState(() {
      isOpenEdit = false;
      selectedParty = null;
      expandedPartyId = null;
    });
  }

  void _onPartySaved(Map<String, dynamic> result) {
    debugPrint('Party saved: ${result['id'] ?? ''}');
    _closeEditParty();
    controller.loadParties(refresh: true);
  }
}
