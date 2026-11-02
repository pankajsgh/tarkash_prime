import '../vars/global_vars.dart';

class ApiPath {
  static String host = "https://gobuzy.in/btpl-test/";
  static String _localHost = 'http://${GlobalVars.localIp}/';
  static String baseUrl = '${host}Web-API/';

  static String paiUrl = "http://localhost/gobuzy_prime/api/";
  static String ipUrl = "http://127.0.0.1/gobuzy_prime/api/";

  static String get localUrl {
    return 'http://${GlobalVars.localIp}/gobuzy_prime/api/';
}

  //
  // static String loginUrl = '${baseUrl}login.php';
  // static String verifyUrl = '${baseUrl}verify.php';
  static String dashboardUrl = '${baseUrl}Dashboard.php';

  // static String getPartyList = '${baseUrl}PartyList.php';
  // static String getStoreList = '${baseUrl}StoreList.php';
  // static String getProductList = '${baseUrl}ProductList.php';

  // static String getColorList = '${baseUrl}ColorList.php';
  // static String getSizeList = '${baseUrl}SizeList.php';
  // static String getHsnList = '${baseUrl}HSNList.php';
  // static String getCategoryList = '${baseUrl}CategoryList.php';
  // static String getSubCategoryList = '${baseUrl}SubCategoryList.php';
  // static String getTransportList = '${baseUrl}TransportList.php';

  //localApi
  static String submitOtherCharges = '${localUrl}submit_otherCharge.php';
  static String updateOtherCharges = '${localUrl}update_otherCharge.php';
  static String searchOtherCharges = '${localUrl}get_otherCharge.php';
  static String deleteOtherCharge = '${localUrl}delete_otherCharge.php';
  static String submitChallanApi = '${localUrl}submit_purchase_challan.php';
  static String updateChallanApi = '${localUrl}edit_purchase_challan.php';
  static String purchaseChallansDetailApi = '${localUrl}purchase_challan_detail.php';
  static String purchaseChallansListApi = '${localUrl}purchase_challan_list.php';
  static String supplierVoucherListApi = '${localUrl}supplier_voucher_list.php';
  static String deletePurchaseChallanApi = '${localUrl}delete_purchase_challan.php';
  static String cancelPurchaseChallanApi = '${localUrl}update_challan_status.php';
  static String insertTransportApi = '${localUrl}insert_transport.php';
  static String getTransportList = '${localUrl}TransportList.php';
  static String getStoreList = '${localUrl}StoreList.php';
  static String getAgentList = '${localUrl}agentlist.php';
  static String addProduct = '${localUrl}add_product.php';
  static String getProductList = '${localUrl}product_list.php';
  static String getColorList = '${localUrl}color_list.php';
  static String getSizeList = '${localUrl}size_list.php';
  static String getHsnList = '${localUrl}hsn_list.php';
  static String getHsnUpdateList = '${localUrl}tax_slab_update.php';
  static String getCategoryList = '${localUrl}CategoryList.php';
  static String getSubCategoryList = '${localUrl}SubCategoryList.php';
  static String getPartyList = '${localUrl}PartyList.php';
  static String getBrandList = '${localUrl}brand_list.php';
  static String deleteProductApi = '${localUrl}delete_product.php';
  static String productTaxSlabs = '${localUrl}product_tax_slabs.php';
  static String generateProductName = '${localUrl}generate_product_name.php';
  static String createHsn = '${localUrl}create_hsn.php';
  static String productParmList = '${localUrl}product_parm_list.php';
  static String getStateList = '${localUrl}state_list.php';
  static String getCityList = '${localUrl}city_list.php';
  static String updateParty = '${localUrl}update_party.php';
  static String createNewParty = '${localUrl}create_party.php';
  // static String getSeriesApi = '${localUrl}get_series.php';
  static String getRateTypeApi = '${localUrl}get_rateType.php';
  static String getGroupAccountApi = '${localUrl}get_group_account.php';
  static String createGroupAccountApi = '${localUrl}create_group_account.php';
  static String updateGroupAccountApi = '${localUrl}update_group_account.php';
  static String addProductParameterApi = '${localUrl}add_product_parameters.php';
  static String stockListApi = '${localUrl}stock_list.php';
  static String stockReportList = '${localUrl}stock_report_list.php';
  static String teamListApi = '${localUrl}team_list.php';
  static String createTeamApi = '${localUrl}create_team.php';
  static String updateTeamApi = '${localUrl}update_team.php';
  static String clearTeamDeviceIdApi = '${localUrl}clear_team_device_id.php';
  static String urlSeriesList = '${localUrl}get_series.php';
  static String urlRateType = '${localUrl}get_rateType.php';
  static String urlTeamList = '${localUrl}team_list.php';
  static String saleProductList = '${localUrl}product_parm_list.php';
  static String getPartyDetails = '${localUrl}party_detail.php';

  static String urlVoucherConfigurationAdd = '${localUrl}create_series.php';
  static String urlVoucherConfigurationUpdate = '${localUrl}update_series.php';
  static String urlVoucherConfigurationDelete = '${localUrl}delete_series.php';
  static String urlGetVoucherNo = '${localUrl}generate_sale_inv_no.php';
  static String getCountryList = '${baseUrl}country_list.php';
  static String getLeadSourceList = '${localUrl}lead_source.php';
  static String urlVoucherConfigurationList = '${localUrl}get_voucherType.php';
  static String urlSaleInvoice = '${localUrl}submit_sales_invoice.php';
  static String urlProductDetail = '${localUrl}get_product_detail.php';

  static String logDetailList = '${localUrl}get_log_detail.php';
  static String roleFeaturePermissions = '${localUrl}role_feature_permissions.php';
  static String roleListUrl = '${localUrl}role_list.php';
  static String saveRoleFeaturePermissions = '${localUrl}save_role_feature_permissions.php';


  static String loginUrl = '${localUrl}login.php';
  static String verifyUrl = '${localUrl}verify.php';

  static String submitSupplierVoucherApi = '${localUrl}submit_supplier_voucher.php';
  static String updateSupplierVoucherApi = '${localUrl}update_supplier_voucher.php';
  static String supplierVoucherDetailApi = '${localUrl}supplier_voucher_detail.php';
  static String deleteSupplierVoucherApi = '${localUrl}delete_supplier_voucher.php';


  static String getImageFullPath(String path){
    return '${_localHost}task_api/$path';
  }

  static String getAudioPath(String path){
    return '${_localHost}task_api/$path';
  }
}
