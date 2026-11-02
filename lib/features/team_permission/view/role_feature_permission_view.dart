import 'package:calculation_panel/core/vars/global_vars.dart';
import 'package:flutter/material.dart';
import '../../../core/routes/routes.dart';
import '../../components/custome_dropdown_widget.dart';
import '../controller/role_feature_permission_controller.dart';
import '../model/role_model.dart';
import '../model/role_feature_permission_model.dart';

class RolePermissionsScreen extends StatefulWidget {
  const RolePermissionsScreen({super.key});

  @override
  State<RolePermissionsScreen> createState() =>
      _RolePermissionsScreenState();
}

class _RolePermissionsScreenState extends State<RolePermissionsScreen> {
  late final RolePermissionsController controller;

  static const Color primaryColor = Color(0xFF3267D5);
  static const Color pageColor = Color(0xFFF4F6FA);
  static const Color textColor = Color(0xFF243047);
  static const Color mutedColor = Color(0xFF718096);
  static const Color borderColor = Color(0xFFE3E8F0);

  @override
  void initState() {
    GlobalVars.globalRoutes = Routes.rolePermissionScreen;
    super.initState();
    controller = RolePermissionsController();
    controller.loadRoles();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------
  // ROLE DROPDOWN
  // ------------------------------------------------------------

  Widget _buildRoleDropdown() {
    final selectedRole = controller.selectedRole;

    return SearchableCustomerDropdown<RoleModel>(
      key: ValueKey(
        'role_${selectedRole?.id ?? 'none'}_${controller.roles.length}',
      ),
      value: selectedRole,
      height: 36,
      borderColor: Colors.grey.shade300,
      borderRadius: 8,
      items: controller.roles,
      onSearch: (value) {},
      displayString: (item) => item.roleName ?? '',
      onSelect: (value) {
        if (value == null) return;

        if (value.id != controller.selectedRole?.id) {
          controller.selectRole(value);
        }
      },
    );
  }

  // ------------------------------------------------------------
  // MAIN BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageColor,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            return Column(
              children: [
                _header(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _roleSelector(),
                        if (controller.errorMessage.isNotEmpty)
                          _message(
                            controller.errorMessage,
                            const Color(0xFFB42318),
                            const Color(0xFFFFF1F0),
                          ),
                        if (controller.successMessage.isNotEmpty)
                          _message(
                            controller.successMessage,
                            const Color(0xFF067647),
                            const Color(0xFFECFDF3),
                          ),
                        const SizedBox(height: 10),
                        Expanded(child: _permissionContent()),
                        const SizedBox(height: 10),
                        _footer(),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // HEADER
  // ------------------------------------------------------------

  Widget _header() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.admin_panel_settings_outlined,
              color: primaryColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 11),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Role Permissions',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Manage access and role-level settings',
                  style: TextStyle(
                    color: mutedColor,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          if (controller.loadingRoles || controller.loadingPermissions)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: primaryColor,
              ),
            ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // ROLE SELECTOR
  // ------------------------------------------------------------

  Widget _roleSelector() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 9),
      decoration: _cardDecoration(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 500;

          final dropdown = SizedBox(
            width: compact ? null : 320,
            child: _buildRoleDropdown(),
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.badge_outlined,
                      color: primaryColor,
                      size: 20,
                    ),
                    SizedBox(width: 9),
                    Text(
                      'Select Role',
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: dropdown),
                    const SizedBox(width: 4),
                    _reloadButton(),
                  ],
                ),
              ],
            );
          }

          return Row(
            children: [
              const Icon(
                Icons.badge_outlined,
                color: primaryColor,
                size: 20,
              ),
              const SizedBox(width: 9),
              const Text(
                'Select Role',
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5,
                ),
              ),
              const SizedBox(width: 16),
              dropdown,
              const SizedBox(width: 8),
              _reloadButton(),
            ],
          );
        },
      ),
    );
  }

  Widget _reloadButton() {
    return IconButton(
      tooltip: 'Reload roles',
      onPressed: controller.loadingRoles ||
          controller.loadingPermissions ||
          controller.saving
          ? null
          : controller.loadRoles,
      icon: const Icon(Icons.refresh, size: 20),
      color: primaryColor,
      visualDensity: VisualDensity.compact,
    );
  }

  // ------------------------------------------------------------
  // PERMISSION CONTENT
  // ------------------------------------------------------------

  Widget _permissionContent() {
    if (controller.loadingRoles && controller.roles.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: primaryColor,
        ),
      );
    }

    if (controller.selectedRole == null) {
      return _emptyState(
        Icons.groups_outlined,
        'No roles available',
        'Add a role before configuring permissions.',
      );
    }

    if (controller.loadingPermissions && controller.features.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: primaryColor,
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 850;

        if (wide) {
          final settingsWidth =
          (constraints.maxWidth * 0.35).clamp(285.0, 390.0);

          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _featurePanel()),
              const SizedBox(width: 12),
              SizedBox(
                width: settingsWidth,
                child: _additionalSettingsPanel(),
              ),
            ],
          );
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 340,
                child: _featurePanel(),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 340,
                child: _additionalSettingsPanel(),
              ),
            ],
          ),
        );
      },
    );
  }

  // ------------------------------------------------------------
  // FEATURE PERMISSIONS PANEL
  // ------------------------------------------------------------

  Widget _featurePanel() {
    return Container(
      decoration: _cardDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _panelHeader(
            icon: Icons.grid_view_rounded,
            title: 'Feature Permissions',
            subtitle: '${controller.features.length} features',
          ),
          const Divider(height: 1, color: borderColor),
          Expanded(
            child: controller.features.isEmpty
                ? _emptyState(
              Icons.list_alt_outlined,
              'No features found',
              'No permissions are available for this role.',
            )
                : Column(
              children: [
                Container(
                  height: 39,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  color: pageColor,
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'FEATURE',
                          style: TextStyle(
                            color: mutedColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      ...controller.permissionLabels.map((label) {
                        return SizedBox(
                          width: 43,
                          child: Tooltip(
                            message: label,
                            child: Center(
                              child: Text(
                                label == 'Search' ? 'Src' : label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: _tableHeadingStyle(),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const Divider(height: 1, color: borderColor),
                Expanded(
                  child: ListView.builder(
                    itemCount: controller.features.length,
                    itemBuilder: (context, index) {
                      return _featureRow(
                        controller.features[index],
                        index,
                        43,
                        12,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _tableHeadingStyle() {
    return const TextStyle(
      color: mutedColor,
      fontSize: 10.5,
      fontWeight: FontWeight.w700,
    );
  }

  Widget _featureRow(
      RoleFeaturePermissionModel feature,
      int index,
      double permissionColumnWidth,
      double horizontalPadding,
      ) {
    final selected = feature.alls ||
        feature.shows ||
        feature.saves ||
        feature.updates ||
        feature.searchs ||
        feature.deletes ||
        feature.prints;

    return Material(
      color: selected
          ? primaryColor.withValues(alpha: 0.035)
          : (index.isEven ? Colors.white : const Color(0xFFFCFDFF)),
      child: InkWell(
        onTap: controller.saving || controller.loadingPermissions
            ? null
            : () => controller.changePermission(
          feature,
          'alls',
          !feature.alls,
        ),
        hoverColor: primaryColor.withValues(alpha: 0.06),
        child: Container(
          constraints: const BoxConstraints(minHeight: 41),
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 2,
          ),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFFF0F2F6)),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Tooltip(
                  message: feature.featureName,
                  child: Text(
                    feature.featureName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected ? primaryColor : textColor,
                      fontSize: 13,
                      height: 1.2,
                      fontWeight:
                      selected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
              ...controller.permissionKeys.map((key) {
                final checked = _featurePermissionValue(feature, key);
                final permissionIndex =
                controller.permissionKeys.indexOf(key);

                final label =
                permissionIndex < controller.permissionLabels.length
                    ? controller.permissionLabels[permissionIndex]
                    : key;

                return SizedBox(
                  width: permissionColumnWidth,
                  child: Center(
                    child: Tooltip(
                      message: '${feature.featureName}: $label',
                      child: Transform.scale(
                        scale: 0.78,
                        child: Checkbox(
                          value: checked,
                          activeColor: primaryColor,
                          checkColor: Colors.white,
                          side: const BorderSide(
                            color: Color(0xFFB8C3D4),
                            width: 1.3,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize:
                          MaterialTapTargetSize.shrinkWrap,
                          onChanged: controller.saving ||
                              controller.loadingPermissions
                              ? null
                              : (value) {
                            controller.changePermission(
                              feature,
                              key,
                              value ?? false,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  bool _featurePermissionValue(
      RoleFeaturePermissionModel feature,
      String key,
      ) {
    switch (key) {
      case 'alls':
        return feature.alls;
      case 'shows':
        return feature.shows;
      case 'saves':
        return feature.saves;
      case 'updates':
        return feature.updates;
      case 'searchs':
        return feature.searchs;
      case 'deletes':
        return feature.deletes;
      case 'prints':
        return feature.prints;
      default:
        return false;
    }
  }

  // ------------------------------------------------------------
  // ADDITIONAL SETTINGS
  // ------------------------------------------------------------

  Widget _additionalSettingsPanel() {
    const descriptions = {
      'allow_price_change_in_voucher':
      'Permit editing item prices in vouchers.',
      'allow_discount_change_in_voucher':
      'Permit changing voucher discounts.',
      'allow_export_of_reports': 'Allow exporting reports and data.',
      'allow_printing_of_documents':
      'Allow printing supported documents.',
      'price_edit': 'Permit editing item prices in vouchers.',
      'disc_edit': 'Permit changing voucher discounts.',
      'report_export': 'Allow exporting reports and data.',
      'doc_print': 'Allow printing supported documents.',
    };

    return Container(
      decoration: _cardDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _panelHeader(
            icon: Icons.tune_rounded,
            title: 'Additional Access',
            subtitle: controller.selectedRole?.roleName ?? 'Selected role',
          ),
          const Divider(height: 1, color: borderColor),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: controller.additionalSettings.length,
              separatorBuilder: (_, __) => const Divider(
                height: 1,
                indent: 12,
                endIndent: 12,
                color: Color(0xFFF0F2F6),
              ),
              itemBuilder: (context, index) {
                final setting = controller.additionalSettings[index];
                final key = setting['key']!;
                final label = setting['label']!;
                final enabled =
                controller.additionalPermissionValue(key);

                return Material(
                  color: enabled
                      ? primaryColor.withValues(alpha: 0.045)
                      : Colors.white,
                  child: InkWell(
                    onTap: controller.saving || controller.loadingPermissions
                        ? null
                        : () => controller.changeAdditionalPermission(
                      key,
                      !enabled,
                    ),
                    hoverColor: primaryColor.withValues(alpha: 0.07),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: enabled
                                  ? primaryColor.withValues(alpha: 0.12)
                                  : pageColor,
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: Icon(
                              enabled
                                  ? Icons.check_circle_outline
                                  : Icons.lock_outline,
                              size: 18,
                              color: enabled ? primaryColor : mutedColor,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  label,
                                  softWrap: true,
                                  style: TextStyle(
                                    fontSize: 12,
                                    height: 1.25,
                                    fontWeight: FontWeight.w600,
                                    color: enabled ? primaryColor : textColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  descriptions[key] ?? '',
                                  softWrap: true,
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    height: 1.3,
                                    color: mutedColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 5),
                          Transform.scale(
                            scale: 0.65,
                            alignment: Alignment.centerRight,
                            child: Switch.adaptive(
                              value: enabled,
                              activeTrackColor: primaryColor,
                              materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                              onChanged: controller.saving ||
                                  controller.loadingPermissions
                                  ? null
                                  : (value) {
                                controller.changeAdditionalPermission(
                                  key,
                                  value,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            color: pageColor,
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 14,
                  color: mutedColor,
                ),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Changes apply to the selected role when saved.',
                    style: TextStyle(
                      fontSize: 10,
                      height: 1.35,
                      color: mutedColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // PANEL HEADER
  // ------------------------------------------------------------

  Widget _panelHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      child: Row(
        children: [
          Icon(icon, color: primaryColor, size: 19),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    color: textColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: mutedColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // FOOTER
  // ------------------------------------------------------------

  Widget _footer() {
    final busy = controller.saving ||
        controller.loadingPermissions ||
        controller.loadingRoles;

    final selectedFeatures = controller.features.where((feature) {
      return feature.alls ||
          feature.shows ||
          feature.saves ||
          feature.updates ||
          feature.searchs ||
          feature.deletes ||
          feature.prints;
    }).length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: _cardDecoration(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 560;

          final actions = Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              OutlinedButton.icon(
                onPressed: busy
                    ? null
                    : () => controller.setAllFeatures(true),
                icon: const Icon(Icons.done_all_rounded, size: 16),
                label: const Text('Select All'),
                style: _outlinedButtonStyle(),
              ),
              OutlinedButton.icon(
                onPressed: busy
                    ? null
                    : () => controller.setAllFeatures(false),
                icon: const Icon(Icons.clear_all_rounded, size: 16),
                label: const Text('Clear All'),
                style: _outlinedButtonStyle(),
              ),
            ],
          );

          final saveButton = FilledButton.icon(
            onPressed: busy || controller.selectedRole == null
                ? null
                : controller.savePermissions,
            icon: controller.saving
                ? const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : const Icon(Icons.save_outlined, size: 16),
            label: Text(
              controller.saving ? 'Saving...' : 'Save Changes',
            ),
            style: FilledButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              disabledBackgroundColor:
              primaryColor.withValues(alpha: 0.45),
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 11,
              ),
              textStyle: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.checklist_rounded,
                      size: 17,
                      color: mutedColor,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Features: $selectedFeatures/${controller.features.length}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                    ),
                    saveButton,
                  ],
                ),
                const SizedBox(height: 9),
                actions,
              ],
            );
          }

          return Row(
            children: [
              const Icon(
                Icons.checklist_rounded,
                size: 17,
                color: mutedColor,
              ),
              const SizedBox(width: 6),
              Text(
                'Features: $selectedFeatures/${controller.features.length}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(child: actions),
              const SizedBox(width: 10),
              saveButton,
            ],
          );
        },
      ),
    );
  }

  ButtonStyle _outlinedButtonStyle() {
    return OutlinedButton.styleFrom(
      foregroundColor: textColor,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      textStyle: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
      side: const BorderSide(color: borderColor),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      visualDensity: VisualDensity.compact,
    );
  }

  // ------------------------------------------------------------
  // MESSAGES AND EMPTY STATES
  // ------------------------------------------------------------

  Widget _message(String message, Color color, Color background) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 9),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: color,
          fontSize: 11.5,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _emptyState(
      IconData icon,
      String title,
      String message,
      ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 31, color: mutedColor),
            const SizedBox(height: 9),
            Text(
              title,
              style: const TextStyle(
                color: textColor,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: mutedColor,
                fontSize: 11.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: borderColor),
    );
  }
}