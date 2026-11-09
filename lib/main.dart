import 'package:flutter/material.dart';
import 'core/routes/routes.dart';
import 'core/widget/toast.dart';
import 'features/custom_sale_invoice/main.dart';
import 'features/custom_sale_invoice/store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

/*  final store = AppStore();
  await store.init();*/

  runApp(const MyApp());
  // runApp(BillingApp(store: store));

}

// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: Toast.navigatorKey,
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),

      onGenerateRoute: Routes.generateRoute,
    );
  }
}
