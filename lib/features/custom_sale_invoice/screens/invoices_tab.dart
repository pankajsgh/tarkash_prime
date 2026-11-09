import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../models.dart';
import '../pdf_invoice.dart';
import '../store.dart';
import '../theme.dart';
import '../utils.dart';
import '../widgets.dart';
import 'invoice_detail.dart';
import 'invoice_editor.dart';

class InvoicesTab extends StatefulWidget {
  final AppStore store;
  const InvoicesTab({super.key, required this.store});

  @override
  State<InvoicesTab> createState() => _InvoicesTabState();
}

class _InvoicesTabState extends State<InvoicesTab> {
  String _query = '';
  String _filter = 'All';
  static const _filters = ['All', 'Unpaid', 'Partial', 'Paid', 'Overdue'];

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final sym = store.settings.currency;
        final q = _query.trim().toLowerCase();
        final list = store.invoices.where((i) {
          if (_filter != 'All' && i.status != _filter) return false;
          if (q.isEmpty) return true;
          return i.customerName.toLowerCase().contains(q) ||
              i.number.toLowerCase().contains(q) ||
              i.customerGstin.toLowerCase().contains(q);
        }).toList()
          ..sort((a, b) {
            final c = b.date.compareTo(a.date);
            return c != 0 ? c : b.number.compareTo(a.number);
          });

        return PageScroll(
          children: [
            PageHeader(
              title: 'Invoices',
              subtitle: '${store.invoices.length} in total',
              actions: [
                FilledButton.icon(
                  onPressed: () => openEditor(context, store),
                  icon: const Icon(Icons.add),
                  label: const Text('New invoice'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Panel(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        SizedBox(
                          width: 340,
                          child: TextField(
                            decoration: dec('Search by customer, number or GSTIN').copyWith(prefixIcon: const Icon(Icons.search)),
                            onChanged: (v) => setState(() => _query = v),
                          ),
                        ),
                        for (final f in _filters)
                          ChoiceChip(
                            label: Text(f),
                            selected: _filter == f,
                            onSelected: (_) => setState(() => _filter = f),
                          ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  if (list.isEmpty)
                    emptyState(
                      Icons.receipt_long,
                      store.invoices.isEmpty ? 'No invoices yet.\nClick "New invoice" to start billing.' : 'No invoices match.',
                    )
                  else
                    DataGrid(
                      minWidth: 980,
                      cols: const [
                        Col('Invoice', width: 110),
                        Col('Date', width: 110),
                        Col('Customer'),
                        Col('Amount', width: 120, right: true),
                        Col('Received', width: 120, right: true),
                        Col('Balance', width: 120, right: true),
                        Col('Status', width: 100),
                        Col('', width: 48),
                      ],
                      onTap: [for (final i in list) () => openInvoice(context, store, i.id)],
                      rows: [for (final i in list) _row(context, i, sym)],
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _row(BuildContext context, Invoice i, String sym) {
    final store = widget.store;
    return [
      Text(i.number, style: const TextStyle(fontWeight: FontWeight.w600)),
      Text(fmtDate(i.date)),
      Text(i.customerName, maxLines: 1, overflow: TextOverflow.ellipsis),
      Text(money(i.total, sym), style: const TextStyle(fontWeight: FontWeight.w600)),
      Text(money(i.paid, sym)),
      Text(money(i.balance, sym), style: TextStyle(color: i.balance > 0.005 ? AppColors.bad : AppColors.muted)),
      statusPill(i.status),
      PopupMenuButton<String>(
        tooltip: 'Actions',
        icon: const Icon(Icons.more_vert, size: 20),
        onSelected: (v) async {
          if (v == 'view') {
            openInvoice(context, store, i.id);
          } else if (v == 'edit') {
            openEditor(context, store, invoice: i);
          } else if (v == 'print') {
            try {
              await Printing.layoutPdf(name: i.number, onLayout: (_) => buildInvoicePdf(i, store.settings));
            } catch (e) {
              if (context.mounted) snack(context, 'Could not open the print preview: $e');
            }
          } else if (v == 'delete') {
            final ok = await confirm(context, 'Delete invoice?', '${i.number} will be removed from this computer.');
            if (ok) await store.deleteInvoice(i.id);
          }
        },
        itemBuilder: (_) => const [
          PopupMenuItem(value: 'view', child: Text('View')),
          PopupMenuItem(value: 'edit', child: Text('Edit')),
          PopupMenuItem(value: 'print', child: Text('Print / PDF')),
          PopupMenuItem(value: 'delete', child: Text('Delete')),
        ],
      ),
    ];
  }
}
