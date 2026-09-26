import 'dart:async';

import 'package:flutter/material.dart';

import '../../components/custome_dropdown_widget.dart';
import '../../dashboard/presentaion/erp_top_header.dart';
import '../data/model/other_charge_model.dart';
import '../data/other_chagres_controller.dart';

class CreateOtherChargeScreen extends StatefulWidget {
  final OtherChargeModel? chargeData;
  const CreateOtherChargeScreen({super.key, this.chargeData});

  @override
  State<CreateOtherChargeScreen> createState() =>
      _CreateOtherChargeScreenState();
}

class _CreateOtherChargeScreenState
    extends State<CreateOtherChargeScreen> {
  late final OtherChargeController controller;
  Timer? _searchDebounce;
// ===========================================================================
// COLORS
// ===========================================================================

  static const Color primary = Color(0xFF246BCE);
  static const Color dark = Color(0xFF172B4D);
  static const Color text = Color(0xFF344054);
  static const Color muted = Color(0xFF667085);
  static const Color border = Color(0xFFE2E8F0);
  static const Color background = Color(0xFFF6F8FB);
  static const Color green = Color(0xFF16A05D);
  static const Color red = Color(0xFFD92D20);

// ===========================================================================
// INIT
// ===========================================================================

  @override
  void initState() {
    super.initState();
    controller = OtherChargeController();

    controller.chargeNameController.addListener(_refresh);
    controller.printNameController.addListener(_refresh);
    controller.defaultValueController.addListener(_refresh);

    if(widget.chargeData !=null)
      {
       controller.setChargeName(widget.chargeData);

      }

  }

  void _refresh() {
    controller.notifyListeners();
  }

  @override
  void dispose() {
    controller.chargeNameController.removeListener(_refresh);
    controller.printNameController.removeListener(_refresh);
    controller.defaultValueController.removeListener(_refresh);

    controller.dispose();

    super.dispose();
  }

// ===========================================================================
// BUILD
// ===========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: controller,
          builder: (context, child) {
            return Column(
              children: [
                _buildHeader(),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      18,
                      12,
                      18,
                      20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSection(
                          number: '1',
                          icon: Icons.info_outline_rounded,
                          title: 'Basic Information',
                          subtitle:
                          'Define the basic details of this charge',
                          child: _buildBasicInformation(),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          Expanded(
                            child: _buildSection(
                              number: '2',
                              icon: Icons.payments_outlined,
                              title: 'Default Value',
                              subtitle: 'Set the default charge value',
                              child: _buildDefaultValue(),
                            ),
                          ),
                          SizedBox(width: 12,),
                          Expanded(child: _buildSection(
                            number: '3',
                            icon: Icons.calculate_outlined,
                            title: 'Charge Calculation',
                            subtitle:'Charge to be fed as',
                            child: _buildChargeCalculation(),
                          )),
                            SizedBox(width: 12,),
                          Expanded(child: _buildSection(
                            number: '6',
                            icon: Icons.tune_rounded,
                            title: 'Additional Settings',
                            subtitle:
                            'Control invoice behaviour',
                            child: _buildAdditionalSettings(),
                          )),
                          ]
                        ),

                        _buildSection(
                          number: '4',
                          icon: Icons.layers_outlined,
                          title: 'Applied On',
                          subtitle:
                          'Choose where this charge should be applied',
                          child: _buildAppliedOn(),
                        ),



                        // _buildTwoSections(
                        //   left: _buildSection(
                        //     number: '5',
                        //     icon: Icons.receipt_long_outlined,
                        //     title: 'Tax Treatment',
                        //     subtitle:
                        //     'Define the tax treatment for this charge',
                        //     child: _buildTaxTreatment(),
                        //   ),
                        //   right: _buildSection(
                        //     number: '6',
                        //     icon: Icons.tune_rounded,
                        //     title: 'Additional Settings',
                        //     subtitle:
                        //     'Control invoice behaviour',
                        //     child: _buildAdditionalSettings(),
                        //   ),
                        // ),

                        const SizedBox(height: 2),

                        _buildBottomBar(),
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

// ===========================================================================
// HEADER
// ===========================================================================

  Widget _buildHeader() {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: border),
        ),
      ),
      child: Row(
        children: [
          InkWell(
              onTap: (){
                Navigator.pop(context);
              },
              child: Icon(Icons.arrow_back)),
          SizedBox(width: 12,),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F5FF),
              borderRadius: BorderRadius.circular(7),
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              size: 17,
              color: primary,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Create Other Charge',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: dark,
                    letterSpacing: -0.2,
                  ),
                ),
                Text(
                  'Define charge calculation, tax treatment and invoice settings.',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 15),


        ],
      ),
    );
  }

  Widget _breadcrumb(String value) {
    return Text(
      value,
      style: const TextStyle(
        fontSize: 12,
        color: muted,
      ),
    );
  }

  Widget _breadcrumbArrow() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Icon(
        Icons.chevron_right,
        size: 14,
        color: Color(0xFF98A2B3),
      ),
    );
  }

