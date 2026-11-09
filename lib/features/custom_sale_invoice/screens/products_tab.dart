import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models.dart';
import '../store.dart';
import '../utils.dart';
import '../widgets.dart';

class ProductsTab extends StatelessWidget {
  final AppStore store;
  const ProductsTab({super.key, required this.store});

  Future<void> _edit(BuildContext context, [Product? p]) async {
    final r = await showDialog<Product>(
      context: context,
      builder: (_) => _ProductDialog(product: p, defaultTax: store.settings.defaultTax),
    );
    if (r != null) await store.saveProduct(r);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final sym = store.settings.currency;
        final list = store.products;
        return PageScroll(
          children: [
            PageHeader(
              title: 'Products and services',
              subtitle: '${list.length} saved',
              actions: [
                FilledButton.icon(
                  onPressed: () => _edit(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add product'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Panel(
              padding: EdgeInsets.zero,
              child: list.isEmpty
                  ? emptyState(Icons.inventory_2_outlined, 'No products yet.\nSave your items with HSN code and tax rate to bill faster.')
                  : DataGrid(
                      minWidth: 820,
                      cols: const [
                        Col('Name'),
                        Col('HSN/SAC', width: 120),
                        Col('Unit', width: 90),
                        Col('Rate', width: 130, right: true),
                        Col('Tax %', width: 90, right: true),
                        Col('', width: 48),
                      ],
                      onTap: [for (final p in list) () => _edit(context, p)],
                      rows: [
                        for (final p in list)
                          [
                            Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text(p.hsn.isEmpty ? '-' : p.hsn),
                            Text(p.unit),
                            Text(money(p.price, sym)),
                            Text(qtyText(p.taxPercent)),
                            IconButton(
                              tooltip: 'Delete product',
                              icon: const Icon(Icons.delete_outline, size: 20),
                              onPressed: () async {
                                final ok = await confirm(context, 'Delete product?', '${p.name} will be removed from your list.');
                                if (ok) await store.deleteProduct(p.id);
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

class _ProductDialog extends StatefulWidget {
  final Product? product;
  final double defaultTax;
  const _ProductDialog({this.product, required this.defaultTax});

  @override
  State<_ProductDialog> createState() => _ProductDialogState();
}

class _ProductDialogState extends State<_ProductDialog> {
  late final TextEditingController _name, _hsn, _unit, _price, _tax;
  String? _error;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _name = TextEditingController(text: p?.name ?? '');
    _hsn = TextEditingController(text: p?.hsn ?? '');
    _unit = TextEditingController(text: p?.unit ?? 'pcs');
    _price = TextEditingController(text: p == null ? '' : qtyText(p.price));
    _tax = TextEditingController(text: qtyText(p?.taxPercent ?? widget.defaultTax));
  }

  @override
  void dispose() {
    for (final c in [_name, _hsn, _unit, _price, _tax]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const dec1 = TextInputType.numberWithOptions(decimal: true);
    final nums = [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))];
    return AlertDialog(
      title: Text(widget.product == null ? 'Add product' : 'Edit product'),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 4),
              TextField(controller: _name, autofocus: true, textCapitalization: TextCapitalization.sentences, decoration: dec('Name').copyWith(errorText: _error)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: TextField(controller: _hsn, decoration: dec('HSN / SAC code'))),
                  const SizedBox(width: 12),
                  Expanded(child: TextField(controller: _unit, decoration: dec('Unit', hint: 'pcs, kg, hr'))),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: TextField(controller: _price, keyboardType: dec1, inputFormatters: nums, decoration: dec('Rate (excluding tax)'))),
                  const SizedBox(width: 12),
                  Expanded(child: TextField(controller: _tax, keyboardType: dec1, inputFormatters: nums, decoration: dec('Tax %'))),
                ],
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
              Product(
                id: widget.product?.id ?? newId(),
                name: _name.text.trim(),
                hsn: _hsn.text.trim(),
                unit: _unit.text.trim().isEmpty ? 'pcs' : _unit.text.trim(),
                price: double.tryParse(_price.text.trim()) ?? 0,
                taxPercent: double.tryParse(_tax.text.trim()) ?? 0,
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
