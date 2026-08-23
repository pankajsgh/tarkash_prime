import 'package:calculation_panel/core/widget/widget_updater.dart';
import 'package:calculation_panel/features/dashboard/representaion/product_selection_section/product_selection_section.dart';
import 'package:calculation_panel/features/dashboard/representaion/supplier_header/model/supplier_model.dart';
import 'package:calculation_panel/features/dashboard/representaion/supplier_header/supplier_header.dart';
import 'package:calculation_panel/features/dashboard/representaion/top_header/top_header.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/vars/global_vars.dart';
import '../../components/custome_dropdown_widget.dart';
import 'extra_charge/model/extra_charge_controller.dart';
import 'extra_charge/model/extra_charge_view.dart';
import 'purchase_controller.dart';

class PurchasePage extends StatefulWidget {
  const PurchasePage({super.key});
  @override
  State<PurchasePage> createState() => _PurchasePageState();
}

class _PurchasePageState extends State<PurchasePage> {

  late final PurchaseController purchaseController;
  late final ExtraChargeController chargeController;

  @override
  void initState() {
    super.initState();
    GlobalVars.globalRoutes = "purchasePage";
    purchaseController = PurchaseController();
    chargeController = ExtraChargeController();
    purchaseController.addItem();
  }

  @override
  void dispose() {
    purchaseController.dispose();
    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),
      body: Column(
        children: [
          ERPHomePage(),

          Expanded(
            child: _buildWorkspace(),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // WORKSPACE
  // ============================================================

  Widget _buildWorkspace() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight - 44,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPageHeader(),
                const SizedBox(height: 12),
                SupplierHeader(
                  purchaseController: purchaseController,
                ),

                const SizedBox(height: 16),

                ProductSelectionSection(
                  controller: purchaseController,
                ),

                const SizedBox(height: 16),

                ListenableBuilder(listenable: purchaseController,
                    builder: (context, _){
                      return  _buildBottomCards();}),

              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // PAGE HEADER
  // ============================================================

  Widget _buildPageHeader() {
    return Row(
      children: [
        const Row(
          children: [
            Text(
              'Purchase',
              style: TextStyle(
                fontSize: 13,
                color: textMedium,
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: textLight,
              ),
            ),

            Text(
              'Create Challan',
              style: TextStyle(
                fontSize: 13,
                color: textDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),

        const Spacer(),

        _statusBadge(),

        const SizedBox(width: 10),

        OutlinedButton.icon(
          onPressed: purchaseController.clearAll,
          icon: const Icon(
            Icons.refresh_rounded,
            size: 17,
          ),
          label: const Text('Reset'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xff475569),
            side: const BorderSide(
              color: Color(0xffD7DEE8),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // STATUS
  // ============================================================

  Widget _statusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: const Color(0xffFFF7ED),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xffFED7AA),
        ),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.circle,
            size: 8,
            color: Color(0xffF97316),
          ),

          SizedBox(width: 7),

          Text(
            'Draft',
            style: TextStyle(
              color: Color(0xffC2410C),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BOTTOM CARDS
  // ============================================================

  Widget _buildBottomCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return Column(
            children: [
              _buildDetailsCard(),

              const SizedBox(height: 16),

              _buildLogisticsCard(),
              const SizedBox(height: 16),
              ListenableBuilder(listenable: purchaseController,
                  builder: (context, _){
                    return ExtraChargeView(extraChargeController: chargeController, purchaseController: purchaseController,);
                  }),

              const SizedBox(height: 16),

              _buildSummaryCard(),
            ],
          );
        }

        if(constraints.maxWidth < 1200)
          {
            return Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                    flex: 3,
                    child: _buildLogisticsCard(),

                  ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: _buildDetailsCard(),

                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Expanded(
                      flex: 6,
                      child: Column(
                        children: [
                          ListenableBuilder(listenable: purchaseController,
                              builder: (context, _){
                                return ExtraChargeView(extraChargeController: chargeController, purchaseController: purchaseController,);
                              })
                        ],
                      ),
                    ),



                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: _buildSummaryCard(),
                    ),
                  ],
                )
              ]
            );
          }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            if(MediaQuery.of(context).size.width>1200)
            ...[
              Expanded(
                flex: 3,
                child: _buildLogisticsCard(),

              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: _buildDetailsCard(),

              ),
            ],
            const SizedBox(width: 12),
            Expanded(
              flex: 6,
              child: Column(
                children: [
                  ListenableBuilder(listenable: purchaseController,
                      builder: (context, _){
                    return ExtraChargeView(extraChargeController: chargeController, purchaseController: purchaseController,);
                      })
                ],
              ),
            ),



            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: _buildSummaryCard(),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // DETAILS CARD
  // ============================================================

  Widget _buildDetailsCard() {
    return _card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(
              Icons.notes_rounded,
              'Additional Details',
            ),

            const SizedBox(height: 10),

            const Text(
              'Remark',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xff475569),
              ),
            ),

            const SizedBox(height: 6),

            TextField(
              controller: purchaseController.remarkController,
              maxLines: 2,
              decoration: _inputDecoration(
                'Add a remark...',
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                const Icon(
                  Icons.attach_file_rounded,
                  size: 17,
                  color: Color(0xff64748B),
                ),

                const SizedBox(width: 7),

                const Text(
                  'Attachment',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const Spacer(),

                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.upload_file_rounded,
                    size: 14,
                  ),
                  label: const Text(
                    'Choose File',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: blue,
                    minimumSize: const Size(0, 30),
                    fixedSize: const Size(100, 30),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                    ),
                    side: const BorderSide(
                      color: Color(0xffBFDBFE),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // LOGISTICS CARD
  // ============================================================

  Widget _buildLogisticsCard() {
    return _card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: ListenableBuilder(
          listenable: purchaseController,
          builder: (context, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle(
                  Icons.local_shipping_outlined,
                  'Logistics',
                ),

                const SizedBox(height: 10),

                _fieldBlock(
                  'Agent',
                  _buildAgentDropdown(),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: _fieldBlock(
                        'LR Number',
                        _textField(
                          purchaseController.lrNoController,
                          hint: 'LR No',
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: _fieldBlock(
                        'LR Date',
                        _dateField(
                          controller: purchaseController.lrDateController,
                          onTap: () {
                            purchaseController.selectLrDate(context);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // AGENT DROPDOWN
  // ============================================================

  Widget _buildAgentDropdown() {
    return ListenableBuilder(
      listenable: purchaseController,
      builder: (context, _) {
        return SearchableCustomerDropdown<Agency>(
          value: purchaseController.selectedAgent,
          height: 36,
          borderColor: Colors.grey.shade300,
          borderRadius: 8,
          items: purchaseController.agents,
          onSearch: (value) {},
          displayString: (item) {
            return item.name ?? '';
          },
          onSelect: (value) {
            purchaseController.setAgent(value);
          },
        );
      },
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xff172B4D),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child:ListenableBuilder(listenable: chargeController,
          builder: (context, _){
            return Padding(
              padding: const EdgeInsets.all(19),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.receipt_long_rounded,
                        color: Colors.white,
                        size: 19,
                      ),

                      const SizedBox(width: 8),

                      const Text(
                        'Bill Summary',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      Text("Qty: ${purchaseController.totalQuantity}",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    ],
                  ),

                  const SizedBox(height: 20),

                  _summaryRow(
                    'Value of Goods',
                    purchaseController.valueOfGoods,
                  ),

                  if(purchaseController.selectSupplier!=null && purchaseController.selectSupplier!.state.id!= GlobalVars.placeOfSupplyId)
                    _summaryRow(
                      'IGST',
                      purchaseController.igst,
                    ) else ...[
                    _summaryRow(
                      'SGST',
                      purchaseController.sgst,
                    ),

                    _summaryRow(
                      'CGST',
                      purchaseController.cgst,
                    ),
                  ],


                  _summaryRow(
                    'Additional Charges',
                    purchaseController.additionalCharge,
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 2),
                    child: Divider(
                      color: Color(0x33FFFFFF),
                    ),
                  ),

                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Grand Total',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ),

                      Text(
                        '₹ ${purchaseController.grandTotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    height: 42,
                    child: ElevatedButton.icon(
                      onPressed: purchaseController.generateChallan,
                      icon: const Icon(
                        Icons.check_circle_outline_rounded,
                        size: 18,
                      ),
                      label: const Text('Generate Challan'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff3B82F6),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          })
    );
  }

  // ============================================================
  // SUMMARY ROW
  // ============================================================

  Widget _summaryRow(
      String title,
      double value,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
              ),
            ),
          ),

          FutureBuilder(future: Future.delayed(Duration(milliseconds: 600)),
              builder: (context, snapshot){
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text(
                    '₹ ${value.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }
                return  Text(
                  '₹ ${value.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                );
              })


        ],
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _sectionTitle(
      IconData icon,
      String title,
      ) {
    return Row(
      children: [
        Container(
          height: 26,
          width: 26,
          decoration: BoxDecoration(
            color: const Color(0xffEAF2FF),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(
            icon,
            size: 14,
            color: blue,
          ),
        ),

        const SizedBox(width: 10),

        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xff1E293B),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // CARD
  // ============================================================

  Widget _card({
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xffE6EBF2),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 15,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  // ============================================================
  // FIELD BLOCK
  // ============================================================

  Widget _fieldBlock(
      String label,
      Widget field,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xff475569),
          ),
        ),

        const SizedBox(height: 6),

        field,
      ],
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _textField(
      TextEditingController textController, {
        String? hint,
        IconData? prefix,
      }) {
    return SizedBox(
      height: 32,
      child: TextField(
        controller: textController,
        decoration: _inputDecoration(
          hint,
          prefix: prefix,
        ),
        style: const TextStyle(
          fontSize: 12,
          color: textDark,
        ),
      ),
    );
  }

  // ============================================================
  // DATE FIELD
  // ============================================================

  Widget _dateField({
    required TextEditingController controller,
    required VoidCallback onTap,
  }) {
    final dateController = controller;

    return SizedBox(
      height: 30,
      child: TextField(
        controller: dateController,
        readOnly: true,
        onTap: onTap,
        decoration: _inputDecoration(
          'Select date',
          prefix: Icons.calendar_today_outlined,
        ),
        style: const TextStyle(
          fontSize: 12,
          color: textDark,
        ),
      ),
    );
  }

  // ============================================================
  // DROPDOWN
  // ============================================================

  Widget _dropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    IconData? prefix,
  }) {
    items = items.toSet().toList();
    return SizedBox(
      height: 39,
      child: DropdownButtonFormField<String>(
        initialValue: items.contains(value)? value:null,
        isExpanded: true,
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          size: 18,
          color: textLight,
        ),
        decoration: _inputDecoration(
          hint,
          prefix: prefix,
        ),
        style: const TextStyle(
          fontSize: 12,
          color: textDark,
        ),
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(10),
        items: items.map(
              (item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                overflow: TextOverflow.ellipsis,
              ),
            );
          },
        ).toList(),
        onChanged: onChanged,
      ),
    );
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration(
      String? hint, {
        IconData? prefix,
      }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontSize: 11,
        color: textLight,
      ),
      prefixIcon: prefix == null
          ? null
          : Icon(
        prefix,
        size: 17,
        color: textLight,
      ),
      filled: true,
      fillColor: const Color(0xffF8FAFC),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 9,
      ),
      isDense: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: borderColor,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: borderColor,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: Color(0xff3B82F6),
          width: 1.3,
        ),
      ),
    );
  }
}