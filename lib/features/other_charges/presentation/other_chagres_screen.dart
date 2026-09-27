import 'dart:async';

import 'package:flutter/material.dart';

import '../../components/custome_dropdown_widget.dart';
import '../data/model/other_charge_model.dart';
import '../data/other_chagres_controller.dart';

class CreateOtherChargeScreen extends StatefulWidget {
  final OtherChargeModel? chargeData;

  const CreateOtherChargeScreen({
    super.key,
    this.chargeData,
  });

  @override
  State<CreateOtherChargeScreen> createState() =>
      _CreateOtherChargeScreenState();
}

class _CreateOtherChargeScreenState
    extends State<CreateOtherChargeScreen> {
  late final OtherChargeController controller;

  Timer? _searchDebounce;

  // =========================================================================
  // COLORS
  // =========================================================================

  static const Color primary = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFFEFF6FF);

  static const Color dark = Color(0xFF172033);
  static const Color text = Color(0xFF344054);
  static const Color muted = Color(0xFF667085);

  static const Color border = Color(0xFFD9E0EA);
  static const Color borderLight = Color(0xFFE9EDF3);

  static const Color background = Color(0xFFF4F6F9);
  static const Color white = Colors.white;

  static const Color green = Color(0xFF16A05D);
  static const Color red = Color(0xFFD92D20);

  // =========================================================================
  // INIT
  // =========================================================================

  @override
  void initState() {
    super.initState();

    controller = OtherChargeController();

    controller.chargeNameController.addListener(_refresh);
    controller.printNameController.addListener(_refresh);
    controller.defaultValueController.addListener(_refresh);

    if (widget.chargeData != null) {
      controller.setChargeName(widget.chargeData);
    }
  }

  void _refresh() {
    if (!mounted) return;

    controller.notifyListeners();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();

    controller.chargeNameController.removeListener(_refresh);
    controller.printNameController.removeListener(_refresh);
    controller.defaultValueController.removeListener(_refresh);

    controller.dispose();

    super.dispose();
  }

  // =========================================================================
  // BUILD
  // =========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            return Column(
              children: [
                _buildTopBar(),

                Expanded(
                  child: _buildDesktopBody(),
                ),

                _buildBottomBar(),
              ],
            );
          },
        ),
      ),
    );
  }

  // =========================================================================
  // DESKTOP BODY
  // =========================================================================

  Widget _buildDesktopBody() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            24,
            20,
            24,
            24,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 1500,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  _buildBasicInformation(),

                  const SizedBox(height: 14),

                  _buildCalculationArea(),

                  const SizedBox(height: 14),

                  _buildAppliedOn(),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // =========================================================================
  // TOP BAR
  // =========================================================================

  Widget _buildTopBar() {
    final bool editMode = widget.chargeData != null;

    return Container(
      height: 62,
      decoration: const BoxDecoration(
        color: white,
        border: Border(
          bottom: BorderSide(
            color: borderLight,
          ),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 18),

          _topIconButton(
            icon: Icons.arrow_back_rounded,
            onTap: () {
              Navigator.pop(context);
            },
          ),

          const SizedBox(width: 14),

          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: primaryLight,
              borderRadius: BorderRadius.circular(7),
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              color: primary,
              size: 18,
            ),
          ),

          const SizedBox(width: 10),

          Text(
            editMode
                ? 'Edit Other Charge'
                : 'Create Other Charge',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: dark,
            ),
          ),

          const SizedBox(width: 12),

          Container(
            width: 1,
            height: 22,
            color: borderLight,
          ),

          const SizedBox(width: 12),

          Text(
            editMode
                ? 'Modify existing charge configuration'
                : 'Create and configure a new charge',
            style: const TextStyle(
              fontSize: 10.5,
              color: muted,
            ),
          ),

          const Spacer(),

          if (editMode)
            Container(
              height: 28,
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
              ),
              decoration: BoxDecoration(
                color: primaryLight,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: const Color(0xFFD6E5FA),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.edit_outlined,
                    size: 12,
                    color: primary,
                  ),
                  SizedBox(width: 5),
                  Text(
                    'EDIT MODE',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: primary,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(width: 20),
        ],
      ),
    );
  }

  Widget _topIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
              color: border,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 17,
            color: dark,
          ),
        ),
      ),
    );
  }


  // =========================================================================
  // BASIC INFORMATION
  // =========================================================================

  Widget _buildBasicInformation() {
    return _sectionCard(
      icon: Icons.info_outline_rounded,
      title: 'Basic Information',
      subtitle: 'Define the identity and basic behaviour of the charge.',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double width = constraints.maxWidth;

          if (width >= 1100) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: _buildChargeNameField(),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildChargeTypeField(),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildChargeNatureField(),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildTextField(
                    label: 'Print Name',
                    hint: 'Enter print name',
                    controller:
                    controller.printNameController,
                  ),
                ),
                const SizedBox(width: 14),
                SizedBox(
                  width: 210,
                  child: _buildSettingTile(
                    title: 'Status',
                    value: controller.isActive,
                    onChanged: controller.setStatus,
                  ),
                ),
              ],
            );
          }

          if (width >= 700) {
            return Wrap(
              spacing: 14,
              runSpacing: 16,
              children: [
                _desktopField(
                  width,
                  _buildChargeNameField(),
                ),
                _desktopField(
                  width,
                  _buildChargeTypeField(),
                ),
                _desktopField(
                  width,
                  _buildChargeNatureField(),
                ),
                _desktopField(
                  width,
                  _buildTextField(
                    label: 'Print Name',
                    hint: 'Enter print name',
                    controller:
                    controller.printNameController,
                  ),
                ),
                _desktopField(
                  width,
                  _buildSettingTile(
                    title: 'Status',
                    value: controller.isActive,
                    onChanged: controller.setStatus,
                  ),
                ),
              ],
            );
          }

          return Column(
            children: [
              _buildChargeNameField(),
              const SizedBox(height: 14),
              _buildChargeTypeField(),
              const SizedBox(height: 14),
              _buildChargeNatureField(),
              const SizedBox(height: 14),
              _buildTextField(
                label: 'Print Name',
                hint: 'Enter print name',
                controller:
                controller.printNameController,
              ),
              const SizedBox(height: 14),
              _buildSettingTile(
                title: 'Status',
                value: controller.isActive,
                onChanged: controller.setStatus,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _desktopField(
      double totalWidth,
      Widget child,
      ) {
    final double fieldWidth =
    totalWidth >= 1000
        ? (totalWidth - 14) / 2
        : totalWidth;

    return SizedBox(
      width: fieldWidth,
      child: child,
    );
  }

  Widget _buildChargeNameField() {
    return _fieldWrapper(
      label: 'Charge Name',
      required: true,
      child: _chargesName(),
    );
  }

  Widget _buildChargeTypeField() {
    return _fieldWrapper(
      label: 'Charge Type',
      required: true,
      child: _chargesTypeField(),
    );
  }

  Widget _buildChargeNatureField() {
    return _fieldWrapper(
      label: 'Charge Nature',
      required: true,
      child: _buildSegmentedOptions(
        options: const [
          'Additional (+)',
          'Deduction (-)',
        ],
        selected:
        controller.chargeNature == 'Additional'
            ? 'Additional (+)'
            : 'Deduction (-)',
        onChanged: (value) {
          controller.setChargeNature(
            value == 'Additional (+)'
                ? 'Additional'
                : 'Deduction',
          );
        },
      ),
    );
  }

  // =========================================================================
  // CHARGE NAME
  // =========================================================================

  Widget _chargesName() {
    return ListenableBuilder(
      listenable: controller.updateCharges,
      builder: (context, _) {
        return SizedBox(
          height: 38,
          child: SearchableCustomerDropdown<
              OtherChargeModel>(
            value: controller.selectedCharge,
            height: 38,
            borderColor: border,
            borderRadius: 6,
            dataFound: controller.chargeNameController.text.length>3? true: false,
            items: controller.allCharges,
            onSearch: (value) {
              controller.chargeNameController.text = value;
              controller.printNameController.text = value;

              _searchDebounce?.cancel();

              _searchDebounce = Timer(
                const Duration(milliseconds: 500),
                    () async {
                  await controller.loadOtherCharges(value);
                },
              );
            },
            displayString: (item) {
              return item.chargeName ?? '';
            },
            onSelect: (OtherChargeModel? value) {
              controller.setChargeName(value);
            },
          ),
        );
      },
    );
  }

  // =========================================================================
  // CHARGE TYPE
  // =========================================================================

  Widget _chargesTypeField() {
    return SizedBox(
      height: 38,
      child: SearchableCustomerDropdown<String>(
        value: controller.chargeType,
        height: 38,
        borderColor: border,
        borderRadius: 6,
        items: controller.chargeTypes
            .where(
              (e) => e != 'Select Charge Type',
        )
            .toList(),
        onSearch: (_) {},
        displayString: (item) {
          return item ?? '';
        },
        onSelect: (value) {
          controller.setChargeType(value);
        },
      ),
    );
  }

  // =========================================================================
  // CALCULATION AREA
  // =========================================================================

  Widget _buildCalculationArea() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool wide =
            constraints.maxWidth >= 900;

        if (wide) {
          return Row(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildDefaultValueSection(),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildCalculationSection(),
              ),
            ],
          );
        }

        return Column(
          children: [
            _buildDefaultValueSection(),
            const SizedBox(height: 14),
            _buildCalculationSection(),
          ],
        );
      },
    );
  }

  // =========================================================================
  // DEFAULT VALUE
  // =========================================================================

  Widget _buildDefaultValueSection() {
    return _sectionCard(
      icon: Icons.payments_outlined,
      title: 'Default Value',
      subtitle: 'Set the initial value used for this charge.',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool wide =
              constraints.maxWidth >= 600;

          if (!wide) {
            return Column(
              children: [
                _buildTextField(
                  label: 'Default Value',
                  hint: '0.00',
                  controller:
                  controller.defaultValueController,
                  keyboardType:
                  const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                const SizedBox(height: 12),
                _buildSettingTile(
                  title: 'Manual Change',
                  value:
                  controller.allowManualChange,
                  onChanged:
                  controller.setAllowManualChange,
                ),
              ],
            );
          }

          return Row(
            crossAxisAlignment:
            CrossAxisAlignment.end,
            children: [
              Expanded(
                child: _buildTextField(
                  label: 'Default Value',
                  hint: '0.00',
                  controller:
                  controller.defaultValueController,
                  keyboardType:
                  const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildValueUnit(),
              const SizedBox(width: 12),
              SizedBox(
                width: 220,
                child: _buildSettingTile(
                  title: 'Manual Change',
                  value:
                  controller.allowManualChange,
                  onChanged:
                  controller.setAllowManualChange,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildValueUnit() {
    final bool percentage =
        controller.calculationType ==
            'Percentage (%)';

    return Container(
      height: 38,
      constraints: const BoxConstraints(
        minWidth: 44,
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        border: Border.all(
          color: border,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        percentage ? '%' : '₹',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: muted,
        ),
      ),
    );
  }

  // =========================================================================
  // CALCULATION
  // =========================================================================

  Widget _buildCalculationSection() {
    return _sectionCard(
      icon: Icons.calculate_outlined,
      title: 'Charge Calculation',
      subtitle:
      'Select how the charge amount should be calculated.',
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 6),

          _buildCalculationOptions(),

          const SizedBox(height: 12),
          
        ],
      ),
    );
  }

  Widget _buildCalculationOptions() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildOptionChip(
          title: 'Amount',
          icon: Icons.currency_rupee,
          selected:
          controller.calculationType ==
              'Amount',
          onTap: () {
            controller.setCalculationType(
              'Amount',
            );
          },
        ),
        _buildOptionChip(
          title: 'Per Main Qty',
          icon: Icons.inventory_2_outlined,
          selected:
          controller.calculationType ==
              'Per Main Qty',
          onTap: () {
            controller.setCalculationType(
              'Per Main Qty',
            );
          },
        ),
        _buildOptionChip(
          title: 'Percentage',
          icon: Icons.percent,
          selected:
          controller.calculationType ==
              'Percentage (%)',
          onTap: () {
            controller.setCalculationType(
              'Percentage (%)',
            );
          },
        ),
      ],
    );
  }

  Widget _buildOptionChip({
    required String title,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(
            milliseconds: 140,
          ),
          height: 38,
          padding: const EdgeInsets.symmetric(
            horizontal: 11,
          ),
          decoration: BoxDecoration(
            color: selected
                ? primaryLight
                : white,
            borderRadius:
            BorderRadius.circular(6),
            border: Border.all(
              color: selected
                  ? const Color(0xFF8BB5EE)
                  : border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color:
                selected ? primary : muted,
              ),
              const SizedBox(width: 7),
              Text(
                title,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: selected
                      ? FontWeight.w700
                      : FontWeight.w500,
                  color:
                  selected ? primary : text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // APPLIED ON
  // =========================================================================

  Widget _buildAppliedOn() {
    return _sectionCard(
      icon: Icons.layers_outlined,
      title: 'Applied On',
      subtitle:
      'Choose where this charge should be applied.',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool wide =
              constraints.maxWidth >= 1050;

          final cards = <Widget>[
            _buildAppliedCard(
              icon: Icons.inventory_2_outlined,
              title: 'Item Wise',
              description:
              'Distribute the charge across invoice items.',
              value: 'Item Wise',
              child: _buildDistributionMethod(controller.appliedOn == 'Item Wise'),
            ),
            _buildAppliedCard(
              icon: Icons.receipt_long_outlined,
              title: 'Final Bill',
              description:
              'Calculate the charge on the final bill.',
              value: 'Final Bill',
              child: _buildInfoMessage(
                icon: Icons.receipt_long_outlined,
                message:
                'The charge will be calculated on the final bill amount.',
              ),
            ),
          ];

          if (controller.chargeNature !=
              'Deduction') {
            cards.add(
              _buildAppliedCard(
                icon: Icons.add_chart_outlined,
                title: 'Separate Line',
                description:
                'Show the charge as a separate invoice line.',
                value: 'Separate',
                child: _buildSeparateFields(),
              ),
            );
          }

          if (wide) {
            return Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                for (int i = 0;
                i < cards.length;
                i++) ...[
                  if (i > 0)
                    const SizedBox(width: 12),
                  Expanded(
                    child: cards[i],
                  ),
                ],
              ],
            );
          }

          return Column(
            children: [
              for (int i = 0;
              i < cards.length;
              i++) ...[
                if (i > 0)
                  const SizedBox(height: 12),
                cards[i],
              ],
            ],
          );
        },
      ),
    );
  }

  // =========================================================================
  // APPLIED CARD
  // =========================================================================

  Widget _buildAppliedCard({
    required IconData icon,
    required String title,
    required String description,
    required String value,
    required Widget child,
  }) {
    final bool selected =
        controller.appliedOn == value;

    return AnimatedContainer(
      duration: const Duration(
        milliseconds: 150,
      ),
      decoration: BoxDecoration(
        color: selected
            ? const Color(0xFFF8FBFF)
            : white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: selected
              ? const Color(0xFF8BB5EE)
              : border,
          width: selected ? 1.2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          controller.setAppliedOn(value);
        },
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildSmallRadio(selected),

                  const SizedBox(width: 9),

                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: selected
                          ? primaryLight
                          : const Color(0xFFF5F6F8),
                      borderRadius:
                      BorderRadius.circular(7),
                    ),
                    child: Icon(
                      icon,
                      size: 16,
                      color: selected
                          ? primary
                          : muted,
                    ),
                  ),

                  const SizedBox(width: 9),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight:
                            FontWeight.w700,
                            color: selected
                                ? dark
                                : text,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          description,
                          maxLines: 1,
                          overflow:
                          TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 8.5,
                            color: muted,
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (selected)
                    const Icon(
                      Icons.check_circle,
                      size: 17,
                      color: primary,
                    ),
                ],
              ),

              const SizedBox(height: 12),

              child,
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // DISTRIBUTION
  // =========================================================================

  Widget _buildDistributionMethod(bool selected) {
    return Container(
      width: double.infinity,
      height: 52,
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F7FF),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: const Color(0xFFD9E6F8),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.account_tree_outlined,
            size: 15,
            color: selected? primary:Colors.grey,
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Column(
              mainAxisAlignment:
              MainAxisAlignment.center,
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'Distribution Method',
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w600,
                    color: muted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  controller.distributionMethod,
                  style:  TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: selected? primary:Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          Icon(
            Icons.check_circle_outline,
            size: 16,
            color: selected? primary: Colors.grey,
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // SEPARATE LINE
  // =========================================================================

  Widget _buildSeparateFields() {
    final bool enabled =
        controller.appliedOn == 'Separate';

    return AnimatedOpacity(
      duration: const Duration(
        milliseconds: 150,
      ),
      opacity: enabled ? 1 : .45,
      child: IgnorePointer(
        ignoring: !enabled,
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            _fieldWrapper(
              label: 'HSN',
              required: true,
              child: _buildDropdown(
                label: '',
                value: controller.hsn,
                items: controller.hsnList.keys
                    .where(
                      (e) => e != 'Select HSN',
                )
                    .toList(),
                hint: 'Select HSN',
                onChanged: controller.setHSN,
              ),
            ),

            const SizedBox(height: 10),

            _fieldWrapper(
              label: 'Tax Rate',
              child: Container(
                height: 38,
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 10,
                ),
                decoration: BoxDecoration(
                  color:
                  const Color(0xFFF5F6F8),
                  border: Border.all(
                    color: border,
                  ),
                  borderRadius:
                  BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome_outlined,
                      size: 14,
                      color: muted,
                    ),

                    const SizedBox(width: 7),

                    Expanded(
                      child: Text(
                        controller.hsnTax
                            ?.trim()
                            .isNotEmpty ==
                            true
                            ? 'GST Rate ${controller.hsnTax}%'
                            : 'Auto from HSN Master',
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight:
                          FontWeight.w600,
                          color: muted,
                        ),
                      ),
                    ),

                    const Text(
                      '%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                        FontWeight.w800,
                        color: muted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // SETTING TILE
  // =========================================================================

  Widget _buildSettingTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(7),
      onTap: () {
        onChanged(!value);
      },
      child: Container(
        constraints: const BoxConstraints(
          minHeight: 38,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: value
              ? const Color(0xFFF3FBF7)
              : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(
            color: value
                ? const Color(0xFFCDEAD9)
                : border,
          ),
        ),
        child: Row(
          children: [
            _buildCompactToggle(
              value: value,
              onChanged: onChanged,
            ),

            const SizedBox(width: 8),

            Expanded(
              child: Column(
                mainAxisAlignment:
                MainAxisAlignment.center,
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: text,
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
              ),
            ),

            const SizedBox(width: 6),

            Text(
              value ? 'ON' : 'OFF',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w800,
                color: value ? green : muted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // BOTTOM BAR
  // =========================================================================

  Widget _buildBottomBar() {
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
      ),
      decoration: const BoxDecoration(
        color: white,
        border: Border(
          top: BorderSide(
            color: borderLight,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6F8),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              size: 15,
              color: muted,
            ),
          ),

          const SizedBox(width: 9),

          const Expanded(
            child: Text(
              'Review the charge configuration before saving.',
              style: TextStyle(
                fontSize: 9.5,
                color: muted,
              ),
            ),
          ),

          OutlinedButton(
            onPressed: controller.isSaving
                ? null
                : controller.resetForm,
            style: OutlinedButton.styleFrom(
              foregroundColor: text,
              minimumSize: const Size(90, 36),
              padding:
              const EdgeInsets.symmetric(
                horizontal: 14,
              ),
              side: const BorderSide(
                color: Color(0xFFD0D5DD),
              ),
              shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(6),
              ),
            ),
            child: const Text(
              'Reset',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(width: 9),

          SizedBox(
            height: 36,
            child: ElevatedButton.icon(
              onPressed: controller.isSaving
                  ? null
                  : () {
                controller.saveCharge(
                  context,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: dark,
                foregroundColor: white,
                disabledBackgroundColor:
                const Color(0xFF98A2B3),
                elevation: 0,
                minimumSize:
                const Size(140, 36),
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 15,
                ),
                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(6),
                ),
              ),
              icon: controller.isSaving
                  ? const SizedBox(
                width: 13,
                height: 13,
                child:
                CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: white,
                ),
              )
                  : const Icon(
                Icons.save_outlined,
                size: 14,
              ),
              label: Text(
                controller.isSaving
                    ? 'Saving...'
                    : controller.selectedCharge != null
                    ? 'Update Charge'
                    : 'Save Charge',
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          const SizedBox(width: 2),
        ],
      ),
    );
  }

  // =========================================================================
  // SECTION CARD
  // =========================================================================

  Widget _sectionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: border,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
            ),
            decoration:  BoxDecoration(
              color: Color(0xFFFBFCFE),
              border: Border(
                bottom: BorderSide(
                  color: borderLight,
                ),
              ),
              borderRadius: BorderRadius.circular(12)
            ),
            child: Row(
              children: [
                Container(
                  width: 31,
                  height: 31,
                  decoration: BoxDecoration(
                    color: primaryLight,
                    borderRadius:
                    BorderRadius.circular(7),
                  ),
                  child: Icon(
                    icon,
                    size: 15,
                    color: primary,
                  ),
                ),

                const SizedBox(width: 10),

                Column(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight:
                        FontWeight.w700,
                        color: dark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 8.5,
                        color: muted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(15),
            child: child,
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // FIELD WRAPPER
  // =========================================================================

  Widget _fieldWrapper({
    required String label,
    required Widget child,
    bool required = false,
  }) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        _smallLabel(
          label,
          required: required,
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  // =========================================================================
  // TEXT FIELD
  // =========================================================================

  Widget _buildTextField({
    required String label,
    String? hint,
    required TextEditingController controller,
    bool required = false,
    TextInputType? keyboardType,
  }) {
    return _fieldWrapper(
      label: label,
      required: required,
      child: SizedBox(
        height: 38,
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(
            fontSize: 11.5,
            color: text,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 10.5,
              color: Color(0xFF98A2B3),
            ),
            filled: true,
            fillColor: white,
            contentPadding:
            const EdgeInsets.symmetric(
              horizontal: 11,
            ),
            border: _inputBorder(),
            enabledBorder: _inputBorder(),
            focusedBorder: _inputBorder(
              color: primary,
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // DROPDOWN
  // =========================================================================

  Widget _buildDropdown({
    required String label,
    required List<String> items,
    required String? value,
    required String hint,
    required ValueChanged<String?> onChanged,
    bool required = false,
  }) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          _smallLabel(
            label,
            required: required,
          ),
          const SizedBox(height: 6),
        ],
        SizedBox(
          height: 38,
          child: DropdownButtonFormField<String>(
            initialValue:
            items.contains(value)
                ? value
                : null,
            isExpanded: true,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: muted,
            ),
            style: const TextStyle(
              fontSize: 11,
              color: text,
            ),
            hint: Text(
              hint,
              style: const TextStyle(
                fontSize: 10.5,
                color: Color(0xFF98A2B3),
              ),
            ),
            items: items.map(
                  (item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    overflow:
                    TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                    ),
                  ),
                );
              },
            ).toList(),
            onChanged: onChanged,
            decoration: InputDecoration(
              contentPadding:
              const EdgeInsets.symmetric(
                horizontal: 11,
              ),
              border: _inputBorder(),
              enabledBorder: _inputBorder(),
              focusedBorder: _inputBorder(
                color: primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // INFO MESSAGE
  // =========================================================================

  Widget _buildInfoMessage({
    required IconData icon,
    required String message,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F9FF),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: const Color(0xFFDCE8F7),
        ),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 14,
            color: primary,
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 8.5,
                height: 1.4,
                color: primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // SEGMENTED OPTIONS
  // =========================================================================

  Widget _buildSegmentedOptions({
    required List<String> options,
    required String selected,
    required ValueChanged<String> onChanged,
  }) {
    return Wrap(
      spacing: 7,
      runSpacing: 7,
      children: options.map(
            (option) {
          final bool active =
              option == selected;

          return InkWell(
            borderRadius:
            BorderRadius.circular(6),
            onTap: () {
              onChanged(option);
            },
            child: AnimatedContainer(
              duration: const Duration(
                milliseconds: 130,
              ),
              height: 34,
              padding:
              const EdgeInsets.symmetric(
                horizontal: 10,
              ),
              decoration: BoxDecoration(
                color: active
                    ? primaryLight
                    : white,
                borderRadius:
                BorderRadius.circular(6),
                border: Border.all(
                  color: active
                      ? const Color(0xFF8BB5EE)
                      : border,
                ),
              ),
              child: Row(
                mainAxisSize:
                MainAxisSize.min,
                children: [
                  _buildSmallRadio(active),
                  const SizedBox(width: 6),
                  Text(
                    option,
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: active
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: active
                          ? primary
                          : text,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ).toList(),
    );
  }

  // =========================================================================
  // RADIO
  // =========================================================================

  Widget _buildSmallRadio(bool selected) {
    return AnimatedContainer(
      duration: const Duration(
        milliseconds: 120,
      ),
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected
              ? primary
              : const Color(0xFF98A2B3),
          width: selected ? 1.4 : 1,
        ),
      ),
      child: selected
          ? Center(
        child: Container(
          width: 6,
          height: 6,
          decoration:
          const BoxDecoration(
            color: primary,
            shape: BoxShape.circle,
          ),
        ),
      )
          : null,
    );
  }

  // =========================================================================
  // SWITCH
  // =========================================================================

  Widget _buildCompactToggle({
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SizedBox(
      width: 32,
      height: 20,
      child: Transform.scale(
        scale: .72,
        child: Switch(
          value: value,
          onChanged: onChanged,
          materialTapTargetSize:
          MaterialTapTargetSize.shrinkWrap,
          thumbColor:
          WidgetStateProperty.all(white),
          trackColor:
          WidgetStateProperty.resolveWith(
                (states) {
              if (states.contains(
                WidgetState.selected,
              )) {
                return green;
              }

              return const Color(0xFFD0D5DD);
            },
          ),
          trackOutlineColor:
          WidgetStateProperty.all(
            Colors.transparent,
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // LABEL
  // =========================================================================

  Widget _smallLabel(
      String label, {
        bool required = false,
      }) {
    return RichText(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          color: text,
        ),
        children: [
          if (required)
            const TextSpan(
              text: ' *',
              style: TextStyle(
                color: red,
              ),
            ),
        ],
      ),
    );
  }

  // =========================================================================
  // INPUT BORDER
  // =========================================================================

  OutlineInputBorder _inputBorder({
    Color color = border,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: BorderSide(
        color: color,
      ),
    );
  }
}