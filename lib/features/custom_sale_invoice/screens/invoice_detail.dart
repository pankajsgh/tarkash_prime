import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';

import '../models.dart';
import '../pdf_invoice.dart';
import '../store.dart';
import '../theme.dart';
import '../utils.dart';
import '../widgets.dart';
import 'invoice_editor.dart';

void openInvoice(BuildContext context, AppStore store, String id) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => InvoiceDetail(store: store, invoiceId: id)),
  );
}

class InvoiceDetail extends StatelessWidget {
  final AppStore store;
  final String invoiceId;
  const InvoiceDetail({super.key, required this.store, required this.invoiceId});

  Future<void> _print(BuildContext context, Invoice inv) async {
    try {
      await Printing.layoutPdf(name: inv.number, onLayout: (_) => buildInvoicePdf(inv, store.settings));
    } catch (e) {
      if (context.mounted) snack(context, 'Could not open the print preview: $e');
    }
  }

  Future<void> _recordPayment(BuildContext context, Invoice inv) async {
    final p = await showDialog<Payment>(
      context: context,
      builder: (_) => _PaymentDialog(balance: inv.balance, symbol: store.settings.currency),
    );
    if (p == null) return;
    await store.addPayment(inv.id, p);
    if (context.mounted) snack(context, 'Payment of ${money(p.amount, store.settings.currency)} recorded.');
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final inv = store.invoiceById(invoiceId);
        if (inv == null) {
          return Scaffold(appBar: AppBar(), body: const Center(child: Text('Invoice not found.')));
        }
        final s = store.settings;
        final sym = s.currency;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            shape: const Border(bottom: BorderSide(color: AppColors.border)),
            title: Row(
              children: [
                Text(inv.number),
                const SizedBox(width: 12),
                statusPill(inv.status),
              ],
            ),
            actions: [
              TextButton.icon(
                onPressed: () => openEditor(context, store, invoice: inv),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit'),
              ),
              IconButton(
                tooltip: 'Copy invoice text',
                icon: const Icon(Icons.copy),
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: invoiceText(inv, s)));
                  if (context.mounted) snack(context, 'Invoice text copied. Paste it into WhatsApp or email.');
                },
              ),
              IconButton(
                tooltip: 'Delete invoice',
                icon: const Icon(Icons.delete_outline),
                onPressed: () async {
                  final ok = await confirm(context, 'Delete invoice?', '${inv.number} will be removed from this computer.');
                  if (!ok) return;
                  await store.deleteInvoice(inv.id);
                  if (context.mounted) Navigator.pop(context);
                },
              ),
              const SizedBox(width: 4),
              if (inv.balance > 0.005)
                OutlinedButton.icon(
                  onPressed: () => _recordPayment(context, inv),
                  icon: const Icon(Icons.payments_outlined),
                  label: const Text('Record payment'),
                ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: () => _print(context, inv),
                icon: const Icon(Icons.print_outlined),
                label: const Text('Print / PDF'),
              ),
              const SizedBox(width: 16),
            ],
          ),
          body: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 940),
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  _Paper(inv: inv, s: s),
                  const SizedBox(height: 16),
                  Panel(
                    title: 'Payments',
                    trailing: inv.balance > 0.005
                        ? TextButton.icon(
                            onPressed: () => _recordPayment(context, inv),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Add payment'),
                          )
                        : null,
                    padding: EdgeInsets.zero,
                    child: inv.payments.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('No payments recorded yet.', style: TextStyle(color: AppColors.muted)),
                          )
                        : Column(
                            children: [
                              for (final p in inv.payments)
                                ListTile(
                                  dense: true,
                                  leading: const Icon(Icons.check_circle_outline, color: AppColors.good),
                                  title: Text('${money(p.amount, sym)}  •  ${p.mode}'),
                                  subtitle: Text('${fmtDate(p.date)}${p.note.isNotEmpty ? '  •  ${p.note}' : ''}'),
                                  trailing: IconButton(
                                    tooltip: 'Remove payment',
                                    icon: const Icon(Icons.close, size: 18),
                                    onPressed: () async {
                                      final ok = await confirm(context, 'Remove payment?', '${money(p.amount, sym)} will be removed from this invoice.', label: 'Remove');
                                      if (ok) await store.deletePayment(inv.id, p.id);
                                    },
                                  ),
                                ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// The invoice as a printed document.
class _Paper extends StatelessWidget {
  final Invoice inv;
  final Settings s;
  const _Paper({required this.inv, required this.s});

  Widget _t(String t, {bool right = false, bool bold = false, bool head = false}) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        child: Text(
          t,
          textAlign: right ? TextAlign.right : TextAlign.left,
          style: TextStyle(
            fontSize: head ? 11.5 : 12.5,
            fontWeight: (bold || head) ? FontWeight.w700 : FontWeight.w400,
            color: head ? AppColors.muted : AppColors.ink,
          ),
        ),
      );

  Widget _total(String l, String v, {bool bold = false, Color? color}) {
    final st = TextStyle(fontWeight: bold ? FontWeight.w700 : FontWeight.w400, fontSize: bold ? 15 : 13, color: color ?? AppColors.ink);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l, style: st), Text(v, style: st)]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sym = s.currency;
    final inter = inv.interState;
    const lineBorder = TableBorder(
      top: BorderSide(color: AppColors.border),
      bottom: BorderSide(color: AppColors.border),
      horizontalInside: BorderSide(color: AppColors.border),
    );
    const headBg = BoxDecoration(color: AppColors.headerFill);

    final taxHead = inter
        ? ['HSN/SAC', 'Taxable', 'IGST %', 'IGST', 'Total tax']
        : ['HSN/SAC', 'Taxable', 'CGST %', 'CGST', 'SGST %', 'SGST', 'Total tax'];

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
        boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 18, offset: Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.businessName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                    if (s.address.isNotEmpty) Text(s.address),
                    if (s.phone.isNotEmpty) Text('Phone: ${s.phone}'),
                    if (s.email.isNotEmpty) Text('Email: ${s.email}'),
                    if (s.gstin.isNotEmpty) Text('GSTIN: ${s.gstin}', style: const TextStyle(fontWeight: FontWeight.w600)),
                    if (s.state.isNotEmpty) Text('State: ${s.state}'),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(s.invoiceTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.accent)),
                  const SizedBox(height: 6),
                  Text('Invoice no: ${inv.number}', style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text('Date: ${fmtDate(inv.date)}'),
                  Text('Due date: ${fmtDate(inv.dueDate)}'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.headerFill, borderRadius: BorderRadius.circular(6)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('BILL TO', style: TextStyle(fontSize: 11, color: AppColors.muted, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(inv.customerName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                if (inv.customerAddress.isNotEmpty) Text(inv.customerAddress),
                if (inv.customerPhone.isNotEmpty) Text('Phone: ${inv.customerPhone}'),
                if (inv.customerGstin.isNotEmpty) Text('GSTIN: ${inv.customerGstin}'),
                if (inv.customerState.isNotEmpty) Text('Place of supply: ${inv.customerState}'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          HScroll(
            minWidth: 680,
            child: Table(
              border: lineBorder,
              columnWidths: const {
                0: FixedColumnWidth(34),
                1: FlexColumnWidth(4),
                2: FlexColumnWidth(1.3),
                3: FlexColumnWidth(1.2),
                4: FlexColumnWidth(1.4),
                5: FlexColumnWidth(0.9),
                6: FlexColumnWidth(0.9),
                7: FlexColumnWidth(1.6),
              },
              children: [
                TableRow(decoration: headBg, children: [
                  _t('#', head: true),
                  _t('Description', head: true),
                  _t('HSN/SAC', head: true),
                  _t('Qty', head: true, right: true),
                  _t('Rate', head: true, right: true),
                  _t('Disc %', head: true, right: true),
                  _t('Tax %', head: true, right: true),
                  _t('Taxable', head: true, right: true),
                ]),
                for (var i = 0; i < inv.items.length; i++)
                  TableRow(children: [
                    _t('${i + 1}'),
                    _t(inv.items[i].name),
                    _t(inv.items[i].hsn),
                    _t('${qtyText(inv.items[i].qty)} ${inv.items[i].unit}', right: true),
                    _t(money(inv.items[i].price, ''), right: true),
                    _t(inv.items[i].discountPercent > 0 ? qtyText(inv.items[i].discountPercent) : '-', right: true),
                    _t(qtyText(inv.items[i].taxPercent), right: true),
                    _t(money(inv.items[i].taxable, ''), right: true),
                  ]),
              ],
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, c) {
              final taxTable = HScroll(
                minWidth: 420,
                child: Table(
                  border: lineBorder,
                  children: [
                    TableRow(decoration: headBg, children: [
                      for (var i = 0; i < taxHead.length; i++) _t(taxHead[i], head: true, right: i > 0),
                    ]),
                    for (final r in inv.taxRows)
                      TableRow(children: [
                        if (inter) ...[
                          _t(r.hsn.isEmpty ? '-' : r.hsn),
                          _t(money(r.taxable, ''), right: true),
                          _t(qtyText(r.rate), right: true),
                          _t(money(r.tax, ''), right: true),
                          _t(money(r.tax, ''), right: true),
                        ] else ...[
                          _t(r.hsn.isEmpty ? '-' : r.hsn),
                          _t(money(r.taxable, ''), right: true),
                          _t(qtyText(r.rate / 2), right: true),
                          _t(money(r.tax / 2, ''), right: true),
                          _t(qtyText(r.rate / 2), right: true),
                          _t(money(r.tax / 2, ''), right: true),
                          _t(money(r.tax, ''), right: true),
                        ],
                      ]),
                  ],
                ),
              );
              final totals = Column(
                children: [
                  _total('Gross amount', money(inv.grossTotal, sym)),
                  if (inv.itemDiscounts > 0) _total('Item discount', '-${money(inv.itemDiscounts, sym)}', color: AppColors.good),
                  if (inv.billDiscount > 0)
                    _total(
                      inv.discountIsPercent ? 'Bill discount (${qtyText(inv.discountValue)}%)' : 'Bill discount',
                      '-${money(inv.billDiscount, sym)}',
                      color: AppColors.good,
                    ),
                  _total('Taxable value', money(inv.taxableValue, sym)),
                  if (inter)
                    _total('IGST', money(inv.igst, sym))
                  else ...[
                    _total('CGST', money(inv.cgst, sym)),
                    _total('SGST', money(inv.sgst, sym)),
                  ],
                  if (inv.roundOffAmount.abs() >= 0.005) _total('Round off', money(inv.roundOffAmount, sym)),
                  const Divider(height: 16),
                  _total('Total', money(inv.total, sym), bold: true),
                  _total('Received', money(inv.paid, sym)),
                  _total('Balance due', money(inv.balance, sym), bold: true, color: inv.balance > 0.005 ? AppColors.bad : AppColors.good),
                ],
              );
              if (c.maxWidth >= 760) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 5, child: taxTable),
                    const SizedBox(width: 24),
                    Expanded(flex: 3, child: totals),
                  ],
                );
              }
              return Column(children: [taxTable, const SizedBox(height: 12), totals]);
            },
          ),
          const SizedBox(height: 12),
          Text(amountInWords(inv.total, sym), style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (s.bankDetails.isNotEmpty) ...[
                      const Text('Bank details', style: TextStyle(fontSize: 11, color: AppColors.muted, fontWeight: FontWeight.w700)),
                      Text(s.bankDetails),
                      const SizedBox(height: 8),
                    ],
                    if (s.upi.isNotEmpty) Text('UPI: ${s.upi}'),
                    if (inv.notes.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Text('Notes', style: TextStyle(fontSize: 11, color: AppColors.muted, fontWeight: FontWeight.w700)),
                      Text(inv.notes),
                    ],
                    if (s.terms.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Text('Terms and conditions', style: TextStyle(fontSize: 11, color: AppColors.muted, fontWeight: FontWeight.w700)),
                      Text(s.terms, style: const TextStyle(fontSize: 12)),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 24),
              SizedBox(
                width: 190,
                child: Column(
                  children: [
                    const SizedBox(height: 56),
                    const Divider(),
                    Text('For ${s.businessName}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
                    const Text('Authorised signatory', style: TextStyle(fontSize: 11, color: AppColors.muted)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaymentDialog extends StatefulWidget {
  final double balance;
  final String symbol;
  const _PaymentDialog({required this.balance, required this.symbol});

  @override
  State<_PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<_PaymentDialog> {
  late final TextEditingController _amount = TextEditingController(text: widget.balance.toStringAsFixed(2));
  final TextEditingController _note = TextEditingController();
  DateTime _date = DateTime.now();
  String _mode = 'Cash';
  String? _error;

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Record payment'),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _amount,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: dec('Amount received', prefix: '${widget.symbol} ').copyWith(
                helperText: 'Balance due: ${money(widget.balance, widget.symbol)}',
                errorText: _error,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _mode,
              decoration: dec('Payment mode'),
              items: [for (final m in kPayModes) DropdownMenuItem(value: m, child: Text(m))],
              onChanged: (v) => setState(() => _mode = v ?? 'Cash'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (d != null) setState(() => _date = d);
              },
              icon: const Icon(Icons.event),
              label: Text('Date: ${fmtDate(_date)}'),
            ),
            const SizedBox(height: 12),
            TextField(controller: _note, decoration: dec('Note (optional)', hint: 'Reference, cheque no.')),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            final v = double.tryParse(_amount.text.trim());
            if (v == null || v <= 0) {
              setState(() => _error = 'Enter an amount above 0.');
              return;
            }
            Navigator.pop(
              context,
              Payment(id: newId(), date: _date, amount: v, mode: _mode, note: _note.text.trim()),
            );
          },
          child: const Text('Save payment'),
        ),
      ],
    );
  }
}
