
import 'package:calculation_panel/core/widget/country_field.dart';
import 'package:calculation_panel/core/widget/lead_source.dart';
import 'package:calculation_panel/core/widget/state_field.dart';
import 'package:calculation_panel/core/widget/toast.dart';
import 'package:calculation_panel/features/dashboard/data/controller/routes_controller.dart';
import 'package:calculation_panel/features/sale_invoice/controller/sale_invoice_controller.dart';
import 'package:calculation_panel/features/sale_invoice/representaion/product_selection_section/product_selection_section.dart';
import 'package:flutter/material.dart';
import 'package:calculation_panel/core/theme/colors.dart';
import '../../../core/routes/routes.dart';
import '../../../core/vars/global_vars.dart';
import '../../../core/widget/date_field.dart';
import '../../../core/widget/ratetype_field.dart';
import '../../../core/widget/series_field.dart';
import '../../../core/widget/store_field.dart';
import '../../../core/widget/supplier_field.dart';
import '../../../core/widget/team_field.dart';
import '../../../core/widget/transport_field.dart';
import '../../components/custome_dropdown_widget.dart';
import 'extra_charge/extra_charge_view.dart';

class SaleInvoicePage extends StatefulWidget {
  final String? challanId;
  final RoutesController routesController;
  const SaleInvoicePage({super.key, this.challanId, required this.routesController});

  @override
  State<SaleInvoicePage> createState() => _SaleInvoicePageState();
}

class _SaleInvoicePageState extends State<SaleInvoicePage> {
  final bool _isEditMode= false;
  late final SaleInvoiceController saleInvoiceController = SaleInvoiceController(
    productPageType: .saleInvoice
  );

  static const Color primaryBlue = Color(0xff3B82F6);
  static const Color darkBlue = Color(0xff172B4D);

  static const Color pageBg = Color(0xffF4F6FA);
  static const Color cardBorder = Color(0xffE2E8F0);

  static const Color textDark = Color(0xff1E293B);
  static const Color textMedium = Color(0xff64748B);
  static const Color textLight = Color(0xff94A3B8);

  static const Color inputBg = Color(0xffF8FAFC);

  final invoiceController =
  TextEditingController(text: 'TN/26-27-3241');

  final mobileController =
  TextEditingController();

  final nameController = TextEditingController();

  final gstController =
  TextEditingController();

  final discountController =
  TextEditingController();

  final caseController =
  TextEditingController();

  final destinationController =
  TextEditingController();

  final remarkController =
  TextEditingController();

  final otherChargeController = TextEditingController();

  final commissionController = TextEditingController();

  CountryController countryController = CountryController();
  LeadSourceController leadSourceController = LeadSourceController();
  StateController stateController = StateController();
  SupplierController customerController = SupplierController();
  TransportController transportController = TransportController();
  TeamController teamController = TeamController();
  FocusNode teamFocus = FocusNode();

  final GlobalKey<DateFieldState> _dateFieldKey = GlobalKey<DateFieldState>();
  final storeKey = GlobalKey<StoreFieldState>();
  final rateTypeKey = GlobalKey<RateTypeFieldState>();
  final customerKey = GlobalKey<SupplierFieldState>();
  final teamKey = GlobalKey<SupplierFieldState>();

  ControllerDate dateController = ControllerDate();
  FocusNode dateFocus = FocusNode();

  ControllerDate lrDateController = ControllerDate();
  FocusNode lrDateFocus = FocusNode();


  SeriesController seriesController = SeriesController();
  RateTypeController rateTypeController = RateTypeController();
  FocusNode rateFocus = FocusNode();

  StoreController storeController = StoreController();
  FocusNode storeFocus = FocusNode();

  FocusNode customerFocus = FocusNode();

  String? salesman;

  String? backman;

  String? supplier;

  String? transport = 'Transport';

  String? country = 'India';

  String? supply = 'Tamil Nadu';

  String? leadSource;

  String? agent;

  String? otherCharge = 'Other Charges';

  final List<int> products = [0];

  @override
  void initState() {
    GlobalVars.globalRoutes != Routes.saleInvoiceScreen;
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    storeFocus.dispose();
    rateFocus.dispose();
    customerFocus.dispose();
    invoiceController.dispose();
    dateController.dispose();
    mobileController.dispose();
    nameController.dispose();
    gstController.dispose();
    discountController.dispose();
    caseController.dispose();
    destinationController.dispose();
    remarkController.dispose();
    otherChargeController.dispose();
    commissionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),

                  const SizedBox(height: 12),

