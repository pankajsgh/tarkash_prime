
import 'package:flutter/material.dart';
import '../../../core/routes/routes.dart';
import '../../../core/widget/confirmation_widget.dart';
import '../../dashboard/data/controller/routes_controller.dart';
import '../controllers/series_list_controller.dart';
import '../models/model_voucher_configuration.dart';

class SeriesListScreen extends StatefulWidget {
  final RoutesController routesController;
  const SeriesListScreen({super.key, required this.routesController});

  @override
  State<SeriesListScreen> createState() => _SeriesListScreenState();
}

class _SeriesListScreenState extends State<SeriesListScreen> {
  late final SeriesListController seriesListController;

  static const Color primaryBlue = Color(0xFF3B82F6);
  static const Color pageBg = Color(0xFFF4F6FA);
  static const Color cardBorder = Color(0xFFE2E8F0);
  static const Color textDark = Color(0xFF1E293B);
  static const Color textMedium = Color(0xFF64748B);
  static const Color successGreen = Color(0xFF15803D);

  final Set<String> expandedItems = {};

  @override
  void initState() {
    super.initState();

    seriesListController = SeriesListController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        seriesListController.fetchDataList(refresh: true);
      }
    });
  }

  @override
  void dispose() {
    seriesListController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBg,
      body: FocusTraversalGroup(
        policy: OrderedTraversalPolicy(),
        child: AnimatedBuilder(
          animation: seriesListController,
          builder: (context, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                Expanded(
                  child: _buildBody(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // Header
  Widget _buildHeader() {
    final voucherCount = seriesListController.products.length;

    final seriesCount = seriesListController.products.fold<int>(
      0,
          (total, voucher) => total + voucher.series.length,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 28,
        vertical: 18,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: cardBorder),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: primaryBlue.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.account_tree_outlined,
              color: primaryBlue,
              size: 23,
            ),
          ),
          const SizedBox(width: 14),

          // Title and compact counts
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Voucher Configuration',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 9),
                Wrap(
                  spacing: 10,
                  runSpacing: 6,
                  children: [
                    _buildHeaderCount(
                      label: 'Voucher Types',
                      count: voucherCount,
                      icon: Icons.category_outlined,
                      color: primaryBlue,
                    ),
                    _buildHeaderCount(
                      label: 'Total Series',
                      count: seriesCount,
                      icon: Icons.list_alt_outlined,
                      color: successGreen,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          OutlinedButton.icon(
            onPressed: seriesListController.isLoading
                ? null
                : () {
              seriesListController.refresh();
            },
            icon: const Icon(Icons.refresh, size: 17),
            label: const Text('Refresh'),
            style: OutlinedButton.styleFrom(
              foregroundColor: textDark,
              side: const BorderSide(color: cardBorder),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 13,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCount({
    required String label,
    required int count,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withValues(alpha: 0.16),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: textMedium,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 11.0,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (seriesListController.isLoading &&
        seriesListController.products.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 32,
              width: 32,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: primaryBlue,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Loading voucher configuration...',
              style: TextStyle(
                fontSize: 14,
                color: textMedium,
              ),
            ),
          ],
        ),
      );
    }

    if (seriesListController.errorMessage.isNotEmpty &&
        seriesListController.products.isEmpty) {
      return Center(
        child: Container(
          width: 440,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: cardBorder),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_outlined,
                size: 48,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 16),
              const Text(
                'Unable to load voucher types',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                seriesListController.errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: textMedium,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () {
                  seriesListController.refresh();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: FilledButton.styleFrom(
                  backgroundColor: primaryBlue,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (seriesListController.products.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.folder_open_outlined,
              size: 56,
              color: Colors.blueGrey.shade300,
            ),
            const SizedBox(height: 14),
            const Text(
              'No voucher types found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: textDark,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Voucher types will appear here when available.',
              style: TextStyle(
                fontSize: 13,
                color: textMedium,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(26),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cardBorder),
        ),
        child: Column(
          children: [
            _buildTableHeader(),
            const Divider(
              height: 1,
              color: cardBorder,
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: seriesListController.products.length,
                separatorBuilder: (_, __) =>
                const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final voucher =
                  seriesListController.products[index];

                  return _buildVoucherItem(
                    voucher: voucher,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Table header
  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 16,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(12),
        ),
      ),
      child: const Row(
        children: [
          SizedBox(width: 34),
          Expanded(
            flex: 5,
            child: Text(
              'VOUCHER TYPE / SERIES',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: textMedium,
                letterSpacing: 0.5,
              ),
            ),
          ),
          SizedBox(
            width: 110,
            child: Text(
              'SERIES COUNT',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: textMedium,
              ),
            ),
          ),
          SizedBox(
            width: 120,
            child: Text(
              'ACTIONS',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: textMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Parent voucher type
  Widget _buildVoucherItem({
    required VoucherType voucher,
  }) {
    final isExpanded = expandedItems.contains(voucher.id);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: isExpanded
              ? primaryBlue.withValues(alpha: 0.35)
              : cardBorder,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Focus(
            canRequestFocus: true,
            child: Builder(
              builder: (focusContext) {
                final hasFocus = Focus.of(focusContext).hasFocus;

                return DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: hasFocus
                        ? Border.all(
                      color: primaryBlue,
                      width: 2,
                    )
                        : Border.all(
                      color: Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        if (isExpanded) {
                          expandedItems.remove(voucher.id);
                        } else {
                          expandedItems.add(voucher.id);
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                      child: Row(
                        children: [
                          AnimatedRotation(
                            turns: isExpanded ? 0.25 : 0,
                            duration: const Duration(milliseconds: 180),
                            child: const Icon(
                              Icons.chevron_right,
                              size: 24,
                              color: textMedium,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            height: 38,
                            width: 38,
                            decoration: BoxDecoration(
                              color: primaryBlue.withValues(alpha: 0.09),
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: const Icon(
                              Icons.folder_outlined,
                              color: primaryBlue,
                              size: 21,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            flex: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  voucher.name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: textDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 110,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${voucher.series.length} series',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: textDark,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 120,
                            child: Center(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  _onAddEditSeries(voucher);
                                },
                                icon: const Icon(
                                  Icons.add,
                                  size: 17,
                                ),
                                label: const Text('Add'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: primaryBlue,
                                  side: BorderSide(
                                    color: primaryBlue.withValues(alpha: 0.4),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 13,
                                    vertical: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
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
            ),
          ),

          // Child voucher series
          // Child voucher series
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: isExpanded
                ? Column(
              children: [
                const Divider(
                  height: 1,
                  color: cardBorder,
                ),
                if (voucher.series.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'No series available for this voucher type.',
                      style: TextStyle(
                        fontSize: 13,
                        color: textMedium,
                      ),
                    ),
                  )
                else
                  ...voucher.series.asMap().entries.map<Widget>((entry) {
                    return _buildSeriesItem(
                      series: entry.value, // Actual VoucherSeries object
                      voucher: voucher,
                      index: entry.key, // Series index
                    );
                  }),
              ],
            )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  // Child series row
  Widget _buildSeriesItem({
    required dynamic series,
    required dynamic voucher,
    required int index,
  }) {
    return Container(
      padding: const EdgeInsets.only(
        left: 78,
        right: 22,
        top: 13,
        bottom: 13,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFFAFBFD),
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFF1F5F9),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 32,
            width: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.subdirectory_arrow_right,
              color: successGreen,
              size: 19,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            flex: 5,
            child: Text(
              '${series.name} (${series.invoiceFormate})',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textDark,
              ),
            ),
          ),
          if(index!=0)
            SizedBox(
            width: 60,
            child: Center(
              child: _buildAccessibleIconButton(
                tooltip: 'Delete ${series.name}',
                icon: Icons.delete_outline,
                color: Colors.redAccent,
                onPressed: () {
                  ConfirmationDialog.show(
                      context: context,
                      title: 'Delete',
                      message: 'Are You sure want to delete ${series.name}',
                      positiveClick: () {
                        seriesListController.requestDeleteSeries(
                          context: context,
                          id: series.id,
                        );
                      }
                  );
                },
              ),
            ),
          ),
          SizedBox(
            width: 60,
            child: Center(
              child: _buildAccessibleIconButton(
                tooltip: 'Edit ${series.name}',
                icon: Icons.edit_outlined,
                color: primaryBlue,
                onPressed: () {
                  _onAddEditSeries(
                    voucher,
                    editableIndex: index,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccessibleIconButton({
    required String tooltip,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Focus(
      canRequestFocus: true,
      child: Builder(
        builder: (context) {
          final hasFocus = Focus.of(context).hasFocus;

          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: hasFocus
                    ? primaryBlue
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: IconButton(
              tooltip: tooltip,
              onPressed: onPressed,
              icon: Icon(icon, size: 19, color: color),
              style: IconButton.styleFrom(
                backgroundColor: color.withValues(alpha: 0.08),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Add action
  void _onAddEditSeries(VoucherType voucher, {int editableIndex = -1}) {
    widget.routesController.setRoute(Routes.seriesAddUpdateScreen, data: {
      'voucher': voucher,
      'voucherList': seriesListController.products,
      'editableIndex': editableIndex
    });
  }

  // Edit action
  void _onEditSeries({
    required dynamic voucher,
    required dynamic series,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Edit ${series.name} under ${voucher.name}',
        ),
      ),
    );

    // Connect your Edit Series screen or dialog here.
  }
}