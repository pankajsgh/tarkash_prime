import '../vars/global_vars.dart';

class ApiPath {
  static String host = "https://gobuzy.in/btpl-test/";
  static String _localHost = 'http://${GlobalVars.localIp}/';
  static String baseUrl = '${host}Web-API/';

  static String localUrl = "http://localhost/gobuzy_prime/api/";
  

  static String loginUrl = '${baseUrl}login.php';
  static String verifyUrl = '${baseUrl}verify.php';
  static String dashboardUrl = '${baseUrl}Dashboard.php';
  static String getPartyList = '${baseUrl}PartyList.php';
  // static String getStoreList = '${baseUrl}StoreList.php';
  static String getProductList = '${baseUrl}ProductList.php';

  static String getColorList = '${baseUrl}ColorList.php';
  static String getSizeList = '${baseUrl}SizeList.php';
  static String getHsnList = '${baseUrl}HSNList.php';
  static String getCategoryList = '${baseUrl}CategoryList.php';
  static String getSubCategoryList = '${baseUrl}SubCategoryList.php';
  // static String getTransportList = '${baseUrl}TransportList.php';

  //localApi
  static String submitOtherCharges = '${localUrl}submit_otherCharge.php';
  static String updateOtherCharges = '${localUrl}update_otherCharge.php';
  static String searchOtherCharges = '${localUrl}get_otherCharge.php';
  static String deleteOtherCharge = '${localUrl}delete_otherCharge.php';
  static String submitChallanApi = '${localUrl}submit_pruchase_challan.php';
  static String purchaseChallansListApi = '${localUrl}get_purchase_challan_list.php';
  static String insertTransportApi = '${localUrl}insert_transport.php';
  static String getTransportList = '${localUrl}TransportList.php';
  static String getStoreList = '${localUrl}StoreList.php';
  static String getAgentList = '${localUrl}agentlist.php';





  static String getImageFullPath(String path){
    return '${_localHost}task_api/$path';
  }

  static String getAudioPath(String path){
    return '${_localHost}task_api/$path';
  }
}