                  ProductSelectionSection(
                    controller: saleInvoiceController,
                  ),

                  const SizedBox(height: 12),

                  ListenableBuilder(
                    listenable: saleInvoiceController,
                    builder: (context, _) {
                      return _buildBottomCards();
                    },
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return _card(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xffEAF2FF),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: primaryBlue,
                  size: 20,
                ),
              ),

              const SizedBox(width: 11),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sale Invoice',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: textDark,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Create and manage your sales invoice',
                      style: TextStyle(
                        fontSize: 10,
                        color: textMedium,
                      ),
                    ),
                  ],
                ),
              ),

              _smallHeaderButton(
                icon: Icons.refresh_rounded,
                label: 'Reset',
                onTap: _resetForm,
              ),

              const SizedBox(width: 8),

              _smallHeaderButton(
                icon: Icons.save_outlined,
                label: 'Save Draft',
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: 16),

          Container(
            height: 1,
            color: const Color(0xffEEF2F6),
          ),

          const SizedBox(height: 15),

          _buildInvoiceFields(),
          const SizedBox(height: 15),
          _buildCustomerSection()
        ],
      ),
    );
  }

  Widget  _buildInvoiceFields() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        if (width >= 1100) {
          return Row(
            crossAxisAlignment: .end,
            children: [
              Expanded(
                flex: 1,
                child: SeriesField(
                  seriesId: '3',
                  controller: SeriesController(),
                  onSelected: (series){
                    dateFocus.requestFocus();
                    _dateFieldKey.currentState?.openDatePicker();
                  },
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                flex: 1,
                child: _field(
                  label: 'Invoice No',
                  controller: invoiceController,
                  isReadOnly: true,
                  suffix: const Icon(
                    Icons.info_outline,
                    size: 15,
                    color: Colors.transparent,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                flex: 1,
                child: DateField(
                  key: _dateFieldKey,
                  controller: dateController,
                  focusNode: dateFocus,
                  hintText: 'Select Date',
                  onSelected: (){
                    storeKey.currentState?.focusAndOpen();
                  },
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                flex: 1,
                child: StoreField(
                  key: storeKey,
                  controller: storeController,
                  focusNode: storeFocus,
                  onSelected: (store){
                    rateTypeKey.currentState?.focusAndOpen();
                  },
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                flex: 1,
                child: RateTypeField(
                  key: rateTypeKey,
                  controller: rateTypeController,
                  focusNode: rateFocus,
                  onSelected: (rateType){
                    if(rateType!=null){
                      teamKey.currentState?.focusAndOpen();
                      saleInvoiceController.applyRateType(rateType);
                    }
                  },
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                flex: 1,
                child: TeamField(
                  key: teamKey,
                  focusNode: teamFocus,
                  controller: teamController,
                  onSelected: (team){
                    customerKey.currentState?.focusAndOpen();
                  },
                ),
              ),



              const SizedBox(width: 12),

              Padding(
                padding: const EdgeInsets.only(bottom: 3.0),
                child: SizedBox(
                  width: 72,
                  height: 35.0,
                  child: _filledButton(
                    label: 'Clear',
                    color: const Color(0xffEF4444),
                    onPressed: _resetForm,
                  ),
                ),
              ),
            ],
          );
        }

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: width > 700 ? 310 : width,
              child: _field(
                label: 'Invoice No',
                controller: invoiceController,
                isReadOnly: true,
                suffix: const Icon(
                  Icons.info_outline,
                  size: 15,
                  color: Colors.transparent,
                ),
              ),
            ),

            SizedBox(
              width: width > 700 ? 210 : width,
              child: DateField(
                controller: dateController,
                focusNode: dateFocus,
                hintText: 'Select Date',
                onSelected: (){

                },
              ),
            ),

            SizedBox(
              width: width > 700 ? 190 : width,
              child: StoreField(
                controller: storeController,
                focusNode: storeFocus,
                onSelected: (store){

                }
              ),
            ),

            SizedBox(
              width: width > 700 ? 220 : width,
              child: _dropdownField(
                label: 'Salesman',
                value: salesman,
                hint: 'Select Salesman',
                items: const [
                  'Salesman 1',
                  'Salesman 2',
                  'Salesman 3',
                ],
                onChanged: (v) {
                  setState(() => salesman = v);
                },
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _dropdownField(
                label: 'Backman',
                value: backman,
                hint: 'Select',
                items: const [
                  'Backman 1',
                  'Backman 2',
                  'Backman 3',
                ],
                onChanged: (v) {
                  setState(() => backman = v);
                },
              ),
            ),

            SizedBox(
              width: width > 700 ? 190 : width,
              child: RateTypeField(
                controller: rateTypeController,
                focusNode: rateFocus,
                onSelected: (rateType){

                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: _filledButton(
                label: 'Clear',
                color: const Color(0xffEF4444),
                onPressed: _resetForm,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCustomerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            if (width >= 1100) {
              return Row(
                children: [
                  Expanded(
                    child: SupplierField(
                      controller: customerController,
                      key: customerKey,
                      type: '2',
                      onSelected: (customer){
                        if(customer!=null){
                          nameController.text = customer.company;
                          gstController.text = customer.gstNo;
                        }
                      },
                    )
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _field(
                      label: 'Customer Name',
                      isReadOnly: true,
                      controller: nameController,
                      hint: 'Enter customer name',
                      suffix: const Icon(
                        Icons.add_circle_outline,
                        color: Colors.transparent,
                        size: 17,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _field(
                      label: 'GST Number',
                      controller: gstController,
                      hint: 'Enter GST number',
                      isReadOnly: true,
                      suffix: const Icon(
                        Icons.add_circle_outline,
                        color: Colors.transparent,
                        size: 17,
                      ),
                    ),
                  ),



                  const SizedBox(width: 12),
                  Expanded(
                    flex: 4,
                    child: const SizedBox(),
                  ),


                ],
              );
            }

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: width > 700 ? 300 : width,
                  child: SupplierField(
                    controller: customerController,
                    key: customerKey,
                    type: '2',
                    onSelected: (customer){
                      if(customer!=null){
                        nameController.text = customer.company;
                        gstController.text = customer.gstNo;
                      }
                    },
                  ),
                ),

                SizedBox(
                  width: width > 700 ? 300 : width,
                  child: _field(
                    label: 'Customer Name',
                    controller: nameController,
                    isReadOnly: true,
                    hint: 'Enter customer name',
                  ),
                ),

                SizedBox(
                  width: width > 700 ? 250 : width,
                  child: _field(
                    label: 'GST Number',
                    controller: gstController,
                    isReadOnly: true,
                    hint: 'Enter GST number',
                  ),
                ),

                SizedBox(
                  width: width > 700 ? 200 : width,
                  child: _dropdownField(
                    label: 'Backman',
                    value: backman,
                    hint: 'Select',
                    items: const [
                      'Backman 1',
                      'Backman 2',
                      'Backman 3',
                    ],
                    onChanged: (v) {
                      setState(() => backman = v);
                    },
                  ),
                ),

                SizedBox(
                  width: width > 700 ? 200 : width,
                  child: _field(
                    label: 'Bill Discount',
                    controller: discountController,
                    hint: '0.00 %',
                  ),
                ),

                SizedBox(
                  width: width > 700 ? 68 : width,
                  child: _filledButton(
                    label: 'Apply',
                    color: darkBlue,
                    onPressed: () {},
                  ),
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 14),

        Container(
          height: 1,
          color: const Color(0xffEEF2F6),
        ),

      ],
    );
  }

  Widget _buildBottomCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        // --------------------------------------------------------
        // MOBILE
        // --------------------------------------------------------

        if (width < 600) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildDetailsCard(),

              const SizedBox(height: 12),

              _buildLogisticsCard(),

              const SizedBox(height: 12),

              ExtraChargeView(
                saleInvoiceController: saleInvoiceController,
              ),

              const SizedBox(height: 12),

              _buildSummaryCard(),
            ],
          );
        }

        // --------------------------------------------------------
        // TABLET / SMALL DESKTOP
        // --------------------------------------------------------

        if (width < 1200) {
          return Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildLogisticsCard(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
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
                    child: ExtraChargeView(
                      saleInvoiceController: saleInvoiceController,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    flex: 3,
                    child: _buildSummaryCard(),
                  ),
                ],
              ),
            ],
          );
        }

        // --------------------------------------------------------
        // LARGE DESKTOP
        // --------------------------------------------------------

        return Row(
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

            const SizedBox(width: 12),

            Expanded(
              flex: 7,
              child: ExtraChargeView(
                saleInvoiceController: saleInvoiceController,
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
              controller: saleInvoiceController.remarkController,
              maxLines: 2,
              minLines: 2,
              style: const TextStyle(
                fontSize: 12,
                color: textDark,
              ),
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
                    color: Color(0xff475569),
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
                    minimumSize: const Size(100, 30),
                    fixedSize: const Size(100, 30),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                    ),
                    side: const BorderSide(
                      color: Color(0xffBFDBFE),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    tapTargetSize:
                    MaterialTapTargetSize.shrinkWrap,
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
        size: 16,
        color: textLight,
      ),
      prefixIconConstraints: prefix == null
          ? null
          : const BoxConstraints(
        minWidth: 36,
        minHeight: 36,
      ),
      filled: true,
      fillColor: const Color(0xffF8FAFC),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
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

  // ============================================================
  // LOGISTICS CARD
  // ============================================================

  Widget _buildLogisticsCard() {
    return _card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(
              Icons.local_shipping_outlined,
              'Logistics',
            ),

            const SizedBox(height: 10),
            CountryField(controller: countryController),
            const SizedBox(height: 10),
            StateField(controller: stateController),
            const SizedBox(height: 10),
            LeadSourceField(controller: leadSourceController),
            const SizedBox(height: 10),

            TransportField(
              controller: transportController,
              onSelected: (transport){

              },
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: _fieldBlock(
                    'LR Number',
                    _textField(
                      saleInvoiceController.lrNoController,
                      hint: 'LR No',
                      prefix: Icons.eighteen_mp
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: DateField(
                    controller: lrDateController,
                    focusNode: lrDateFocus,
                    hintText: 'Select LR Date',
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
  // AGENT DROPDOWN
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

        const SizedBox(height: 5),

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
      height: 34,
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

  /*Widget _buildAgentDropdown() {

    return SearchableCustomerDropdown<Agency>(
      value: saleInvoiceController.selectedAgent,
      height: 36,
      borderColor: Colors.grey.shade300,
      borderRadius: 8,
      items: saleInvoiceController.agents,
      onSearch: (value) {},
      displayString: (item) {
        return item.name ?? '';
      },
      onSelect: (value) {
        saleInvoiceController.setAgent(value);
      },
    );
  }*/

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
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 14,
            color: blue,
          ),
        ),

        const SizedBox(width: 9),

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


  Widget _buildChargesCard() {
    return _bottomCard(
      icon: Icons.account_balance_wallet_outlined,
      title: 'Charges & Tax',
      child: Column(
        children: [
          _moneyRow(
            'Value of Goods',
            '₹ 0.00',
          ),

          _moneyRow(
            'Discount',
            '₹ 0.00',
          ),

          const SizedBox(height: 5),

          Row(
            children: [
              Expanded(
                child: _dropdownField(
                  label: 'Other Charges',
                  value: otherCharge,
                  items: const [
                    'Other Charges',
                    'Freight',
                    'Transport',
                    'Packing',
                  ],
                  onChanged: (v) {
                    setState(() => otherCharge = v);
                  },
                ),
              ),

              const SizedBox(width: 8),

              SizedBox(
                width: 105,
                child: _field(
                  label: 'Amount',
                  controller: otherChargeController,
                  hint: '0.00',
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          _moneyRow(
            'SGST',
            '₹ 0.00',
          ),

          _moneyRow(
            'CGST',
            '₹ 0.00',
          ),

          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.only(top: 9),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Color(0xffE8EDF3),
                ),
              ),
            ),
            child: _moneyRow(
              'Round Off (+/-)',
              '₹ 0.00',
              red: true,
            ),
          ),
        ],
      ),
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
      child: ListenableBuilder(
        listenable: saleInvoiceController.updateSummery,
        builder: (context, _) {
          final supplier = saleInvoiceController.selectSupplier;

          final bool isInterState = supplier!= null &&  supplier.state!=null && supplier.state!.id != GlobalVars.placeOfSupplyId;

          return Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --------------------------------------------------
                // TITLE
                // --------------------------------------------------

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

                    Text(
                      'Qty: ${saleInvoiceController.totalQuantity}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 13),

                // --------------------------------------------------
                // VALUES
                // --------------------------------------------------

                _summaryRow(
                  'Value of Goods',
                  saleInvoiceController.getTotalGoodsValue,
                ),

                _summaryRow(
                  'Additional Discount',
                  saleInvoiceController.additionalDiscountTotal ?? 0,
                ),

                _summaryRow(
                  'Taxable Amount',
                  saleInvoiceController.valueOfTaxableGoods(),
                ),

                if (isInterState) ...[
                  _summaryRow(
                    'IGST',
                    saleInvoiceController.igst,
                  ),
                ] else ...[
                  _summaryRow(
                    'SGST',
                    saleInvoiceController.sgst,
                  ),

                  _summaryRow(
                    'CGST',
                    saleInvoiceController.cgst,
                  ),
                ],

                _summaryRow(
                  'Additional Charges',
                  saleInvoiceController.additionalCharge,
                ),

                if (saleInvoiceController.finalDiscount > 0)
                  _summaryRow(
                    'Final Discount',
                    saleInvoiceController.finalDiscount,
                  ),

                const Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 4,
                  ),
                  child: Divider(
                    color: Color(0x33FFFFFF),
                    height: 1,
                  ),
                ),

                // --------------------------------------------------
                // GRAND TOTAL
                // --------------------------------------------------

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
                      '₹ ${saleInvoiceController.grandTotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 13),

                // --------------------------------------------------
                // GENERATE CHALLAN
                // --------------------------------------------------
                _isEditMode?
                  SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: ElevatedButton.icon(
                    onPressed: saleInvoiceController.isSubmitting
                        ? null
                        : (){
                      _submitSaleInvoice(true);
                    },
                    icon: saleInvoiceController.isSubmitting
                        ? const SizedBox(
                      width: 17,
                      height: 17,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Icon(
                      Icons.check_circle_outline_rounded,
                      size: 18,
                    ),
                    label: Text(
                      saleInvoiceController.isSubmitting
                          ? 'Updating...'
                          : 'Update Challan',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      const Color(0xff3B82F6),
                      disabledBackgroundColor:
                      const Color(0xff3B82F6),
                      foregroundColor: Colors.white,
                      disabledForegroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ):
                  SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: ElevatedButton.icon(
                    onPressed: saleInvoiceController.isSubmitting
                        ? null
                        : (){_submitSaleInvoice(false);},
                    icon: saleInvoiceController.isSubmitting
                        ? const SizedBox(
                      width: 17,
                      height: 17,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Icon(
                      Icons.check_circle_outline_rounded,
                      size: 18,
                    ),
                    label: Text(
                      saleInvoiceController.isSubmitting
                          ? 'Generating...'
                          : 'Generate Sale Invoice',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      const Color(0xff3B82F6),
                      disabledBackgroundColor:
                      const Color(0xff3B82F6),
                      foregroundColor: Colors.white,
                      disabledForegroundColor: Colors.white,
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
        },
      ),
    );
  }

  Widget _summaryRow(
      String title,
      double value,
      ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 5,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(width: 10),

          Text(
            '₹ ${value.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(14),
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: cardBorder,
        ),
      ),
      padding: padding,
      child: child,
    );
  }

  Widget _bottomCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return _card(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            icon: icon,
            title: title,
          ),

          const SizedBox(height: 16),

          child,
        ],
      ),
    );
  }

  Widget _sectionHeader({
    required IconData icon,
    required String title,
    String? subtitle,
  }) {
    return Row(
      children: [
        _iconBox(icon),

        const SizedBox(width: 9),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: textDark,
                ),
              ),

              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 9,
                    color: textMedium,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _iconBox(IconData icon) {
    return Container(
      width: 31,
      height: 31,
      decoration: BoxDecoration(
        color: const Color(0xffEAF2FF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        size: 16,
        color: primaryBlue,
      ),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    String? hint,
    Widget? suffix,
    int maxLines = 1,
    bool isReadOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label),

        const SizedBox(height: 6),

        SizedBox(
          height: maxLines == 1 ? 36 : 72,
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            readOnly: isReadOnly,
            style: const TextStyle(
              fontSize: 11,
              color: textDark,
            ),
            decoration: _decoration(
              hint: hint,
              suffix: suffix,
            ),
          ),
        ),
      ],
    );
  }

  Widget _dropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String? hint,
  }) {
    final safeValue =
    items.contains(value) ? value : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label),

        const SizedBox(height: 6),

        SizedBox(
          height: 36,
          child: DropdownButtonFormField<String>(
            value: safeValue,
            isExpanded: true,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: textLight,
            ),
            style: const TextStyle(
              fontSize: 11,
              color: textDark,
            ),
            decoration: _decoration(
              hint: hint,
            ),
            items: items.map(
                  (item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: textDark,
                    ),
                  ),
                );
              },
            ).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  InputDecoration _decoration({
    String? hint,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontSize: 10,
        color: textLight,
      ),
      filled: true,
      fillColor: inputBg,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 9,
      ),
      suffixIcon: suffix,
      suffixIconConstraints: suffix == null
          ? null
          : const BoxConstraints(
        minWidth: 34,
        minHeight: 34,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(
          color: cardBorder,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(
          color: cardBorder,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(
          color: primaryBlue,
          width: 1.2,
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 9.5,
        fontWeight: FontWeight.w600,
        color: textMedium,
      ),
    );
  }

  Widget _moneyRow(
      String title,
      String amount, {
        bool red = false,
      }) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 10,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 10,
                color: red
                    ? const Color(0xffEF4444)
                    : textMedium,
                fontWeight:
                red ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 10,
              color: red
                  ? const Color(0xffEF4444)
                  : textDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryMoneyRow(
      String title,
      String amount,
      ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 9,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 10,
              ),
            ),
          ),
          Text(
            amount,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _filledButton({
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 36,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _smallHeaderButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
        ),
        decoration: BoxDecoration(
          color: const Color(0xffF8FAFC),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: cardBorder,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: textMedium,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryButton(
      String text,
      Color bg,
      Color fg,
      VoidCallback onPressed,
      ) {
    return SizedBox(
      height: 38,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: 0,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  void _resetForm() {
    setState(() {
      invoiceController.text = 'TN/26-27-3241';
      //dateController.text = '07/10/2026';

      mobileController.clear();
      nameController.clear();
      gstController.clear();
      discountController.clear();
      caseController.clear();
      destinationController.clear();
      remarkController.clear();
      otherChargeController.clear();
      commissionController.clear();

      salesman = null;
      backman = null;
      supplier = null;
      transport = 'Transport';
      country = 'India';
      supply = 'Tamil Nadu';
      leadSource = null;
      agent = null;
      otherCharge = 'Other Charges';

      products
        ..clear()
        ..add(0);
    });
  }

  void _submitSaleInvoice(bool isUpdate) {
    if (saleInvoiceController.isSubmitting) {
      return;
    }

    // ----------------------------------------------------------
    // SUPPLIER
    // ----------------------------------------------------------

    if (saleInvoiceController.selectSupplier == null) {
      Toast.show(message: 'Please select a supplier', type: .error);
      return;
    }

    if (saleInvoiceController.challanNo.trim().isEmpty) {
      Toast.show(message: 'Please Enter challan Nor', type: .error);
      return;
    }

    if (saleInvoiceController.selectedData.trim().isEmpty) {
      Toast.show(message: 'Please Select date', type: .error);
      return;
    }

    // ----------------------------------------------------------
    // ITEMS
    // ----------------------------------------------------------

    if (saleInvoiceController.items.isEmpty) {
      Toast.show(message: 'No product added', type: .error);
      return;
    }

    // ----------------------------------------------------------
    // VALIDATE EVERY PRODUCT
    // ----------------------------------------------------------

    for (int index = 0;
    index < saleInvoiceController.items.length;
    index++) {
      final item = saleInvoiceController.items[index];

      if (item.product == null) {
        Toast.show(message: 'Please select product for item ${index + 1}', type: .error);

        return;
      }

      if (item.product!.color == null) {
        Toast.show(message: 'Please select color for item ${index + 1}', type: .error);

        return;
      }

      if (item.product!.size == null) {
        Toast.show(message:'Please select size for item ${index + 1}', type: .error);

        return;
      }

      if (item.productPrice == null ||
          item.productPrice! <= 0) {
        Toast.show(message:  'Please enter amount for item ${index + 1}', type: .error);

        return;
      }
    }

    saleInvoiceController.submitChallan(isUpdate);
  }
}

class CreateCustomerDialog extends StatefulWidget {
  const CreateCustomerDialog({
    super.key,
  });

  @override
  State<CreateCustomerDialog> createState() =>
      _CreateCustomerDialogState();
}

class _CreateCustomerDialogState
    extends State<CreateCustomerDialog> {

  static const Color primary = Color(0xff1557B0);
  static const Color background = Color(0xffF5F7FB);
  static const Color border = Color(0xffE1E6EF);
  static const Color textDark = Color(0xff172033);
  static const Color textGrey = Color(0xff697386);

  final customerNameController = TextEditingController();
  final mobileController = TextEditingController();
  final addressController = TextEditingController();
  final pincodeController = TextEditingController();

  final companyNameController = TextEditingController();
  final gstController = TextEditingController();
  final panController = TextEditingController();
  final aadharController = TextEditingController();

  String customerType = 'B2B';

  String selectedState = 'Uttar Pradesh';
  String selectedCity = 'New Delhi';
  String selectedAgent = 'Select Agent';
  String selectedMembership = 'Silver';

  @override
  void dispose() {
    customerNameController.dispose();
    mobileController.dispose();
    addressController.dispose();
    pincodeController.dispose();

    companyNameController.dispose();
    gstController.dispose();
    panController.dispose();
    aadharController.dispose();



    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 45,
        vertical: 30,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 1180,
          maxHeight: 850,
        ),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          clipBehavior: Clip.antiAlias,
          elevation: 18,
          child: Column(
            children: [
              _buildHeader(),

              Expanded(
                child: Container(
                  color: background,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      28,
                      26,
                      28,
                      24,
                    ),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        _buildCustomerSection(),

                        const SizedBox(height: 20),

                        _buildCompanySection(),
                      ],
                    ),
                  ),
                ),
              ),

              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 26),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            primaryAppColor,
            primaryPurpleDark,
          ],
        ),
      ),
      child: Row(
        children: [

          // Icon
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.13),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.person_add_alt_1_rounded,
              color: Colors.white,
              size: 23,
            ),
          ),

          const SizedBox(width: 14),

          // Title
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create New Customer',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -.2,
                ),
              ),

              SizedBox(height: 3),

              Text(
                'Add customer and business information',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),

          const Spacer(),

          // Close
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 21,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerSection() {
    return _sectionCard(
      icon: Icons.person_outline_rounded,
      title: 'Customer Details',
      subtitle: 'Basic information about the customer',
      child: Column(
        children: [

          Row(
            children: [
              const Text(
                'Customer Type',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textGrey,
                ),
              ),

              const SizedBox(width: 16),

              _buildCustomerTypeSelector(),
            ],
          ),

          const SizedBox(height: 25),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Expanded(
                child: _buildTextField(
                  label: 'Customer Name',
                  hint: 'Enter customer name',
                  controller: customerNameController,
                  icon: Icons.person_outline_rounded,
                  required: true,
                ),
              ),

              const SizedBox(width: 18),

              Expanded(
                child: _buildTextField(
                  label: 'Mobile Number',
                  hint: 'Enter mobile number',
                  controller: mobileController,
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  required: true,
                ),
              ),

              const SizedBox(width: 18),

              Expanded(
                child: _buildTextField(
                  label: 'Address',
                  hint: 'Enter address',
                  controller: addressController,
                  icon: Icons.location_on_outlined,
                ),
              ),
            ],
          ),

          const SizedBox(height: 19),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Expanded(
                child: _buildDropdown(
                  label: 'Place of Supply',
                  value: selectedState,
                  icon: Icons.map_outlined,
                  items: const [
                    'Uttar Pradesh',
                    'Delhi',
                    'Haryana',
                    'Rajasthan',
                    'Maharashtra',
                    'Gujarat',
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedState = value!;
                    });
                  },
                ),
              ),

              const SizedBox(width: 18),

              Expanded(
                child: _buildDropdown(
                  label: 'City',
                  value: selectedCity,
                  icon: Icons.location_city_outlined,
                  items: const [
                    'New Delhi',
                    'Noida',
                    'Ghaziabad',
                    'Lucknow',
                    'Kanpur',
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedCity = value!;
                    });
                  },
                ),
              ),

              const SizedBox(width: 18),

              Expanded(
                child: _buildTextField(
                  label: 'Pincode',
                  hint: 'Enter pincode',
                  controller: pincodeController,
                  icon: Icons.markunread_mailbox_outlined,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompanySection() {
    return _sectionCard(
      icon: Icons.business_outlined,
      title: 'Company Details',
      subtitle: 'Business and registration information',
      child: Column(
        children: [

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Expanded(
                child: _buildTextField(
                  label: 'Company Name',
                  hint: 'Enter company name',
                  controller: companyNameController,
                  icon: Icons.business_outlined,
                ),
              ),

              const SizedBox(width: 18),

              Expanded(
                child: _buildTextField(
                  label: 'GST Number',
                  hint: 'Enter GST number',
                  controller: gstController,
                  icon: Icons.receipt_long_outlined,
                ),
              ),

              const SizedBox(width: 18),

              Expanded(
                child: _buildTextField(
                  label: 'PAN Number',
                  hint: 'Enter PAN number',
                  controller: panController,
                  icon: Icons.credit_card_outlined,
                ),
              ),
            ],
          ),

          const SizedBox(height: 19),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Expanded(
                child: _buildTextField(
                  label: 'Aadhaar Number',
                  hint: 'Enter Aadhaar number',
                  controller: aadharController,
                  icon: Icons.badge_outlined,
                  keyboardType: TextInputType.number,
                ),
              ),

              const SizedBox(width: 18),

              Expanded(
                child: _buildDropdown(
                  label: 'Agent',
                  value: selectedAgent,
                  icon: Icons.support_agent_outlined,
                  items: const [
                    'Select Agent',
                    'Agent 1',
                    'Agent 2',
                    'Agent 3',
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedAgent = value!;
                    });
                  },
                ),
              ),

              const SizedBox(width: 18),

              Expanded(
                child: _buildDropdown(
                  label: 'Membership',
                  value: selectedMembership,
                  icon: Icons.workspace_premium_outlined,
                  items: const [
                    'Silver',
                    'Gold',
                    'Platinum',
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedMembership = value!;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        22,
        19,
        22,
        22,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.025),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [

              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: primary.withOpacity(.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: primary,
                  size: 20,
                ),
              ),

              const SizedBox(width: 12),

              Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: textDark,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: textGrey,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          Container(
            height: 1,
            color: const Color(0xffEEF1F5),
          ),

          const SizedBox(height: 21),

          child,
        ],
      ),
    );
  }

  Widget _buildCustomerTypeSelector() {
    return Container(
      height: 40,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xffF0F3F8),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _customerTypeButton(
            'B2C',
            Icons.person_outline,
          ),
          _customerTypeButton(
            'B2B',
            Icons.business_outlined,
          ),
        ],
      ),
    );
  }

  Widget _customerTypeButton(
      String title,
      IconData icon,
      ) {
    final bool selected = customerType == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          customerType = title;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 34,
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
        ),
        decoration: BoxDecoration(
          color: selected
              ? Colors.white
              : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
          boxShadow: selected
              ? [
            BoxShadow(
              color: Colors.black.withOpacity(.07),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ]
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: selected
                  ? primary
                  : textGrey,
            ),

            const SizedBox(width: 7),

            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected
                    ? FontWeight.w700
                    : FontWeight.w500,
                color: selected
                    ? primary
                    : textGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    bool required = false,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        _fieldLabel(
          label,
          required: required,
        ),

        const SizedBox(height: 7),

        SizedBox(
          height: 44,
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(
              fontSize: 13.5,
              color: textDark,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: Color(0xffA3ACBB),
                fontSize: 13.5,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Icon(
                icon,
                size: 18,
                color: const Color(0xff8A94A6),
              ),
              filled: true,
              fillColor: const Color(0xffFBFCFE),
              contentPadding:
              const EdgeInsets.symmetric(
                horizontal: 12,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: border,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: primary,
                  width: 1.3,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required IconData icon,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        _fieldLabel(label),

        const SizedBox(height: 7),

        SizedBox(
          height: 44,
          child: DropdownButtonFormField<String>(
            initialValue: value,
            isExpanded: true,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 20,
              color: Color(0xff667085),
            ),
            style: const TextStyle(
              fontSize: 13.5,
              color: textDark,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                size: 18,
                color: const Color(0xff8A94A6),
              ),
              filled: true,
              fillColor: const Color(0xffFBFCFE),
              contentPadding:
              const EdgeInsets.symmetric(
                horizontal: 12,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: border,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: primary,
                  width: 1.3,
                ),
              ),
            ),
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
        ),
      ],
    );
  }

  Widget _fieldLabel(
      String title, {
        bool required = false,
      }) {
    return RichText(
      text: TextSpan(
        text: title,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        children: required
            ? const [
          TextSpan(
            text: ' *',
            style: TextStyle(
              color: Color(0xffE53935),
            ),
          ),
        ]
            : null,
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(
        horizontal: 28,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color(0xffE8ECF2),
          ),
        ),
      ),
      child: Row(
        children: [

          const Icon(
            Icons.info_outline_rounded,
            size: 17,
            color: Color(0xff8A94A6),
          ),

          const SizedBox(width: 8),

          const Text(
            'Fields marked with * are required',
            style: TextStyle(
              fontSize: 11.5,
              color: textGrey,
            ),
          ),

          const Spacer(),

          // Cancel
          OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(100, 42),
              side: const BorderSide(
                color: border,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              foregroundColor: textDark,
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Create
          ElevatedButton.icon(
            onPressed: _createCustomer,
            icon: const Icon(
              Icons.person_add_alt_1_rounded,
              size: 17,
            ),
            label: const Text(
              'Create Customer',
            ),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(165, 42),
              backgroundColor: primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _createCustomer() {
    if (customerNameController.text.trim().isEmpty) {
      _showError('Please enter customer name');
      return;
    }

    if (mobileController.text.trim().isEmpty) {
      _showError('Please enter mobile number');
      return;
    }

    // Your API / GetX controller call here.

    debugPrint(
      'Creating customer: '
          '${customerNameController.text}',
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}