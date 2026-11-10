import 'package:calculation_panel/core/widget/country_field.dart';
import 'package:calculation_panel/core/widget/lead_source.dart';
import 'package:calculation_panel/core/widget/state_field.dart';
import 'package:calculation_panel/core/widget/toast.dart';
import 'package:calculation_panel/features/dashboard/data/controller/routes_controller.dart';
import 'package:calculation_panel/features/sale_invoice/controller/sale_invoice_controller.dart';
import 'package:calculation_panel/features/sale_invoice/representaion/product_selection_section/product_selection_section.dart';
import 'package:flutter/material.dart';
import 'package:calculation_panel/core/theme/colors.dart';
import '../../../core/database/local_store_manager.dart';
import '../../../core/routes/routes.dart';
import '../../../core/vars/global_vars.dart';
import '../../../core/widget/date_field.dart';
import '../../../core/widget/ratetype_field.dart';
import '../../../core/widget/series_field.dart';
import '../../../core/widget/store_field.dart';
import '../../../core/widget/supplier_field.dart';
import '../../../core/widget/team_field.dart';
import '../../../core/widget/transport_field.dart';
import 'extra_charge/extra_charge_sales.dart';

part 'sale_invoice_page_header.dart';
part 'sale_invoice_page_sections.dart';
part 'sale_invoice_page_helpers.dart';
part 'create_customer_dialog.dart';

class SaleInvoicePage extends StatefulWidget {
  final String? challanId;
  final RoutesController routesController;
  const SaleInvoicePage({super.key, this.challanId, required this.routesController});

  @override
  State<SaleInvoicePage> createState() => _SaleInvoicePageState();
}

class _SaleInvoicePageState extends State<SaleInvoicePage> {
  final bool _isEditMode= false;
  late final SaleInvoiceController saleInvoiceController = SaleInvoiceController();

  static const Color primaryBlue = Color(0xff3B82F6);
  static const Color darkBlue = Color(0xff172B4D);

  static const Color pageBg = Color(0xffF4F6FA);
  static const Color cardBorder = Color(0xffE2E8F0);

  static const Color textDark = Color(0xff1E293B);
  static const Color textMedium = Color(0xff64748B);
  static const Color textLight = Color(0xff94A3B8);

  static const Color inputBg = Color(0xffF8FAFC);

  final invoiceController = TextEditingController(text: 'TN/26-27-3241');

  final mobileController = TextEditingController();

  final nameController = TextEditingController();

  final gstController = TextEditingController();

  final discountController = TextEditingController();

  final caseController = TextEditingController();

  final destinationController = TextEditingController();

  final remarkController = TextEditingController();

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

  @override
  void initState() {
    GlobalVars.globalRoutes = Routes.saleInvoiceScreen;

    countryController.addListener(() {
      saleInvoiceController.selectedCountry = countryController.value;
    });
    stateController.addListener(() {
      saleInvoiceController.selectedStateData = stateController.value;
    });
    leadSourceController.addListener(() {
      saleInvoiceController.selectedLeadSource = leadSourceController.value;
    });
    transportController.addListener(() {
      saleInvoiceController.selectedTransport = transportController.value;
    });

    saleInvoiceController.onDraftLoaded = () {
      if (!mounted) return;
      setState(() {
        if (saleInvoiceController.selectSupplier != null) {
          customerController.selectSupplier(saleInvoiceController.selectSupplier);
          nameController.text = saleInvoiceController.selectSupplier!.company;
          gstController.text = saleInvoiceController.selectSupplier!.gstNo;
        }
        if (saleInvoiceController.selectedStore != null) {
          storeController.selectStore(Store(
            id: saleInvoiceController.selectedStore!.id ?? '',
            store: saleInvoiceController.selectedStore!.store ?? '',
            shortName: saleInvoiceController.selectedStore!.shortName ?? '',
          ));
        }
        if (saleInvoiceController.selectedTransport != null) {
          transportController.selectTransport(saleInvoiceController.selectedTransport);
        }
        if (saleInvoiceController.selectedCountry != null) {
          countryController.selectCountry(saleInvoiceController.selectedCountry);
        }
        if (saleInvoiceController.selectedStateData != null) {
          stateController.selectState(saleInvoiceController.selectedStateData);
        }
        if (saleInvoiceController.selectedLeadSource != null) {
          leadSourceController.selectLeadSource(saleInvoiceController.selectedLeadSource);
        }
        if (saleInvoiceController.rateType != null) {
          rateTypeController.selectRateType(saleInvoiceController.rateType);
        }
        if (saleInvoiceController.selectedData.isNotEmpty) {
          dateController.dateController.text = saleInvoiceController.selectedData;
        }
        if (saleInvoiceController.lrDateController.text.isNotEmpty) {
          lrDateController.dateController.text = saleInvoiceController.lrDateController.text;
        }
      });
    };
    super.initState();
  }

  @override
  void dispose() {
    storeFocus.dispose();
    rateFocus.dispose();
    customerFocus.dispose();
    teamFocus.dispose();
    dateFocus.dispose();
    lrDateFocus.dispose();
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
    lrDateController.dispose();
    seriesController.dispose();
    rateTypeController.dispose();
    storeController.dispose();
    countryController.dispose();
    leadSourceController.dispose();
    stateController.dispose();
    customerController.dispose();
    transportController.dispose();
    teamController.dispose();
    saleInvoiceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBg,
      body: SafeArea(
        child: ListenableBuilder(
          listenable:saleInvoiceController,
          builder: (BuildContext context, Widget? child) {
            return LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(),

                      const SizedBox(height: 12),

                      ProductSelectionSalesSection(
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
            );
          },
        ),
      ),
    );}
}