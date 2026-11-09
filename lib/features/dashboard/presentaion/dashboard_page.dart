import 'dart:math' as math;
import 'package:calculation_panel/core/vars/global_vars.dart';
import 'package:calculation_panel/features/dashboard/presentaion/erp_top_header.dart';
import 'package:calculation_panel/features/other_charges/presentation/other_charges_list.dart';
import 'package:calculation_panel/features/party_list/view/party_list.dart';
import 'package:calculation_panel/features/purchase_challan/representaion/purchase_page.dart';
import 'package:calculation_panel/features/supplier_voucher/view/supplier_voucher_page.dart';
import 'package:calculation_panel/features/team_permission/view/role_feature_permission_view.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/routes/routes.dart';
import '../../../core/widget/intractive_loder.dart';
import '../../account_group/view/account_group_view.dart';
import '../../hsn/view/hsn_list_view.dart';
import '../../product_list/view/product_list_view.dart';
import '../../purchase_challan_view/representation/purchase_challan_list.dart';
import '../../purchase_challan_view/representation/supplier_voucher_list.dart';
import '../../sale_invoice/representaion/sale_invoice_page.dart';
import '../../series/presentation/series_addupdate_screen.dart';
import '../../series/presentation/series_list_screen.dart';
import '../../stock_list/view/stock_report_screen.dart';
import '../../team/view/team_view.dart';
import '../../transport_list/view/transport_list_screen.dart';
import '../data/controller/dashboard_controller.dart';
import '../data/controller/routes_controller.dart';
import 'component/dashboard_summary.dart';

class BillingDashboardPage extends StatefulWidget {
  const BillingDashboardPage({super.key});

  @override
  State<BillingDashboardPage> createState() =>
      _BillingDashboardPageState();
}

class _BillingDashboardPageState extends State<BillingDashboardPage> {

  late final DashboardController controller;
  late final RoutesController routesController;

  @override
  void initState() {
    super.initState();
    setIpSetting();
    routesController = RoutesController();
    controller = DashboardController();
  }


  Future<void> setIpSetting() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;
    final savedIp = prefs.getString(serverIpKey) ?? '';

    GlobalVars.localIp = savedIp;

    controller.getPartyDashboard();
    controller.getStoreData();

  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          body: Column(
            children:  [
              ERPHeaderPage(routesController: routesController,),

              Expanded(
                child: ListenableBuilder(listenable: routesController,
                    builder: (context, _){

                      if (routesController.isLoading) {
                        return const InteractiveLoadingView();
                      }

                      if(routesController.selectedRoutes==Routes.purchaseChallanList)
                      {
                        return PurchaseChallanListPage(routesController: routesController,);
                      }

                     if(routesController.selectedRoutes==Routes.purchaseChallanPage)
                       {
                         if(routesController.params.isNotEmpty)
                           {
                             if(routesController.params['id']!=null && routesController.params['id']!.isNotEmpty)
                               {
                                 var id = routesController.params['id'];
                                 return PurchaseChallanPage(challanId: id, routesController: routesController,);
                               }
                           }
                         return PurchaseChallanPage(routesController: routesController);
                       }
                
                     if(routesController.selectedRoutes== Routes.otherChargeScreen)
                     {
                       return OtherChargeListScreen();
                     }

                      if(routesController.selectedRoutes== Routes.productListScreen)
                      {
                        return ProductListScreen();
                      }

                      if(routesController.selectedRoutes== Routes.taxListScreen)
                      {
                        return HSNListScreen();
                      }

                      if(routesController.selectedRoutes== Routes.accountScreen)
                      {
                        return PartyListScreen();
                      }

                        if(routesController.selectedRoutes== Routes.accountGroupScreen)
                        {
                          return CreateAccountGroupScreen();
                        }

                      if(routesController.selectedRoutes== Routes.stockListScreen)
                      {
                        return StockReportScreen();
                      }

                      if(routesController.selectedRoutes== Routes.teamListScreen)
                      {
                        return TeamMemberScreen();
                      }

                      if(routesController.selectedRoutes== Routes.saleInvoiceScreen)
                      {
                        return SaleInvoicePage(routesController: routesController,);
                      }

                      if(routesController.selectedRoutes== Routes.transportListScreen)
                      {
                        return TransportListScreen();
                      }

                      if(routesController.selectedRoutes== Routes.seriesAddUpdateScreen)
                      {
                        return SeriesAddUpdateScreen(routesController: routesController);
                      }
                      if(routesController.selectedRoutes== Routes.seriesListScreen)
                      {
                        return SeriesListScreen(routesController: routesController);
                      }

                      if(routesController.selectedRoutes== Routes.rolePermissionScreen)
                      {
                        return RolePermissionsScreen();
                      }

                      if(routesController.selectedRoutes== Routes.supplierVoucherScreen)
                      {
                        return SupplierVoucherListPage(routesController: routesController);
                      }
                      if(routesController.selectedRoutes== Routes.supplierVoucherSubmitScreen)
                      {
                        var id = routesController.params['id'];
                        return SupplierVoucherPage(routesController: routesController, challanId: id,);
                      }

                      GlobalVars.globalRoutes = Routes.dashboard;

                     return
                     controller.dashboardModel!=null ?
                       Padding(
                         padding: const EdgeInsets.only(top: 12.0, left: 12, right: 12),
                         child: DashboardSummarySection(dashboard: controller.dashboardModel!,),
                       ): Center(
                       child: CircularProgressIndicator(
                
                       ),
                     );
                
                    }),
              )



            ],
          ),
        );
      },
    );
  }


}


