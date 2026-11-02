import 'package:flutter/material.dart';
import '../../../core/routes/routes.dart';
import '../../../core/vars/global_vars.dart';
import '../controller/hsn_controller.dart';
import '../model/hsn_tax_slab.dart';

class HSNListScreen extends StatefulWidget {
  const HSNListScreen({super.key});

  @override
  State<HSNListScreen> createState() => _HSNListScreenState();
}

class _HSNListScreenState extends State<HSNListScreen> {
  static const Color primary = Color(0xFF3267D5);
  static const Color primaryDark = Color(0xFF244FAF);
  static const Color background = Color(0xFFF5F7FB);
  static const Color surface = Colors.white;
  static const Color dark = Color(0xFF1C2940);
  static const Color muted = Color(0xFF7C879A);
  static const Color border = Color(0xFFE6EAF1);
  static const Color green = Color(0xFF18865A);
  static const Color red = Color(0xFFD94A52);
  static const Color orange = Color(0xFFCB7A25);

  final TextEditingController _searchController =
  TextEditingController();

  late final HsnController hsnController;

  @override
  void initState() {
    super.initState();

    GlobalVars.globalRoutes = Routes.taxListScreen;

    hsnController = HsnController();
    hsnController.fetchHsnList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    hsnController.dispose();
    super.dispose();
  }