// ===========================================================================
// SECTION
// ===========================================================================

  Widget _buildSection({
    required String number,
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(
              12,
              9,
              12,
              8,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFFFCFDFE),
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFFF0F2F5),
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 27,
                  height: 27,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F5FF),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    icon,
                    size: 14,
                    color: primary,
                  ),
                ),

                const SizedBox(width: 8),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F4F7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    number,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: muted,
                    ),
                  ),
                ),

                const SizedBox(width: 7),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: dark,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 8,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: child,
          ),
        ],
      ),
    );
  }

// ===========================================================================
// TWO SECTIONS
// ===========================================================================

  Widget _buildTwoSections({
    required Widget left,
    required Widget right,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool compact = constraints.maxWidth < 720;

        if (compact) {
          return Column(
            children: [
              left,
              right,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: left),
            const SizedBox(width: 9),
            Expanded(child: right),
          ],
        );
      },
    );
  }

// ===========================================================================
// BASIC INFORMATION
// ===========================================================================

  Widget _buildBasicInformation() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;

// Dynamic minimum width.
// The fields automatically move to the next line when space is less.
        const double minFieldWidth = 175;
        const double spacing = 10;

        final int columns = (width / (minFieldWidth + spacing))
            .floor()
            .clamp(1, 5);

        final double fieldWidth = columns == 1
            ? width
            : (width - ((columns - 1) * spacing)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: 11,
          children: [

            SizedBox(
              width: fieldWidth -20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _smallLabel(
                    'Charge Name',
                    required: true,
                  ),

                  const SizedBox(height: 4),
                  _chargesName(),
                ],
              )
            ),
            SizedBox(width: 4,),

            SizedBox(
              width: fieldWidth -50,
              child:Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  _smallLabel(
                    'Charge Type',
                    required: true,
                  ),
                  const SizedBox(height: 4),


                  SizedBox(
                      height: 36,
                      child:   _chargesTypeField()
                  ),
                ],
              )

              ,
              // child: _buildDropdown(
              //   label: 'Charge Type',
              //   required: true,
              //   value: controller.chargeType,
              //   items: controller.chargeTypes
              //       .where(
              //         (e) => e != 'Select Charge Type',
              //   )
              //       .toList(),
              //   hint: 'Select Charge Type',
              //   onChanged: controller.setChargeType,
              // ),
            ),

            SizedBox(width: 6,),

            SizedBox(
              width: fieldWidth,
              child: _buildRadioGroup(
                label: 'Charge Nature',
                required: true,
                options: const [
                  'Additional (+)',
                  'Deduction (-)',
                ],
                selected: controller.chargeNature == 'Additional'
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
            ),

            SizedBox(
              width: fieldWidth,
              child: _buildTextField(
                label: 'Charge Print Name',
                hint: 'Enter Print Name',
                controller: controller.printNameController,
              ),
            ),
            SizedBox(width: 12,),
            SizedBox(
              width: fieldWidth,
              child: _buildSwitchField(
                label: 'Status',
                value: controller.isActive,
                onChanged: controller.setStatus,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _chargesTypeField() {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return SearchableCustomerDropdown<String>(
          value: controller.chargeType,
          height: 40,
          borderColor: Colors.grey.shade300,
          borderRadius: 4,
          items: controller.chargeTypes,
          onSearch: (value) {},
          displayString: (item) {
            return item ?? '';
          },
          onSelect: (value) {
            controller.setChargeType(value);
          },
        );
      },
    );
  }


  Widget _chargesName() {
    return ListenableBuilder(
      listenable: controller.updateCharges,
      builder: (context, _) {


        return SearchableCustomerDropdown<OtherChargeModel>(
          value: controller.selectChargeName,
          height: 36,
          borderColor: Colors.grey.shade300,
          borderRadius: 4,
          dataFound: true,
          items: controller.searchCharges,
          onSearch: (value) {
            controller.chargeNameController.text = value;
            controller.printNameController.text = value;
            _searchDebounce?.cancel();
            _searchDebounce = Timer(
              const Duration(milliseconds: 500), () async {
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
        );
      },
    );
  }


// ===========================================================================
// DEFAULT VALUE
// ===========================================================================

  Widget _buildDefaultValue() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: _buildTextField(
            label: 'Default Value',
            hint: '0.00',
            controller: controller.defaultValueController,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
          ),
        ),

        const SizedBox(width: 8),

        Container(
          height: 36,
          constraints: const BoxConstraints(
            minWidth: 36,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F7FA),
            border: Border.all(color: border),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            controller.calculationType == 'Percentage (%)'
                ? '%'
                : '₹',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: muted,
            ),
          ),
        ),
      ],
    );
  }

