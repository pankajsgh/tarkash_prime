import 'package:flutter/material.dart';
import 'core/routes/routes.dart';
import 'core/widget/toast.dart';

Future<void> main() async {
  runApp(const MyApp());
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