  // ============================================================
  // MAIN SCREEN
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: hsnController,
      builder: (context, _) {
        final records = hsnController.filteredList;
        final selected = hsnController.selectedHsn;
        final slabs = selected?.hsnTaxSlabs ?? <HsnTaxSlabModel>[];

        return Scaffold(
          backgroundColor: background,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final desktop = constraints.maxWidth >= 1000;
                final compact = constraints.maxWidth < 600;

                return Padding(
                  padding: EdgeInsets.all(compact ? 10 : 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(compact),
                      const SizedBox(height: 16),
                      _buildStatistics(
                        total: hsnController.hsnList.length,
                        displayed: records.length,
                        slabs: hsnController.totalSlabs,
                        compact: compact,
                      ),
                      const SizedBox(height: 14),
                      Expanded(
                        child: desktop
                            ? Row(
                          crossAxisAlignment:
                          CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: 9,
                              child: _buildRecordsPanel(
                                records,
                                desktop: true,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              flex: 11,
                              child: _buildSlabsPanel(
                                selected,
                                slabs,
                              ),
                            ),
                          ],
                        )
                            : Column(
                          children: [
                            Expanded(
                              flex: 5,
                              child: _buildRecordsPanel(
                                records,
                                desktop: false,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Expanded(
                              flex: 6,
                              child: _buildSlabsPanel(
                                selected,
                                slabs,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader(bool compact) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF477CE0),
                Color(0xFF2853B5),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(13),
            boxShadow: [
              BoxShadow(
                color: primary.withValues(alpha: 0.20),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.receipt_long_rounded,
            color: Colors.white,
            size: 23,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'HSN Master',
                style: TextStyle(
                  fontSize: 19,
                  height: 1.2,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                  color: dark,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'HSN codes and tax configuration',
                style: TextStyle(
                  fontSize: 11,
                  color: muted,
                ),
              ),
            ],
          ),
        ),
        _headerIconButton(
          icon: Icons.refresh_rounded,
          tooltip: 'Refresh',
          loading: hsnController.isLoading,
          onTap: hsnController.isLoading || hsnController.isSaving
              ? null
              : () => hsnController.fetchHsnList(),
        ),
        const SizedBox(width: 8),
        if (!compact)
          ElevatedButton.icon(
            onPressed: hsnController.isSaving
                ? null
                : _showCreateHsnDialog,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text(
              'Add HSN',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 13,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          )
        else
          _headerIconButton(
            icon: Icons.add_rounded,
            tooltip: 'Add HSN',
            onTap: hsnController.isSaving
                ? null
                : _showCreateHsnDialog,
          ),
      ],
    );
  }

  Widget _headerIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback? onTap,
    bool loading = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: surface,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(color: border),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: loading
                  ? const SizedBox(
                width: 17,
                height: 17,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: primary,
                ),
              )
                  : Icon(
                icon,
                size: 19,
                color: primary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // STATISTICS
  // ============================================================

  Widget _buildStatistics({
    required int total,
    required int displayed,
    required int slabs,
    required bool compact,
  }) {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            title: 'Total HSN',
            value: total,
            icon: Icons.inventory_2_outlined,
            color: primary,
            tint: const Color(0xFFEDF3FF),
          ),
        ),
        SizedBox(width: compact ? 7 : 12),
        Expanded(
          child: _statCard(
            title: 'Filtered',
            value: displayed,
            icon: Icons.filter_list_rounded,
            color: const Color(0xFF16855B),
            tint: const Color(0xFFEAF7F0),
          ),
        ),
        SizedBox(width: compact ? 7 : 12),
        Expanded(
          child: _statCard(
            title: 'Tax Slabs',
            value: slabs,
            icon: Icons.percent_rounded,
            color: const Color(0xFF8C60D1),
            tint: const Color(0xFFF3EDFF),
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required String title,
    required int value,
    required IconData icon,
    required Color color,
    required Color tint,
  }) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: dark.withValues(alpha: 0.025),
            blurRadius: 9,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    color: muted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                  child: Text(
                    '$value',
                    key: ValueKey(value),
                    style: const TextStyle(
                      fontSize: 17,
                      color: dark,
                      fontWeight: FontWeight.w600,
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

  // ============================================================
  // COMMON PANEL
  // ============================================================

  Widget _panel({required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: dark.withValues(alpha: 0.025),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }

  // ============================================================
  // HSN RECORDS PANEL
  // ============================================================

  Widget _buildRecordsPanel(
      List<HsnModelItem> records, {
        required bool desktop,
      }) {
    return _panel(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(13, 13, 13, 12),
            child: Row(
              children: [
                _sectionIcon(Icons.list_alt_rounded),
                const SizedBox(width: 9),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'HSN Records',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: dark,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Select a code to manage tax slabs',
                        style: TextStyle(
                          fontSize: 10,
                          color: muted,
                        ),
                      ),
                    ],
                  ),
                ),
                _countBadge(records.length),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: _buildSearchField(),
          ),
          const Divider(height: 1, color: border),
          Expanded(
            child: hsnController.isLoading &&
                hsnController.hsnList.isEmpty
                ? const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: primary,
              ),
            )
                : hsnController.errorMessage != null &&
                hsnController.hsnList.isEmpty
                ? _emptyState(
              icon: Icons.cloud_off_rounded,
              title: 'Unable to load HSN records',
              subtitle: hsnController.errorMessage!,
              actionLabel: 'Try again',
              onAction: () =>
                  hsnController.fetchHsnList(),
            )
                : records.isEmpty
                ? _emptyState(
              icon: Icons.search_off_rounded,
              title: 'No records found',
              subtitle:
              'Try another search or create a new HSN.',
              actionLabel: 'Add HSN',
              onAction: _showCreateHsnDialog,
            )
                : ListView.separated(
              padding: const EdgeInsets.all(9),
              itemCount: records.length,
              separatorBuilder: (_, __) =>
              const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final item = records[index];
                final selected =
                    hsnController.selectedHsn?.id ==
                        item.id;

                return _hsnTile(item, selected);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: (value) {
        hsnController.search(value);
        setState(() {});
      },
      style: const TextStyle(
        fontSize: 12,
        color: dark,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: 'Search HSN code...',
        hintStyle: const TextStyle(
          fontSize: 11,
          color: muted,
        ),
        prefixIcon: const Icon(
          Icons.search_rounded,
          size: 19,
          color: muted,
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 39,
          minHeight: 40,
        ),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
          tooltip: 'Clear search',
          onPressed: () {
            _searchController.clear();
            hsnController.search('');
            setState(() {});
          },
          icon: const Icon(
            Icons.close_rounded,
            size: 17,
            color: muted,
          ),
        )
            : null,
        filled: true,
        fillColor: const Color(0xFFF8FAFD),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 12,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: primary,
            width: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _hsnTile(HsnModelItem item, bool selected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 190),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: selected
            ? const Color(0xFFF0F5FF)
            : Colors.white,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: selected
              ? const Color(0xFFB8CCF8)
              : border,
          width: selected ? 1.2 : 0.9,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(11),
        child: InkWell(
          borderRadius: BorderRadius.circular(11),
          onTap: () => hsnController.selectHsn(item),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 6,
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 190),
                  width: 37,
                  height: 37,
                  decoration: BoxDecoration(
                    color: selected
                        ? primary
                        : const Color(0xFFF0F3F8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: selected
                        ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 20,
                    )
                        : const Icon(
                      Icons.tag_rounded,
                      color: muted,
                      size: 19,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.hsncode,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: selected ? primaryDark : dark,
                          letterSpacing: 0.15,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Text(
                            'ID: ${item.id}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: muted,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 3,
                            height: 3,
                            decoration: const BoxDecoration(
                              color: muted,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${item.hsnTaxSlabs.length} slabs',
                            style: const TextStyle(
                              fontSize: 10,
                              color: muted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 5),
                Icon(
                  selected
                      ? Icons.check_circle_rounded
                      : Icons.chevron_right_rounded,
                  color: selected ? primary : const Color(0xFFB5BECC),
                  size: 19,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // TAX SLABS PANEL
  // ============================================================

  Widget _buildSlabsPanel(
      HsnModelItem? selected,
      List<HsnTaxSlabModel> slabs,
      ) {
    return _panel(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(13, 13, 12, 12),
            child: Row(
              children: [
                _sectionIcon(Icons.percent_rounded),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tax Slabs',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: dark,
                        ),
                      ),
                      const SizedBox(height: 3),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: Text(
                          selected == null
                              ? 'Select an HSN record'
                              : 'HSN ${selected.hsncode} · ${slabs.length} slabs',
                          key: ValueKey(selected?.id ?? 'none'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            color: muted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (selected != null)
                  Material(
                    color: primary,
                    borderRadius: BorderRadius.circular(9),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(9),
                      onTap: hsnController.isSaving
                          ? null
                          : () => _showSlabDialog(),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 9,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.add_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Add Slab',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1, color: border),
          if (selected != null)
            Container(
              margin: const EdgeInsets.fromLTRB(12, 11, 12, 9),
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFF0F5FF),
                    Color(0xFFF8FAFF),
                  ],
                ),
                borderRadius: BorderRadius.circular(11),
                border: Border.all(
                  color: const Color(0xFFDCE7FF),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Icon(
                      Icons.qr_code_rounded,
                      size: 20,
                      color: primary,
                    ),
                  ),
                  const SizedBox(width: 9),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selected HSN Code',
                          style: TextStyle(
                            fontSize: 9,
                            color: muted,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Tax configuration',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: dark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    selected.hsncode,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: primaryDark,
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: selected == null
                  ? _emptyState(
                key: const ValueKey('no-hsn-selected'),
                icon: Icons.touch_app_rounded,
                title: 'Select an HSN code',
                subtitle:
                'Choose a record from the list to manage its tax slabs.',
              )
                  : slabs.isEmpty
                  ? _emptyState(
                key: ValueKey('empty-${selected.id}'),
                icon: Icons.percent_rounded,
                title: 'No tax slabs added',
                subtitle:
                'Add a price range and tax rate to get started.',
                actionLabel: 'Add first slab',
                onAction: hsnController.isSaving
                    ? null
                    : () => _showSlabDialog(),
              )
                  : ListView.separated(
                key: ValueKey('slabs-${selected.id}'),
                padding: const EdgeInsets.fromLTRB(
                  11,
                  2,
                  11,
                  12,
                ),
                itemCount: slabs.length,
                separatorBuilder: (_, __) =>
                const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  return _slabCard(
                    slabs[index],
                    index,
                  );
                },
              ),
            ),
          ),
          if (selected != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: border),
                ),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Unsaved changes?',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: dark,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Save to apply changes',
                          style: TextStyle(
                            fontSize: 9,
                            color: muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 40,
                    child: ElevatedButton.icon(
                      onPressed: hsnController.isSaving
                          ? null
                          : _saveChanges,
                      icon: hsnController.isSaving
                          ? const SizedBox(
                        width: 15,
                        height: 15,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Icon(
                        Icons.save_rounded,
                        size: 16,
                      ),
                      label: Text(
                        hsnController.isSaving
                            ? 'Saving...'
                            : 'Save Changes',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9),
                        ),
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

  // ============================================================
  // TAX SLAB CARD
  // ============================================================

  String formatDate(String date) {
    final parsedDate = DateTime.parse(date);

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    return '${parsedDate.day} '
        '${months[parsedDate.month - 1]} '
        '${parsedDate.year}';
  }

  Widget _slabCard(HsnTaxSlabModel slab, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4FF),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(
              Icons.currency_rupee_rounded,
              color: primary,
              size: 17,
            ),
          ),
          const SizedBox(width: 10),

          // Price range: 0.00 - 240.00
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_formatNumber(slab.priceFrom)} - '
                      '${_formatNumber(slab.priceTo)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: dark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  slab.slabsDate.isEmpty
                      ? 'Tax slab'
                      :formatDate(slab.slabsDate),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: muted,
                  ),
                ),
              ],
            ),
          ),

          // Tax percentage
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF7F0),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${_formatNumber(slab.tax)}%',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: green,
              ),
            ),
          ),

          const SizedBox(width: 7),

          _slabAction(
            icon: Icons.edit_outlined,
            tooltip: 'Edit tax slab',
            color: primary,
            onTap: hsnController.isSaving
                ? null
                : () => _showSlabDialog(slab: slab),
          ),

          const SizedBox(width: 4),

          _slabAction(
            icon: Icons.delete_outline_rounded,
            tooltip: 'Delete tax slab',
            color: red,
            onTap: hsnController.isSaving
                ? null
                : () => _confirmDelete(slab),
          ),
        ],
      ),
    );
  }

  Widget _priceValue(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 8,
            letterSpacing: 0.45,
            color: muted,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12,
            color: dark,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _slabAction({
    required IconData icon,
    required String tooltip,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 32,
            height: 32,
            child: Icon(
              icon,
              size: 17,
              color: color,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CREATE HSN DIALOG
  // ============================================================

  Future<void> _showCreateHsnDialog() async {
    final controller = TextEditingController();

    String? error;
    bool submitting = false;

    try {
      final result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              Future<void> submit() async {
                if (submitting) return;

                final code = controller.text.trim();

                if (code.isEmpty) {
                  setDialogState(() {
                    error = 'Please enter an HSN code.';
                  });
                  return;
                }

                final exists = hsnController.hsnList.any(
                      (item) =>
                  item.hsncode.trim().toLowerCase() ==
                      code.toLowerCase(),
                );

                if (exists) {
                  setDialogState(() {
                    error = 'This HSN code already exists.';
                  });
                  return;
                }

                setDialogState(() {
                  submitting = true;
                  error = null;
                });

                try {
                  final success =
                  await hsnController.createHsn(code);

                  if (!dialogContext.mounted) return;

                  if (success) {
                    Navigator.of(dialogContext).pop(true);
                  } else {
                    setDialogState(() {
                      submitting = false;
                      error = hsnController.errorMessage ??
                          'Unable to create HSN.';
                    });
                  }
                } catch (_) {
                  if (!dialogContext.mounted) return;

                  setDialogState(() {
                    submitting = false;
                    error = 'Something went wrong. Please try again.';
                  });
                }
              }

              return _dialogShell(
                icon: Icons.add_box_rounded,
                title: 'Create HSN',
                subtitle: 'Add a new code to your HSN master.',
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'HSN CODE',
                      style: TextStyle(
                        fontSize: 9,
                        letterSpacing: 0.6,
                        fontWeight: FontWeight.w700,
                        color: muted,
                      ),
                    ),
                    const SizedBox(height: 7),
                    TextField(
                      controller: controller,
                      autofocus: true,
                      enabled: !submitting,
                      textCapitalization:
                      TextCapitalization.characters,
                      onChanged: (_) {
                        if (error != null) {
                          setDialogState(() => error = null);
                        }
                      },
                      onSubmitted: (_) => submit(),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: dark,
                      ),
                      decoration: _inputDecoration(
                        hint: 'Enter HSN code',
                        icon: Icons.tag_rounded,
                      ),
                    ),
                    if (error != null) ...[
                      const SizedBox(height: 10),
                      _errorMessage(error!),
                    ],
                  ],
                ),
                cancelLabel: 'Cancel',
                confirmLabel: 'Create HSN',
                loading: submitting,
                onCancel: () =>
                    Navigator.of(dialogContext).pop(false),
                onConfirm: submit,
              );
            },
          );
        },
      );

      if (!mounted || result != true) return;

      _showMessage(
        'HSN created successfully.',
        success: true,
      );
    } finally {
      // showDialog completes when pop starts; allow the closing transition to
      // remove TextFields before disposing their controllers.
      await Future<void>.delayed(const Duration(milliseconds: 300));
      controller.dispose();
    }
  }

  // ============================================================
  // ADD / EDIT TAX SLAB DIALOG
  // ============================================================

  Future<void> _showSlabDialog({HsnTaxSlabModel? slab}) async {
    final editing = slab != null;

    final fromController = TextEditingController(
      text: slab == null ? '' : _formatNumber(slab.priceFrom),
    );
    final toController = TextEditingController(
      text: slab == null ? '' : _formatNumber(slab.priceTo),
    );
    final taxController = TextEditingController(
      text: slab == null ? '' : _formatNumber(slab.tax),
    );

    String selectedDate = slab?.slabsDate ?? _today();
    String? error;
    bool submitting = false;

    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              Future<void> submit() async {
                if (submitting) return;

                final from =
                double.tryParse(fromController.text.trim());
                final to =
                double.tryParse(toController.text.trim());
                final tax =
                double.tryParse(taxController.text.trim());

                if (from == null ||
                    to == null ||
                    tax == null ||
                    !from.isFinite ||
                    !to.isFinite ||
                    !tax.isFinite ||
                    from < 0 ||
                    to < from ||
                    tax < 0 ||
                    tax > 100) {
                  setDialogState(() {
                    error =
                    'Enter valid prices and a tax rate between 0 and 100.';
                  });
                  return;
                }

                setDialogState(() {
                  submitting = true;
                  error = null;
                });

                try {
                  if (editing) {
                    hsnController.updateSlab(
                      slab,
                      priceFrom: from,
                      priceTo: to,
                      tax: tax,
                      date: selectedDate,
                    );
                  } else {
                    hsnController.addSlab(
                      priceFrom: from,
                      priceTo: to,
                      tax: tax,
                      date: selectedDate,
                    );
                  }

                  if (!dialogContext.mounted) return;

                  Navigator.of(dialogContext).pop();
                } catch (_) {
                  if (!dialogContext.mounted) return;

                  setDialogState(() {
                    submitting = false;
                    error = 'Unable to update the tax slab.';
                  });
                }
              }

              return _dialogShell(
                icon: editing
                    ? Icons.edit_note_rounded
                    : Icons.percent_rounded,
                title: editing ? 'Edit Tax Slab' : 'Add Tax Slab',
                subtitle: editing
                    ? 'Update the selected tax configuration.'
                    : 'Set the price range and applicable tax.',
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _numberField(
                            controller: fromController,
                            label: 'Price From',
                            hint: '0.00',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _numberField(
                            controller: toController,
                            label: 'Price To',
                            hint: '2499.99',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 13),
                    _numberField(
                      controller: taxController,
                      label: 'Tax Rate (%)',
                      hint: '5',
                      suffix: '%',
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'EFFECTIVE DATE',
                      style: TextStyle(
                        fontSize: 9,
                        letterSpacing: 0.6,
                        fontWeight: FontWeight.w700,
                        color: muted,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Material(
                      color: const Color(0xFFF7F9FC),
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: submitting
                            ? null
                            : () async {
                          final picked = await showDatePicker(
                            context: dialogContext,
                            initialDate:
                            _dateFromString(selectedDate),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );

                          if (picked != null &&
                              dialogContext.mounted) {
                            setDialogState(() {
                              selectedDate =
                              '${picked.year.toString().padLeft(4, '0')}-'
                                  '${picked.month.toString().padLeft(2, '0')}-'
                                  '${picked.day.toString().padLeft(2, '0')}';
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: border),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_month_rounded,
                                color: primary,
                                size: 18,
                              ),
                              const SizedBox(width: 9),
                              Expanded(
                                child: Text(
                                  selectedDate,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: dark,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 19,
                                color: muted,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (error != null) ...[
                      const SizedBox(height: 11),
                      _errorMessage(error!),
                    ],
                  ],
                ),
                cancelLabel: 'Cancel',
                confirmLabel: editing ? 'Update Slab' : 'Add Slab',
                loading: submitting,
                onCancel: () =>
                    Navigator.of(dialogContext).pop(),
                onConfirm: submit,
              );
            },
          );
        },
      );
    } finally {
      // Keep controllers alive while the dialog's reverse transition is running.
      await Future<void>.delayed(const Duration(milliseconds: 300));
      fromController.dispose();
      toController.dispose();
      taxController.dispose();
    }
  }

  // ============================================================
  // DELETE CONFIRMATION
  // ============================================================

  Future<void> _confirmDelete(HsnTaxSlabModel slab) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 7),
          contentPadding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          actionsPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          title: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEEEE),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: red,
                  size: 21,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Delete tax slab?',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: dark,
                  ),
                ),
              ),
            ],
          ),
          content: const Text(
            'This slab will be removed from the current list. '
                'Save your changes to apply the updated list.',
            style: TextStyle(
              fontSize: 11,
              color: muted,
              height: 1.6,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 11,
                  color: muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: red,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 11,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
              child: const Text(
                'Delete Slab',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      hsnController.deleteSlab(slab);
    }
  }

  // ============================================================
  // SAVE CHANGES
  // ============================================================

  Future<void> _saveChanges() async {
    final success = await hsnController.saveTaxSlabs();

    if (!mounted) return;

    _showMessage(
      success
          ? 'Tax slabs saved successfully.'
          : hsnController.errorMessage ?? 'Unable to save tax slabs.',
      success: success,
    );
  }

  void _showMessage(String message, {required bool success}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                success
                    ? Icons.check_circle_outline_rounded
                    : Icons.error_outline_rounded,
                size: 19,
                color: Colors.white,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          backgroundColor: success ? green : red,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
  }

  // ============================================================
  // REUSABLE DIALOG
  // ============================================================

  Widget _dialogShell({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget content,
    required String cancelLabel,
    required String confirmLabel,
    required VoidCallback onCancel,
    required VoidCallback onConfirm,
    bool loading = false,
  }) {
    return AlertDialog(
      backgroundColor: Colors.white,
      elevation: 12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(17),
      ),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 6),
      contentPadding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      actionsPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      title: Row(
        children: [
          Container(
            width: 39,
            height: 39,
            decoration: BoxDecoration(
              color: const Color(0xFFEDF3FF),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              icon,
              size: 21,
              color: primary,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: dark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.normal,
                    color: muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 370,
        child: SingleChildScrollView(child: content),
      ),
      actions: [
        TextButton(
          onPressed: loading ? null : onCancel,
          child: Text(
            cancelLabel,
            style: const TextStyle(
              fontSize: 11,
              color: muted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: loading ? null : onConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor:
            primary.withValues(alpha: 0.5),
            elevation: 0,
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 11,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(9),
            ),
          ),
          child: loading
              ? const SizedBox(
            width: 15,
            height: 15,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
              : Text(
            confirmLabel,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _numberField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 9,
            letterSpacing: 0.5,
            fontWeight: FontWeight.w700,
            color: muted,
          ),
        ),
        const SizedBox(height: 7),
        TextField(
          controller: controller,
          keyboardType:
          const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: dark,
          ),
          decoration: _inputDecoration(
            hint: hint,
            suffix: suffix,
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    IconData? icon,
    String? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontSize: 11,
        color: Color(0xFFA3ADBD),
      ),
      prefixIcon: icon == null
          ? null
          : Icon(icon, size: 17, color: muted),
      prefixIconConstraints: icon == null
          ? null
          : const BoxConstraints(
        minWidth: 37,
        minHeight: 40,
      ),
      suffixText: suffix,
      suffixStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: muted,
      ),
      filled: true,
      fillColor: const Color(0xFFFAFBFD),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 13,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: primary,
          width: 1.3,
        ),
      ),
    );
  }

  Widget _errorMessage(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F0),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: red.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 16,
            color: red,
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 10,
                color: red,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SMALL UI HELPERS
  // ============================================================

  Widget _sectionIcon(IconData icon) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFFEDF3FF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        icon,
        color: primary,
        size: 19,
      ),
    );
  }

  Widget _countBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFEDF3FF),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: primary,
        ),
      ),
    );
  }

  Widget _emptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    String? actionLabel,
    VoidCallback? onAction,
    Key? key,
  }) {
    return Center(
      key: key,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4FA),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                size: 26,
                color: const Color(0xFF8B9AB0),
              ),
            ),
            const SizedBox(height: 13),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: dark,
              ),
            ),
            const SizedBox(height: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 240),
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 10,
                  color: muted,
                  height: 1.6,
                ),
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: onAction,
                icon: const Icon(
                  Icons.add_rounded,
                  size: 16,
                ),
                label: Text(
                  actionLabel,
                  style: const TextStyle(fontSize: 11),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primary,
                  side: const BorderSide(color: border),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DATE AND NUMBER HELPERS
  // ============================================================

  String _today() {
    final now = DateTime.now();

    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  DateTime _dateFromString(String value) {
    try {
      final parsed = DateTime.tryParse(value);

      if (parsed != null) {
        return parsed;
      }

      final parts = value.split('/');

      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      }
    } catch (_) {}

    return DateTime.now();
  }

  String _formatNumber(double value) {
    return value.toStringAsFixed(2);
  }
}

