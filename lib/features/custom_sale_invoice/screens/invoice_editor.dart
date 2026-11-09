import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models.dart';
import '../store.dart';
import '../theme.dart';
import '../utils.dart';
import '../widgets.dart';

void openEditor(BuildContext context, AppStore store, {Invoice? invoice}) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => InvoiceEditor(store: store, invoice: invoice)),
  );
}

// Column widths of the item grid. The header row uses the same numbers.
const double _wPick = 36, _wHsn = 96, _wQty = 72, _wUnit = 74, _wRate = 104, _wDisc = 72, _wTax = 72, _wAmt = 116, _wDel = 40;

class InvoiceEditor extends StatefulWidget {
  final AppStore store;
  final Invoice? invoice; // null = create new
  const InvoiceEditor({super.key, required this.store, this.invoice});

  @override
  State<InvoiceEditor> createState() => _InvoiceEditorState();
}

class _InvoiceEditorState extends State<InvoiceEditor> {
  late Invoice inv;
  late final TextEditingController _number, _name, _phone, _address, _gstin, _discount, _received, _notes;
  String _payMode = 'Cash';

  bool get _isNew => widget.invoice == null;
  Settings get _s => widget.store.settings;

  @override
  void initState() {
    super.initState();
    if (widget.invoice == null) {
      final now = DateTime.now();
      inv = Invoice(
        id: newId(),
        number: widget.store.nextInvoiceNumber(),
        date: now,
        dueDate: now.add(const Duration(days: 15)),
        roundOff: _s.roundOff,
        items: [LineItem(taxPercent: _s.defaultTax)],
      );
    } else {
      // Work on a copy so Cancel leaves the saved invoice untouched.
      inv = Invoice.fromJson(widget.invoice!.toJson());
    }
    _number = TextEditingController(text: inv.number);
    _name = TextEditingController(text: inv.customerName);
    _phone = TextEditingController(text: inv.customerPhone);
    _address = TextEditingController(text: inv.customerAddress);
    _gstin = TextEditingController(text: inv.customerGstin);
    _discount = TextEditingController(text: inv.discountValue == 0 ? '' : qtyText(inv.discountValue));
    _received = TextEditingController();
    _notes = TextEditingController(text: inv.notes);
  }