// ===========================================================================
// CHARGE CALCULATION
// ===========================================================================

  Widget _buildChargeCalculation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRadioGroup(
          label: 'Charge to be fed as',
          required: true,
          options: const [
            'Amount',
            'Per Main Qty',
            'Percentage (%)',
          ],
          selected: controller.calculationType,
          onChanged: controller.setCalculationType,
        ),

        const SizedBox(height: 8),

        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(
            horizontal: 9,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFF7FAFF),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: const Color(0xFFDCE8F7),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                size: 13,
                color: primary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _calculationDescription(),
                  style: const TextStyle(
                    fontSize: 8.5,
                    color: Color(0xFF246BCE),
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _calculationDescription() {
    switch (controller.calculationType) {
      case 'Per Main Qty':
        return 'Charge will be calculated according to the main item quantity.';

      case 'Percentage (%)':
        return 'Charge will be calculated as a percentage of the applicable amount.';

      default:
        return 'A fixed amount will be applied as the charge value.';
    }
  }

// ===========================================================================
// APPLIED ON
// ===========================================================================

  Widget _buildAppliedOn() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;

        const double minCardWidth = 220;
        const double spacing = 9;

        final int columns = (width / (minCardWidth + spacing))
            .floor()
            .clamp(1, 3);

        final double cardWidth = columns == 1
            ? width
            : (width - ((columns - 1) * spacing)) / columns;

        final cards = [
          _buildAppliedCard(
            icon: Icons.inventory_2_outlined,
            title: 'Item Wise',
            description:
            'Distribute charge across invoice items.',
            value: 'Item Wise',
            child: _buildDistributionMethod(controller.appliedOn == 'Item Wise'),
          ),

          _buildAppliedCard(
            icon: Icons.receipt_long_outlined,
            title: 'Final Bill',
            description:
            'Calculate charge on the final bill amount.',
            value: 'Final Bill',
            child: _buildInfoMessage(
              'Calculated on final bill amount after item total and other charges.',
            ),
          ),

          if(controller.chargeNature!='Deduction')
          _buildAppliedCard(
            icon: Icons.add_chart_outlined,
            title: 'Separate Line',
            description:
            'Show the charge as a separate invoice line.',
            value: 'Separate',
            child: _buildSeparateFields(),
          ),
        ];

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: cards
              .map(
                (card) => SizedBox(
              width: cardWidth,
              child: card,
            ),
          )
              .toList(),
        );
      },
    );
  }

