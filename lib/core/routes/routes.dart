
import 'package:flutter/material.dart';

import '../../features/auth/presentation/page/login.dart';
import '../../features/dashboard/presentaion/dashboard_page.dart';
import '../../features/splash/splashPage.dart';

class Routes {
  static const String login = '/login';
  static const String intro = '/';
  static const String dashboard = '/dashboard';
  static const String purchaseChallanPage = '/purchaseChallanPage';
  static const String purchaseChallanList = '/purchaseChallanList';
  static const String taskDetail = '/taskDetail';
  static const String profile = '/profile';
  static const String otherChargeScreen = '/otherChargeScreen';
  static const String productListScreen = '/productListScreen';
  static const String taxListScreen = '/taxListScreen';
  static const String accountScreen = '/accountScreen';
  static const String accountGroupScreen = '/accountGroupScreen';
  static const String stockListScreen = '/stockListScreen';
  static const String teamListScreen = '/teamListScreen';
  static const String saleInvoiceScreen = '/saleInvoiceScreen';
  static const String transportListScreen = '/transportListScreen';
  static const String seriesListScreen = '/seriesListScreen';
  static const String seriesAddUpdateScreen = '/seriesAddUpdateScreen';
  static const String rolePermissionScreen = '/rolePermissionScreen';
  static const String supplierVoucherScreen = '/supplierVoucherScreen';
  static const String supplierVoucherSubmitScreen = '/supplierVoucherSubmitScreen';


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