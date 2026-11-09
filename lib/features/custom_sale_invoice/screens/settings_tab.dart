import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models.dart';
import '../store.dart';
import '../utils.dart';
import '../widgets.dart';

class SettingsTab extends StatefulWidget {
  final AppStore store;
  const SettingsTab({super.key, required this.store});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  late final TextEditingController _biz, _addr, _phone, _email, _gstin, _cur, _prefix, _next, _tax, _title, _bank, _upi, _terms;
  String _state = '';
  bool _roundOff = true;

  @override
  void initState() {
    super.initState();
    _biz = TextEditingController();
    _addr = TextEditingController();
    _phone = TextEditingController();
    _email = TextEditingController();
    _gstin = TextEditingController();
    _cur = TextEditingController();
    _prefix = TextEditingController();
    _next = TextEditingController();
    _tax = TextEditingController();
    _title = TextEditingController();
    _bank = TextEditingController();
    _upi = TextEditingController();
    _terms = TextEditingController();
    _load();
    widget.store.addListener(_syncNext);
  }

  // The invoice counter moves every time an invoice is saved, so keep the field current.
  void _syncNext() {
    final n = widget.store.settings.nextNumber.toString();
    if (_next.text != n) _next.text = n;
  }

  @override
  void dispose() {
    widget.store.removeListener(_syncNext);
    for (final c in [_biz, _addr, _phone, _email, _gstin, _cur, _prefix, _next, _tax, _title, _bank, _upi, _terms]) {
      c.dispose();
    }
    super.dispose();
  }

  void _load() {
    final s = widget.store.settings;
    _biz.text = s.businessName;
    _addr.text = s.address;
    _phone.text = s.phone;
    _email.text = s.email;
    _gstin.text = s.gstin;
    _cur.text = s.currency;
    _prefix.text = s.prefix;
    _next.text = s.nextNumber.toString();
    _tax.text = qtyText(s.defaultTax);
    _title.text = s.invoiceTitle;
    _bank.text = s.bankDetails;
    _upi.text = s.upi;
    _terms.text = s.terms;
    _state = kStates.contains(s.state) ? s.state : '';
    _roundOff = s.roundOff;
  }

  Future<void> _save() async {
    final old = widget.store.settings;
    await widget.store.saveSettings(Settings(
      businessName: _biz.text.trim().isEmpty ? 'My Business' : _biz.text.trim(),
      address: _addr.text.trim(),
      phone: _phone.text.trim(),
      email: _email.text.trim(),
      gstin: _gstin.text.trim(),
      state: _state,
      currency: _cur.text.trim().isEmpty ? old.currency : _cur.text.trim(),
      prefix: _prefix.text,
      invoiceTitle: _title.text.trim().isEmpty ? 'TAX INVOICE' : _title.text.trim(),
      bankDetails: _bank.text.trim(),
      upi: _upi.text.trim(),
      terms: _terms.text.trim(),
      nextNumber: int.tryParse(_next.text.trim()) ?? old.nextNumber,
      defaultTax: double.tryParse(_tax.text.trim()) ?? old.defaultTax,
      roundOff: _roundOff,
    ));
    if (mounted) snack(context, 'Settings saved.');
  }

  Future<void> _backup() async {
    await Clipboard.setData(ClipboardData(text: widget.store.exportJson()));
    if (mounted) snack(context, 'Backup copied. Paste it into a text file and keep it safe.');
  }

