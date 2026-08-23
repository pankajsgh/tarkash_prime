import '../vars/global_vars.dart';

class ApiPath {
  static String host = "https://gobuzy.in/btpl-test/";
  static String _localHost = 'http://${GlobalVars.localIp}/';
  static String baseUrl = '${host}Web-API/';

  static String loginUrl = '${baseUrl}login.php';
  static String verifyUrl = '${baseUrl}verify.php';
  static String dashboardUrl = '${baseUrl}Dashboard.php';
  static String getPartyList = '${baseUrl}PartyList.php';
  static String getStoreList = '${baseUrl}StoreList.php';
  static String getProductList = '${baseUrl}ProductList.php';

  static String getColorList = '${baseUrl}ColorList.php';
  static String getSizeList = '${baseUrl}SizeList.php';
  static String getHsnList = '${baseUrl}HSNList.php';
  static String getCategoryList = '${baseUrl}CategoryList.php';
  static String getSubCategoryList = '${baseUrl}SubCategoryList.php';
  static String getTransportList = '${baseUrl}TransportList.php';




  static String getImageFullPath(String path){
    return '${_localHost}task_api/$path';
  }

  static String getAudioPath(String path){
    return '${_localHost}task_api/$path';
  }
}
