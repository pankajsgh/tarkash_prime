import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/customers_tab.dart';
import 'screens/dashboard_tab.dart';
import 'screens/invoice_editor.dart';
import 'screens/invoices_tab.dart';
import 'screens/products_tab.dart';
import 'screens/reports_tab.dart';
import 'screens/settings_tab.dart';
import 'store.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = AppStore();
  await store.init();
  runApp(BillingApp(store: store));
}

class BillingApp extends StatelessWidget {
  final AppStore store;
  const BillingApp({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Billing',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: HomeScreen(store: store),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final AppStore store;
  const HomeScreen({super.key, required this.store});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  static const _nav = <(String, IconData, IconData)>[
    ('Dashboard', Icons.dashboard_outlined, Icons.dashboard),
    ('Invoices', Icons.receipt_long_outlined, Icons.receipt_long),
    ('Customers', Icons.people_outline, Icons.people),
    ('Products', Icons.inventory_2_outlined, Icons.inventory_2),
    ('Reports', Icons.bar_chart_outlined, Icons.bar_chart),
    ('Settings', Icons.settings_outlined, Icons.settings),
  ];

  void _newInvoice() => openEditor(context, widget.store);

  void _go(int i) => setState(() => _tab = i);

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final pages = <Widget>[
      DashboardTab(store: store, onNew: _newInvoice, onViewAll: () => _go(1)),
      InvoicesTab(store: store),
      CustomersTab(store: store),
      ProductsTab(store: store),
      ReportsTab(store: store),
      SettingsTab(store: store),
    ];

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyN, control: true): _newInvoice,
        const SingleActivator(LogicalKeyboardKey.digit1, control: true): () => _go(0),
        const SingleActivator(LogicalKeyboardKey.digit2, control: true): () => _go(1),
        const SingleActivator(LogicalKeyboardKey.digit3, control: true): () => _go(2),
        const SingleActivator(LogicalKeyboardKey.digit4, control: true): () => _go(3),
        const SingleActivator(LogicalKeyboardKey.digit5, control: true): () => _go(4),
        const SingleActivator(LogicalKeyboardKey.digit6, control: true): () => _go(5),
      },
      child: Focus(
        autofocus: true,
        child: LayoutBuilder(
          builder: (context, c) {
            final compact = c.maxWidth < 1000;
            return Scaffold(
              body: Row(
                children: [
                  ListenableBuilder(
                    listenable: store,
                    builder: (context, _) => _Sidebar(
                      compact: compact,
                      business: store.settings.businessName,
                      selected: _tab,
                      items: _nav,
                      onSelect: _go,
                      onNew: _newInvoice,
                    ),
                  ),
                  Expanded(
                    child: IndexedStack(index: _tab, children: pages),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  final bool compact;
  final String business;
  final int selected;
  final List<(String, IconData, IconData)> items;
  final ValueChanged<int> onSelect;
  final VoidCallback onNew;

  const _Sidebar({
    required this.compact,
    required this.business,
    required this.selected,
    required this.items,
    required this.onSelect,
    required this.onNew,
  });

  @override
  Widget build(BuildContext context) {
    final initial = business.trim().isEmpty ? 'B' : business.trim()[0].toUpperCase();
    return Container(
      width: compact ? 76 : 236,
      color: AppColors.sidebar,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(compact ? 0 : 18, 22, compact ? 0 : 18, 18),
            child: Row(
              mainAxisAlignment: compact ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(10)),
                  child: Text(initial, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                ),
                if (!compact) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      business,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: compact ? 14 : 16),
            child: compact
                ? IconButton.filled(
                    tooltip: 'New invoice (Ctrl+N)',
                    onPressed: onNew,
                    icon: const Icon(Icons.add),
                  )
                : FilledButton.icon(
                    onPressed: onNew,
                    icon: const Icon(Icons.add),
                    label: const Text('New invoice'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(44),
                      backgroundColor: AppColors.accent,
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < items.length; i++)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 12, vertical: 2),
              child: Tooltip(
                message: compact ? '${items[i].$1} (Ctrl+${i + 1})' : '',
                child: Material(
                  color: selected == i ? const Color(0x26FFFFFF) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => onSelect(i),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: compact ? 0 : 12, vertical: 12),
                      child: Row(
                        mainAxisAlignment: compact ? MainAxisAlignment.center : MainAxisAlignment.start,
                        children: [
                          Icon(
                            selected == i ? items[i].$3 : items[i].$2,
                            size: 20,
                            color: selected == i ? Colors.white : AppColors.sidebarText,
                          ),
                          if (!compact) ...[
                            const SizedBox(width: 12),
                            Text(
                              items[i].$1,
                              style: TextStyle(
                                color: selected == i ? Colors.white : AppColors.sidebarText,
                                fontWeight: selected == i ? FontWeight.w600 : FontWeight.w400,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          const Spacer(),
          if (!compact)
            const Padding(
              padding: EdgeInsets.all(18),
              child: Text(
                'Ctrl+N  New invoice\nCtrl+1 to 6  Switch pages',
                style: TextStyle(color: AppColors.sidebarText, fontSize: 11.5, height: 1.5),
              ),
            ),
        ],
      ),
    );
  }
}
