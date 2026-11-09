import 'package:flutter/material.dart';

import '../models.dart';
import '../store.dart';
import '../theme.dart';
import '../utils.dart';
import '../widgets.dart';

class CustomersTab extends StatelessWidget {
  final AppStore store;
  const CustomersTab({super.key, required this.store});

  Future<void> _edit(BuildContext context, [Customer? c]) async {
    final r = await showDialog<Customer>(
      context: context,
      builder: (_) => _CustomerDialog(customer: c),
    );
    if (r != null) await store.saveCustomer(r);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final sym = store.settings.currency;
        final list = store.customers;

        double owedBy(String name) =>
            store.invoices.where((i) => i.customerName == name).fold<double>(0, (a, i) => a + i.balance);
        int countFor(String name) => store.invoices.where((i) => i.customerName == name).length;

        return PageScroll(
          children: [
            PageHeader(
              title: 'Customers',
              subtitle: '${list.length} saved',
              actions: [
                FilledButton.icon(
                  onPressed: () => _edit(context),
                  icon: const Icon(Icons.person_add_alt),
                  label: const Text('Add customer'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Panel(
              padding: EdgeInsets.zero,
              child: list.isEmpty
                  ? emptyState(Icons.people_outline, 'No customers yet.\nSave customers here to fill invoices faster.')
                  : DataGrid(
                      minWidth: 900,
                      cols: const [
                        Col('Name'),
                        Col('Phone', width: 130),
                        Col('State', width: 150),
                        Col('GSTIN', width: 160),
                        Col('Invoices', width: 80, right: true),
                        Col('Balance due', width: 130, right: true),
                        Col('', width: 48),
                      ],
                      onTap: [for (final c in list) () => _edit(context, c)],
                      rows: [
                        for (final c in list)
                          [
                            Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text(c.phone),
                            Text(c.state, maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text(c.gstin),
                            Text('${countFor(c.name)}'),
                            Text(
                              money(owedBy(c.name), sym),
                              style: TextStyle(color: owedBy(c.name) > 0.005 ? AppColors.bad : AppColors.muted),
                            ),
                            IconButton(
                              tooltip: 'Delete customer',
                              icon: const Icon(Icons.delete_outline, size: 20),
                              onPressed: () async {
                                final ok = await confirm(context, 'Delete customer?', '${c.name} will be removed. Existing invoices keep their details.');
                                if (ok) await store.deleteCustomer(c.id);
                              },
                            ),
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

class _CustomerDialog extends StatefulWidget {
  final Customer? customer;
  const _CustomerDialog({this.customer});

  @override
  State<_CustomerDialog> createState() => _CustomerDialogState();
}

class _CustomerDialogState extends State<_CustomerDialog> {
  late final TextEditingController _name, _phone, _email, _address, _gstin;
  late String _state;
  String? _error;

  @override
  void initState() {
    super.initState();
    final c = widget.customer;
    _name = TextEditingController(text: c?.name ?? '');
    _phone = TextEditingController(text: c?.phone ?? '');
    _email = TextEditingController(text: c?.email ?? '');
    _address = TextEditingController(text: c?.address ?? '');
    _gstin = TextEditingController(text: c?.gstin ?? '');
    _state = kStates.contains(c?.state) ? c!.state : '';
  }

  @override
  void dispose() {
    for (final c in [_name, _phone, _email, _address, _gstin]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.customer == null ? 'Add customer' : 'Edit customer'),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 4),
              TextField(controller: _name, autofocus: true, textCapitalization: TextCapitalization.words, decoration: dec('Name').copyWith(errorText: _error)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: TextField(controller: _phone, keyboardType: TextInputType.phone, decoration: dec('Phone'))),
                  const SizedBox(width: 12),
                  Expanded(child: TextField(controller: _email, keyboardType: TextInputType.emailAddress, decoration: dec('Email'))),
                ],
              ),
              const SizedBox(height: 12),
              TextField(controller: _address, maxLines: 2, decoration: dec('Address')),
              const SizedBox(height: 12),
              TextField(controller: _gstin, textCapitalization: TextCapitalization.characters, decoration: dec('GSTIN (optional)')),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _state,
                isExpanded: true,
                decoration: dec('State'),
                items: [
                  const DropdownMenuItem(value: '', child: Text('Select state')),
                  for (final st in kStates) DropdownMenuItem(value: st, child: Text(st, overflow: TextOverflow.ellipsis)),
                ],
                onChanged: (v) => setState(() => _state = v ?? ''),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            if (_name.text.trim().isEmpty) {
              setState(() => _error = 'Enter a name.');
              return;
            }
            Navigator.pop(
              context,
              Customer(
                id: widget.customer?.id ?? newId(),
                name: _name.text.trim(),
                phone: _phone.text.trim(),
                email: _email.text.trim(),
                address: _address.text.trim(),
                gstin: _gstin.text.trim(),
                state: _state,
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
