import 'package:calculation_panel/core/ulitls/utility.dart';
import 'package:calculation_panel/core/vars/global_vars.dart';
import 'package:calculation_panel/features/dashboard/representaion/supplier_header/model/supplier_model.dart';
import 'package:flutter/material.dart';
import '../../../core/network/api_path.dart';
import '../../../core/network/api_repository.dart';
import '../../../core/ulitls/calculation.dart';
import '../../../core/widget/toast.dart';
import '../model/product_model.dart';
import 'model/purchase_model.dart';

class PurchaseController extends ChangeNotifier {
  final TextEditingController lrNoController = TextEditingController();
  final TextEditingController lrDateController = TextEditingController();
  final TextEditingController remarkController = TextEditingController();
  final TextEditingController applyDiscountController = TextEditingController();
  double additionalChargeValue = 0.0;

  void update(){
    notifyListeners();
  }

  String selectedData = '';
  Party? selectSupplier;
  Agency? selectedAgent;
  List<ProductModel> products = [];

  void setSupplier(Party? value){
    items.clear();
    addItem();
    selectSupplier = value;
    getProductList('');
  }

  void setData(String value){
    selectedData =value;
  }

  void selectProduct(PurchaseItem item, ProductModel product, {String? qty}) {
      item.productId = product.id;
      item.product = product;
      item.nameController.text = product.name?? "";
      item.brandController.text = product.brand!.name?? "";
      item.quantityController.text = qty?? '1';
      item.discountController.text = '0';
      notifyListeners();
  }

  Future<List<ProductModel>> getProductList(String search) async {

    if(selectSupplier==null)
      {
        showMessage("Please select supplier", ToastType.error);
        return [];
      }

    Map<String, dynamic> requestBody = {};
    requestBody['SupplierId'] = selectSupplier!=null? selectSupplier!.id: "";
    requestBody['BillDate'] = GlobalVars.currentData;
    requestBody['search'] = search;
    requestBody['limit'] = "0";
    var response = await ApiProvider.createServerRequest(apiUrl: ApiPath.getProductList, requestBody: requestBody, isFormData: true);

    if(response['error']!=null && response['error'])
    {
      try{
        var data = ProductListResponse.fromJson(response);
        products = data.productList;
      } catch(e){
        print(e);
      }
    } else {
      products.clear();
    }

    notifyListeners();
    return products;
  }


  List<Agency> agents = [];

  double? additionalDiscountTotal = 0.0;
  List<double> additionalDiscountList = [];

  final List<PurchaseItem> items = [];

  int get totalItems => items.length;

  int get totalQuantity {
    int total = 0;

    for (final item in items) {
      total += item.quantity;
    }
    return total;
  }

  // ============================================================
  // VALUE OF GOODS
  // ============================================================

  double get valueOfGoods {
    double total = 0;
    if(additionalDiscountTotal!=null)
      {
        additionalDiscountList = distributeProportionally(totalAmount: additionalDiscountTotal!, proportions: items.map((e)=> e.getAmount).toList());
      }
   
    for(var x=0; x<items.length; x++)
     {
       var item = items[x];
       if(item.amount!=null) {
         if(items.length==additionalDiscountList.length && x<additionalDiscountList.length)
           {
             var discountProportion =  additionalDiscountList[x];
             item.itemFinalPrice = (item.amount!*item.quantity)-discountProportion;
             total += item.itemFinalPrice;
           } else {
           item.itemFinalPrice  = item.amount!*item.quantity;
           total += item.amount!*item.quantity;
         }
       }
     }
    return total;
  }

  // ============================================================
  // DISCOUNT
  // ============================================================

  double get appliedDiscount {
    return _parseDouble(applyDiscountController.text);
  }

  void applyDiscountAll(){
    for(var x in items)
    {
      x.discountController.text = appliedDiscount.toString();
      x.amount = calculatePriceAfterDiscount(price: x.purchase, discount: appliedDiscount);
    }
    applyDiscountController.clear();
    notifyListeners();
  }

  double get additionalCharge {
    return additionalChargeValue;
  }

  // ============================================================
  // GST
  // ============================================================

  double get sgst {
    double sgstValue = 0.0;

    for (final item in items) {
      final double tax = double.tryParse(item.getGST) ?? 0.0;
      sgstValue += (item.itemFinalPrice * (tax / 2)) / 100;
    }

    return sgstValue;
  }

  double get cgst {
    double cgstValue = 0.0;

    for (final item in items) {
      final double tax =
          double.tryParse(item.getGST) ?? 0.0;
      cgstValue += (item.itemFinalPrice * (tax / 2)) / 100;
    }

    return cgstValue;
  }

