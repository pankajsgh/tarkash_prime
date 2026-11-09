import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models.dart';
import '../store.dart';
import '../theme.dart';
import '../utils.dart';
import '../widgets.dart';

class ReportsTab extends StatefulWidget {
  final AppStore store;
  const ReportsTab({super.key, required this.store});

  @override
  State<ReportsTab> createState() => _ReportsTabState();
}

class _ReportsTabState extends State<ReportsTab> {
  static const _presets = ['Today', 'This month', 'Last month', 'This quarter', 'This financial year', 'All time', 'Custom'];
  String _preset = 'This month';
  DateTimeRange? _custom;

  DateTimeRange? _range() {
    final n = DateTime.now();
    final today = DateTime(n.year, n.month, n.day);
    switch (_preset) {
      case 'Today':
        return DateTimeRange(start: today, end: today);
      case 'This month':
        return DateTimeRange(start: DateTime(n.year, n.month, 1), end: DateTime(n.year, n.month + 1, 0));
      case 'Last month':
        return DateTimeRange(start: DateTime(n.year, n.month - 1, 1), end: DateTime(n.year, n.month, 0));
      case 'This quarter':
        final qm = ((n.month - 1) ~/ 3) * 3 + 1;
        return DateTimeRange(start: DateTime(n.year, qm, 1), end: DateTime(n.year, qm + 3, 0));
      case 'This financial year':
        final y = n.month >= 4 ? n.year : n.year - 1;
        return DateTimeRange(start: DateTime(y, 4, 1), end: DateTime(y + 1, 3, 31));
      case 'Custom':
        return _custom;
      default:
        return null; // all time
    }
  }

  Future<void> _selectPreset(String p) async {
    if (p == 'Custom') {
      final r = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
        initialDateRange: _custom,
      );
      if (r == null) return;
      setState(() {
        _custom = r;
        _preset = 'Custom';
      });
    } else {
      setState(() => _preset = p);
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final sym = store.settings.currency;
        final range = _range();
        final list = store.invoices.where((i) {
          if (range == null) return true;
          final d = DateTime(i.date.year, i.date.month, i.date.day);
          return !d.isBefore(range.start) && !d.isAfter(range.end);
        }).toList()
          ..sort((a, b) => a.date.compareTo(b.date));

        final taxable = list.fold<double>(0, (a, i) => a + i.taxableValue);
        final tax = list.fold<double>(0, (a, i) => a + i.totalTax);
        final total = list.fold<double>(0, (a, i) => a + i.total);
        final received = list.fold<double>(0, (a, i) => a + i.paid);
        final due = list.fold<double>(0, (a, i) => a + i.balance);

        // GST summary by tax rate: [taxable, cgst, sgst, igst]
        final byRate = <double, List<double>>{};
        for (final inv in list) {
          for (final r in inv.taxRows) {
            final a = byRate.putIfAbsent(r.rate, () => <double>[0, 0, 0, 0]);
            a[0] += r.taxable;
            if (inv.interState) {
              a[3] += r.tax;
            } else {
              a[1] += r.tax / 2;
              a[2] += r.tax / 2;
            }
          }
        }
        final rates = byRate.keys.toList()..sort();

        // Sales by customer
        final byCustomer = <String, double>{};
        for (final i in list) {
          byCustomer[i.customerName] = (byCustomer[i.customerName] ?? 0) + i.total;
        }
        final topCustomers = byCustomer.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

        final periodText = range == null
            ? 'All invoices'
            : '${fmtDate(range.start)} to ${fmtDate(range.end)}';

        return PageScroll(
          children: [
            PageHeader(
              title: 'Reports',
              subtitle: '$periodText  •  ${list.length} invoices',
              actions: [
                FilledButton.icon(
                  onPressed: list.isEmpty
                      ? null
                      : () async {
                          try {
                            final path = await store.exportCsv(list);
                            await Clipboard.setData(ClipboardData(text: path));
                            if (context.mounted) snack(context, 'Saved to $path (path copied). Open it in Excel.');
                          } catch (e) {
                            if (context.mounted) snack(context, 'Could not save the file: $e');
                          }
                        },
                  icon: const Icon(Icons.table_view),
                  label: const Text('Export to Excel (CSV)'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final p in _presets)
                  ChoiceChip(
                    label: Text(p),
                    selected: _preset == p,
                    onSelected: (_) => _selectPreset(p),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            kpiGrid([
              KpiCard(label: 'Total sales', value: money(total, sym), sub: '${list.length} invoices', icon: Icons.point_of_sale),
              KpiCard(label: 'Taxable value', value: money(taxable, sym), sub: 'GST collected ${money(tax, sym)}', icon: Icons.receipt, color: const Color(0xFF1D4ED8)),
              KpiCard(label: 'Received', value: money(received, sym), icon: Icons.account_balance, color: AppColors.good),
              KpiCard(label: 'Balance due', value: money(due, sym), icon: Icons.pending_actions, color: AppColors.bad),
            ]),
            const SizedBox(height: 16),
            Panel(
              title: 'GST summary by tax rate',
              padding: EdgeInsets.zero,
              child: rates.isEmpty
                  ? emptyState(Icons.percent, 'No sales in this period.')
                  : DataGrid(
                      minWidth: 760,
                      cols: const [
                        Col('Tax rate', width: 100),
                        Col('Taxable value', right: true),
                        Col('CGST', right: true),
                        Col('SGST', right: true),
                        Col('IGST', right: true),
                        Col('Total tax', right: true),
                      ],
                      rows: [
                        for (final r in rates)
                          [
                            Text('${qtyText(r)}%', style: const TextStyle(fontWeight: FontWeight.w600)),
                            Text(money(byRate[r]![0], sym)),
                            Text(money(byRate[r]![1], sym)),
                            Text(money(byRate[r]![2], sym)),
                            Text(money(byRate[r]![3], sym)),
                            Text(money(byRate[r]![1] + byRate[r]![2] + byRate[r]![3], sym), style: const TextStyle(fontWeight: FontWeight.w600)),
                          ],
                      ],
                    ),
            ),
            const SizedBox(height: 16),
            Panel(
              title: 'Sales by customer',
              padding: EdgeInsets.zero,
              child: topCustomers.isEmpty
                  ? emptyState(Icons.people_outline, 'No sales in this period.')
                  : DataGrid(
                      minWidth: 520,
                      cols: const [
                        Col('Customer'),
                        Col('Sales', width: 160, right: true),
                      ],
                      rows: [
                        for (final e in topCustomers.take(15))
                          [
                            Text(e.key.isEmpty ? 'Walk-in customer' : e.key, maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text(money(e.value, sym), style: const TextStyle(fontWeight: FontWeight.w600)),
                          ],
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }
}