// ===========================================================================
// APPLIED CARD
// ===========================================================================

  Widget _buildAppliedCard({
    required IconData icon,
    required String title,
    required String description,
    required String value,
    required Widget child,
  }) {
    final bool selected = controller.appliedOn == value;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: selected
            ? const Color(0xFFF7FAFF)
            : Colors.white,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: selected
              ? const Color(0xFF8FB9EA)
              : border,
          width: selected ? 1.2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(7),
        onTap: () {
          controller.setAppliedOn(value);
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildSmallRadio(selected),

                  const SizedBox(width: 7),

                  Container(
                    width: 27,
                    height: 27,
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFFEAF3FF)
                          : const Color(0xFFF5F6F8),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      icon,
                      size: 14,
                      color: selected
                          ? primary
                          : muted,
                    ),
                  ),

                  const SizedBox(width: 7),

                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: selected ? dark : text,
                      ),
                    ),
                  ),

                  if (selected)
                    const Icon(
                      Icons.check_circle,
                      size: 15,
                      color: primary,
                    ),
                ],
              ),

              const SizedBox(height: 6),

              Padding(
                padding: const EdgeInsets.only(left: 34),
                child: Text(
                  description,
                  style: TextStyle(
                    fontSize: 8.5,
                    height: 1.3,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),

              const SizedBox(height: 9),

              child,
            ],
          ),
        ),
      ),
    );
  }

// ===========================================================================
// DISTRIBUTION
// ===========================================================================

  Widget _buildDistributionMethod(bool isActive) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F6FF),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: const Color(0xFFD9E6F8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _smallLabel(
            'Distribution ${controller.distributionMethod}',
            required: false,
          ),

          const SizedBox(height: 5),



          // _buildRadioGroup(
          //   label: '',
          //   options: const [
          //     'By Quantity',
          //     'By Amount',
          //   ],
          //   selected:isActive? controller.distributionMethod:'',
          //   onChanged: controller.setDistributionMethod,
          // ),

          const SizedBox(height: 3),

          Text(
            'Charge is distributed based on the selected method.',
            style: TextStyle(
              fontSize: 8.5,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

// ===========================================================================
// INFO
// ===========================================================================

  Widget _buildInfoMessage(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F9FF),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: const Color(0xFFDCE8F7),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 13,
            color: primary,
          ),

          const SizedBox(width: 6),

          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 8.5,
                height: 1.35,
                color: Color(0xFF246BCE),
              ),
            ),
          ),
        ],
      ),
    );
  }

