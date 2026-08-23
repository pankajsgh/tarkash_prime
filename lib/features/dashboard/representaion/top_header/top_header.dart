import 'dart:async';

import 'package:calculation_panel/core/widget/logo_widget.dart';
import 'package:flutter/material.dart';

import '../../../../core/routes/routes.dart';
import '../../../../core/session/session_manager.dart';
import '../../../../core/vars/global_vars.dart';

class ERPHomePage extends StatefulWidget {
  const ERPHomePage({super.key});

  @override
  State<ERPHomePage> createState() => _ERPHomePageState();
}

class _ERPHomePageState extends State<ERPHomePage> {
  int? hoveredMenu;

  Timer? _hoverTimer;

  OverlayEntry? _dropdownOverlay;

  final List<GlobalKey> _menuKeys = [];

  final List<ERPMenu> menus = [
    ERPMenu(
      title: 'Ledger',
      icon: Icons.account_balance_wallet_outlined,
      items: [
        'Chart of Accounts',
        'Journal Entry',
        'Ledger',
        'Trial Balance',
        'Profit & Loss',
        'Balance Sheet',
      ],
    ),
    ERPMenu(
      title: 'Purchase',
      icon: Icons.groups_outlined,
      items: [
        'Challan',
        'Customer',
        'Agent',
        'Transport',
        'Parcel',
        'Vendor',
      ],
    ),
    ERPMenu(
      title: 'Sales',
      icon: Icons.bar_chart_outlined,
      items: [
        'Sales Order',
        'Sales Invoice',
        'Sales Return',
        'Quotation',
        'Delivery Challan',
      ],
    ),
    ERPMenu(
      title: 'Payment',
      icon: Icons.touch_app_outlined,
      items: [
        'Payment Receipt',
        'Payment Voucher',
        'Bank Payment',
        'Cash Payment',
        'Payment History',
      ],
    ),
    ERPMenu(
      title: 'Important',
      icon: Icons.error_outline,
      items: [
        'Pending Approval',
        'Overdue Sales',
        'Outstanding Payment',
        'Alerts',
      ],
    ),
    ERPMenu(
      title: 'Stock',
      icon: Icons.inventory_2_outlined,
      items: [
        'Stock Summary',
        'Stock Transfer',
        'Stock Adjustment',
        'Stock Ledger',
        'Warehouse',
      ],
    ),
    ERPMenu(
      title: 'Master',
      icon: Icons.settings_outlined,
      items: [
        'Company',
        'Branch',
        'Product',
        'Category',
        'Unit',
        'Tax',
      ],
    ),
    ERPMenu(
      title: 'CRM',
      icon: Icons.credit_card_outlined,
      items: [
        'Leads',
        'Contacts',
        'Follow Ups',
        'Opportunities',
        'Activities',
      ],
    ),
    ERPMenu(
      title: 'Report',
      icon: Icons.table_chart_outlined,
      items: [
        'Sales Report',
        'Purchase Report',
        'Stock Report',
        'Payment Report',
        'Customer Report',
        'Supplier Report',
      ],
    ),
    ERPMenu(
      title: 'Request',
      icon: Icons.notifications_none_outlined,
      items: [
        'New Request',
        'Pending Requests',
        'Approved Requests',
        'Rejected Requests',
      ],
    ),
  ];

