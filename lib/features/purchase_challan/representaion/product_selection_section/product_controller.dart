import 'package:flutter/material.dart';
import '../../../../core/network/api_path.dart';
import '../../../../core/network/api_repository.dart';
import '../../model/category_model.dart';
import '../../model/color_model.dart';
import '../../model/hsn_model.dart';
import '../../model/size_model.dart';
import '../../model/sub_cat_model.dart';

class ProductController extends ChangeNotifier{

  List<ColorModel>  colorList = [];
  List<SizeModel>  sizeList = [];
  List<HsnModel> hsnList = [];
  List<CategoryModel> categoryList = [];
  List<SubCategoryModel> subCategoryList = [];

  Future<void> initialize(String date) async{
    await getColorList('');
    await getSizeList('');
    await getHsnList('', date: date);
  }

  Future<void> getColorList(String search) async {
    Map<String, dynamic> requestBody = {};
    requestBody['search'] = search;
    requestBody['limit'] = "0";
    var response = await ApiProvider.createServerRequest(apiUrl: ApiPath.getColorList, requestBody: requestBody, isFormData: true);

    if(response['error']!=null && response['error'])
    {
      try{
        var data = ColorResponse.fromJson(response);
        colorList = data.colorList;
      } catch(e){
        print(e);
      }
    }
    notifyListeners();
  }
  Future<void> getSizeList(String search) async {
    Map<String, dynamic> requestBody = {};
    requestBody['search'] = search;
    requestBody['limit'] = "0";
    var response = await ApiProvider.createServerRequest(apiUrl: ApiPath.getSizeList, requestBody: requestBody, isFormData: true);

    if(response['error']!=null && response['error'])
    {
      try{
        var data = SizeResponse.fromJson(response);
        sizeList = data.sizeList;
      } catch(e){
        print(e);
      }
    }

    notifyListeners();
  }
  Future<void> getHsnList(String search, {required String date}) async {
    Map<String, dynamic> requestBody = {};
    requestBody['search'] = search;
    requestBody['BillDate'] = date;
    requestBody['limit'] = "0";
    var response = await ApiProvider.createServerRequest(apiUrl: ApiPath.getHsnList, requestBody: requestBody, isFormData: true);

    if(response['error']!=null && response['error'])
    {
      try{
        var data = HsnResponse.fromJson(response);
        hsnList = data.hsnList;
      } catch(e){
        print(e);
      }
    }
    notifyListeners();
  }
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
  Future<void> getSubCategoryList(String search, {required String categoryId}) async {

    Map<String, dynamic> requestBody = {};
    requestBody['category'] = categoryId;
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

}