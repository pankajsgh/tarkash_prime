
import 'package:flutter/material.dart';

import '../../features/auth/presentation/page/login.dart';
import '../../features/dashboard/representaion/dashboard_page.dart';
import '../../features/dashboard/representaion/purchase_page.dart';
import '../../features/splash/splashPage.dart';


class Routes {
  static const String login = '/login';
  static const String intro = '/';
  static const String dashboard = '/dashboard';
  static const String purchasePage = '/purchasePage';
  static const String expense = '/expense';
  static const String report = '/report';
  static const String taskDetail = '/taskDetail';
  static const String profile = '/profile';
  static const String vendor = '/vendor';


  static Route<dynamic> generateRoute(RouteSettings settings) {
    if (settings.name == login) {
      return MaterialPageRoute(builder: (context) => LoginPage());
    }
    if (settings.name == intro) {
      return MaterialPageRoute(builder: (context) => SplashPage());
    }
    if (settings.name == purchasePage) {
      return MaterialPageRoute(builder: (context) => PurchasePage());
    }
    if (settings.name == dashboard) {
      return MaterialPageRoute(builder: (context) => BillingDashboardPage());
    }
    return MaterialPageRoute(builder: (context) => SplashPage());
  }
}