  Future<void> _restore() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => _RestoreDialog(store: widget.store),
    );
    if (ok == true && mounted) {
      setState(_load);
      snack(context, 'Backup restored.');
    }
  }

  @override
  Widget build(BuildContext context) {
    const dec1 = TextInputType.numberWithOptions(decimal: true);
    return PageScroll(
      children: [
        PageHeader(
          title: 'Settings',
          subtitle: 'Business details printed on every invoice',
          actions: [
            FilledButton.icon(onPressed: _save, icon: const Icon(Icons.save_outlined), label: const Text('Save settings')),
          ],
        ),
        const SizedBox(height: 20),
        Panel(
          title: 'Your business',
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(flex: 3, child: TextField(controller: _biz, textCapitalization: TextCapitalization.words, decoration: dec('Business name'))),
                  const SizedBox(width: 12),
                  Expanded(flex: 2, child: TextField(controller: _gstin, textCapitalization: TextCapitalization.characters, decoration: dec('GSTIN'))),
                ],
              ),
              const SizedBox(height: 12),
              TextField(controller: _addr, maxLines: 2, decoration: dec('Address')),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: TextField(controller: _phone, keyboardType: TextInputType.phone, decoration: dec('Phone'))),
                  const SizedBox(width: 12),
                  Expanded(child: TextField(controller: _email, keyboardType: TextInputType.emailAddress, decoration: dec('Email'))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _state,
                      isExpanded: true,
                      decoration: dec('Your state'),
                      items: [
                        const DropdownMenuItem(value: '', child: Text('Select state')),
                        for (final st in kStates) DropdownMenuItem(value: st, child: Text(st, overflow: TextOverflow.ellipsis)),
                      ],
                      onChanged: (v) => setState(() => _state = v ?? ''),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Panel(
          title: 'Invoice settings',
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: TextField(controller: _title, decoration: dec('Invoice heading', hint: 'TAX INVOICE'))),
                  const SizedBox(width: 12),
                  Expanded(child: TextField(controller: _prefix, decoration: dec('Number prefix'))),
                  const SizedBox(width: 12),
                  Expanded(child: TextField(controller: _next, keyboardType: TextInputType.number, decoration: dec('Next number'))),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: TextField(controller: _cur, decoration: dec('Currency symbol'))),
                  const SizedBox(width: 12),
                  Expanded(child: TextField(controller: _tax, keyboardType: dec1, decoration: dec('Default tax %'))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      title: const Text('Round off total'),
                      value: _roundOff,
                      onChanged: (v) => setState(() => _roundOff = v),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Panel(
          title: 'Bank details and terms',
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _bank,
                      maxLines: 4,
                      decoration: dec('Bank details', hint: 'Bank name, account number, IFSC'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(flex: 2, child: TextField(controller: _upi, decoration: dec('UPI ID', hint: 'name@bank'))),
                ],
              ),
              const SizedBox(height: 12),
              TextField(controller: _terms, maxLines: 3, decoration: dec('Terms and conditions')),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Panel(
          title: 'Your data',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Everything is saved on this computer in this file. Copy the file, or use Copy backup, before you reinstall Windows or move to another PC.'),
              const SizedBox(height: 8),
              SelectableText(widget.store.dataPath, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                children: [
                  OutlinedButton.icon(onPressed: _backup, icon: const Icon(Icons.upload), label: const Text('Copy backup')),
                  OutlinedButton.icon(onPressed: _restore, icon: const Icon(Icons.download), label: const Text('Restore backup')),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RestoreDialog extends StatefulWidget {
  final AppStore store;
  const _RestoreDialog({required this.store});

  @override
  State<_RestoreDialog> createState() => _RestoreDialogState();
}

class _RestoreDialogState extends State<_RestoreDialog> {
  final TextEditingController _c = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Restore backup'),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Paste a backup here. This replaces all data on this computer.'),
            const SizedBox(height: 12),
            TextField(controller: _c, maxLines: 8, decoration: dec('Backup text').copyWith(errorText: _error)),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
        FilledButton(
          onPressed: () async {
            try {
              await widget.store.importJson(_c.text);
              if (context.mounted) Navigator.pop(context, true);
            } catch (_) {
              setState(() => _error = 'This is not a valid backup.');
            }
          },
          child: const Text('Restore'),
        ),
      ],
    );
  }
}
