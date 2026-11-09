import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models.dart';
import '../store.dart';
import '../theme.dart';
import '../utils.dart';
import '../widgets.dart';
import 'invoice_detail.dart';

class DashboardTab extends StatelessWidget {
  final AppStore store;
  final VoidCallback onNew;
  final VoidCallback onViewAll;
  const DashboardTab({super.key, required this.store, required this.onNew, required this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final sym = store.settings.currency;
        final all = store.invoices;
        final now = DateTime.now();

        final today = all.where((i) => sameDay(i.date, now));
        final month = all.where((i) => i.date.year == now.year && i.date.month == now.month);
        final todaySales = today.fold<double>(0, (a, i) => a + i.total);
        final monthSales = month.fold<double>(0, (a, i) => a + i.total);
        final outstanding = all.fold<double>(0, (a, i) => a + i.balance);
        final unpaidCount = all.where((i) => i.balance > 0.005).length;
        final overdue = all.where((i) => i.status == 'Overdue').toList();
        final overdueAmt = overdue.fold<double>(0, (a, i) => a + i.balance);

        // Sales for the last six months.
        final labels = <String>[];
        final values = <double>[];
        for (var k = 5; k >= 0; k--) {
          final m = DateTime(now.year, now.month - k, 1);
          labels.add(DateFormat('MMM').format(m));
          values.add(all
              .where((i) => i.date.year == m.year && i.date.month == m.month)
              .fold<double>(0, (a, i) => a + i.total));
        }

        // Customers who owe the most.
        final owed = <String, double>{};
        for (final i in all) {
          if (i.balance > 0.005) owed[i.customerName] = (owed[i.customerName] ?? 0) + i.balance;
        }
        final topOwed = owed.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

        final recent = (List<Invoice>.from(all)..sort((a, b) => b.date.compareTo(a.date))).take(8).toList();

        final chart = Panel(
          title: 'Sales, last 6 months',
          child: BarChart(labels: labels, values: values, fmt: (v) => compactMoney(v, sym)),
        );
        final owedPanel = Panel(
          title: 'Customers with balance due',
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: topOwed.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('No pending balances.', style: TextStyle(color: AppColors.muted)),
                )
              : Column(
                  children: [
                    for (final e in topOwed.take(6))
                      ListTile(
                        dense: true,
                        title: Text(e.key.isEmpty ? 'Walk-in customer' : e.key, maxLines: 1, overflow: TextOverflow.ellipsis),
                        trailing: Text(money(e.value, sym), style: const TextStyle(fontWeight: FontWeight.w700)),
                      ),
                  ],
                ),
        );

        return PageScroll(
          children: [
            PageHeader(
              title: 'Dashboard',
              subtitle: DateFormat('EEEE, dd MMMM yyyy').format(now),
              actions: [
                FilledButton.icon(
                  onPressed: onNew,
                  icon: const Icon(Icons.add),
                  label: const Text('New invoice'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            kpiGrid([
              KpiCard(label: "Today's sales", value: money(todaySales, sym), sub: '${today.length} invoices', icon: Icons.today),
              KpiCard(label: 'This month', value: money(monthSales, sym), sub: '${month.length} invoices', icon: Icons.calendar_month, color: const Color(0xFF1D4ED8)),
              KpiCard(label: 'Outstanding', value: money(outstanding, sym), sub: '$unpaidCount unpaid invoices', icon: Icons.account_balance_wallet, color: AppColors.warn),
              KpiCard(label: 'Overdue', value: money(overdueAmt, sym), sub: '${overdue.length} invoices past due', icon: Icons.warning_amber, color: AppColors.bad),
            ]),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, c) {
                if (c.maxWidth >= 900) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: chart),
                      const SizedBox(width: 16),
                      Expanded(flex: 2, child: owedPanel),
                    ],
                  );
                }
                return Column(children: [chart, const SizedBox(height: 16), owedPanel]);
              },
            ),
            const SizedBox(height: 16),
            Panel(
              title: 'Recent invoices',
              trailing: TextButton(onPressed: onViewAll, child: const Text('View all')),
              padding: EdgeInsets.zero,
              child: recent.isEmpty
                  ? emptyState(Icons.receipt_long, 'No invoices yet.\nClick "New invoice" to create your first one.')
                  : DataGrid(
                      minWidth: 760,
                      cols: const [
                        Col('Invoice', width: 110),
                        Col('Date', width: 110),
                        Col('Customer'),
                        Col('Amount', width: 130, right: true),
                        Col('Balance', width: 130, right: true),
                        Col('Status', width: 100),
                      ],
                      onTap: [for (final i in recent) () => openInvoice(context, store, i.id)],
                      rows: [
                        for (final i in recent)
                          [
                            Text(i.number, style: const TextStyle(fontWeight: FontWeight.w600)),
                            Text(fmtDate(i.date)),
                            Text(i.customerName, maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text(money(i.total, sym)),
                            Text(money(i.balance, sym)),
                            statusPill(i.status),
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
