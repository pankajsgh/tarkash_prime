
import 'package:flutter/material.dart';

import '../controller/team_list_controller.dart';
import '../model/tema_model.dart';

class TeamMemberScreen extends StatefulWidget {
  const TeamMemberScreen({super.key});

  @override
  State<TeamMemberScreen> createState() => _TeamMemberScreenState();
}

class _TeamMemberScreenState extends State<TeamMemberScreen> {
  late final TeamListController controller;
  final TextEditingController searchController = TextEditingController();

  static const Color primary = Color(0xFF3267D5);
  static const Color pageColor = Color(0xFFF4F6FA);
  static const Color borderColor = Color(0xFFE2E7F0);

  @override
  void initState() {
    super.initState();
    controller = TeamListController();
    controller.loadMembers();
  }

  @override
  void dispose() {
    controller.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageColor,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            return Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _header(),
                  const SizedBox(height: 12),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth < 700) {
                          return _mobileLayout();
                        }

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 290,
                              child: _memberList(),
                            ),
                            const SizedBox(width: 14),
                            Expanded(child: _memberDetails()),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Team Members',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF202938),
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Manage team details and device access',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Refresh',
          onPressed: controller.isLoading
              ? null
              : () => controller.loadMembers(),
          icon: const Icon(Icons.refresh),
        ),
        const SizedBox(width: 6),
        FilledButton.icon(
          onPressed: () => _showMemberForm(),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add Team'),
          style: FilledButton.styleFrom(
            backgroundColor: primary,
          ),
        ),
      ],
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: borderColor),
    );
  }

  Widget _memberList() {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          TextField(
            controller: searchController,
            onChanged: controller.searchMembers,
            decoration: InputDecoration(
              hintText: 'Search team...',
              hintStyle: const TextStyle(fontSize: 12),
              prefixIcon: const Icon(Icons.search, size: 19),
              suffixIcon: searchController.text.isEmpty
                  ? null
                  : IconButton(
                onPressed: () {
                  searchController.clear();
                  controller.searchMembers('');
                  setState(() {});
                },
                icon: const Icon(Icons.close, size: 17),
              ),
              isDense: true,
              filled: true,
              fillColor: pageColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: controller.isLoading && controller.members.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : controller.filteredMembers.isEmpty
                ? Center(
              child: Text(
                controller.errorMessage.isNotEmpty
                    ? controller.errorMessage
                    : 'No team members found',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
            )
                : ListView.separated(
              itemCount: controller.filteredMembers.length,
              separatorBuilder: (_, __) =>
              const SizedBox(height: 5),
              itemBuilder: (context, index) {
                final member =
                controller.filteredMembers[index];

                final selected =
                    controller.selectedMember?.id == member.id;

                return InkWell(
                  borderRadius: BorderRadius.circular(9),
                  onTap: () =>
                      controller.selectMember(member),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: selected
                          ? primary.withValues(alpha: 0.07)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(
                        color: selected
                            ? primary
                            : borderColor,
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor:
                          primary.withValues(alpha: 0.10),
                          child: Text(
                            member.name.isEmpty
                                ? '?'
                                : member.name[0].toUpperCase(),
                            style: const TextStyle(
                              color: primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                member.name.isEmpty
                                    ? 'Unnamed member'
                                    : member.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                member.loginMobile.isNotEmpty
                                    ? member.loginMobile
                                    : member.mobile,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (selected)
                          const Icon(
                            Icons.chevron_right,
                            size: 19,
                            color: primary,
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


  Widget _memberDetails() {
    final member = controller.selectedMember;

    if (member == null) {
      return Container(
        decoration: _cardDecoration(),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.groups_2_outlined,
                size: 48,
                color: Color(0xFF9CAAC0),
              ),
              SizedBox(height: 12),
              Text(
                'Select a team member',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Member information will appear here',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
        ),
      );
    }

    final active = member.status == 'Active';
    final deviceAssigned = member.deviceId.trim().isNotEmpty;

    return Container(
      decoration: _cardDecoration(),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFEAF1FF),
                    Color(0xFFF8FAFF),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: primary.withValues(alpha: 0.22),
                        width: 1.5,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 31,
                      backgroundColor: primary,
                      child: Text(
                        member.name.trim().isEmpty
                            ? '?'
                            : member.name.trim()[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          member.name.isEmpty
                              ? 'Team Member'
                              : member.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1F2D45),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          member.designation.isNotEmpty
                              ? member.designation
                              : member.roleName.isNotEmpty
                              ? member.roleName
                              : 'Team Member',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF5F6F89),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 7,
                          runSpacing: 6,
                          children: [
                            _detailBadge(
                              active ? 'Active' : 'Inactive',
                              active
                                  ? const Color(0xFF16865B)
                                  : const Color(0xFFD04444),
                              active
                                  ? const Color(0xFFE0F7EB)
                                  : const Color(0xFFFFE8E8),
                              active
                                  ? Icons.check_circle_outline
                                  : Icons.block_outlined,
                            ),
                            _detailBadge(
                              deviceAssigned ? 'Device Linked' : 'No Device',
                              deviceAssigned
                                  ? const Color(0xFF3267D5)
                                  : const Color(0xFF7A8495),
                              deviceAssigned
                                  ? const Color(0xFFE4EDFF)
                                  : const Color(0xFFEDEFF3),
                              deviceAssigned
                                  ? Icons.phonelink
                                  : Icons.phonelink_off,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Tooltip(
                    message: 'Edit all team details',
                    child: FilledButton.icon(
                      onPressed: () => _showMemberForm(member: member),
                      icon: const Icon(Icons.edit_outlined, size: 17),
                      label: const Text('Edit'),
                      style: FilledButton.styleFrom(
                        backgroundColor: primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick information cards
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final count = constraints.maxWidth >= 650
                          ? 3
                          : constraints.maxWidth >= 390
                          ? 2
                          : 1;

                      final width = (constraints.maxWidth -
                          ((count - 1) * 10)) /
                          count;

                      return Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          SizedBox(
                            width: width,
                            child: _quickInfo(
                              Icons.badge_outlined,
                              'Employee Code',
                              member.employeeCode,
                              const Color(0xFF3267D5),
                            ),
                          ),
                          SizedBox(
                            width: width,
                            child: _quickInfo(
                              Icons.phone_outlined,
                              'Login Mobile',
                              member.loginMobile.isNotEmpty
                                  ? member.loginMobile
                                  : member.mobile,
                              const Color(0xFF15936C),
                            ),
                          ),
                          SizedBox(
                            width: width,
                            child: _quickInfo(
                              Icons.apartment_outlined,
                              'Department',
                              member.department,
                              const Color(0xFF8A56C5),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 22),

                  // Device management panel
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F9FC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: 43,
                          width: 43,
                          decoration: BoxDecoration(
                            color: deviceAssigned
                                ? const Color(0xFFE3EDFF)
                                : const Color(0xFFEDEFF3),
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: Icon(
                            deviceAssigned
                                ? Icons.phonelink_lock_outlined
                                : Icons.phonelink_off_outlined,
                            color: deviceAssigned
                                ? primary
                                : Colors.blueGrey,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Registered Device',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 5),
                              SelectableText(
                                deviceAssigned
                                    ? member.deviceId
                                    : 'No device is currently linked',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: deviceAssigned
                                      ? const Color(0xFF35445B)
                                      : Colors.black54,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        OutlinedButton.icon(
                          onPressed: !deviceAssigned || controller.isSaving
                              ? null
                              : () => _confirmClearDeviceId(member),
                          icon: const Icon(
                            Icons.phonelink_erase_outlined,
                            size: 16,
                          ),
                          label: const Text('Clear Device'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFD33D45),
                            side: const BorderSide(
                              color: Color(0xFFF0C4C6),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  _sectionHeading(
                    'Personal Information',
                    Icons.person_outline,
                  ),
                  const SizedBox(height: 13),
                  _detailSection([
                    ('Full Name', member.name, Icons.person_outline),
                    (
                    'Login Mobile',
                    member.loginMobile,
                    Icons.phone_android_outlined,
                    ),
                    ('Mobile', member.mobile, Icons.phone_outlined),
                    (
                    'Employee Code',
                    member.employeeCode,
                    Icons.badge_outlined,
                    ),
                    (
                    'Address',
                    member.address,
                    Icons.location_on_outlined,
                    ),
                  ]),

                  const SizedBox(height: 23),

                  _sectionHeading(
                    'Work & Permissions',
                    Icons.admin_panel_settings_outlined,
                  ),
                  const SizedBox(height: 13),
                  _detailSection([
                    (
                    'Designation',
                    member.designation,
                    Icons.work_outline,
                    ),
                    (
                    'Department',
                    member.department,
                    Icons.apartment_outlined,
                    ),
                    ('Role', member.roleName.isNotEmpty
                        ? member.roleName
                        : member.role, Icons.security_outlined),
                    ('Role ID', member.roleId, Icons.key_outlined),
                    ('Store ID', member.storeId, Icons.store_outlined),
                    ('Level', member.level, Icons.layers_outlined),
                    (
                    'Rate Type Access',
                    member.rateTypeAccess,
                    Icons.price_change_outlined,
                    ),
                    (
                    'IP Login',
                    member.ipLoginStatus == '1'
                        ? 'Enabled'
                        : 'Disabled',
                    Icons.wifi_outlined,
                    ),
                  ]),

                  const SizedBox(height: 23),

                  _sectionHeading(
                    'Other Details',
                    Icons.receipt_long_outlined,
                  ),
                  const SizedBox(height: 13),
                  _detailSection([
                    ('Salary', member.salary, Icons.currency_rupee),
                    (
                    'Status',
                    active ? 'Active' : 'Inactive',
                    Icons.toggle_on_outlined,
                    ),
                    (
                    'Created At',
                    member.createdAt,
                    Icons.calendar_today_outlined,
                    ),
                    (
                    'Updated At',
                    member.updatedAt,
                    Icons.update_outlined,
                    ),
                    ('Remarks', member.remarks, Icons.notes_outlined),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailBadge(
      String label,
      Color textColor,
      Color backgroundColor,
      IconData icon,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: textColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickInfo(
      IconData icon,
      String label,
      String value,
      Color color,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical:  8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            height: 34,
            width: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? '—' : value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF26354B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeading(String title, IconData icon) {
    return Row(
      children: [
        Container(
          height: 30,
          width: 30,
          decoration: BoxDecoration(
            color: primary.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 17, color: primary),
        ),
        const SizedBox(width: 9),
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: Color(0xFF25344A),
          ),
        ),
      ],
    );
  }

  Widget _detailSection(
      List<(String, String, IconData)> entries,
      ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 600 ? 3 : 2;
        final width = (constraints.maxWidth - ((columns - 1) * 12)) /
            columns;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: entries.map((entry) {
            return Container(
              width: width,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFAFBFD),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFEDF0F5),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    entry.$3,
                    size: 17,
                    color: const Color(0xFF7A8AA2),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.$1,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF7B8799),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          entry.$2.isEmpty ? '—' : entry.$2,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2B394E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }



  Widget _mobileLayout() {
    return Column(
      children: [
        SizedBox(
          height: 220,
          child: _memberList(),
        ),
        const SizedBox(height: 12),
        Expanded(child: _memberDetails()),
      ],
    );
  }

  Future<void> _confirmClearDeviceId(TeamMember member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear Device ID?'),
        content: Text(
          'Clear the device ID for ${member.name}? '
              'The team member will not be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Clear Device ID'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final success = await controller.clearDeviceId(member);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Device ID cleared successfully'
              : controller.errorMessage.isNotEmpty
              ? controller.errorMessage
              : 'Unable to clear device ID',
        ),
      ),
    );
  }


  void _showMemberForm({TeamMember? member}) {
    final bool isEdit = member != null;
    final formKey = GlobalKey<FormState>();

    final Map<String, TextEditingController> fields = {
      'name': TextEditingController(text: member?.name ?? ''),
      'employee_code': TextEditingController(
        text: member?.employeeCode ?? '',
      ),
      'login_mobile': TextEditingController(
        text: member?.loginMobile ?? '',
      ),
      'mobile': TextEditingController(text: member?.mobile ?? ''),
      'designation': TextEditingController(
        text: member?.designation ?? '',
      ),
      'department': TextEditingController(
        text: member?.department ?? '',
      ),
      'level': TextEditingController(text: member?.level ?? ''),
      'role_id': TextEditingController(text: member?.roleId ?? ''),
      'store_id': TextEditingController(text: member?.storeId ?? ''),
      'rate_type_access': TextEditingController(
        text: member?.rateTypeAccess ?? '',
      ),
      'salary': TextEditingController(text: member?.salary ?? ''),
      'address': TextEditingController(text: member?.address ?? ''),
      'remarks': TextEditingController(text: member?.remarks ?? ''),
    };

    String normalizeStatus(String? value) {
      switch (value?.trim().toLowerCase()) {
        case '1':
        case 'active':
          return '1';
        case '0':
        case 'inactive':
          return '0';
        default:
          return '1';
      }
    }

    String status = normalizeStatus(member?.status);
    String ipLoginStatus = normalizeStatus(member?.ipLoginStatus);
    bool isSaving = false;

    const Color fieldBorder = Color(0xFFBFC6D1);
    const Color fieldFill = Color(0xFFFAFBFC);
    const Color labelColor = Color(0xFF526071);
    const Color textColor = Color(0xFF253247);

    InputDecoration fieldDecoration(
        String label, {
          bool required = false,
          String? hint,
          IconData? icon,
        }) {
      final labelWidget = RichText(
        text: TextSpan(
          text: label,
          style: const TextStyle(
            color: labelColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          children: [
            if (required)
              const TextSpan(
                text: ' *',
                style: TextStyle(
                  color: Color(0xFFD64545),
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      );

      OutlineInputBorder outline(Color color, [double width = 1]) {
        return OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: BorderSide(color: color, width: width),
        );
      }

      return InputDecoration(
        label: labelWidget,
        hintText: hint,
        hintStyle: const TextStyle(
          fontSize: 12,
          color: Color(0xFF9AA4B2),
        ),
        prefixIcon: icon == null
            ? null
            : Icon(
          icon,
          size: 17,
          color: const Color(0xFF7C899B),
        ),
        filled: true,
        fillColor: fieldFill,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        border: outline(fieldBorder),
        enabledBorder: outline(fieldBorder),
        focusedBorder: outline(primary, 1.5),
        errorBorder: outline(const Color(0xFFD64545)),
        focusedErrorBorder: outline(
          const Color(0xFFD64545),
          1.5,
        ),
      );
    }

    Widget textField(
        String key,
        String label, {
          bool required = false,
          TextInputType keyboardType = TextInputType.text,
          int maxLines = 1,
          IconData? icon,
          String? hint,
        }) {
      return TextFormField(
        controller: fields[key],
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(
          fontSize: 13,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
        decoration: fieldDecoration(
          label,
          required: required,
          hint: hint,
          icon: icon,
        ),
        validator: required
            ? (value) {
          if (value == null || value.trim().isEmpty) {
            return '$label is required';
          }
          return null;
        }
            : null,
      );
    }

    Widget dropdownField({
      required String label,
      required String value,
      required List<DropdownMenuItem<String>> items,
      required ValueChanged<String?> onChanged,
      IconData? icon,
    }) {
      return DropdownButtonFormField<String>(
        value: items.any((item) => item.value == value)
            ? value
            : items.first.value,
        isExpanded: true,
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          size: 20,
          color: Color(0xFF718096),
        ),
        style: const TextStyle(
          fontSize: 13,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
        decoration: fieldDecoration(label, icon: icon),
        items: items,
        onChanged: onChanged,
      );
    }

    Widget popupSection(String title, IconData icon) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 9,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F4FA),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: const Color(0xFFE0E6EF),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: primary,
                size: 17,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF344054),
                ),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 20,
              color: Color(0xFF8994A5),
            ),
          ],
        ),
      );
    }

    Widget responsiveRow(
        List<Widget> children,
        ) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final int columns = constraints.maxWidth >= 700
              ? 3
              : constraints.maxWidth >= 420
              ? 2
              : 1;

          final double itemWidth =
              (constraints.maxWidth - (12 * (columns - 1))) /
                  columns;

          return Wrap(
            spacing: 12,
            runSpacing: 14,
            children: children
                .map(
                  (child) => SizedBox(
                width: itemWidth,
                child: child,
              ),
            )
                .toList(),
          );
        },
      );
    }

    Widget sectionContent(
        String title,
        IconData icon,
        List<Widget> children,
        ) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          popupSection(title, icon),
          const SizedBox(height: 14),
          responsiveRow(children),
        ],
      );
    }

    Future<void> saveForm(
        BuildContext dialogContext,
        StateSetter setDialogState,
        ) async {
      if (isSaving) return;

      if (!formKey.currentState!.validate()) {
        return;
      }

      setDialogState(() => isSaving = true);

      // Preserve the existing API payload structure.
      final Map<String, String> payload = {};

      fields.forEach((key, textController) {
        if (key != 'name' &&
            key != 'login_mobile' &&
            key != 'mobile') {
          payload[key] = textController.text.trim();
        }
      });

      payload['mobile'] = fields['mobile']!.text.trim();
      payload['status'] = status;
      payload['ip_login_status'] = ipLoginStatus;

      try {
        await controller.saveMember(
          id: member?.id ?? '',
          name: fields['name']!.text.trim(),
          mobile: fields['login_mobile']!.text.trim(),
          fields: payload,
        );

        if (dialogContext.mounted) {
          Navigator.of(dialogContext).pop();
        }
      } catch (e) {
        if (!dialogContext.mounted) return;

        setDialogState(() => isSaving = false);

        ScaffoldMessenger.of(this.context).showSnackBar(
          SnackBar(
            content: Text('Unable to save team member: $e'),
            backgroundColor: const Color(0xFFD64545),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.white,
              insetPadding: const EdgeInsets.all(20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 980,
                  maxHeight: MediaQuery.sizeOf(context).height * 0.90,
                ),
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.fromLTRB(
                        22,
                        16,
                        18,
                        16,
                      ),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF8FAFD),
                        border: Border(
                          bottom: BorderSide(
                            color: Color(0xFFE5EAF1),
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: primary.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: Icon(
                              isEdit
                                  ? Icons.edit_note_rounded
                                  : Icons.person_add_alt_1_rounded,
                              color: primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 13),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isEdit
                                      ? 'Edit Team Member'
                                      : 'Add Team Member',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF243247),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  isEdit
                                      ? 'Update employee information'
                                      : 'Enter the details to create a team member',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF778397),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Close',
                            onPressed: isSaving
                                ? null
                                : () => Navigator.of(dialogContext).pop(),
                            icon: const Icon(
                              Icons.close_rounded,
                              size: 21,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Scrollable form
                    Expanded(
                      child: Form(
                        key: formKey,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(
                            22,
                            20,
                            22,
                            24,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              sectionContent(
                                'Personal Information',
                                Icons.person_outline_rounded,
                                [
                                  textField(
                                    'name',
                                    'Full Name',
                                    required: true,
                                    icon: Icons.badge_outlined,
                                    hint: 'Enter full name',
                                  ),
                                  textField(
                                    'employee_code',
                                    'Employee Code',
                                    icon: Icons.numbers_rounded,
                                    hint: 'Employee code',
                                  ),
                                  textField(
                                    'designation',
                                    'Designation',
                                    icon: Icons.work_outline_rounded,
                                    hint: 'Job designation',
                                  ),
                                  textField(
                                    'department',
                                    'Department',
                                    icon: Icons.account_tree_outlined,
                                    hint: 'Department name',
                                  ),
                                  textField(
                                    'level',
                                    'Level',
                                    icon: Icons.stairs_rounded,
                                    hint: 'Employee level',
                                  ),
                                  textField(
                                    'address',
                                    'Address',
                                    icon: Icons.location_on_outlined,
                                    hint: 'Enter address',
                                  ),
                                ],
                              ),

                              const SizedBox(height: 24),

                              sectionContent(
                                'Contact Information',
                                Icons.contact_phone_outlined,
                                [
                                  textField(
                                    'login_mobile',
                                    'Login Mobile',
                                    required: true,
                                    keyboardType: TextInputType.phone,
                                    icon: Icons.phone_android_rounded,
                                    hint: 'Mobile used for login',
                                  ),
                                  textField(
                                    'mobile',
                                    'Contact Mobile',
                                    keyboardType: TextInputType.phone,
                                    icon: Icons.call_outlined,
                                    hint: 'Contact number',
                                  ),

                                ],
                              ),

                              const SizedBox(height: 24),

                              sectionContent(
                                'Access & Assignment',
                                Icons.admin_panel_settings_outlined,
                                [
                                  textField(
                                    'role_id',
                                    'Role ID',
                                    keyboardType: TextInputType.number,
                                    icon: Icons.security_outlined,
                                    hint: 'Role ID',
                                  ),
                                  textField(
                                    'store_id',
                                    'Store ID',
                                    keyboardType: TextInputType.number,
                                    icon: Icons.store_outlined,
                                    hint: 'Store ID',
                                  ),
                                  textField(
                                    'rate_type_access',
                                    'Rate Type Access',
                                    icon: Icons.price_change_outlined,
                                    hint: 'Rate access',
                                  ),
                                  dropdownField(
                                    label: 'Status',
                                    value: status,
                                    icon: Icons.toggle_on_outlined,
                                    items: const [
                                      DropdownMenuItem(
                                        value: '1',
                                        child: Text('Active'),
                                      ),
                                      DropdownMenuItem(
                                        value: '0',
                                        child: Text('Inactive'),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      if (value != null) {
                                        setDialogState(() {
                                          status = value;
                                        });
                                      }
                                    },
                                  ),
                                  dropdownField(
                                    label: 'IP Login Access',
                                    value: ipLoginStatus,
                                    icon: Icons.wifi_tethering_rounded,
                                    items: const [
                                      DropdownMenuItem(
                                        value: '1',
                                        child: Text('Enabled'),
                                      ),
                                      DropdownMenuItem(
                                        value: '0',
                                        child: Text('Disabled'),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      if (value != null) {
                                        setDialogState(() {
                                          ipLoginStatus = value;
                                        });
                                      }
                                    },
                                  ),
                                ],
                              ),

                              const SizedBox(height: 24),

                              sectionContent(
                                'Salary Information',
                                Icons.payments_outlined,
                                [
                                  textField(
                                    'salary',
                                    'Salary',
                                    keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                    icon: Icons.currency_rupee_rounded,
                                    hint: 'Enter salary',
                                  ),
                                  textField(
                                    'remarks',
                                    'Remarks',
                                    icon: Icons.notes_rounded,
                                    hint: 'Additional notes',
                                  ),
                                ],

                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Fixed footer
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 14,
                      ),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFAFBFD),
                        border: Border(
                          top: BorderSide(
                            color: Color(0xFFE5EAF1),
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              '* Required fields',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF8A94A5),
                              ),
                            ),
                          ),
                          OutlinedButton(
                            onPressed: isSaving
                                ? null
                                : () => Navigator.of(dialogContext).pop(),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF526071),
                              side: const BorderSide(color: fieldBorder),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(9),
                              ),
                            ),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton.icon(
                            onPressed: isSaving
                                ? null
                                : () => saveForm(
                              dialogContext,
                              setDialogState,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor:
                              primary.withValues(alpha: 0.65),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 22,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(9),
                              ),
                            ),
                            icon: isSaving
                                ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                                : Icon(
                              isEdit
                                  ? Icons.save_outlined
                                  : Icons.person_add_alt_1_rounded,
                              size: 17,
                            ),
                            label: Text(
                              isSaving
                                  ? 'Saving...'
                                  : isEdit
                                  ? 'Update Member'
                                  : 'Save Member',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      for (final textController in fields.values) {
        textController.dispose();
      }
    });
  }





}
