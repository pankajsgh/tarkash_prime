import 'package:calculation_panel/core/ulitls/utility.dart';
import 'package:calculation_panel/features/dashboard/representaion/model/color_model.dart';
import 'package:calculation_panel/features/dashboard/representaion/model/hsn_model.dart';
import 'package:calculation_panel/features/dashboard/representaion/model/size_model.dart';
import 'package:calculation_panel/features/dashboard/representaion/supplier_header/model/supplier_model.dart';
import 'package:flutter/material.dart';
import '../../../../core/network/api_path.dart';
import '../../../../core/network/api_repository.dart';
import '../../../../core/widget/toast.dart';
import '../model/category_model.dart';
import '../model/sub_cat_model.dart';

class ProductAttribute {
  SizeModel? size;
  ColorModel? color;
  String quantity;
  String purchasePrice;

  ProductAttribute({
    this.size,
    this.color,
    this.quantity = '',
    this.purchasePrice = '',
  });
}

class CreateProductController extends ChangeNotifier {

  final productNameController = TextEditingController();
  final supplierNameController = TextEditingController();
  List<CategoryModel> categoryList = [];
  List<SubCategoryModel> subCategoryList = [];

  CategoryModel? selectedCategory;
  SubCategoryModel? selectedSubCategory;
  BrandItem? selectedBrand;
  HsnModel? selectedHsn;

  Future<void> getCategoryList(String search, {required String supplierId}) async {

    Map<String, dynamic> requestBody = {};
    requestBody['customer'] = supplierId;
    requestBody['search'] = search;
    var response = await ApiProvider.createServerRequest(apiUrl: ApiPath.getCategoryList, requestBody: requestBody, isFormData: true);

    if(response['error']!=null && response['error'])
    {
      try{
        var data = CategoryResponse.fromJson(response);
        categoryList = data.categoryList;
      } catch(e){
        print(e);
      }
    }
    notifyListeners();
  }

  Future<void> getSubCategoryList(String search) async {
    if(selectedCategory==null)
      {
        showMessage("Please select Category", ToastType.info);
        return;
      }
    Map<String, dynamic> requestBody = {};
    requestBody['category'] = selectedCategory!.id;
    requestBody['search'] = search;
    var response = await ApiProvider.createServerRequest(apiUrl: ApiPath.getSubCategoryList, requestBody: requestBody, isFormData: true);

    if(response['error']!=null && response['error'])
    {
      try{
        var data = SubCategoryResponse.fromJson(response);
        subCategoryList = data.subCategoryList;
      } catch(e){
        print(e);
      }
    }
    notifyListeners();
  }

  List<BrandItem> brands = [];

  List<HsnModel> hsnCodes = [];

  List<SizeModel> sizes = [];

  List<ColorModel> colors = [];

  List<ProductAttribute> attributes = [
    ProductAttribute(),
  ];


  void setCategory(CategoryModel? value) {
    selectedCategory = value;
    if(value!=null) {
      getSubCategoryList('');
    }
    notifyListeners();
  }

  void setSubCategory(SubCategoryModel? value) {
    selectedSubCategory = value;
    notifyListeners();
  }

  void setBrand(BrandItem? value) {
    selectedBrand = value;
    notifyListeners();
  }

  void setHsn(HsnModel? value) {
    selectedHsn = value;
    notifyListeners();
  }

  void addAttribute() {
    attributes.add(
      ProductAttribute(),
    );
    notifyListeners();
  }

  void removeAttribute(int index) {
    if (attributes.length <= 1) {
      return;
    }
    attributes.removeAt(index);
    notifyListeners();
  }

  void setColor(int index, ColorModel value,) {
    attributes[index].color = value;
    notifyListeners();
  }

  void setSize(int index, SizeModel value,) {
    attributes[index].size = value;
    notifyListeners();
  }

  void setQuantity(int index, String value,) {
    attributes[index].quantity = value;
  }

  void setPurchasePrice(int index, String value,) {
    attributes[index].purchasePrice = value;
  }



  String text = 'Please enter Product Name and Category';

  bool validate() {

    if (selectedCategory == null) {
      return false;
    }

    if (selectedHsn == null) {
      text = 'Please select hsn';
      return false;
    }

    if (selectedBrand == null) {
      text = 'Please select brand';
      return false;
    }

     for(var item in attributes) {

       if (item.color == null) {
         text = 'Please select color';
         return false;
       }
       if (item.size == null) {
         text = 'Please select size';
         return false;
       }
       if (item.quantity.isEmpty && item.quantity != "0") {
         text = 'Please enter qty';
         return false;
       }
       if (item.purchasePrice.isEmpty &&
           (double.tryParse(item.purchasePrice) ?? 0) > 0) {
         text = 'Please select purchase price';
         return false;
         // code
       }
     }

    if (productNameController.text.trim().isEmpty) {
      return false;
    }

    return true;
  }

  Map<String, dynamic> toJson() {
    return {
      'category': selectedCategory,
      'subcategory': selectedSubCategory,
      'brand': selectedBrand,
      'hsncode': selectedHsn,
      'product_name': productNameController.text.trim(),
      'supplier_name': supplierNameController.text.trim(),
      'attributes': attributes,
    };
  }

  @override
  void dispose() {
    productNameController.dispose();
    supplierNameController.dispose();
    super.dispose();
  }
}