  // ==========================================================
  // INIT
  // ==========================================================

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < menus.length; i++) {
      _menuKeys.add(GlobalKey());
    }
  }

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    _hoverTimer?.cancel();
    _removeDropdown();

    super.dispose();
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return _buildTopBar();
  }

  // ==========================================================
  // TOP BAR
  // ==========================================================

  Widget _buildTopBar() {
    return Container(
      height: 70,
      color: const Color(0xff97004d),
      child: Row(
        children: [
          // ==================================================
          // LOGO
          // ==================================================

          Container(
            height: 70,
            color: Colors.white,
            padding: const EdgeInsets.all(12.0),
            child: buildLogo(context),
          ),

          // ==================================================
          // NAVIGATION
          // ==================================================

          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: List.generate(
                  menus.length,
                      (index) {
                    return _buildMenuItem(
                      menus[index],
                      index,
                    );
                  },
                ),
              ),
            ),
          ),

          // ==================================================
          // USER PROFILE
          // ==================================================

      // ==========================================================
// USER PROFILE
// ==========================================================

      const SizedBox(width: 20),

      Padding(
        padding: const EdgeInsets.all(10.0),
        child: PopupMenuButton<String>(
          offset: const Offset(0, 58),
          elevation: 8,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),

          onSelected: (value) async {
            if (value == 'profile') {
              debugPrint('Profile clicked');
            }

            if (value == 'logout') {
              await SessionManager.removeLogin();

              if (!mounted) return;

              Navigator.pushNamedAndRemoveUntil(
                context,
                Routes.login,
                    (route) => false,
              );
            }
          },

          itemBuilder: (context) {
            return [
              PopupMenuItem<String>(
                enabled: false,
                padding: EdgeInsets.zero,
                child: Container(
                  width: 240,
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ==================================================
                      // USER INFO
                      // ==================================================

                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 25,
                            backgroundColor: Color(0xFFEAF2FF),
                            child: Icon(
                              Icons.person,
                              color: Color(0xFF1557C0),
                              size: 28,
                            ),
                          ),

                          const SizedBox(width: 12),

                          const Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pankaj',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),

                                SizedBox(height: 3),

                                Text(
                                  'Admin',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),

                                SizedBox(height: 2),

                                Text(
                                  'admin@example.com',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      const Divider(
                        height: 1,
                      ),
                    ],
                  ),
                ),
              ),

              // ======================================================
              // PROFILE / DETAILS
              // ======================================================

              const PopupMenuItem<String>(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 20,
                      color: Colors.black87,
                    ),

                    SizedBox(width: 12),

                    Text(
                      'My Profile',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),

              // ======================================================
              // LOGOUT
              // ======================================================

              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(
                      Icons.logout,
                      size: 20,
                      color: Color(0xffd32f2f),
                    ),

                    SizedBox(width: 12),

                    Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xffd32f2f),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ];
          },

          // ========================================================
          // PROFILE BUTTON
          // ========================================================

          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 6,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Colors.white.withValues(
                alpha: 0.2,
              ),
            ),

            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pankaj',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    Text(
                      'Admin',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 10),

                const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white,
                  size: 18,
                ),

                const SizedBox(width: 6),
              ],
            ),
          ),
        )),
        ],
      ),
    );
  }

  // ==========================================================
  // MENU ITEM
  // ==========================================================

  Widget _buildMenuItem(
      ERPMenu menu,
      int index,
      ) {
    final bool isHovered = hoveredMenu == index;

    return MouseRegion(
      cursor: SystemMouseCursors.click,

      onEnter: (_) {
        _hoverTimer?.cancel();

        if (hoveredMenu != index) {
          setState(() {
            hoveredMenu = index;
          });
        }

        _showDropdown(index);
      },

      onExit: (_) {
        // Don't close immediately.
        //
        // Give mouse time to enter dropdown.
        _startCloseTimer();
      },

      child: Container(
        key: _menuKeys[index],

        height: 70,

        padding: const EdgeInsets.symmetric(
          horizontal: 10,
        ),

        color: isHovered
            ? const Color(0xff820041)
            : const Color(0xff97004d),

        child: Row(
          children: [
            Icon(
              menu.icon,
              size: 18,
              color: Colors.white,
            ),

            const SizedBox(width: 4),

            Text(
              menu.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(width: 3),

            const Icon(
              Icons.arrow_drop_down,
              color: Colors.white,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // SHOW DROPDOWN
  // ==========================================================

  void _showDropdown(int index) {
    _hoverTimer?.cancel();

    // Remove existing dropdown.
    _removeDropdown();

    if (!mounted) return;

    final RenderBox? renderBox =
    _menuKeys[index]
        .currentContext
        ?.findRenderObject()
    as RenderBox?;

    if (renderBox == null) {
      return;
    }

    final Offset position =
    renderBox.localToGlobal(
      Offset.zero,
    );

    final double left = position.dx;

    final double top = position.dy + 70;

    final ERPMenu menu = menus[index];

    _dropdownOverlay = OverlayEntry(
      builder: (context) {
        return Positioned(
          left: left,
          top: top,

          child: MouseRegion(
            cursor: SystemMouseCursors.click,

            // ==================================================
            // ENTER DROPDOWN
            // ==================================================

            onEnter: (_) {
              _hoverTimer?.cancel();

              if (hoveredMenu != index) {
                setState(() {
                  hoveredMenu = index;
                });
              }
            },

            // ==================================================
            // EXIT DROPDOWN
            // ==================================================

            onExit: (_) {
              _startCloseTimer();
            },

            child: _buildDropdown(
              menu,
              index,
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(
      _dropdownOverlay!,
    );
  }

  // ==========================================================
  // REMOVE DROPDOWN
  // ==========================================================

  void _removeDropdown() {
    _dropdownOverlay?.remove();
    _dropdownOverlay = null;
  }

  // ==========================================================
  // CLOSE TIMER
  // ==========================================================

  void _startCloseTimer() {
    _hoverTimer?.cancel();

    _hoverTimer = Timer(
      const Duration(milliseconds: 400),
          () {
        if (!mounted) return;

        setState(() {
          hoveredMenu = null;
        });

        _removeDropdown();
      },
    );
  }

  // ==========================================================
  // DROPDOWN
  // ==========================================================

  Widget _buildDropdown(
      ERPMenu menu,
      int menuIndex,
      ) {
    return Material(
      elevation: 8,
      color: Colors.white,

      child: Container(
        width: 285,

        constraints: const BoxConstraints(
          minHeight: 50,
        ),

        decoration: BoxDecoration(
          color: Colors.white,

          border: Border.all(
            color: const Color(0xffeeeeee),
          ),
        ),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.stretch,

          children: menu.items.map(
                (item) {
              return _buildDropdownItem(
                item,
                menu.icon,
              );
            },
          ).toList(),
        ),
      ),
    );
  }

  // ==========================================================
  // DROPDOWN ITEM
  // ==========================================================

  Widget _buildDropdownItem(
      String title,
      IconData icon,
      ) {
    return Material(
      color: Colors.transparent,

      child: InkWell(
        mouseCursor: SystemMouseCursors.click,

        // ======================================================
        // CLICK
        // ======================================================

        onTap: () {
          debugPrint(
            'Selected: $title',
          );

          setState(() {
            hoveredMenu = null;
          });
          _removeDropdown();

          if(GlobalVars.globalRoutes != "purchasePage")
            {
              Navigator.pushNamed(
                context,
                Routes.purchasePage,
              );
            }



        },

        // ======================================================
        // HOVER COLOR
        // ======================================================

        hoverColor: const Color(0xffffeef6),

        child: Container(
          height: 45,

          padding: const EdgeInsets.symmetric(
            horizontal: 18,
          ),

          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: Colors.black87,
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xff8b7777),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// MENU MODEL
// ============================================================

class ERPMenu {
  final String title;
  final IconData icon;
  final List<String> items;

  const ERPMenu({
    required this.title,
    required this.icon,
    required this.items,
  });
}