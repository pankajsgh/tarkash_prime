import 'dart:convert';

import 'package:calculation_panel/core/network/api_path.dart';
import 'package:calculation_panel/core/network/api_repository.dart';
import 'package:calculation_panel/core/widget/toast.dart';
import 'package:flutter/material.dart';
import '../../../core/ulitls/utility.dart';
import '../model/category_model.dart';
import '../model/color_model.dart';
import '../model/hsn_model.dart';
import '../model/party_model.dart';
import '../model/size_model.dart';
import '../model/sub_cat_model.dart';
import '../model/supplier_model.dart';

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
  // ===========================================================================
  // CONTROLLERS
  // ===========================================================================

  final TextEditingController productNameController =
  TextEditingController();

  final TextEditingController supplierNameController =
  TextEditingController();
  String productName = '';

  // ===========================================================================
  // DATA
  // ===========================================================================

  List<CategoryModel> categoryList = [];
  List<SubCategoryModel> subCategoryList = [];
  String productId='';

  List<BrandItem> brands = [];
  List<HsnModel> hsnCodes = [];
  List<SizeModel> sizes = [];
  List<ColorModel> colors = [];

  List<HsnModel> filteredHsnCodes = [];

  // ===========================================================================
  // INITIALIZATION
  // ===========================================================================

  void initialize({
    required Party supplier,
    required String supplierId,
    required List<HsnModel> hsnList,
    required List<SizeModel> sizeList,
    required List<ColorModel> colorList,
  })
  {
    selectedSupplier = supplier;
    brands = supplier.brandList == null
        ? []
        : List<BrandItem>.from(supplier.brandList!,);

    hsnCodes = List<HsnModel>.from(hsnList);
    sizes = List<SizeModel>.from(sizeList);
    colors = List<ColorModel>.from(colorList);
    filteredHsnCodes = hsnCodes;


    if (brands.isNotEmpty) {
      selectedBrand = brands.first;
    }

    if (attributes.isEmpty) {
      attributes.add(
        ProductAttribute(),
      );
    }

    getCategoryList(
      '',
      supplierId: supplierId,
    );
  }


  void searchHsn(String query) {
    final searchText = query.trim().toLowerCase();

    if (searchText.isEmpty) {
      filteredHsnCodes = List<HsnModel>.from(hsnCodes);
    } else {
      filteredHsnCodes = hsnCodes.where((hsn) {
        return hsn.hsnCode.toLowerCase().contains(searchText);
      }).toList();
    }
    notifyListeners();
  }

  List<ProductAttribute> attributes = [
    ProductAttribute(),
  ];

  // ===========================================================================
  // SELECTED VALUES
  // ===========================================================================

  CategoryModel? selectedCategory;
  SubCategoryModel? selectedSubCategory;
  BrandItem? selectedBrand;
  HsnModel? selectedHsn;
  Party? selectedSupplier;

  // ===========================================================================
  // STATE
  // ===========================================================================

  bool isSaving = false;

  String errorMessage = '';


  // ===========================================================================
  // CATEGORY
  // ===========================================================================

  Future<void> getCategoryList(
      String search, {
        required String supplierId,
      }) async {
    final requestBody = <String, dynamic>{
      'customer': supplierId,
      'search': search,
    };

    try {
      final response = await ApiProvider.createServerRequest(
        apiUrl: ApiPath.getCategoryList,
        requestBody: requestBody,
        isFormData: true,
      );

      if (response['error'] == true) {
        final data = CategoryResponse.fromJson(response);

        categoryList.clear();

        for(var x in data.categoryList)
          {
            for(var y in selectedSupplier!.categoryMargins)
             {
               if(x.id == y.categoryId)
                 {
                   print("this is good 22");

                   categoryList.add(x);
                 }
             }
          }

        print("this is good 22");
        print(categoryList);
        notifyListeners();
      }
    } catch (e) {
      debugPrint(
        'Category API Error: $e',
      );
    }
  }

  // ===========================================================================
  // SUB CATEGORY
  // ===========================================================================

  Future<void> getSubCategoryList(String search) async {
    if (selectedCategory == null) {
      showMessage(
        'Please select Category',
        ToastType.info,
      );
      return;
    }

    final requestBody = <String, dynamic>{
      'category': selectedCategory!.id,
      'search': search,
    };

    try {
      final response = await ApiProvider.createServerRequest(
        apiUrl: ApiPath.getSubCategoryList,
        requestBody: requestBody,
        isFormData: true,
      );

      if (response['error'] == true) {
        final data = SubCategoryResponse.fromJson(response);

        subCategoryList = data.subCategoryList;

        notifyListeners();
      }
    } catch (e) {
      debugPrint(
        'Sub Category API Error: $e',
      );
    }
  }

  // ===========================================================================
  // BRAND
  // ===========================================================================

  Future<void> searchBrandsPost({
    String search = '',
  }) async {
    final requestBody = <String, String>{
      'search': search,
      'limit': '0',
    };

    try {
      final response = await ApiProvider.createServerRequest(
        apiUrl: ApiPath.getBrandList,
        isFormData: true,
        requestBody: requestBody,
      );

      if (response['error'] == true) {
        final brandData = response['BrandList'];

        if (brandData is List) {
          brands = brandData
              .map(
                (item) => BrandItem.fromJson(
              item as Map<String, dynamic>,
            ),
          )
              .toList();

          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint(
        'Brand API Error: $e',
      );
    }
  }

  // ===========================================================================
  // SETTERS
  // ===========================================================================

  void setSupplier(Party? value) {
    selectedSupplier = value;
    notifyListeners();
  }

  void setCategory(CategoryModel? value) {
    selectedCategory = value;

    // Clear old sub-category when category changes.
    selectedSubCategory = null;
    subCategoryList = [];

    notifyListeners();

    if (value != null) {
      getSubCategoryList('');
    }
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

  // ===========================================================================
  // ATTRIBUTES
  // ===========================================================================

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

    if (index < 0 || index >= attributes.length) {
      return;
    }

    attributes.removeAt(index);

    notifyListeners();
  }

  void setSize(
      int index,
      SizeModel? value,
      ) {
    if (!_validAttributeIndex(index)) {
      return;
    }

    attributes[index].size = value;

    notifyListeners();
  }

  void setColor(
      int index,
      ColorModel? value,
      ) {
    if (!_validAttributeIndex(index)) {
      return;
    }

    attributes[index].color = value;

    notifyListeners();
  }

  void setQuantity(
      int index,
      String value,
      ) {
    if (!_validAttributeIndex(index)) {
      return;
    }

    attributes[index].quantity = value;
  }

  void setPurchasePrice(
      int index,
      String value,
      ) {
    if (!_validAttributeIndex(index)) {
      return;
    }

    attributes[index].purchasePrice = value;
  }

  bool _validAttributeIndex(int index) {
    return index >= 0 && index < attributes.length;
  }

  // ===========================================================================
  // VALIDATION
  // ===========================================================================

  String? validate() {
    errorMessage = '';

    final productName =
    productNameController.text.trim();

    if (productName.isEmpty) {
      return _setValidationError(
        'Please enter product name',
      );
    }

    if (selectedCategory == null) {
      return _setValidationError(
        'Please select category',
      );
    }

    if (selectedBrand == null) {
      return _setValidationError(
        'Please select brand',
      );
    }

    if (selectedHsn == null) {
      return _setValidationError(
        'Please select HSN',
      );
    }

    if (selectedSupplier == null) {
      return _setValidationError(
        'Supplier information is missing',
      );
    }

    if (attributes.isEmpty) {
      return _setValidationError(
        'Please add at least one attribute',
      );
    }

    for (int index = 0; index < attributes.length; index++) {
      final item = attributes[index];

      if (item.size == null) {
        return _setValidationError(
          'Please select size for row ${index + 1}',
        );
      }

      if (item.color == null) {
        return _setValidationError(
          'Please select color for row ${index + 1}',
        );
      }

      final quantity =
      int.tryParse(item.quantity.trim());

      if (quantity == null || quantity <= 0) {
        return _setValidationError(
          'Please enter valid quantity for row ${index + 1}',
        );
      }

      final price =
      double.tryParse(item.purchasePrice.trim());

      if (price == null || price <= 0) {
        return _setValidationError(
          'Please enter valid purchase price for row ${index + 1}',
        );
      }
    }

    return null;
  }

  String _setValidationError(String message) {
    errorMessage = message;
    return message;
  }

  Future<void> generateProductName() async {
    if(productName.isNotEmpty)
      {
        return ;
      }
    String prefix  = await loadProductPrefix();
    try {
      final requestData = {
        'prefix': prefix.trim(),
      };

      final response =
      await ApiProvider.createServerRequest(
        apiUrl: ApiPath.generateProductName,
        requestBody: requestData,
        isFormData: true,
      );

      print('Create Product Response: $response');

      if (response['code'] == 1 &&
          response['error'] == true) {

        final data = response['data'];

        final String id = data['id']?.toString() ?? '';
        final String product = data['product']?.toString() ?? '';

        print('Product ID: $id');
        print('Product Code: $product');
        productName =  product;
        productNameController.text = product;

      } else {
        print(
          'Product creation failed: '
              '${response['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      print('Create Product Error: $e');
    }
    return;
  }

  // ===========================================================================
  // SAVE PRODUCT
  // ===========================================================================

  Future<bool> saveProduct() async {
    if (isSaving) {
      return false;
    }

    final validationError = validate();

    if (validationError != null) {
      return false;
    }

    isSaving = true;
    errorMessage = '';

    notifyListeners();

    try {
      final barcodePrefix = await loadBarcodePrefix();
      final multipleBarcode = await loadMultipleBarcode();

      final List<Map<String, String>> productParameters = [];

      for (final item in attributes) {
        productParameters.add({
          'size_id': item.size?.id ?? '',
          'color_id': item.color?.id ?? '',
          'quantity': item.quantity.trim(),
          'purchase_price': item.purchasePrice.trim(),
        });
      }

      final Map<String, String> requestData = {
        'product':
        productNameController.text.trim(),

        'supplier_id':
        selectedSupplier?.id ?? '',

        'supplier_prod_name':
        supplierNameController.text.trim(),

        'category':
        selectedCategory?.category ?? '',

        'category_id':
        selectedCategory?.id ?? '',

        'sub_category_id':
        selectedSubCategory?.id ?? '',

        'hsn_id':
        selectedHsn?.id ?? '',

        'brand':
        selectedBrand?.id ?? '',

        'barcode_prefix': barcodePrefix,

        'update_existing': multipleBarcode,

        'product_parameters': jsonEncode(productParameters),
      };

      debugPrint(
        'Create Product Request: $requestData',
      );

      await Future.delayed(Duration(milliseconds: 600));

      final response =
      await ApiProvider.createServerRequest(
        apiUrl: ApiPath.addProduct,
        requestBody: requestData,
        isFormData: true,
      );

      debugPrint(
        'Create Product Response: $response',
      );

      final bool status = response['error'] == true;

      if (status) {
        errorMessage =
            response['message']?.toString() ??
                'Product created successfully';
        if(response['data']!=null) {
          productId= response['data']['id']?? '';
        }

        return true;
      }

      errorMessage =
          response['message']?.toString() ??
              'Failed to create product';


      return false;
    } catch (e) {
      debugPrint(
        'Save Product Error: $e',
      );

      errorMessage =
      'Something went wrong while creating product';

      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  // ===========================================================================
  // JSON RESULT
  // ===========================================================================

  Map<String, dynamic> toJson() {
    return {
      'id': productId,
      'category': selectedCategory,
      'subcategory': selectedSubCategory,
      'brand': selectedBrand,
      'hsncode': selectedHsn,
      'product_name': productNameController.text.trim(),
      'supplier_name': supplierNameController.text.trim(),
      'attributes': attributes
    };
  }

  // ===========================================================================
  // DISPOSE
  // ===========================================================================

  @override
  void dispose() {
    productNameController.dispose();
    supplierNameController.dispose();

    super.dispose();
  }
}
