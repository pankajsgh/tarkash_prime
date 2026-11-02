
import 'package:flutter/material.dart';

import '../../../core/routes/routes.dart';
import '../../../core/vars/global_vars.dart';
import '../controller/account_group_controller.dart';
import '../model/account_group_model.dart';

class CreateAccountGroupScreen extends StatefulWidget {
  const CreateAccountGroupScreen({super.key});

  @override
  State<CreateAccountGroupScreen> createState() =>
      _CreateAccountGroupScreenState();
}

class _CreateAccountGroupScreenState
    extends State<CreateAccountGroupScreen> {
  late final AccountGroupController controller;

  static const Color primaryColor = Color(0xFF3267D5);
  static const Color textColor = Color(0xFF263449);
  static const Color mutedColor = Color(0xFF78869A);
  static const Color borderColor = Color(0xFFDCE4EE);
  static const Color backgroundColor = Color(0xFFF4F6FA);
  static const Color lightBlue = Color(0xFFEAF1FF);
  static const Color dividerColor = Color(0xFFEDF1F6);
  static const Color greenColor = Color(0xFF16845B);
  static const Color redColor = Color(0xFFE05252);

  @override
  void initState() {
    super.initState();
    GlobalVars.globalRoutes = Routes.accountGroupScreen;
    controller = AccountGroupController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: controller,
          builder: (context, child) {
            return Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final groups = controller.filteredAccountGroups;
                        final selected = controller.selectedAccountGroup;

                        if (constraints.maxWidth >= 680) {
                          final leftWidth =
                          constraints.maxWidth < 900 ? 320.0 : 390.0;

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(
                                width: leftWidth,
                                child: _buildLeftList(groups),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildDetailsPanel(selected),
                              ),
                            ],
                          );
                        }

                        return Column(
                          children: [
                            SizedBox(
                              height: 265,
                              child: _buildLeftList(groups),
                            ),
                            const SizedBox(height: 12),
                            Expanded(
                              child: _buildDetailsPanel(selected),
                            ),
                          ],
                        );
                      },
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 10, 12, 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: borderColor),
        ),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.maybePop(context),
            borderRadius: BorderRadius.circular(20),
            child: const Padding(
              padding: EdgeInsets.all(5),
              child: Icon(
                Icons.arrow_back,
                color: textColor,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 9),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Account Groups',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Manage and view account group records',
                  style: TextStyle(
                    fontSize: 10,
                    color: mutedColor,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Refresh',
            onPressed:
            controller.isLoading ? null : controller.loadAccountGroups,
            icon: const Icon(
              Icons.refresh,
              size: 19,
              color: primaryColor,
            ),
          ),
          const SizedBox(width: 4),
          ElevatedButton.icon(
            onPressed: controller.isSaving
                ? null
                : () => _openAccountGroupDialog(),
            icon: const Icon(Icons.add, size: 15),
            label: const Text('Create'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 11,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              textStyle: const TextStyle(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // LEFT PANEL
  // ------------------------------------------------------------

  Widget _buildLeftList(List<AccountGroup> groups) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(7),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 11, 12, 9),
            child: Row(
              children: [
                const Icon(
                  Icons.account_tree_outlined,
                  size: 17,
                  color: primaryColor,
                ),
                const SizedBox(width: 7),
                const Expanded(
                  child: Text(
                    'Account Groups',
                    style: TextStyle(
                      fontSize: 13,
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _countBadge(groups.length),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
            child: TextField(
              onChanged: controller.setSearchQuery,
              style: const TextStyle(
                fontSize: 12,
                color: textColor,
              ),
              decoration: InputDecoration(
                hintText: 'Search groups...',
                hintStyle: const TextStyle(
                  fontSize: 11,
                  color: mutedColor,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  size: 17,
                  color: mutedColor,
                ),
                suffixIcon: controller.searchQuery.isEmpty
                    ? null
                    : IconButton(
                  onPressed: () => controller.setSearchQuery(''),
                  icon: const Icon(Icons.close, size: 15),
                ),
                isDense: true,
                filled: true,
                fillColor: backgroundColor,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: const BorderSide(color: borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: const BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: const BorderSide(color: primaryColor),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 9),
            child: DropdownButtonFormField<String>(
              initialValue: controller.statusFilter,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Filter status',
                labelStyle: const TextStyle(fontSize: 10),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: const BorderSide(color: borderColor),
                ),
              ),
              style: const TextStyle(
                fontSize: 11,
                color: textColor,
              ),
              items: const [
                DropdownMenuItem(value: 'All', child: Text('All')),
                DropdownMenuItem(value: 'Active', child: Text('Active')),
                DropdownMenuItem(
                  value: 'Inactive',
                  child: Text('Inactive'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  controller.setStatusFilter(value);
                }
              },
            ),
          ),
          const Divider(height: 1, color: borderColor),
          Expanded(child: _buildGroupList(groups)),
          const Divider(height: 1, color: borderColor),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 11,
              vertical: 9,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.storage_outlined,
                  size: 14,
                  color: mutedColor,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${controller.totalGroups} total records',
                    style: const TextStyle(
                      fontSize: 10,
                      color: mutedColor,
                    ),
                  ),
                ),
                Text(
                  '${controller.activeGroups} active',
                  style: const TextStyle(
                    fontSize: 10,
                    color: greenColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupList(List<AccountGroup> groups) {
    if (controller.isLoading && controller.accountGroups.isEmpty) {
      return const Center(
        child: SizedBox(
          width: 25,
          height: 25,
          child: CircularProgressIndicator(
            strokeWidth: 2.2,
            color: primaryColor,
          ),
        ),
      );
    }

    if (controller.errorMessage != null &&
        controller.accountGroups.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_outlined,
                size: 29,
                color: redColor,
              ),
              const SizedBox(height: 8),
              Text(
                controller.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: controller.loadAccountGroups,
                icon: const Icon(Icons.refresh, size: 15),
                label: const Text(
                  'Retry',
                  style: TextStyle(fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (groups.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.search_off,
                size: 29,
                color: Color(0xFFB4C1D1),
              ),
              const SizedBox(height: 7),
              const Text(
                'No groups found',
                style: TextStyle(
                  fontSize: 12,
                  color: textColor,
                ),
              ),
              if (controller.searchQuery.isNotEmpty)
                TextButton(
                  onPressed: () => controller.setSearchQuery(''),
                  child: const Text(
                    'Clear search',
                    style: TextStyle(fontSize: 11),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 4),
          itemCount: groups.length,
          separatorBuilder: (_, __) => const Divider(
            height: 1,
            indent: 12,
            endIndent: 12,
            color: dividerColor,
          ),
          itemBuilder: (context, index) {
            final group = groups[index];
            final selected =
                controller.selectedAccountGroup?.id == group.id;

            return Material(
              color: selected ? lightBlue : Colors.white,
              child: InkWell(
                onTap: () => controller.selectAccountGroup(group),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: selected
                            ? primaryColor
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: selected ? primaryColor : backgroundColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.account_tree_outlined,
                          size: 17,
                          color: selected ? Colors.white : mutedColor,
                        ),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              group.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                color: textColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              group.parent.isEmpty
                                  ? 'No parent'
                                  : group.parent,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: mutedColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 5),
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: group.isActive
                              ? const Color(0xFF20A46B)
                              : const Color(0xFF9AA5B5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        if (controller.isLoading)
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(
              minHeight: 2,
              color: primaryColor,
            ),
          ),
      ],
    );
  }

  // ------------------------------------------------------------
  // RIGHT DETAILS PANEL
  // ------------------------------------------------------------

  Widget _buildDetailsPanel(AccountGroup? group) {
    if (group == null) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.touch_app_outlined,
                  size: 38,
                  color: Color(0xFFB4C1D1),
                ),
                const SizedBox(height: 10),
                Text(
                  controller.isLoading
                      ? 'Loading account groups...'
                      : 'Select an account group',
                  style: const TextStyle(
                    fontSize: 14,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Choose a record from the left panel to view its details.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: mutedColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(7),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(13),
            color: const Color(0xFFF0F4F9),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0EBFF),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: const Icon(
                    Icons.account_tree_outlined,
                    color: primaryColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Account Group ID: ${group.id}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: mutedColor,
                        ),
                      ),
                    ],
                  ),
                ),
                _statusBadge(group.isActive),
                IconButton(
                  tooltip: 'Edit',

                  onPressed: controller.isSaving || controller.isDeleting
                      ? null
                      : () => _openAccountGroupDialog(group: group),
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 19,
                    color: primaryColor,
                  ),
                ),
                IconButton(
                  tooltip: 'Delete',
                  onPressed: controller.isDeleting || controller.isSaving
                      ? null
                      : () => _confirmDelete(group),
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 19,
                    color: redColor,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(17),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ACCOUNT GROUP DETAILS',
                    style: TextStyle(
                      fontSize: 12,
                      color: mutedColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _detailRow('Account Group Name', group.name),
                  _detailRow('Group ID', group.id.toString()),
                  _detailRow(
                    'Under / Parent Group',
                    group.parent.isEmpty ? 'No parent' : group.parent,
                  ),
                  _detailRow(
                    'Parent Group ID',
                    group.parentGroupId.isEmpty
                        ? '-'
                        : group.parentGroupId,
                  ),
                  _detailRow(
                    'Is Parent Group',
                    group.isParent ? 'Yes' : 'No',
                  ),
                  _detailRow(
                    'Status',
                    group.isActive ? 'Active' : 'Inactive',
                  ),
                  _detailRow(
                    'Description',
                    group.description.isEmpty ? '-' : group.description,
                  ),
                  _detailRow(
                    'Notes',
                    group.notes.isEmpty ? '-' : group.notes,
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      border: Border.all(color: borderColor),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          group.isActive
                              ? Icons.check_circle_outline
                              : Icons.pause_circle_outline,
                          size: 18,
                          color: group.isActive ? greenColor : mutedColor,
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            group.isActive
                                ? 'This account group is active.'
                                : 'This account group is inactive.',
                            style: const TextStyle(
                              fontSize: 11,
                              color: textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: borderColor),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _openAccountGroupDialog(group: group),
                  icon: const Icon(Icons.edit_outlined, size: 15),
                  label: const Text('Edit Details', style: TextStyle(fontWeight: FontWeight.w600),),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryColor,
                    side: const BorderSide(color: borderColor),
                    textStyle: const TextStyle(fontSize: 11),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: controller.isDeleting
                      ? null
                      : () => _confirmDelete(group),
                  icon: const Icon(Icons.delete_outline, size: 15),
                  label: const Text('Delete', style: TextStyle(fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: redColor,
                    side: const BorderSide(color: Color(0xFFF0CDCD)),
                    textStyle: const TextStyle(fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: dividerColor),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 155,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: mutedColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _countBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: lightBlue,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        count.toString(),
        style: const TextStyle(
          fontSize: 11,
          color: primaryColor,
        ),
      ),
    );
  }

  Widget _statusBadge(bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: active
            ? const Color(0xFFE5F7EF)
            : const Color(0xFFEDF0F4),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        active ? 'Active' : 'Inactive',
        style: TextStyle(
          fontSize: 10,
          color: active ? greenColor : mutedColor,
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // CREATE / EDIT DIALOG
  // ------------------------------------------------------------

  Future<void> _openAccountGroupDialog({
    AccountGroup? group,
  }) async {
    if (group == null) {
      controller.resetAccountGroup();
    } else {
      controller.loadForEdit(group);
    }

    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListenableBuilder(
              listenable: controller,
              builder: (context, child) {
                return Form(
                  key: controller.formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: lightBlue,
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: const Icon(
                                Icons.account_tree_outlined,
                                size: 20,
                                color: primaryColor,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    group == null
                                        ? 'Create Account Group'
                                        : 'Edit Account Group',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  const Text(
                                    'Enter account group details',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: mutedColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: controller.isSaving
                                  ? null
                                  : () => Navigator.pop(dialogContext, false),
                              icon: const Icon(Icons.close, size: 19),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        _fieldLabel('Account Group Name *'),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: controller.accountGroupNameController,
                          autofocus: true,
                          style: const TextStyle(
                            fontSize: 12,
                            color: textColor,
                          ),
                          decoration: _inputDecoration(
                            'Enter account group name',
                            Icons.groups_outlined,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Account group name is required';
                            }

                            return controller.duplicateNameError;
                          },
                        ),

                        const SizedBox(height: 14),

                        _fieldLabel('Parent Account Group'),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: controller.parentAccountGroup,
                          isExpanded: true,
                          style: const TextStyle(
                            fontSize: 12,
                            color: textColor,
                          ),
                          decoration: _inputDecoration(
                            'Select parent group (optional)',
                            Icons.folder_outlined,
                          ),
                          items: [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text('No parent'),
                            ),
                            ...controller.accountGroups
                                .where(
                                  (item) =>
                              item.id != controller.editingId,
                            )
                                .map(
                                  (item) => DropdownMenuItem<String>(
                                value: item.id.toString(),
                                child: Text(
                                  item.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                          onChanged: controller.isParent
                              ? null
                              : controller.setParentAccountGroup,
                        ),

                        const SizedBox(height: 14),

                        _switchRow(
                          title: 'Is Parent Group',
                          value: controller.isParent,
                          onChanged: controller.setIsParent,
                        ),

                        const SizedBox(height: 12),

                        _fieldLabel('Description'),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: controller.descriptionController,
                          maxLines: 3,
                          maxLength: 500,
                          style: const TextStyle(
                            fontSize: 12,
                            color: textColor,
                          ),
                          decoration: _inputDecoration(
                            'Enter description',
                            Icons.description_outlined,
                          ).copyWith(counterText: ''),
                        ),

                        const SizedBox(height: 12),

                        _fieldLabel('Notes'),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: controller.notesController,
                          maxLines: 2,
                          maxLength: 500,
                          style: const TextStyle(
                            fontSize: 12,
                            color: textColor,
                          ),
                          decoration: _inputDecoration(
                            'Enter additional notes',
                            Icons.notes_outlined,
                          ).copyWith(counterText: ''),
                        ),

                        const SizedBox(height: 12),

                        _switchRow(
                          title: 'Account Group Status',
                          value: controller.isActive,
                          activeText: 'Active',
                          inactiveText: 'Inactive',
                          onChanged: controller.setActive,
                        ),

                        if (controller.errorMessage != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF0F0),
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                color: const Color(0xFFF3CCCC),
                              ),
                            ),
                            child: Text(
                              controller.errorMessage!,
                              style: const TextStyle(
                                fontSize: 11,
                                color: redColor,
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 20),

                        Row(
                          children: [
                            OutlinedButton(
                              onPressed: controller.isSaving
                                  ? null
                                  : controller.resetAccountGroup,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: textColor,
                                side: const BorderSide(color: borderColor),
                              ),
                              child: const Text(
                                'Reset',
                                style: TextStyle(fontSize: 11),
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: controller.isSaving
                                  ? null
                                  : () => Navigator.pop(dialogContext, false),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(fontSize: 11),
                              ),
                            ),
                            const SizedBox(width: 7),
                            ElevatedButton.icon(
                              onPressed: controller.isSaving
                                  ? null
                                  : () => _saveAccountGroup(dialogContext),
                              icon: controller.isSaving
                                  ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                                  : Icon(
                                group == null
                                    ? Icons.add
                                    : Icons.edit_outlined,
                                size: 15,
                              ),
                              label: Text(
                                controller.isSaving
                                    ? (group == null ? 'Adding...' : 'Updating...')
                                    : (group == null ? 'Add' : 'Update'),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                textStyle: const TextStyle(fontSize: 11),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );

    if (!mounted || saved != true) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            group == null
                ? 'Account group created successfully.'
                : 'Account group updated successfully.',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  Future<void> _saveAccountGroup(BuildContext dialogContext) async {
    if (controller.isSaving) return;

    if (!controller.validateForm()) return;

    final duplicateError = controller.duplicateNameError;

    if (duplicateError != null) {
      ScaffoldMessenger.of(dialogContext).showSnackBar(
        SnackBar(content: Text(duplicateError)),
      );
      return;
    }

    final isUpdate = controller.editingId != null;

    final success = await controller.saveAccountGroup();

    if (!mounted || !dialogContext.mounted) return;

    if (success) {
      Navigator.pop(dialogContext, true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isUpdate
                ? 'Account group updated successfully.'
                : 'Account group added successfully.',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(dialogContext).showSnackBar(
        SnackBar(
          content: Text(
            controller.errorMessage ??
                (isUpdate
                    ? 'Unable to update account group.'
                    : 'Unable to add account group.'),
          ),
        ),
      );
    }
  }
  // ------------------------------------------------------------
  // DELETE
  // ------------------------------------------------------------

  Future<void> _confirmDelete(AccountGroup group) async {
    if (controller.isDeleting || controller.isSaving) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Delete Account Group',
            style: TextStyle(fontSize: 16),
          ),
          content: Text(
            'Are you sure you want to delete "${group.name}"?\n\n'
                'This action cannot be undone.',
            style: const TextStyle(fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(dialogContext, true),
              icon: const Icon(Icons.delete_outline, size: 16),
              label: const Text('Delete'),
              style: ElevatedButton.styleFrom(
                backgroundColor: redColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    final success = await controller.deleteAccountGroup(group.id);

    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Account group deleted successfully.'
                : controller.errorMessage ?? 'Unable to delete account group.',
          ),
        ),
      );
  }

  // ------------------------------------------------------------
  // FORM HELPERS
  // ------------------------------------------------------------

  Widget _fieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 11,
        color: textColor,
      ),
    );
  }

  Widget _switchRow({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    String activeText = 'Yes',
    String inactiveText = 'No',
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: textColor,
              ),
            ),
          ),
          Text(
            value ? activeText : inactiveText,
            style: TextStyle(
              fontSize: 11,
              color: value ? greenColor : mutedColor,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: primaryColor,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontSize: 11,
        color: Color(0xFF8A99AE),
      ),
      prefixIcon: Icon(
        icon,
        size: 16,
        color: mutedColor,
      ),
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 12,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: const BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: const BorderSide(color: primaryColor),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: const BorderSide(color: redColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: const BorderSide(color: redColor),
      ),
    );
  }
}