  @override
  void dispose() {
    for (final c in [_number, _name, _phone, _address, _gstin, _discount, _received, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  void _autoInter() {
    if (_s.state.isNotEmpty && inv.customerState.isNotEmpty) {
      inv.interState = _s.state != inv.customerState;
    }
  }

  void _sync() {
    inv.number = _number.text.trim();
    inv.customerName = _name.text.trim();
    inv.customerPhone = _phone.text.trim();
    inv.customerAddress = _address.text.trim();
    inv.customerGstin = _gstin.text.trim();
    inv.discountValue = double.tryParse(_discount.text.trim()) ?? 0;
    inv.notes = _notes.text.trim();
  }

  Future<void> _pickDate(bool isDue) async {
    final d = await showDatePicker(
      context: context,
      initialDate: isDue ? inv.dueDate : inv.date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (d == null) return;
    setState(() {
      if (isDue) {
        inv.dueDate = d;
      } else {
        inv.date = d;
        if (inv.dueDate.isBefore(d)) inv.dueDate = d;
      }
    });
  }

  Future<void> _pickCustomer() async {
    final list = widget.store.customers;
    if (list.isEmpty) {
      snack(context, 'No saved customers yet. Add them on the Customers page.');
      return;
    }
    final picked = await showDialog<Customer>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Choose customer'),
        children: [
          SizedBox(
            width: 440,
            height: 360,
            child: ListView(
              children: [
                for (final c in list)
                  ListTile(
                    title: Text(c.name),
                    subtitle: Text([c.phone, c.state].where((e) => e.isNotEmpty).join('  •  ')),
                    onTap: () => Navigator.pop(ctx, c),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
    if (picked == null) return;
    setState(() {
      _name.text = picked.name;
      _phone.text = picked.phone;
      _address.text = picked.address;
      _gstin.text = picked.gstin;
      inv.customerState = picked.state;
      _autoInter();
    });
  }

  Future<void> _pickProduct(int index) async {
    final list = widget.store.products;
    if (list.isEmpty) {
      snack(context, 'No saved products yet. Add them on the Products page.');
      return;
    }
    final sym = _s.currency;
    final chosen = await showDialog<Product>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Choose product'),
        children: [
          SizedBox(
            width: 480,
            height: 380,
            child: ListView(
              children: [
                for (final p in list)
                  ListTile(
                    title: Text(p.name),
                    subtitle: Text(
                      '${money(p.price, sym)} / ${p.unit}  •  Tax ${qtyText(p.taxPercent)}%'
                      '${p.hsn.isNotEmpty ? '  •  HSN ${p.hsn}' : ''}',
                    ),
                    onTap: () => Navigator.pop(ctx, p),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
    if (chosen == null) return;
    setState(() {
      final old = inv.items[index];
      // A new object gives the row fresh text fields.
      inv.items[index] = LineItem(
        name: chosen.name,
        hsn: chosen.hsn,
        unit: chosen.unit,
        qty: old.qty <= 0 ? 1 : old.qty,
        price: chosen.price,
        discountPercent: old.discountPercent,
        taxPercent: chosen.taxPercent,
      );
    });
  }

  Future<void> _save() async {
    _sync();
    inv.items.removeWhere((i) => i.name.trim().isEmpty && i.price == 0);
    if (inv.number.isEmpty) {
      snack(context, 'Enter an invoice number.');
      return;
    }
    if (inv.customerName.isEmpty) {
      snack(context, 'Enter the customer name.');
      return;
    }
    if (inv.items.isEmpty || inv.items.any((i) => i.name.trim().isEmpty)) {
      snack(context, 'Every item needs a name. Add at least one item.');
      setState(() {
        if (inv.items.isEmpty) inv.items.add(LineItem(taxPercent: _s.defaultTax));
      });
      return;
    }
    final dup = widget.store.invoices.any((e) => e.number == inv.number && e.id != inv.id);
    if (dup) {
      snack(context, 'Invoice number ${inv.number} is already used.');
      return;
    }
    final received = double.tryParse(_received.text.trim()) ?? 0;
    if (_isNew && received > 0) {
      inv.payments.add(Payment(id: newId(), date: DateTime.now(), amount: received, mode: _payMode));
    }
    await widget.store.saveInvoice(inv);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final sym = _s.currency;
    // Keep totals live while typing the bill discount.
    inv.discountValue = double.tryParse(_discount.text.trim()) ?? 0;

    return CallbackShortcuts(
      bindings: {const SingleActivator(LogicalKeyboardKey.keyS, control: true): _save},
      child: Focus(
        autofocus: true,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            shape: const Border(bottom: BorderSide(color: AppColors.border)),
            title: Text(_isNew ? 'New invoice' : 'Edit invoice ${widget.invoice!.number}'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Save  (Ctrl+S)'),
              ),
              const SizedBox(width: 16),
            ],
          ),
          body: PageScroll(
            children: [
              LayoutBuilder(
                builder: (context, c) {
                  final wide = c.maxWidth >= 900;
                  final customer = _customerPanel();
                  final details = _detailsPanel();
                  if (wide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: customer),
                        const SizedBox(width: 16),
                        Expanded(flex: 2, child: details),
                      ],
                    );
                  }
                  return Column(children: [customer, const SizedBox(height: 16), details]);
                },
              ),
              const SizedBox(height: 16),
              _itemsPanel(sym),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, c) {
                  final wide = c.maxWidth >= 900;
                  final notes = _notesPanel(sym);
                  final totals = _totalsPanel(sym);
                  if (wide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: notes),
                        const SizedBox(width: 16),
                        SizedBox(width: 400, child: totals),
                      ],
                    );
                  }
                  return Column(children: [notes, const SizedBox(height: 16), totals]);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---- panels ----

  Widget _customerPanel() {
    return Panel(
      title: 'Bill to',
      trailing: TextButton.icon(
        onPressed: _pickCustomer,
        icon: const Icon(Icons.person_search, size: 18),
        label: const Text('Saved customers'),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(controller: _name, textCapitalization: TextCapitalization.words, decoration: dec('Customer name')),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: TextField(controller: _phone, keyboardType: TextInputType.phone, decoration: dec('Phone')),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(controller: _address, maxLines: 2, decoration: dec('Address')),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _gstin,
                  textCapitalization: TextCapitalization.characters,
                  decoration: dec('Customer GSTIN (optional)'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: kStates.contains(inv.customerState) ? inv.customerState : '',
                  isExpanded: true,
                  decoration: dec('State (place of supply)'),
                  items: [
                    const DropdownMenuItem(value: '', child: Text('Select state')),
                    for (final st in kStates) DropdownMenuItem(value: st, child: Text(st, overflow: TextOverflow.ellipsis)),
                  ],
                  onChanged: (v) => setState(() {
                    inv.customerState = v ?? '';
                    _autoInter();
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detailsPanel() {
    return Panel(
      title: 'Invoice details',
      child: Column(
        children: [
          TextField(controller: _number, decoration: dec('Invoice number')),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _dateButton('Invoice date', inv.date, () => _pickDate(false))),
              const SizedBox(width: 12),
              Expanded(child: _dateButton('Due date', inv.dueDate, () => _pickDate(true))),
            ],
          ),
          const SizedBox(height: 4),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: const Text('Inter-state sale (IGST)'),
            subtitle: Text(
              _s.state.isEmpty
                  ? 'Set your state in Settings to choose this automatically.'
                  : 'Your state: ${_s.state}. Off = CGST + SGST.',
              style: const TextStyle(fontSize: 12),
            ),
            value: inv.interState,
            onChanged: (v) => setState(() => inv.interState = v),
          ),
        ],
      ),
    );
  }

  Widget _dateButton(String label, DateTime d, VoidCallback onTap) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
          Text(fmtDate(d)),
        ],
      ),
    );
  }

  Widget _itemsPanel(String sym) {
    const head = TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.muted, letterSpacing: 0.4);
    Widget h(double w, String t, {bool right = false}) => Padding(
          padding: const EdgeInsets.only(left: 6),
          child: SizedBox(width: w, child: Text(t.toUpperCase(), style: head, textAlign: right ? TextAlign.right : TextAlign.left)),
        );

    return Panel(
      title: 'Items',
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HScroll(
            minWidth: 920,
            child: Column(
              children: [
                Container(
                  color: AppColors.headerFill,
                  padding: const EdgeInsets.fromLTRB(12, 9, 12, 9),
                  child: Row(
                    children: [
                      const SizedBox(width: 26, child: Text('#', style: head)),
                      const Expanded(child: Padding(padding: EdgeInsets.only(left: 6), child: Text('ITEM', style: head))),
                      h(_wPick, ''),
                      h(_wHsn, 'HSN/SAC'),
                      h(_wQty, 'Qty', right: true),
                      h(_wUnit, 'Unit'),
                      h(_wRate, 'Rate', right: true),
                      h(_wDisc, 'Disc %', right: true),
                      h(_wTax, 'Tax %', right: true),
                      h(_wAmt, 'Line total', right: true),
                      h(_wDel, ''),
                    ],
                  ),
                ),
                const Divider(height: 1),
                for (var i = 0; i < inv.items.length; i++)
                  _LineRow(
                    key: ObjectKey(inv.items[i]),
                    index: i,
                    item: inv.items[i],
                    symbol: sym,
                    onChanged: () => setState(() {}),
                    onPick: () => _pickProduct(i),
                    onRemove: () => setState(() {
                      inv.items.removeAt(i);
                      if (inv.items.isEmpty) inv.items.add(LineItem(taxPercent: _s.defaultTax));
                    }),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: OutlinedButton.icon(
              onPressed: () => setState(() => inv.items.add(LineItem(taxPercent: _s.defaultTax))),
              icon: const Icon(Icons.add),
              label: const Text('Add item'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _notesPanel(String sym) {
    return Panel(
      title: 'Payment and notes',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isNew)
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _received,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                    onChanged: (_) => setState(() {}),
                    decoration: dec('Amount received now', prefix: '$sym '),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _payMode,
                    decoration: dec('Payment mode'),
                    items: [for (final m in kPayModes) DropdownMenuItem(value: m, child: Text(m))],
                    onChanged: (v) => setState(() => _payMode = v ?? 'Cash'),
                  ),
                ),
              ],
            )
          else
            Text(
              inv.payments.isEmpty
                  ? 'No payments recorded yet. Record payments on the invoice page.'
                  : 'Received so far: ${money(inv.paid, sym)} in ${inv.payments.length} payment(s). '
                      'Manage payments on the invoice page.',
              style: const TextStyle(color: AppColors.muted),
            ),
          const SizedBox(height: 12),
          TextField(
            controller: _notes,
            maxLines: 4,
            decoration: dec('Notes for this invoice', hint: 'Delivery details, PO number, thank-you note'),
          ),
        ],
      ),
    );
  }

  Widget _totalsPanel(String sym) {
    final received = _isNew ? (double.tryParse(_received.text.trim()) ?? 0) : inv.paid;
    final balance = (inv.total - received).clamp(0.0, double.infinity).toDouble();

    Widget row(String l, String v, {bool bold = false, Color? color}) {
      final st = TextStyle(fontWeight: bold ? FontWeight.w700 : FontWeight.w400, fontSize: bold ? 15 : 14, color: color);
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l, style: st), Text(v, style: st)]),
      );
    }

    return Panel(
      title: 'Summary',
      child: Column(
        children: [
          row('Gross amount', money(inv.grossTotal, sym)),
          if (inv.itemDiscounts > 0) row('Item discounts', '-${money(inv.itemDiscounts, sym)}', color: AppColors.good),
          const SizedBox(height: 4),
          Row(
            children: [
              const Expanded(child: Text('Bill discount')),
              SegmentedButton<bool>(
                showSelectedIcon: false,
                style: SegmentedButton.styleFrom(visualDensity: VisualDensity.compact),
                segments: [
                  const ButtonSegment(value: true, label: Text('%')),
                  ButtonSegment(value: false, label: Text(sym)),
                ],
                selected: {inv.discountIsPercent},
                onSelectionChanged: (s) => setState(() => inv.discountIsPercent = s.first),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 88,
                child: TextField(
                  controller: _discount,
                  textAlign: TextAlign.right,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                  onChanged: (_) => setState(() {}),
                  decoration: cellDec('0'),
                ),
              ),
            ],
          ),
          if (inv.billDiscount > 0) row('Bill discount amount', '-${money(inv.billDiscount, sym)}', color: AppColors.good),
          const Divider(height: 20),
          row('Taxable value', money(inv.taxableValue, sym)),
          if (inv.interState)
            row('IGST', money(inv.igst, sym))
          else ...[
            row('CGST', money(inv.cgst, sym)),
            row('SGST', money(inv.sgst, sym)),
          ],
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: Text('Round off${inv.roundOff ? '  (${money(inv.roundOffAmount, sym)})' : ''}'),
            value: inv.roundOff,
            onChanged: (v) => setState(() => inv.roundOff = v),
          ),
          const Divider(height: 12),
          row('Total', money(inv.total, sym), bold: true),
          row('Received', money(received, sym)),
          row('Balance due', money(balance, sym), bold: true, color: balance > 0.005 ? AppColors.bad : AppColors.good),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(amountInWords(inv.total, sym), style: const TextStyle(fontSize: 12, color: AppColors.muted)),
          ),
        ],
      ),
    );
  }
}

class _LineRow extends StatefulWidget {
  final int index;
  final LineItem item;
  final String symbol;
  final VoidCallback onChanged, onPick, onRemove;

  const _LineRow({
    super.key,
    required this.index,
    required this.item,
    required this.symbol,
    required this.onChanged,
    required this.onPick,
    required this.onRemove,
  });

  @override
  State<_LineRow> createState() => _LineRowState();
}

class _LineRowState extends State<_LineRow> {
  late final TextEditingController _name, _hsn, _qty, _unit, _price, _disc, _tax;

  @override
  void initState() {
    super.initState();
    final it = widget.item;
    _name = TextEditingController(text: it.name);
    _hsn = TextEditingController(text: it.hsn);
    _qty = TextEditingController(text: qtyText(it.qty));
    _unit = TextEditingController(text: it.unit);
    _price = TextEditingController(text: it.price == 0 ? '' : qtyText(it.price));
    _disc = TextEditingController(text: it.discountPercent == 0 ? '' : qtyText(it.discountPercent));
    _tax = TextEditingController(text: qtyText(it.taxPercent));
  }

  @override
  void dispose() {
    for (final c in [_name, _hsn, _qty, _unit, _price, _disc, _tax]) {
      c.dispose();
    }
    super.dispose();
  }

  void _update() {
    final it = widget.item;
    it.name = _name.text;
    it.hsn = _hsn.text.trim();
    it.qty = double.tryParse(_qty.text) ?? 0;
    it.unit = _unit.text.trim();
    it.price = double.tryParse(_price.text) ?? 0;
    it.discountPercent = (double.tryParse(_disc.text) ?? 0.0).clamp(0.0, 100.0).toDouble();
    it.taxPercent = double.tryParse(_tax.text) ?? 0;
    widget.onChanged();
  }

  Widget _cell(double w, Widget child) =>
      Padding(padding: const EdgeInsets.only(left: 6), child: SizedBox(width: w, child: child));

  Widget _num(double w, TextEditingController c, String hint) => _cell(
        w,
        TextField(
          controller: c,
          textAlign: TextAlign.right,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
          onChanged: (_) => _update(),
          decoration: cellDec(hint),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 26, child: Text('${widget.index + 1}', style: const TextStyle(color: AppColors.muted))),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 6),
              child: TextField(
                controller: _name,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (_) => _update(),
                decoration: cellDec('Item or service name'),
              ),
            ),
          ),
          _cell(
            _wPick,
            IconButton(
              tooltip: 'Pick from products',
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.inventory_2_outlined, size: 20),
              onPressed: widget.onPick,
            ),
          ),
          _cell(_wHsn, TextField(controller: _hsn, onChanged: (_) => _update(), decoration: cellDec('HSN'))),
          _num(_wQty, _qty, '1'),
          _cell(_wUnit, TextField(controller: _unit, onChanged: (_) => _update(), decoration: cellDec('pcs'))),
          _num(_wRate, _price, '0.00'),
          _num(_wDisc, _disc, '0'),
          _num(_wTax, _tax, '0'),
          _cell(
            _wAmt,
            Text(
              money(widget.item.total, widget.symbol),
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          _cell(
            _wDel,
            IconButton(
              tooltip: 'Remove item',
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.close, size: 20),
              onPressed: widget.onRemove,
            ),
          ),
        ],
      ),
    );
  }
}