// ============================================================
// SALES CHART PAINTER
// ============================================================

class SalesChartPainter extends CustomPainter {
  final List<double> values;

  SalesChartPainter({
    required this.values,
  });

  @override
  void paint(
      Canvas canvas,
      Size size,
      ) {
    if (values.isEmpty) return;

    final chartLeft = 45.0;
    final chartRight = size.width - 12;
    final chartTop = 15.0;
    final chartBottom = size.height - 28;

    final chartWidth =
        chartRight - chartLeft;

    final chartHeight =
        chartBottom - chartTop;

    final maxValue =
    values.reduce(math.max);

    final minValue =
    values.reduce(math.min);

    final range =
    (maxValue - minValue) == 0
        ? maxValue
        : maxValue - minValue;

    final gridPaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..strokeWidth = 1;

    // Horizontal grid
    for (int i = 0; i <= 4; i++) {
      final y =
          chartTop +
              (chartHeight / 4) * i;

      canvas.drawLine(
        Offset(chartLeft, y),
        Offset(chartRight, y),
        gridPaint,
      );

      final label =
          '${((maxValue / 1000) * (4 - i) / 4).round()}K';

      final textPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: const TextStyle(
            fontSize: 9,
            color: Color(0xFF6B7280),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(
          0,
          y - 6,
        ),
      );
    }

    final points = <Offset>[];

    for (int i = 0;
    i < values.length;
    i++) {
      final x = chartLeft +
          (chartWidth /
              (values.length - 1)) *
              i;

      final normalized =
          (values[i] - minValue) / range;

      final y =
          chartBottom -
              normalized * chartHeight;

      points.add(
        Offset(x, y),
      );
    }

    // Area
    final areaPath = Path();

    areaPath.moveTo(
      points.first.dx,
      chartBottom,
    );

    for (final point in points) {
      areaPath.lineTo(
        point.dx,
        point.dy,
      );
    }

    areaPath.lineTo(
      points.last.dx,
      chartBottom,
    );

    areaPath.close();

    final areaPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0x332563EB),
          Color(0x002563EB),
        ],
      ).createShader(
        Rect.fromLTWH(
          0,
          chartTop,
          size.width,
          chartHeight,
        ),
      );

    canvas.drawPath(
      areaPath,
      areaPaint,
    );

    // Line
    final linePath = Path();

    linePath.moveTo(
      points.first.dx,
      points.first.dy,
    );

    for (int i = 1;
    i < points.length;
    i++) {
      linePath.lineTo(
        points[i].dx,
        points[i].dy,
      );
    }

    final linePaint = Paint()
      ..color = const Color(0xFF2563EB)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawPath(
      linePath,
      linePaint,
    );

    // Points
    final pointPaint = Paint()
      ..color = const Color(0xFF2563EB);

    for (final point in points) {
      canvas.drawCircle(
        point,
        3.5,
        pointPaint,
      );
    }

    // X labels
    for (int i = 0;
    i < points.length;
    i++) {
      final label =
          '${11 + i} May';

      final textPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: const TextStyle(
            fontSize: 9,
            color: Color(0xFF6B7280),
          ),
        ),
        textDirection:
        TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(
          points[i].dx -
              textPainter.width / 2,
          chartBottom + 7,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(
      covariant SalesChartPainter oldDelegate,
      ) {
    return oldDelegate.values != values;
  }
}


// ============================================================
// PAYMENT DONUT
// ============================================================

class PaymentChartPainter
    extends CustomPainter {
  final double paid;
  final double pending;
  final double overdue;

  PaymentChartPainter({
    required this.paid,
    required this.pending,
    required this.overdue,
  });

  @override
  void paint(
      Canvas canvas,
      Size size,
      ) {
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final radius =
        math.min(size.width, size.height) /
            2 -
            8;

    final strokeWidth = 25.0;

    final rect = Rect.fromCircle(
      center: center,
      radius: radius,
    );

    final segments = [
      (
      value: paid,
      color: const Color(0xFF22C55E),
      ),
      (
      value: pending,
      color: const Color(0xFFF59E0B),
      ),
      (
      value: overdue,
      color: const Color(0xFFEF4444),
      ),
    ];

    double startAngle =
        -math.pi / 2;

    for (final segment in segments) {
      final sweep =
          segment.value * math.pi * 2;

      final paint = Paint()
        ..color = segment.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;

      canvas.drawArc(
        rect,
        startAngle,
        sweep - 0.025,
        false,
        paint,
      );

      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(
      covariant PaymentChartPainter oldDelegate,
      ) {
    return oldDelegate.paid != paid ||
        oldDelegate.pending != pending ||
        oldDelegate.overdue != overdue;
  }
}
