import 'package:flutter/material.dart';

import '../model/dashboard_model.dart';

import 'package:flutter/material.dart';

import '../model/dashboard_model.dart';

class DashboardSummarySection extends StatelessWidget {
  final DashboardModel dashboard;

  const DashboardSummarySection({
    super.key,
    required this.dashboard,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 20,),
        /// =================================================
        /// SALES + PURCHASE
        /// =================================================
        LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 600;


            if (isDesktop) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildOverdueSales(context),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildPurchase(context),
                  ),
                ],
              );
            }

            return Column(
              children: [
                _buildOverdueSales(context),
                const SizedBox(height: 10),
                _buildPurchase(context),
              ],
            );
          },
        ),

        const SizedBox(height: 10),

        /// =================================================
        /// 90 DAYS OVERDUE
        /// =================================================
        _build90Days(context),

        const SizedBox(height: 10),

        /// =================================================
        /// CUSTOMER + SUPPLIER
        /// =================================================
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 700) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildPartyCard(
                      context,
                      title: 'Customer',
                      icon: Icons.people_outline_rounded,
                      pending: dashboard.customer?.pending ?? '0',
                      active: dashboard.customer?.active ?? '0',
                      inactive: dashboard.customer?.inactive ?? '0',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildPartyCard(
                      context,
                      title: 'Supplier',
                      icon: Icons.business_outlined,
                      pending: dashboard.supplier?.pending ?? '0',
                      active: dashboard.supplier?.active ?? '0',
                      inactive: dashboard.supplier?.inactive ?? '0',
                    ),
                  ),
                ],
              );
            }

            return Column(
              children: [
                _buildPartyCard(
                  context,
                  title: 'Customer',
                  icon: Icons.people_outline_rounded,
                  pending: dashboard.customer?.pending ?? '0',
                  active: dashboard.customer?.active ?? '0',
                  inactive: dashboard.customer?.inactive ?? '0',
                ),
                const SizedBox(height: 10),
                _buildPartyCard(
                  context,
                  title: 'Supplier',
                  icon: Icons.business_outlined,
                  pending: dashboard.supplier?.pending ?? '0',
                  active: dashboard.supplier?.active ?? '0',
                  inactive: dashboard.supplier?.inactive ?? '0',
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  // =========================================================
  // OVERDUE SALES
  // =========================================================

  Widget _buildOverdueSales(BuildContext context) {
    final items = [
      _SalesItem(
        title: '15 Days',
        data: dashboard.overdueSaleBills?.days15,
      ),
      _SalesItem(
        title: '30 Days',
        data: dashboard.overdueSaleBills?.days30,
      ),
      _SalesItem(
        title: '45 Days',
        data: dashboard.overdueSaleBills?.days45,
      ),
      _SalesItem(
        title: '60 Days',
        data: dashboard.overdueSaleBills?.days60,
      ),
      _SalesItem(
        title: '75 Days',
        data: dashboard.overdueSaleBills?.days75,
      ),
      _SalesItem(
        title: '90 Days',
        data: dashboard.overdueSaleBills?.days90,
      ),
    ];

    return _DashboardCard(
      title: 'Overdue Sale Bills',
      subtitle: 'Outstanding sales by ageing',
      icon: Icons.trending_up_rounded,
      iconColor: const Color(0xff2563EB),
      action: () {
        debugPrint('Open all overdue sales');
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
            childAspectRatio: 3,
          ),
          itemBuilder: (context, index) {
            final item = items[index];

            return _InteractiveSalesBox(
              title: item.title,
              amount: _formatAmount(item.data?.amount),
              bills: item.data?.bills ?? '0',
              onTap: () {
                debugPrint(
                  'Open ${item.title} overdue bills',
                );
              },
            );
          },
        ),
      ),
    );
  }

  // =========================================================
  // PURCHASE
  // =========================================================

  Widget _buildPurchase(BuildContext context) {
    final items = [
      _PurchaseItem(
        title: 'Challan',
        icon: Icons.description_outlined,
        data: dashboard.purchase?.challan,
      ),
      _PurchaseItem(
        title: 'Bills',
        icon: Icons.receipt_long_outlined,
        data: dashboard.purchase?.bills,
      ),
      _PurchaseItem(
        title: 'Voucher',
        icon: Icons.account_balance_wallet_outlined,
        data: dashboard.purchase?.voucher,
      ),
      _PurchaseItem(
        title: 'Purchase Return',
        icon: Icons.keyboard_return_rounded,
        data: dashboard.purchase?.purchaseReturn,
      ),
    ];

    return _DashboardCard(
      title: 'Purchase',
      subtitle: 'Purchase transactions summary',
      icon: Icons.shopping_cart_outlined,
      iconColor: const Color(0xff059669),
      action: () {
        debugPrint('Open purchase');
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
            childAspectRatio: 4.6,
          ),
          itemBuilder: (context, index) {
            final item = items[index];

            return _InteractivePurchaseBox(
              title: item.title,
              icon: item.icon,
              amount: _formatAmount(item.data?.amount),
              bills: item.data?.bills ?? '0',
              onTap: () {
                debugPrint(
                  'Open ${item.title}',
                );
              },
            );
          },
        ),
      ),
    );
  }

  // =========================================================
  // 90 DAYS OVERDUE
  // =========================================================

  Widget _build90Days(BuildContext context) {
    final data = dashboard.overdue90DaysBills;

    return _DashboardCard(
      title: '90 Days Overdue',
      subtitle: 'High priority outstanding bills',
      icon: Icons.warning_amber_rounded,
      iconColor: const Color(0xffD97706),
      action: () {
        debugPrint('Open 90 days overdue');
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmall = constraints.maxWidth < 500;

          if (isSmall) {
            return Column(
              children: [
                _InteractiveHorizontalStat(
                  icon: Icons.groups_outlined,
                  title: 'Total Party',
                  value: data?.totalParty ?? '0',
                  onTap: () {},
                ),
                const SizedBox(height: 5),
                _InteractiveHorizontalStat(
                  icon: Icons.receipt_long_outlined,
                  title: 'Total Bills',
                  value: data?.totalBills ?? '0',
                  onTap: () {},
                ),
                const SizedBox(height: 5),
                _InteractiveHorizontalStat(
                  icon: Icons.currency_rupee_rounded,
                  title: 'Total Amount',
                  value: _formatAmount(data?.totalAmount),
                  onTap: () {},
                ),
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                child: _InteractiveHorizontalStat(
                  icon: Icons.groups_outlined,
                  title: 'Total Party',
                  value: data?.totalParty ?? '0',
                  onTap: () {},
                ),
              ),
              _divider(),
              Expanded(
                child: _InteractiveHorizontalStat(
                  icon: Icons.receipt_long_outlined,
                  title: 'Total Bills',
                  value: data?.totalBills ?? '0',
                  onTap: () {},
                ),
              ),
              _divider(),
              Expanded(
                child: _InteractiveHorizontalStat(
                  icon: Icons.currency_rupee_rounded,
                  title: 'Total Amount',
                  value: _formatAmount(data?.totalAmount),
                  onTap: () {},
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // =========================================================
  // CUSTOMER / SUPPLIER
  // =========================================================

  Widget _buildPartyCard(
      BuildContext context, {
        required String title,
        required IconData icon,
        required String pending,
        required String active,
        required String inactive,
      }) {
    return _DashboardCard(
      title: title,
      subtitle: '$title status overview',
      icon: icon,
      iconColor: const Color(0xff6366F1),
      action: () {
        debugPrint('Open $title');
      },
      child: Row(
        children: [
          Expanded(
            child: _InteractivePartyStat(
              title: 'Pending',
              value: pending,
              icon: Icons.pending_actions_rounded,
              iconColor: const Color(0xffF59E0B),
              onTap: () {},
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _InteractivePartyStat(
              title: 'Active',
              value: active,
              icon: Icons.check_circle_outline_rounded,
              iconColor: const Color(0xff10B981),
              onTap: () {},
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _InteractivePartyStat(
              title: 'Inactive',
              value: inactive,
              icon: Icons.block_outlined,
              iconColor: const Color(0xffEF4444),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // HELPERS
  // =========================================================

  Widget _divider() {
    return Container(
      width: 1,
      height: 38,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      color: const Color(0xffE5E7EB),
    );
  }

  String _formatAmount(String? value) {
    final number = double.tryParse(value ?? '');

    if (number == null) {
      return '₹0';
    }

    if (number >= 10000000) {
      return '₹${(number / 10000000).toStringAsFixed(2)} Cr';
    }

    if (number >= 100000) {
      return '₹${(number / 100000).toStringAsFixed(2)} L';
    }

    if (number >= 1000) {
      return '₹${(number / 1000).toStringAsFixed(1)} K';
    }

    return '₹${number.toStringAsFixed(0)}';
  }
}

// =========================================================
// DASHBOARD CARD
// =========================================================

class _DashboardCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Widget child;
  final VoidCallback? action;

  const _DashboardCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.child,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: const Color(0xffE5E7EB),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: iconColor,
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xff111827),
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 9,
                        color: Color(0xff9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),

              if (action != null)
                _HeaderAction(
                  color: iconColor,
                  onTap: action!,
                ),
            ],
          ),

          const SizedBox(height: 9),

          child,
        ],
      ),
    );
  }
}

// =========================================================
// HEADER ACTION
// =========================================================

class _HeaderAction extends StatefulWidget {
  final Color color;
  final VoidCallback onTap;

  const _HeaderAction({
    required this.color,
    required this.onTap,
  });

  @override
  State<_HeaderAction> createState() => _HeaderActionState();
}

class _HeaderActionState extends State<_HeaderAction> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() => hover = true);
      },
      onExit: (_) {
        setState(() => hover = false);
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: 25,
          height: 25,
          decoration: BoxDecoration(
            color: hover
                ? widget.color.withOpacity(.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            Icons.arrow_forward_rounded,
            size: 14,
            color: hover
                ? widget.color
                : const Color(0xff9CA3AF),
          ),
        ),
      ),
    );
  }
}

// =========================================================
// SALES ITEM
// =========================================================

class _InteractiveSalesBox extends StatefulWidget {
  final String title;
  final String amount;
  final String bills;
  final VoidCallback onTap;

  const _InteractiveSalesBox({
    required this.title,
    required this.amount,
    required this.bills,
    required this.onTap,
  });

  @override
  State<_InteractiveSalesBox> createState() =>
      _InteractiveSalesBoxState();
}

class _InteractiveSalesBoxState
    extends State<_InteractiveSalesBox> {
  bool _hover = false;
  bool _pressed = false;

  static const Color blue = Color(0xff2563EB);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,

      onEnter: (_) {
        setState(() {
          _hover = true;
        });
      },

      onExit: (_) {
        setState(() {
          _hover = false;
          _pressed = false;
        });
      },

      child: AnimatedScale(
        scale: _pressed
            ? 0.97
            : _hover
            ? 1.015
            : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,

        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),

            boxShadow: _hover
                ? [
              BoxShadow(
                color: blue.withOpacity(.12),
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(0, 3),
              ),
            ]
                : const [],

            border: Border.all(
              color: _hover
                  ? blue.withOpacity(.30)
                  : const Color(0xffE5E7EB),
            ),

            color: _hover
                ? const Color(0xffF5F9FF)
                : const Color(0xffF8FAFC),
          ),

          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(10),

            child: InkWell(
              borderRadius: BorderRadius.circular(10),

              splashColor: blue.withOpacity(.08),
              highlightColor: blue.withOpacity(.035),

              onTap: widget.onTap,

              onTapDown: (_) {
                setState(() {
                  _pressed = true;
                });
              },

              onTapCancel: () {
                setState(() {
                  _pressed = false;
                });
              },

              onTapUp: (_) {
                setState(() {
                  _pressed = false;
                });
              },

              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 6,
                ),

                child: Row(
                  children: [

                    // =================================================
                    // ICON
                    // =================================================

                    AnimatedContainer(
                      duration:
                      const Duration(milliseconds: 160),

                      width: 29,
                      height: 29,

                      decoration: BoxDecoration(
                        color: _hover
                            ? blue.withOpacity(.12)
                            : blue.withOpacity(.07),

                        borderRadius:
                        BorderRadius.circular(8),
                      ),

                      child: Icon(
                        Icons.receipt_long_outlined,
                        size: 15,
                        color: blue,
                      ),
                    ),

                    const SizedBox(width: 7),

                    // =================================================
                    // CONTENT
                    // =================================================

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,

                        mainAxisAlignment:
                        MainAxisAlignment.center,

                        children: [

                          // TITLE
                          Text(
                            widget.title,

                            maxLines: 1,

                            overflow:
                            TextOverflow.ellipsis,

                            style: TextStyle(
                              fontSize: 9.5,

                              fontWeight: _hover
                                  ? FontWeight.w600
                                  : FontWeight.w500,

                              color: _hover
                                  ? blue
                                  : const Color(
                                0xff6B7280,
                              ),
                            ),
                          ),

                          const SizedBox(height: 2),

                          // AMOUNT
                          Text(
                            widget.amount,

                            maxLines: 1,

                            overflow:
                            TextOverflow.ellipsis,

                            style: const TextStyle(
                              fontSize: 13,

                              fontWeight:
                              FontWeight.w700,

                              color:
                              Color(0xff111827),
                            ),
                          ),

                          const SizedBox(height: 2),

                          // BILL BADGE
                          Container(
                            padding:
                            const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 1.5,
                            ),

                            decoration: BoxDecoration(
                              color: _hover
                                  ? blue.withOpacity(.10)
                                  : const Color(
                                0xffEEF2F7,
                              ),

                              borderRadius:
                              BorderRadius.circular(4),
                            ),

                            child: Text(
                              '${widget.bills} Bills',

                              style: TextStyle(
                                fontSize: 7.5,

                                fontWeight:
                                FontWeight.w600,

                                color: _hover
                                    ? blue
                                    : const Color(
                                  0xff6B7280,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 3),

                    // =================================================
                    // ARROW
                    // =================================================

                    AnimatedSlide(
                      duration:
                      const Duration(milliseconds: 160),

                      offset: _hover
                          ? const Offset(.15, 0)
                          : Offset.zero,

                      child: AnimatedOpacity(
                        duration:
                        const Duration(milliseconds: 120),

                        opacity: _hover ? 1 : .35,

                        child: Icon(
                          Icons.chevron_right_rounded,
                          size: 17,
                          color: blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =========================================================
// PURCHASE ITEM
// =========================================================

class _InteractivePurchaseBox extends StatefulWidget {
  final String title;
  final IconData icon;
  final String amount;
  final String bills;
  final VoidCallback onTap;

  const _InteractivePurchaseBox({
    required this.title,
    required this.icon,
    required this.amount,
    required this.bills,
    required this.onTap,
  });

  @override
  State<_InteractivePurchaseBox> createState() =>
      _InteractivePurchaseBoxState();
}

class _InteractivePurchaseBoxState
    extends State<_InteractivePurchaseBox> {
  bool hover = false;

  static const Color green = Color(0xff059669);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() => hover = true);
      },
      onExit: (_) {
        setState(() => hover = false);
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(
            horizontal: 7,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: hover
                ? green.withOpacity(.055)
                : const Color(0xffF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: hover
                  ? green.withOpacity(.28)
                  : const Color(0xffE5E7EB),
            ),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 140),
                width: 27,
                height: 27,
                decoration: BoxDecoration(
                  color: green.withOpacity(
                    hover ? .14 : .08,
                  ),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(
                  widget.icon,
                  size: 14,
                  color: green,
                ),
              ),

              const SizedBox(width: 6),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: hover
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: hover
                            ? green
                            : const Color(0xff6B7280),
                      ),
                    ),

                    const SizedBox(height: 1),

                    Text(
                      widget.amount,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xff111827),
                      ),
                    ),

                    Text(
                      '${widget.bills} Bills',
                      style: const TextStyle(
                        fontSize: 8,
                        color: Color(0xff9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),

              AnimatedOpacity(
                duration: const Duration(milliseconds: 120),
                opacity: hover ? 1 : .3,
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 14,
                  color: green,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =========================================================
// HORIZONTAL STAT
// =========================================================

class _InteractiveHorizontalStat extends StatefulWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  const _InteractiveHorizontalStat({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  State<_InteractiveHorizontalStat> createState() =>
      _InteractiveHorizontalStatState();
}

class _InteractiveHorizontalStatState
    extends State<_InteractiveHorizontalStat> {
  bool hover = false;

  static const Color orange = Color(0xffD97706);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() => hover = true);
      },
      onExit: (_) {
        setState(() => hover = false);
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 130),
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: hover
                ? orange.withOpacity(.06)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: orange.withOpacity(.09),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(
                  widget.icon,
                  size: 15,
                  color: orange,
                ),
              ),

              const SizedBox(width: 7),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 9,
                        color: Color(0xff6B7280),
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      widget.value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xff111827),
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
}

// =========================================================
// PARTY STAT
// =========================================================

class _InteractivePartyStat extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _InteractivePartyStat({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  State<_InteractivePartyStat> createState() =>
      _InteractivePartyStatState();
}

class _InteractivePartyStatState
    extends State<_InteractivePartyStat> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() => hover = true);
      },
      onExit: (_) {
        setState(() => hover = false);
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 130),
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: hover
                ? widget.iconColor.withOpacity(.06)
                : const Color(0xffF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: hover
                  ? widget.iconColor.withOpacity(.20)
                  : const Color(0xffE5E7EB),
            ),
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                size: 15,
                color: widget.iconColor,
              ),

              const SizedBox(width: 6),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 9,
                        color: Color(0xff6B7280),
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      widget.value,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xff111827),
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
}

// =========================================================
// MODELS FOR UI
// =========================================================

class _SalesItem {
  final String title;
  final BillData? data;

  const _SalesItem({
    required this.title,
    required this.data,
  });
}

class _PurchaseItem {
  final String title;
  final IconData icon;
  final BillData? data;

  const _PurchaseItem({
    required this.title,
    required this.icon,
    required this.data,
  });
}