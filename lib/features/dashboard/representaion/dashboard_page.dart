import 'dart:math' as math;

import 'package:calculation_panel/core/routes/routes.dart';
import 'package:calculation_panel/core/vars/global_vars.dart';
import 'package:calculation_panel/core/widget/logo_widget.dart';
import 'package:calculation_panel/features/dashboard/representaion/dashboard_controller.dart';
import 'package:calculation_panel/features/dashboard/representaion/top_header/top_header.dart';
import 'package:flutter/material.dart';
import 'dashboard_components.dart';

class BillingDashboardPage extends StatefulWidget {
  const BillingDashboardPage({super.key});

  @override
  State<BillingDashboardPage> createState() =>
      _BillingDashboardPageState();
}

class _BillingDashboardPageState
    extends State<BillingDashboardPage> {

  late final DashboardController controller;

  @override
  void initState() {
    GlobalVars.globalRoutes = "dashboard";
    super.initState();

    controller = DashboardController()..getPartyDashboard()..getStoreData();
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
          body: Stack(
            children:  [
              _buildTopBar(),

              if(controller.dashboardModel!=null)
              Padding(
                padding: const EdgeInsets.only(top: 70.0, left: 12, right: 12),
                child: DashboardSummarySection(dashboard: controller.dashboardModel!,),
              ) else Center(
                child: CircularProgressIndicator(

                ),
              ),
              ERPHomePage(),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // SIDEBAR
  // ============================================================

  Widget _buildSidebar() {
    return Container(
      width: 220,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(
            color: Color(0xFFE5E7EB),
          ),
        ),
      ),
      child: Column(
        children: [

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: buildLogo(context),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 10,
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  _menuItem(
                    icon: Icons.dashboard_rounded,
                    title: 'Dashboard',
                    selected: true,
                  ),

                  const SizedBox(height: 18),

                  _sectionTitle('SALES'),

                  _menuItem(
                    icon: Icons.description_outlined,
                    title: 'Sales Invoice',
                  ),

                  _menuItem(
                    icon: Icons.assignment_return_outlined,
                    title: 'Sales Return',
                  ),

                  const SizedBox(height: 12),

                  _sectionTitle('PURCHASE'),

                  _menuItem(
                    onTap: (){
                      print("this is good");
                      Navigator.pushNamed(context, Routes.purchasePage);
                    },
                    icon: Icons.receipt_long,
                    title: 'Challan',
                  ),


                  _menuItem(
                    icon: Icons.shopping_cart_outlined,
                    title: 'Purchase Bill',
                  ),

                  _menuItem(
                    icon: Icons.keyboard_return_rounded,
                    title: 'Purchase Return',
                  ),

                  const SizedBox(height: 12),

                  _sectionTitle('CONTACTS'),

                  _menuItem(
                    icon: Icons.people_outline_rounded,
                    title: 'Customers',
                  ),

                  _menuItem(
                    icon: Icons.local_shipping_outlined,
                    title: 'Suppliers',
                  ),

                  const SizedBox(height: 12),

                  _sectionTitle('FINANCE'),

                  _menuItem(
                    icon: Icons.receipt_long_outlined,
                    title: 'Receipts',
                  ),

                  _menuItem(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Payments',
                  ),

                  const SizedBox(height: 12),

                  _sectionTitle('REPORTS'),

                  _menuItem(
                    icon: Icons.bar_chart_rounded,
                    title: 'Reports',
                  ),

                  const SizedBox(height: 12),

                  _sectionTitle('SETTINGS'),

                  _menuItem(
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                  ),
                ],
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Color(0xFFE5E7EB),
                ),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.copyright_rounded,
                  size: 13,
                  color: Color(0xFF6B7280),
                ),
                SizedBox(width: 4),
                Text(
                  '2025 Billing ERP',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 14,
        bottom: 6,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Color(0xFF374151),
          letterSpacing: .4,
        ),
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String title,
    bool selected = false,
    VoidCallback? onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(7),
          onTap: onTap,
          hoverColor: const Color(0xFFF3F6FB),
          splashColor: const Color(0xFF1557C0).withOpacity(0.08),
          child: Container(
            height: 42,
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
            ),
            decoration: BoxDecoration(
              color: selected
                  ? const Color(0xFFEAF2FF)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 19,
                  color: selected
                      ? const Color(0xFF1557C0)
                      : const Color(0xFF374151),
                ),

                const SizedBox(width: 12),

                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: selected
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: selected
                        ? const Color(0xFF1557C0)
                        : const Color(0xFF111827),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // TOP BAR
  // ============================================================

  Widget _buildTopBar() {
    return Container(
      height: 74,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE5E7EB),
          ),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.menu_rounded,
            size: 23,
            color: Color(0xFF374151),
          ),

          const SizedBox(width: 28),

          const Text(
            'Dashboard',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),

          const Spacer(),

          // Search
          SizedBox(
            width: 430,
            height: 42,
            child: TextField(
              decoration: InputDecoration(
                hintText:
                'Search (Invoice, Customer, Product...)',
                hintStyle: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  size: 21,
                ),
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(
                    right: 8,
                  ),
                  child: Center(
                    widthFactor: 1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius:
                        BorderRadius.circular(5),
                      ),
                      child: const Text(
                        'Ctrl + K',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ),
                ),
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                contentPadding:
                const EdgeInsets.symmetric(
                  vertical: 0,
                ),
                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xFFE5E7EB),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xFFE5E7EB),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 24),

          const Icon(
            Icons.notifications_none_rounded,
            size: 24,
            color: Color(0xFF374151),
          ),

          const SizedBox(width: 20),

          const Icon(
            Icons.help_outline_rounded,
            size: 23,
            color: Color(0xFF374151),
          ),

          const SizedBox(width: 20),

          const CircleAvatar(
            radius: 19,
            backgroundColor: Color(0xFFEAF2FF),
            child: Icon(
              Icons.person,
              color: Color(0xFF1557C0),
            ),
          ),

          const SizedBox(width: 9),

          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                'Admin User',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Administrator',
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),

          const SizedBox(width: 10),

          const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 19,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DASHBOARD CONTENT
  // ============================================================

  Widget _buildDashboardContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              _buildWelcome(),

              const SizedBox(height: 18),

              _buildSummaryCards(),

              const SizedBox(height: 16),

              _buildCharts(
                constraints.maxWidth,
              ),

              const SizedBox(height: 16),

              _buildTables(
                constraints.maxWidth,
              ),

              const SizedBox(height: 16),

              _buildQuickActions(),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // WELCOME
  // ============================================================

  Widget _buildWelcome() {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                'Good Morning, Admin! 👋',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              SizedBox(height: 5),
              Text(
                "Here's what's happening with your business today.",
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),

        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(7),
            border: Border.all(
              color: const Color(0xFFE5E7EB),
            ),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: Color(0xFF374151),
              ),
              SizedBox(width: 9),
              Text(
                '17 May 2025',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 20),
              Text(
                'Today',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF374151),
                ),
              ),
              SizedBox(width: 5),
              Icon(
                Icons.keyboard_arrow_down,
                size: 17,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SUMMARY CARDS
  // ============================================================

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _summaryCard(
            title: "Today's Sales",
            value: _money(controller.todaySales),
            subtitle:
            '↑ 12.5% from yesterday',
            bottom: '${controller.todayInvoices} Invoices',
            icon: Icons.trending_up_rounded,
            iconBackground:
            const Color(0xFFEAF2FF),
            iconColor:
            const Color(0xFF2563EB),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: _summaryCard(
            title: "Today's Purchase",
            value: _money(controller.todayPurchase),
            subtitle:
            '↑ 5.2% from yesterday',
            bottom: '${controller.todayBills} Bills',
            icon: Icons.shopping_cart_outlined,
            iconBackground:
            const Color(0xFFE9FBEF),
            iconColor:
            const Color(0xFF16A34A),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: _summaryCard(
            title: 'Receivable',
            value: _money(controller.receivable),
            subtitle:
            '${controller.receivableCustomers} Customers',
            bottom: 'View Details  →',
            icon:
            Icons.account_balance_wallet_outlined,
            iconBackground:
            const Color(0xFFFFF1DF),
            iconColor:
            const Color(0xFFF97316),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: _summaryCard(
            title: 'Payable',
            value: _money(controller.payable),
            subtitle:
            '${controller.payableSuppliers} Suppliers',
            bottom: 'View Details  →',
            icon: Icons.payments_outlined,
            iconBackground:
            const Color(0xFFF2E9FF),
            iconColor:
            const Color(0xFF7C3AED),
          ),
        ),
      ],
    );
  }

  Widget _summaryCard({
    required String title,
    required String value,
    required String subtitle,
    required String bottom,
    required IconData icon,
    required Color iconBackground,
    required Color iconColor,
  }) {
    return Container(
      height: 166,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius:
                  BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),

          const SizedBox(height: 3),

          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: subtitle.startsWith('↑')
                  ? const Color(0xFF16A34A)
                  : const Color(0xFF374151),
            ),
          ),

          const Spacer(),

          Container(
            height: 1,
            color: const Color(0xFFE5E7EB),
          ),

          const SizedBox(height: 8),

          Text(
            bottom,
            style: TextStyle(
              fontSize: 11,
              color: bottom.contains('View')
                  ? const Color(0xFF1557C0)
                  : const Color(0xFF374151),
              fontWeight: bottom.contains('View')
                  ? FontWeight.w500
                  : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CHARTS
  // ============================================================

  Widget _buildCharts(double width) {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: _salesChart(),
        ),

        const SizedBox(width: 14),

        Expanded(
          flex: 2,
          child: _paymentChart(),
        ),
      ],
    );
  }

  Widget _salesChart() {
    return Container(
      height: 265,
      padding: const EdgeInsets.all(16),
      decoration: _boxDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'Sales Overview',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const Spacer(),

              PopupMenuButton<String>(
                initialValue:
                controller.salesPeriod,
                onSelected:
                controller.changeSalesPeriod,
                itemBuilder: (context) {
                  return [
                    'This Week',
                    'This Month',
                    'This Year',
                  ].map((e) {
                    return PopupMenuItem(
                      value: e,
                      child: Text(
                        e,
                        style: const TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    );
                  }).toList();
                },
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color:
                      const Color(0xFFE5E7EB),
                    ),
                    borderRadius:
                    BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Text(
                        controller.salesPeriod,
                        style: const TextStyle(
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Expanded(
            child: CustomPaint(
              painter: SalesChartPainter(
                values: controller.salesValues,
              ),
              child: const SizedBox(
                width: double.infinity,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentChart() {
    final paid = controller.paidPayments /
        controller.totalPayments;

    final pending =
        controller.pendingPayments /
            controller.totalPayments;

    final overdue =
        controller.overduePayments /
            controller.totalPayments;

    return Container(
      height: 265,
      padding: const EdgeInsets.all(16),
      decoration: _boxDecoration(),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Status',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 15),

          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: 145,
                  child: CustomPaint(
                    painter: PaymentChartPainter(
                      paid: paid,
                      pending: pending,
                      overdue: overdue,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize:
                        MainAxisSize.min,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 11,
                              color:
                              Color(0xFF6B7280),
                            ),
                          ),
                          Text(
                            '${controller.totalPayments}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight:
                              FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    children: [
                      _paymentRow(
                        title: 'Paid',
                        value:
                        '${(paid * 100).round()}%',
                        count:
                        '(${controller.paidPayments})',
                        dotColor:
                        const Color(0xFF22C55E),
                      ),

                      const SizedBox(height: 14),

                      _paymentRow(
                        title: 'Pending',
                        value:
                        '${(pending * 100).round()}%',
                        count:
                        '(${controller.pendingPayments})',
                        dotColor:
                        const Color(0xFFF59E0B),
                      ),

                      const SizedBox(height: 14),

                      _paymentRow(
                        title: 'Overdue',
                        value:
                        '${(overdue * 100).round()}%',
                        count:
                        '(${controller.overduePayments})',
                        dotColor:
                        const Color(0xFFEF4444),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          const SizedBox(height: 9),

          const Row(
            children: [
              Text(
                'View All Payments',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF1557C0),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Spacer(),
              Icon(
                Icons.arrow_forward,
                size: 15,
                color: Color(0xFF1557C0),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _paymentRow({
    required String title,
    required String value,
    required String count,
    required Color dotColor,
  }) {
    return Row(
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
          ),
        ),

        const SizedBox(width: 9),

        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 12,
            ),
          ),
        ),

        Text(
          '$value $count',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TABLES
  // ============================================================

  Widget _buildTables(double width) {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _recentInvoices(),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: _topCustomers(),
        ),
      ],
    );
  }

  Widget _recentInvoices() {
    return Container(
      height: 290,
      decoration: _boxDecoration(),
      child: Column(
        children: [
          _tableHeader(
            title: 'Recent Invoices',
            action: 'View All',
          ),

          const Divider(
            height: 1,
          ),

          Expanded(
            child: ListView.separated(
              physics:
              const ClampingScrollPhysics(),
              itemCount:
              controller.recentInvoices.length,
              separatorBuilder: (_, __) =>
              const Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
              ),
              itemBuilder: (context, index) {
                final invoice =
                controller.recentInvoices[index];

                return SizedBox(
                  height: 42,
                  child: Padding(
                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            invoice.invoiceNo,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight:
                              FontWeight.w500,
                            ),
                          ),
                        ),

                        Expanded(
                          flex: 3,
                          child: Text(
                            invoice.customer,
                            style: const TextStyle(
                              fontSize: 11,
                            ),
                          ),
                        ),

                        Expanded(
                          flex: 2,
                          child: Text(
                            invoice.date,
                            style: const TextStyle(
                              fontSize: 10,
                              color:
                              Color(0xFF6B7280),
                            ),
                          ),
                        ),

                        Expanded(
                          flex: 2,
                          child: Text(
                            _money(invoice.amount),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight:
                              FontWeight.w500,
                            ),
                          ),
                        ),

                        Expanded(
                          flex: 2,
                          child: _statusBadge(
                            invoice.status,
                          ),
                        ),

                        const SizedBox(
                          width: 25,
                          child: Icon(
                            Icons.visibility_outlined,
                            size: 16,
                            color:
                            Color(0xFF1557C0),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _topCustomers() {
    return Container(
      height: 290,
      decoration: _boxDecoration(),
      child: Column(
        children: [
          _tableHeader(
            title: 'Top Customers (This Month)',
            action: 'View All',
          ),

          const Divider(
            height: 1,
          ),

          Expanded(
            child: ListView.separated(
              physics:
              const ClampingScrollPhysics(),
              itemCount:
              controller.topCustomers.length,
              separatorBuilder: (_, __) =>
              const Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
              ),
              itemBuilder: (context, index) {
                final customer =
                controller.topCustomers[index];

                return SizedBox(
                  height: 42,
                  child: Padding(
                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            customer.name,
                            style: const TextStyle(
                              fontSize: 11,
                            ),
                          ),
                        ),

                        SizedBox(
                          width: 100,
                          child: Text(
                            _money(customer.sales),
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight:
                              FontWeight.w500,
                            ),
                          ),
                        ),

                        SizedBox(
                          width: 70,
                          child: Text(
                            '${customer.invoices}',
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableHeader({
    required String title,
    required String action,
  }) {
    return SizedBox(
      height: 50,
      child: Padding(
        padding:
        const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),

            const Spacer(),

            Text(
              action,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF1557C0),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color background;
    Color foreground;

    switch (status) {
      case 'Paid':
        background = const Color(0xFFE5F8EA);
        foreground = const Color(0xFF16A34A);
        break;

      case 'Pending':
        background = const Color(0xFFFFF1D9);
        foreground = const Color(0xFFF59E0B);
        break;

      case 'Overdue':
        background = const Color(0xFFFFE5E5);
        foreground = const Color(0xFFEF4444);
        break;

      default:
        background = const Color(0xFFF3F4F6);
        foreground = const Color(0xFF374151);
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding:
        const EdgeInsets.symmetric(
          horizontal: 9,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius:
          BorderRadius.circular(5),
        ),
        child: Text(
          status,
          style: TextStyle(
            fontSize: 9,
            color: foreground,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // QUICK ACTIONS
  // ============================================================

  Widget _buildQuickActions() {
    return Container(
      height: 92,
      decoration: _boxDecoration(),
      child: Row(
        children: [
          Expanded(
            child: _quickAction(
              icon: Icons.add_rounded,
              title: 'New Sales Invoice',
              subtitle: 'Create new invoice',
              iconColor:
              const Color(0xFF2563EB),
              background:
              const Color(0xFFEAF2FF),
              onTap:
              controller.createSalesInvoice,
            ),
          ),

          _verticalDivider(),

          Expanded(
            child: _quickAction(
              icon:
              Icons.shopping_cart_outlined,
              title: 'New Purchase Bill',
              subtitle: 'Create new purchase',
              iconColor:
              const Color(0xFF16A34A),
              background:
              const Color(0xFFE9FBEF),
              onTap:
              controller.createPurchaseBill,
            ),
          ),

          _verticalDivider(),

          Expanded(
            child: _quickAction(
              icon:
              Icons.people_outline_rounded,
              title: 'Add Customer',
              subtitle: 'Create new customer',
              iconColor:
              const Color(0xFF7C3AED),
              background:
              const Color(0xFFF2E9FF),
              onTap: controller.addCustomer,
            ),
          ),

          _verticalDivider(),

          Expanded(
            child: _quickAction(
              icon:
              Icons.local_shipping_outlined,
              title: 'Add Supplier',
              subtitle: 'Create new supplier',
              iconColor:
              const Color(0xFFF97316),
              background:
              const Color(0xFFFFF1DF),
              onTap: controller.addSupplier,
            ),
          ),

          _verticalDivider(),

          Expanded(
            child: _quickAction(
              icon: Icons.bar_chart_rounded,
              title: 'Reports',
              subtitle: 'View all reports',
              iconColor:
              const Color(0xFF2563EB),
              background:
              const Color(0xFFEAF2FF),
              onTap: controller.openReports,
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickAction({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required Color background,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding:
          const EdgeInsets.symmetric(
            horizontal: 16,
          ),
          child: Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: background,
                  borderRadius:
                  BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 23,
                ),
              ),

              const SizedBox(width: 11),

              Expanded(
                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow:
                      TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow:
                      TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        color:
                        Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _verticalDivider() {
    return Container(
      width: 1,
      height: 55,
      color: const Color(0xFFE5E7EB),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(9),
      border: Border.all(
        color: const Color(0xFFE5E7EB),
      ),
    );
  }

  String _money(double value) {
    return '₹${_formatNumber(value)}';
  }

  String _formatNumber(double value) {
    final number = value.round().toString();

    if (number.length <= 3) {
      return number;
    }

    final lastThree =
    number.substring(number.length - 3);

    var remaining =
    number.substring(0, number.length - 3);

    final parts = <String>[];

    while (remaining.length > 2) {
      parts.insert(
        0,
        remaining.substring(
          remaining.length - 2,
        ),
      );

      remaining = remaining.substring(
        0,
        remaining.length - 2,
      );
    }

    if (remaining.isNotEmpty) {
      parts.insert(0, remaining);
    }

    return '${parts.join(',')},$lastThree';
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
