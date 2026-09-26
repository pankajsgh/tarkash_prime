import 'package:calculation_panel/core/database/local_data/store_json.dart';
import 'package:calculation_panel/core/vars/global_vars.dart';
import 'package:flutter/material.dart';

import '../../../../core/network/api_path.dart';
import '../../../../core/network/api_repository.dart';
import '../../../../core/ulitls/utility.dart';
import '../../../purchase_challan/model/dashboard_model.dart';
import '../../../purchase_challan/model/store_model.dart';

class DashboardController extends ChangeNotifier {
  // ============================================================
  // Dashboard Summary
  // ============================================================

  double todaySales = 84520;
  double todayPurchase = 42300;
  double receivable = 182450;
  double payable = 94200;

  int todayInvoices = 12;
  int todayBills = 8;
  int receivableCustomers = 24;
  int payableSuppliers = 15;
  bool isLoading = true;
  DashboardModel? dashboardModel;


  Future<void> getPartyDashboard() async {

    String deviceId = await getDeviceId();

    isLoading = true;
    notifyListeners();
    Map<String, dynamic> requestBody = {};
    requestBody['uid'] = GlobalVars.userId;
    requestBody['device_id'] = '';
    requestBody['App_Version'] = GlobalVars.appVersion;
    var response = await ApiProvider.createServerRequest(apiUrl: ApiPath.dashboardUrl, requestBody: requestBody, isFormData: true);

    if(response['error']!=null && response['error'])
    {
      try{

        dashboardModel = DashboardModel.fromJson(response);
        if(dashboardModel!=null && dashboardModel!.placeOfSupply!=null && dashboardModel!.placeOfSupply!.id!=null)
          {
            GlobalVars.placeOfSupply = dashboardModel!.placeOfSupply!.name!;
            GlobalVars.placeOfSupplyId = dashboardModel!.placeOfSupply!.id!;
          }

        notifyListeners();
      } catch(e){
        print(e);
      }
    }

    isLoading = false;
    notifyListeners();
  }


  Future<void> getStoreData() async {


    notifyListeners();
    Map<String, dynamic> requestBody = {};
    requestBody['uid'] = GlobalVars.userId;
    requestBody['search'] = '';
    var response = await ApiProvider.createServerRequest(apiUrl: ApiPath.getStoreList, requestBody: requestBody, isFormData: true);
    if(GlobalVars.isOffline)
    {
      response = storeJson;
    }

    if(response['error']!=null && response['error'])
    {
      try{
        var data = StoreListResponse.fromJson(response);

        GlobalVars.storeList = data.storeList;

        notifyListeners();
      } catch(e){
        print(e);
      }
    }

    isLoading = false;
    notifyListeners();
  }

  // ============================================================
  // Sales Chart
  // ============================================================

  final List<String> salesDays = [
    '11 May',
    '12 May',
    '13 May',
    '14 May',
    '15 May',
    '16 May',
    '17 May',
  ];

  final List<double> salesValues = [
    42000,
    65000,
    77000,
    92000,
    76000,
    58000,
    45000,
  ];

  String salesPeriod = 'This Week';

  // ============================================================
  // Payment Status
  // ============================================================

  int totalPayments = 258;

  int paidPayments = 175;
  int pendingPayments = 57;
  int overduePayments = 26;

  // ============================================================
  // Recent Invoices
  // ============================================================

  final List<InvoiceModel> recentInvoices = [
    InvoiceModel(
      invoiceNo: 'INV-1024',
      customer: 'ABC Ltd.',
      date: '17 May 2025',
      amount: 8450,
      status: 'Paid',
    ),
    InvoiceModel(
      invoiceNo: 'INV-1023',
      customer: 'XYZ Traders',
      date: '17 May 2025',
      amount: 4200,
      status: 'Pending',
    ),
    InvoiceModel(
      invoiceNo: 'INV-1022',
      customer: 'Shree Enterprises',
      date: '16 May 2025',
      amount: 12750,
      status: 'Paid',
    ),
    InvoiceModel(
      invoiceNo: 'INV-1021',
      customer: 'Krishna Stores',
      date: '16 May 2025',
      amount: 6980,
      status: 'Overdue',
    ),
    InvoiceModel(
      invoiceNo: 'INV-1020',
      customer: 'Mahesh & Co.',
      date: '15 May 2025',
      amount: 9300,
      status: 'Paid',
    ),
  ];

  // ============================================================
  // Top Customers
  // ============================================================

  final List<CustomerModel> topCustomers = [
    CustomerModel(
      name: 'ABC Ltd.',
      sales: 125400,
      invoices: 18,
    ),
    CustomerModel(
      name: 'XYZ Traders',
      sales: 98750,
      invoices: 14,
    ),
    CustomerModel(
      name: 'Shree Enterprises',
      sales: 76300,
      invoices: 11,
    ),
    CustomerModel(
      name: 'Krishna Stores',
      sales: 55200,
      invoices: 9,
    ),
    CustomerModel(
      name: 'Mahesh & Co.',
      sales: 43650,
      invoices: 7,
    ),
  ];

  // ============================================================
  // Actions
  // ============================================================

  void changeSalesPeriod(String period) {
    salesPeriod = period;

    if (period == 'This Week') {
      salesValues
        ..clear()
        ..addAll([
          42000,
          65000,
          77000,
          92000,
          76000,
          58000,
          45000,
        ]);
    } else if (period == 'This Month') {
      salesValues
        ..clear()
        ..addAll([
          85000,
          92000,
          78000,
          110000,
          125000,
          98000,
          135000,
        ]);
    } else {
      salesValues
        ..clear()
        ..addAll([
          450000,
          520000,
          480000,
          610000,
          590000,
          680000,
          720000,
        ]);
    }

    notifyListeners();
  }

  void refreshDashboard() {
    // API call can be placed here.

    notifyListeners();
  }

  void createSalesInvoice() {
    debugPrint('Create Sales Invoice');
  }

  void createPurchaseBill() {
    debugPrint('Create Purchase Bill');
  }

  void addCustomer() {
    debugPrint('Add Customer');
  }

  void addSupplier() {
    debugPrint('Add Supplier');
  }

  void openReports() {
    debugPrint('Open Reports');
  }
}


// ============================================================
// Models
// ============================================================

class InvoiceModel {
  final String invoiceNo;
  final String customer;
  final String date;
  final double amount;
  final String status;

  InvoiceModel({
    required this.invoiceNo,
    required this.customer,
    required this.date,
    required this.amount,
    required this.status,
  });
}

class CustomerModel {
  final String name;
  final double sales;
  final int invoices;

  CustomerModel({
    required this.name,
    required this.sales,
    required this.invoices,
  });
}