// ===========================================================================
// SEPARATE FIELDS
// ===========================================================================

  Widget _buildSeparateFields() {
    final bool enabled = controller.appliedOn == 'Separate';

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: enabled ? 1 : 0.42,
      child: IgnorePointer(
        ignoring: !enabled,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _smallLabel(
              'HSN',
              required: true,
            ),

            const SizedBox(height: 5),

            _buildDropdown(
              label: '',
              value: controller.hsn,
              items: controller.hsnList.keys
                  .where((e) => e != 'Select HSN')
                  .toList(),
              hint: 'Select HSN',
              onChanged: controller.setHSN,
            ),

            const SizedBox(height: 7),

            _smallLabel('Tax Rate'),

            const SizedBox(height: 5),

            Container(
              height: 36,
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6F8),
                border: Border.all(color: border),
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.auto_awesome_outlined,
                    size: 12,
                    color: Color(0xFF98A2B3),
                  ),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Auto from HSN Master',
                      style: TextStyle(
                        fontSize: 9,
                        color: Color(0xFF98A2B3),
                      ),
                    ),
                  ),
                  Text(
                    '%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: muted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

// ===========================================================================
// TAX TREATMENT
// ===========================================================================

  Widget _buildTaxTreatment() {
    final bool taxable =
        controller.taxTreatment == 'Taxable';

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool compact = constraints.maxWidth < 300;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (compact)
              Column(
                children: [
                  _buildChoiceChip(
                    icon: Icons.receipt_long_outlined,
                    title: 'Taxable',
                    selected: taxable,
                    onTap: () {
                      controller.setTaxTreatment('Taxable');
                    },
                  ),
                  const SizedBox(height: 7),
                  _buildChoiceChip(
                    icon: Icons.receipt_long_outlined,
                    title: 'Non-Taxable',
                    selected: !taxable,
                    onTap: () {
                      controller.setTaxTreatment('Non-Taxable');
                    },
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: _buildChoiceChip(
                      icon: Icons.receipt_long_outlined,
                      title: 'Taxable',
                      selected: taxable,
                      onTap: () {
                        controller.setTaxTreatment('Taxable');
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildChoiceChip(
                      icon: Icons.receipt_long_outlined,
                      title: 'Non-Taxable',
                      selected: !taxable,
                      onTap: () {
                        controller.setTaxTreatment('Non-Taxable');
                      },
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 7),

            Text(
              taxable
                  ? 'Tax will be applied according to the selected charge configuration.'
                  : 'No tax will be applied to this charge.',
              style: TextStyle(
                fontSize: 8.5,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        );
      },
    );
  }

// ===========================================================================
// ADDITIONAL SETTINGS
// ===========================================================================

  Widget _buildAdditionalSettings() {
    final bool enabled = controller.allowManualChange;

    return InkWell(
      borderRadius: BorderRadius.circular(7),
      onTap: () {
        controller.setAllowManualChange(!enabled);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: enabled
              ? const Color(0xFFF4FBF7)
              : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(
            color: enabled
                ? const Color(0xFFCDEAD9)
                : border,
          ),
        ),
        child: Row(
          children: [
            _buildCompactToggle(
              value: enabled,
              onChanged: controller.setAllowManualChange,
            ),

            const SizedBox(width: 8),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Allow Manual Change',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'User can change the charge value in invoice.',
                    style: TextStyle(
                      fontSize: 8.5,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 160),
              child: Text(
                enabled ? 'Enabled' : 'Disabled',
                key: ValueKey(enabled),
                style: TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w700,
                  color: enabled ? green : muted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

// ===========================================================================
// STATUS
// ===========================================================================

  Widget _buildStatus() {
    final bool active = controller.isActive;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: active
            ? const Color(0xFFF4FBF7)
            : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: active
              ? const Color(0xFFCDEAD9)
              : border,
        ),
      ),
      child: Row(
        children: [
          _buildCompactToggle(
            value: active,
            onChanged: controller.setStatus,
          ),

          const SizedBox(width: 8),

          Text(
            active ? 'Active' : 'Inactive',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: active ? green : muted,
            ),
          ),

          const SizedBox(width: 12),

          Container(
            width: 1,
            height: 18,
            color: border,
          ),

          const SizedBox(width: 12),

          Icon(
            active
                ? Icons.check_circle_outline
                : Icons.info_outline,
            size: 14,
            color: active ? green : muted,
          ),

          const SizedBox(width: 6),

          Expanded(
            child: Text(
              active
                  ? 'This charge will be available when creating an invoice.'
                  : 'Inactive charges will not be available in invoice.',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 8.5,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }

// ===========================================================================
// BOTTOM ACTION BAR
// ===========================================================================

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool compact = constraints.maxWidth < 520;

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.security_outlined,
                      size: 14,
                      color: muted,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Review the charge settings before saving.',
                        style: TextStyle(
                          fontSize: 8.5,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: _resetButton(),
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: _saveButton(),
                    ),
                  ],
                ),
              ],
            );
          }

          return Row(
            children: [
              const Icon(
                Icons.security_outlined,
                size: 15,
                color: muted,
              ),

              const SizedBox(width: 6),

              Expanded(
                child: Text(
                  'Review the charge settings before saving.',
                  style: TextStyle(
                    fontSize: 8.5,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              _resetButton(),

              const SizedBox(width: 7),

              _saveButton(),
            ],
          );
        },
      ),
    );
  }

  Widget _resetButton() {
    return OutlinedButton.icon(
      onPressed: controller.isSaving
          ? null
          : () {
        controller.clear();
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: text,
        minimumSize: const Size(88, 34),
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
        ),
        side: const BorderSide(
          color: Color(0xFFD0D5DD),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
      icon: const Icon(
        Icons.refresh_rounded,
        size: 14,
      ),
      label: const Text(
        'Reset',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _saveButton() {
    return ElevatedButton.icon(
      onPressed: controller.isSaving ? null : (){
        controller.saveCharge(context);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: dark,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size(118, 34),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
      icon: controller.isSaving
          ? const SizedBox(
        width: 13,
        height: 13,
        child: CircularProgressIndicator(
          strokeWidth: 1.5,
          color: Colors.white,
        ),
      )
          : const Icon(
        Icons.save_outlined,
        size: 14,
      ),
      label: Text(
        controller.isSaving ? 'Saving...' : 'Save Charge',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

// ===========================================================================
// CHOICE CHIP
// ===========================================================================

  Widget _buildChoiceChip({
    required IconData icon,
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
          ),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFFF2F7FF)
                : Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: selected
                  ? const Color(0xFF8FB9EA)
                  : border,
            ),
          ),
          child: Row(
            children: [
              _buildSmallRadio(selected),

              const SizedBox(width: 6),

              Icon(
                icon,
                size: 13,
                color: selected ? primary : muted,
              ),

              const SizedBox(width: 5),

              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: selected
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: text,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

// ===========================================================================
// TEXT FIELD
// ===========================================================================

  Widget _buildTextField({
    required String label,
    String? hint,
    required TextEditingController controller,
    bool required = false,
    TextInputType? keyboardType,
    Function? onChange,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _smallLabel(
          label,
          required: required,
        ),

        const SizedBox(height: 4),

        SizedBox(
          height: 36,
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(
              fontSize: 12,
              color: text,
            ),
            onChanged: (value){
              onChange?.call(value);
            },
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 7,
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

// ===========================================================================
// DROPDOWN
// ===========================================================================

  Widget _buildDropdown({
    required String label,
    required List<String> items,
    required String? value,
    required String hint,
    required ValueChanged<String?> onChanged,
    bool required = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          _smallLabel(
            label,
            required: required,
          ),
          const SizedBox(height: 4),
        ],

        SizedBox(
          height: 36,
          child: DropdownButtonFormField<String>(
            initialValue: items.contains(value) ? value : null,
            isExpanded: true,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: muted,
            ),
            style: const TextStyle(
              fontSize: 12,
              color: text,
            ),
            hint: Text(hint),
            items: items.map(
                  (item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ).toList(),
            onChanged: onChanged,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
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

// ===========================================================================
// RADIO GROUP
// ===========================================================================

  Widget _buildRadioGroup({
    required String label,
    required List<String> options,
    required String selected,
    required ValueChanged<String> onChanged,
    bool required = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // if (label.isNotEmpty) ...[
        //   _smallLabel(
        //     label,
        //     required: required,
        //   ),
        //   const SizedBox(height: 10),
        // ],

        Wrap(
          spacing: 10,
          runSpacing: 6,
          children: options.map(
                (option) {
              final bool isSelected = selected == option;

              return InkWell(
                borderRadius: BorderRadius.circular(4),
                onTap: () {
                  onChanged(option);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 2,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildSmallRadio(isSelected),

                      const SizedBox(width: 5),

                      Text(
                        option,
                        style: TextStyle(
                          fontSize: 11,
                          color: text,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ).toList(),
        ),
      ],
    );
  }

// ===========================================================================
// RADIO
// ===========================================================================

  Widget _buildSmallRadio(bool selected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
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
          decoration: const BoxDecoration(
            color: primary,
            shape: BoxShape.circle,
          ),
        ),
      )
          : null,
    );
  }

// ===========================================================================
// COMPACT SWITCH
// ===========================================================================

  Widget _buildCompactToggle({
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SizedBox(
      width: 30,
      height: 18,
      child: Transform.scale(
        scale: 0.72,
        child: Switch(
          value: value,
          onChanged: onChanged,
          materialTapTargetSize:
          MaterialTapTargetSize.shrinkWrap,
          thumbColor: WidgetStateProperty.all(
            Colors.white,
          ),
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

// ===========================================================================
// SWITCH FIELD
// ===========================================================================

  Widget _buildSwitchField({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _smallLabel(label),

        const SizedBox(height: 4),

        Container(
          height: 36,
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
          ),
          // decoration: BoxDecoration(
          //   color: value
          //       ? const Color(0xFFF4FBF7)
          //       : const Color(0xFFF8F9FA),
          //   borderRadius: BorderRadius.circular(5),
          //   border: Border.all(
          //     color: value
          //         ? const Color(0xFFCDEAD9)
          //         : border,
          //   ),
          // ),
          child: Row(
            children: [
              _buildCompactToggle(
                value: value,
                onChanged: onChanged,
              ),

              const SizedBox(width: 12),

              Text(
                value ? 'Active' : 'Inactive',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: value ? green : muted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

// ===========================================================================
// LABEL
// ===========================================================================

  Widget _smallLabel(
      String label, {
        bool required = false,
      }) {
    return RichText(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          fontSize: 9,
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

// ===========================================================================
// INPUT BORDER
// ===========================================================================

  OutlineInputBorder _inputBorder({
    Color color = border,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(5),
      borderSide: BorderSide(
        color: color,
      ),
    );
  }
}