  double get igst {
    double cgstValue = 0.0;

    for (final item in items) {
      final double tax =
          double.tryParse(item.getGST) ?? 0.0;
      cgstValue += (item.itemFinalPrice * (tax)) / 100;
    }

    return cgstValue;
  }

  // ============================================================
  // GRAND TOTAL
  // ============================================================

  double get grandTotal {
    return valueOfGoods +
        sgst +
        cgst +
        additionalChargeValue;
  }

  // ============================================================
  // SAFE DOUBLE PARSER
  // ============================================================

  double _parseDouble(String value) {
    return double.tryParse(value.trim()) ?? 0;
  }



  // ============================================================
  // AGENT
  // ============================================================

  void setAgent(Agency? value) {
    if (selectedAgent == value) return;
    selectedAgent = value;
    notifyListeners();
  }

  // ============================================================
  // ADDITIONAL CHARGE TYPE
  // ============================================================

  void setAdditionalDiscount(double? value) {
    additionalDiscountTotal = value?? 0;
  }

  void setAdditionalCharge(double? value) {
    additionalChargeValue = value?? 0;
  }


  // ============================================================
  // LR DATE
  // ============================================================

  Future<void> selectLrDate(BuildContext context) async {
    final currentDate = _parseDate(lrDateController.text);

    final result = await showDatePicker(
      context: context,
      initialDate: currentDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xff2563EB),
            ),
          ),
          child: child!,
        );
      },
    );

    if (result == null) return;

    lrDateController.text = _formatDate(result);

    notifyListeners();
  }

  // ============================================================
  // FORMAT DATE
  // ============================================================

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  // ============================================================
  // PARSE DATE
  // ============================================================

  DateTime? _parseDate(String value) {
    final parts = value.split('/');

    if (parts.length != 3) {
      return null;
    }

    final day = int.tryParse(parts[0]);

    final month = int.tryParse(parts[1]);

    final year = int.tryParse(parts[2]);

    if (day == null || month == null || year == null) {
      return null;
    }

    try {
      return DateTime(year, month, day);
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // ADD ITEM
  // ============================================================

  void addItem() {
    final item = PurchaseItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      onChanged: notifyListeners,
    );

    item.quantityController.text = '1';
    item.purchaseController.text = '0';
    item.mrpRateController.text = '0';
    item.wholesaleRateController.text = '0';
    item.retailRateController.text = '0';
    item.discountController.text = '0';

    items.add(item);

    notifyListeners();
  }

  // ============================================================
  // REMOVE ITEM
  // ============================================================

  void removeItem(int index) {
    if (index < 0 || index >= items.length) {
      return;
    }

    if(items.length==1){
      addItem();
    }

    final item = items.removeAt(index);

    item.dispose();

    notifyListeners();
  }

  // ============================================================
  // UPDATE ITEM
  // ============================================================

  void updateItem(int index) {
    if (index < 0 || index >= items.length) {
      return;
    }

    notifyListeners();
  }

  // ============================================================
  // CLEAR ITEMS
  // ============================================================

  void clearItems() {
    for (final item in items) {
      item.dispose();
    }

    items.clear();

    notifyListeners();
  }

  // ============================================================
  // CLEAR ALL
  // ============================================================

  void clearAll() {

    lrNoController.clear();

    lrDateController.clear();

    remarkController.clear();

    applyDiscountController.text = '0';

    selectedAgent = null;

    additionalChargeValue =0;

    for (final item in items) {
      item.dispose();
    }

    items.clear();

    notifyListeners();
  }

  // ============================================================
  // GENERATE CHALLAN
  // ============================================================

  void generateChallan() {
    debugPrint(
      '======================================',
    );

    debugPrint('Generating Purchase Challan');

     debugPrint(
      'Agent: $selectedAgent',
    );

    debugPrint(
      'Total Items: $totalItems',
    );

    debugPrint(
      'Total Quantity: $totalQuantity',
    );

    debugPrint(
      'Value of Goods: $valueOfGoods',
    );

    debugPrint(
      'Discount: $applyDiscountController',
    );

    debugPrint(
      'Additional Charge: $additionalCharge',
    );

    debugPrint(
      'SGST: $sgst',
    );

    debugPrint(
      'CGST: $cgst',
    );

    debugPrint(
      'Grand Total: $grandTotal',
    );

    debugPrint(
      '======================================',
    );

    // TODO:
    // API CALL
  }



  @override
  void dispose() {
    lrNoController.dispose();
    lrDateController.dispose();
    remarkController.dispose();
    applyDiscountController.dispose();

    for (final item in items) {
      item.dispose();
    }

    items.clear();
    super.dispose();
  }
}


