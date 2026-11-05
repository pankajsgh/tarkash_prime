import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/routes/routes.dart';
import '../../../core/session/session_manager.dart';
import '../../../core/theme/colors.dart';
import '../../../core/vars/global_vars.dart';
import '../data/controller/routes_controller.dart';

class ERPHeaderPage extends StatefulWidget {
  final RoutesController routesController;

  const ERPHeaderPage({
    super.key,
    required this.routesController,
  });

  @override
  State<ERPHeaderPage> createState() => _ERPHeaderPageState();
}

class _ERPHeaderPageState extends State<ERPHeaderPage> {
  int? hoveredMenu;
  int _focusedMenuIndex = 0;
  int _focusedItemIndex = 0;

  bool _dropdownOpen = false;

  Timer? _hoverTimer;
  OverlayEntry? _dropdownOverlay;

  final FocusScopeNode _headerFocusScope =
  FocusScopeNode(debugLabel: 'ERP Header Scope');

  final FocusNode _navigationFocusNode =
  FocusNode(debugLabel: 'ERP Navigation');

  final List<GlobalKey> _menuKeys = [];

  static const double _headerHeight = 70;
  static const double _dropdownWidth = 285;
  static const double _dropdownGap = 0;

  final List<ERPMenu> menus = [
    ERPMenu(
      title: 'Ledger',
      icon: Icons.account_balance_wallet_outlined,
      items: ['Account Group', 'Account', 'Role', 'Team'],
    ),
    ERPMenu(
      title: 'Purchase',
      icon: Icons.groups_outlined,
      items: ['Challans', 'Supplier Voucher', 'Purchase Bill'],
    ),
    ERPMenu(
      title: 'Sales',
      icon: Icons.bar_chart_outlined,
      items: [
        'Sales Order',
        'Sales Invoice',
        'Sales Return',
        'Quotation',
      ],
    ),
    ERPMenu(
      title: 'Payment',
      icon: Icons.touch_app_outlined,
      items: [
        'Payment Receipt',
        'Payment Paid',
        'Contra Payment',
        'Journal Voucher',
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
      ],
    ),
    ERPMenu(
      title: 'Master',
      icon: Icons.settings_outlined,
      items: [
        'Company',
        'Branch',
        'Transport',
        'Product',
        'Category',
        'Unit',
        'Voucher Configuration',
        'HSN Tax Slab',
        'Other Charges',
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

  @override
  void initState() {
    super.initState();

    _menuKeys.addAll(
      List.generate(menus.length, (_) => GlobalKey()),
    );
  }

  @override
  void dispose() {
    _hoverTimer?.cancel();
    _removeDropdown();

    _navigationFocusNode.dispose();
    _headerFocusScope.dispose();

    super.dispose();
  }

  // ==========================================================
  // LOGO
  // ==========================================================

  Widget buildLogo(BuildContext context) {
    return InkWell(
      onTap: () {
        _closeDropdown();
        _navigateIfNeeded(Routes.dashboard);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 200,
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              height: 31,
              width: 31,
              decoration: BoxDecoration(
                color: const Color(0xff0D7894),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.business_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Globuzy',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xff126B8C),
              ),
            ),
            const Text(
              'Prime',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xff25364A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      node: _headerFocusScope,
      child: _buildTopBar(),
    );
  }

  // ==========================================================
  // TOP BAR
  // ==========================================================

  Widget _buildTopBar() {
    return Container(
      height: _headerHeight,
      color: themeColor,
      child: Row(
        children: [
          Container(
            height: _headerHeight,
            color: Colors.white,
            padding: const EdgeInsets.all(12),
            child: buildLogo(context),
          ),
          Expanded(
            child: Focus(
              focusNode: _navigationFocusNode,
              onKeyEvent: _handleNavigationKey,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: List.generate(
                    menus.length,
                        (index) => _buildMenuItem(menus[index], index),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: _buildProfileMenu(),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // KEYBOARD NAVIGATION
  // ==========================================================

  KeyEventResult _handleNavigationKey(
      FocusNode node,
      KeyEvent event,
      ) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.arrowRight) {
      _switchMenu(1);
      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.arrowLeft) {
      _switchMenu(-1);
      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.arrowDown) {
      if (!_dropdownOpen) {
        _openKeyboardDropdown();
      } else {
        _moveItem(1);
      }
      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.arrowUp) {
      if (!_dropdownOpen) {
        _openKeyboardDropdown();
      } else {
        _moveItem(-1);
      }
      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.space) {
      if (!_dropdownOpen) {
        _openKeyboardDropdown();
      } else {
        _selectFocusedItem();
      }
      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.escape) {
      _closeDropdown();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  void _switchMenu(int direction) {
    _hoverTimer?.cancel();

    _focusedMenuIndex =
        (_focusedMenuIndex + direction + menus.length) % menus.length;
    _focusedItemIndex = 0;

    _openMenu(_focusedMenuIndex);
  }

  void _openKeyboardDropdown() {
    _hoverTimer?.cancel();
    _focusedItemIndex = 0;

    _openMenu(_focusedMenuIndex);
  }

  void _openMenu(int index) {
    if (index < 0 || index >= menus.length) return;

    _hoverTimer?.cancel();

    setState(() {
      _focusedMenuIndex = index;
      _focusedItemIndex = 0;
      hoveredMenu = index;
      _dropdownOpen = true;
    });

    _showDropdown(index);
  }

  void _moveItem(int direction) {
    final items = menus[_focusedMenuIndex].items;

    if (items.isEmpty) return;

    setState(() {
      _focusedItemIndex =
          (_focusedItemIndex + direction + items.length) % items.length;
    });

    _dropdownOverlay?.markNeedsBuild();
  }

  void _selectFocusedItem() {
    final items = menus[_focusedMenuIndex].items;

    if (items.isEmpty) return;

    final index = _focusedItemIndex.clamp(0, items.length - 1);
    _handleMenuSelection(items[index]);
  }

  // ==========================================================
  // PROFILE MENU
  // ==========================================================

  Widget _buildProfileMenu() {
    return PopupMenuButton<String>(
      offset: const Offset(0, 58),
      elevation: 8,
      color: Colors.white,
      tooltip: 'User settings',
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      onOpened: _closeDropdown,
      onSelected: (value) async {
        if (value == 'profile') {
          debugPrint('Profile clicked');
        } else if (value == 'ip_address') {
          await _showServerSettings();
        } else if (value == 'logout') {
          _closeDropdown();

          await SessionManager.removeLogin();

          if (!mounted) return;

          Navigator.pushNamedAndRemoveUntil(
            context,
            Routes.login,
                (route) => false,
          );
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          enabled: false,
          padding: EdgeInsets.zero,
          child: Container(
            width: 240,
            padding: const EdgeInsets.all(15),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: Color(0xFFEAF2FF),
                      child: Icon(
                        Icons.person,
                        color: Color(0xFF1557C0),
                        size: 28,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                SizedBox(height: 12),
                Divider(height: 1),
              ],
            ),
          ),
        ),
        const PopupMenuItem<String>(
          value: 'profile',
          child: Row(
            children: [
              Icon(Icons.person_outline, size: 20),
              SizedBox(width: 12),
              Text('My Profile'),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'ip_address',
          child: Row(
            children: [
              Icon(Icons.settings, size: 20),
              SizedBox(width: 12),
              Text('IP Address'),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, size: 20, color: Color(0xffd32f2f)),
              SizedBox(width: 12),
              Text(
                'Logout',
                style: TextStyle(
                  color: Color(0xffd32f2f),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Colors.white.withValues(alpha: 0.2),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 19,
              backgroundColor: Color(0xFFEAF2FF),
              child: Icon(
                Icons.person,
                color: Color(0xFF1557C0),
              ),
            ),
            SizedBox(width: 9),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
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
            SizedBox(width: 10),
            Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white,
              size: 18,
            ),
            SizedBox(width: 6),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // SERVER SETTINGS
  // ==========================================================

  Future<void> _showServerSettings() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    final savedIp = prefs.getString(serverIpKey) ?? '';
    GlobalVars.localIp = savedIp;

    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ServerSettingsDialog(initialIp: savedIp),
    );

    if (!mounted || result == null) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Local server address saved.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // ==========================================================
  // MENU ITEM
  // ==========================================================

  Widget _buildMenuItem(ERPMenu menu, int index) {
    final isHovered = hoveredMenu == index;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        _hoverTimer?.cancel();

        if (hoveredMenu != index || !_dropdownOpen) {
          _focusedMenuIndex = index;
          _focusedItemIndex = 0;

          setState(() {
            hoveredMenu = index;
            _dropdownOpen = true;
          });

          _showDropdown(index);
        }
      },
      onExit: (_) => _startCloseTimer(),
      child: InkWell(
        key: _menuKeys[index],
        canRequestFocus: false,
        onTap: () {
          _navigationFocusNode.requestFocus();

          if (_dropdownOpen && hoveredMenu == index) {
            _closeDropdown();
          } else {
            _focusedMenuIndex = index;
            _focusedItemIndex = 0;
            _openMenu(index);
          }
        },
        child: Container(
          height: _headerHeight,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          color: isHovered
              ? const Color(0xff820041)
              : const Color(0xff97004d),
          child: Row(
            children: [
              Icon(menu.icon, size: 18, color: Colors.white),
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
      ),
    );
  }

  // ==========================================================
  // SHOW DROPDOWN
  // ==========================================================

  void _showDropdown(int index) {
    _hoverTimer?.cancel();
    _removeDropdown();

    if (!mounted || index < 0 || index >= menus.length) return;

    final renderObject =
    _menuKeys[index].currentContext?.findRenderObject();

    if (renderObject is! RenderBox || !renderObject.hasSize) return;

    final position = renderObject.localToGlobal(Offset.zero);
    final screenSize = MediaQuery.sizeOf(context);

    final maxLeft = (screenSize.width - _dropdownWidth).clamp(
      0.0,
      screenSize.width,
    );

    final left = position.dx.clamp(0.0, maxLeft).toDouble();
    final top = position.dy + _headerHeight + _dropdownGap;

    final menu = menus[index];

    _dropdownOverlay = OverlayEntry(
      builder: (overlayContext) {
        final availableHeight =
        (screenSize.height - top - 8).clamp(0.0, screenSize.height);

        return Positioned(
          left: left,
          top: top,
          width: _dropdownWidth,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) {
              _hoverTimer?.cancel();
            },
            onExit: (_) => _startCloseTimer(),
            child: _buildDropdown(
              menu,
              index,
              availableHeight,
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_dropdownOverlay!);
  }

  void _removeDropdown() {
    _dropdownOverlay?.remove();
    _dropdownOverlay = null;
  }

  void _closeDropdown() {
    _hoverTimer?.cancel();

    final wasOpen =
        _dropdownOpen || hoveredMenu != null || _dropdownOverlay != null;

    _removeDropdown();

    if (!wasOpen || !mounted) return;

    setState(() {
      hoveredMenu = null;
      _dropdownOpen = false;
    });
  }

  void _startCloseTimer() {
    _hoverTimer?.cancel();

    _hoverTimer = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      _closeDropdown();
    });
  }

  // ==========================================================
  // DROPDOWN CONTENT
  // ==========================================================

  Widget _buildDropdown(
      ERPMenu menu,
      int menuIndex,
      double availableHeight,
      ) {
    return Material(
      elevation: 8,
      color: Colors.white,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: availableHeight.clamp(0.0, 500.0),
        ),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xffeeeeee)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: List.generate(
              menu.items.length,
                  (index) => _buildDropdownItem(
                menu.items[index],
                menu.icon,
                index,
                menuIndex,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownItem(
      String title,
      IconData icon,
      int itemIndex,
      int menuIndex,
      ) {
    final isKeyboardFocused = _dropdownOpen &&
        _focusedMenuIndex == menuIndex &&
        _focusedItemIndex == itemIndex;

    return Material(
      color: isKeyboardFocused
          ? const Color(0xffffdce9)
          : Colors.transparent,
      child: InkWell(
        canRequestFocus: false,
        mouseCursor: SystemMouseCursors.click,
        hoverColor: const Color(0xffffeef6),
        onHover: (hovering) {
          if (!hovering) return;

          if (_focusedMenuIndex != menuIndex ||
              _focusedItemIndex != itemIndex ||
              !_dropdownOpen) {
            setState(() {
              _focusedMenuIndex = menuIndex;
              _focusedItemIndex = itemIndex;
              _dropdownOpen = true;
              hoveredMenu = menuIndex;
            });

            _dropdownOverlay?.markNeedsBuild();
          }
        },
        onTap: () {
          _focusedMenuIndex = menuIndex;
          _focusedItemIndex = itemIndex;
          _handleMenuSelection(title);
        },
        child: Container(
          height: 45,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            children: [
              Icon(icon, size: 20, color: Colors.black87),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    color: isKeyboardFocused
                        ? const Color(0xff820041)
                        : const Color(0xff8b7777),
                    fontWeight: isKeyboardFocused
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
              if (isKeyboardFocused)
                const Icon(
                  Icons.keyboard_return,
                  size: 15,
                  color: Color(0xff820041),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // MENU SELECTION / ROUTES
  // ==========================================================

  void _handleMenuSelection(String title) {
    _closeDropdown();

    debugPrint('Selected: $title');

    switch (title) {
      case 'Challans':
        _navigateIfNeeded(Routes.purchaseChallanList);
        return;

      case 'Other Charges':
        _navigateIfNeeded(Routes.otherChargeScreen);
        return;

      case 'Product':
        _navigateIfNeeded(Routes.productListScreen);
        return;

      case 'HSN Tax Slab':
        _navigateIfNeeded(Routes.taxListScreen);
        return;

      case 'Account':
        _navigateIfNeeded(Routes.accountScreen);
        return;

      case 'Role':
        _navigateIfNeeded(Routes.rolePermissionScreen);
        return;

      case 'Account Group':
        _navigateIfNeeded(Routes.accountGroupScreen);
        return;

      case 'Stock Summary':
        _navigateIfNeeded(Routes.stockListScreen);
        return;

      case 'Team':
        _navigateIfNeeded(Routes.teamListScreen);
        return;

      case 'Sales Invoice':
        _navigateIfNeeded(Routes.saleInvoiceScreen);
        return;

      case 'Transport':
        _navigateIfNeeded(Routes.transportListScreen);
        return;

      case 'Voucher Configuration':
        _navigateIfNeeded(Routes.seriesListScreen);
        return;

      case 'Supplier Voucher':
        _navigateIfNeeded(Routes.supplierVoucherScreen);
        return;


      default:
        showComingSoon(context);
    }
  }

  void _navigateIfNeeded(String route) {
    if (GlobalVars.globalRoutes != route) {
      widget.routesController.setRoute(route);
    }
  }

  // ==========================================================
  // COMING SOON
  // ==========================================================

  void showComingSoon(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        Future.delayed(const Duration(seconds: 1), () {
          if (dialogContext.mounted) {
            Navigator.of(dialogContext).pop();
          }
        });

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 40,
              vertical: 40,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.access_time_rounded,
                  color: Color(0xFF3267D5),
                  size: 24,
                ),
                SizedBox(width: 12),
                Text(
                  'Coming Soon',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
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

// ============================================================
// SERVER SETTINGS DIALOG
// ============================================================

class ServerSettingsDialog extends StatefulWidget {
  final String initialIp;

  const ServerSettingsDialog({
    super.key,
    required this.initialIp,
  });

  @override
  State<ServerSettingsDialog> createState() =>
      _ServerSettingsDialogState();
}

class _ServerSettingsDialogState extends State<ServerSettingsDialog> {
  late final TextEditingController _ipController;

  bool _saving = false;
  String? _error;

  Color get _primary => primaryBlue;

  @override
  void initState() {
    super.initState();
    _ipController = TextEditingController(text: widget.initialIp);
  }

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }

  bool _isValidHostAndPort(String value) {
    if (value.isEmpty ||
        value.startsWith('.') ||
        value.endsWith('.') ||
        value.contains('..') ||
        value.contains('://') ||
        value.contains('/') ||
        value.contains(' ')) {
      return false;
    }

    final parts = value.split(':');

    if (parts.length > 2) return false;

    final host = parts.first;
    final hostPattern = RegExp(
      r'^[a-zA-Z0-9](?:[a-zA-Z0-9.-]*[a-zA-Z0-9])?$',
    );

    if (!hostPattern.hasMatch(host)) return false;

    if (parts.length == 2) {
      final port = int.tryParse(parts[1]);

      if (port == null || port < 1 || port > 65535) {
        return false;
      }
    }

    final ipv4Parts = host.split('.');

    final looksLikeIpv4 = RegExp(r'^[0-9.]+$').hasMatch(host);

    if (looksLikeIpv4) {
      if (ipv4Parts.length != 4) return false;

      for (final part in ipv4Parts) {
        final octet = int.tryParse(part);

        if (octet == null || octet < 0 || octet > 255) {
          return false;
        }
      }
    }

    return true;
  }

  Future<void> _saveIp() async {
    if (_saving) return;

    final ip = _ipController.text.trim();

    if (!_isValidHostAndPort(ip)) {
      setState(() {
        _error = 'Enter a valid IP address or host and port.';
      });
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(serverIpKey, ip);

      GlobalVars.localIp = ip;

      if (!mounted) return;

      Navigator.of(context).pop(ip);
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _saving = false;
        _error = 'Unable to save the server address.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Icon(Icons.dns_rounded, color: _primary, size: 24),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Server Settings',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Local Server IP Address',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _ipController,
              enabled: !_saving,
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.done,
              onChanged: (_) {
                if (_error != null) {
                  setState(() => _error = null);
                }
              },
              onSubmitted: (_) => _saveIp(),
              decoration: InputDecoration(
                hintText: '192.168.1.5:8080',
                prefixIcon: Icon(
                  Icons.computer_rounded,
                  color: _primary,
                  size: 20,
                ),
                filled: true,
                fillColor: const Color(0xFFF7F9FC),
                errorText: _error,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: borderColor),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Enter the computer IP and optional port, without '
                  'http:// or the API folder path.',
              style: TextStyle(fontSize: 11, height: 1.5),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: _saving ? null : _saveIp,
          icon: _saving
              ? const SizedBox(
            width: 15,
            height: 15,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
              : const Icon(Icons.save_rounded, size: 17),
          label: Text(_saving ? 'Saving...' : 'Save IP'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _primary,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
