
import '../../features/dashboard/model/store_model.dart';
import '../../features/purchase_challan/model/party_model.dart';
import '../../features/purchase_challan/model/store_model.dart';
import '../../features/purchase_challan/model/supplier_model.dart';

class GlobalVars{
  static bool fromDrawer=false;
  static bool hadIntro = false;
  static String userId = '';
  static String roleName ='';
  static String roleId = '';
  static String userName = '';
  static String appVersion = '04.06.26';
  static String accessKey = '';
  static List<StoreModel> storeList =[];
  static bool isAdmin = true;
  static int currentFocus = 0;
  static String placeOfSupply = '';
  static String placeOfSupplyId = '';
  static String currentData = '';
  static String localIp = '192.168.31.65';
  static String totalTask = "0";
  static String globalRoutes = '';
  static bool isOffline = false;
  static List<CategoryMargin> supplierCatMargin = [];
}