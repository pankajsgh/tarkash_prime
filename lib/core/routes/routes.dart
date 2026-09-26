
import 'package:flutter/material.dart';

import '../../features/auth/presentation/page/login.dart';
import '../../features/dashboard/presentaion/dashboard_page.dart';
import '../../features/splash/splashPage.dart';


class Routes {
  static const String login = '/login';
  static const String intro = '/';
  static const String dashboard = '/dashboard';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    if (settings.name == login) {
      return MaterialPageRoute(builder: (context) => LoginPage());
    }
    if (settings.name == intro) {
      return MaterialPageRoute(builder: (context) => SplashPage());
    }
    if (settings.name == dashboard) {
      return MaterialPageRoute(builder: (context) => BillingDashboardPage());
    }
    return MaterialPageRoute(builder: (context) => SplashPage());
  }
}