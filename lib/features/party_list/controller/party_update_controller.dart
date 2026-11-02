import 'dart:async';
import 'dart:convert';
import 'package:calculation_panel/core/network/api_path.dart';
import 'package:calculation_panel/core/network/api_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../account_group/model/account_group_model.dart';
import '../../purchase_challan/model/category_model.dart';
import '../../purchase_challan/model/hsn_model.dart';
import '../../purchase_challan/model/party_model.dart';
import '../../purchase_challan/model/transport_model.dart';
import '../../purchase_challan/model/agent_model.dart';
import '../model/city_model.dart';
import '../model/state_model.dart';

class PartyUpdateController extends ChangeNotifier {
  bool _disposed = false;

  Timer? _stateDebounce;
  Timer? _cityDebounce;
  Timer? _transportDebounce;
  Timer? _agentDebounce;
  int _stateRequestId = 0;
  int _cityRequestId = 0;
  int _transportRequestId = 0;
  int _agentRequestId = 0;
  int _accountGroupRequestId = 0;
  int _detailsRequestId = 0;

  // ============================================================
  // LISTS AND SELECTED VALUES
  // ============================================================

  List<BrandItem> brands = [];
  List<BrandItem> selectedBrands = [];

  List<CategoryModel> categoryList = [];
  CategoryModel? selectedCategory;

  List<StateModelItem> states = [];
  StateModelItem? selectedState;

  List<CityModelItem> cities = [];
  CityModelItem? selectedCity;

  List<TransportModel> transports = [];
  TransportModel? selectedTransport;

  List<Agency> agents = [];
  Agency? selectedAgent;

  List<AccountGroup> accountGroups = [];
  AccountGroup? selectedAccountGroup;

  List<HsnModel> filteredHsnCodes = [];
  List<HsnModel> controllerHsnList = [];
  HsnModel? selectedHsn;

  // ============================================================
  // LOADING STATES
  // ============================================================

  bool isLoadingStates = false;
  bool isLoadingCities = false;
  bool isLoadingTransports = false;
  bool isLoadingAgents = false;
  bool isLoadingAccountGroups = false;
  bool isUpdatingParty = false;
  bool isLoadingPartyDetails = false;

  // ============================================================
  // ERROR MESSAGES
  // ============================================================

  String stateError = '';
  String cityError = '';
  String transportError = '';
  String agentError = '';
  String accountGroupError = '';
  String updateError = '';
  String partyDetailsError = '';

  Map<String, dynamic>? updatedParty;

  // ============================================================
  // COMMON METHODS
  // ============================================================

  void _notify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  String _errorMessage(
      Object error, [
        String fallback = 'Something went wrong.',
      ]) {
    if (error is DioException) {
      final data = error.response?.data;

      if (data is Map) {
        final message = data['message'] ??
            data['msg'] ??
            data['error_message'] ??
            data['error'];

        if (message != null &&
            message is! bool &&
            message.toString().trim().isNotEmpty) {
          return message.toString();
        }
      } else if (data is String && data.trim().isNotEmpty) {
        return data.trim();
      }

      if (error.response?.statusCode != null) {
        return 'Request failed with status ${error.response!.statusCode}.';
      }

      return error.message ?? 'Network connection failed.';
    }

    return error.toString().isNotEmpty ? error.toString() : fallback;
  }

  Map<String, dynamic>? _responseData(Map response) {
    final data = response['data'];

    return data is Map ? Map<String, dynamic>.from(data) : null;
  }

  // ============================================================
  // HSN METHODS
  // ============================================================

  void setHsn(HsnModel? value) {
    selectedHsn = value;
    _notify();
  }

  Future<void> getHsnList(String search) async {
    try {
      final requestBody = {
        'search': search,
        'BillDate': '',
        'limit': '0',
      };

      final response = await ApiProvider.createServerRequest(
        apiUrl: ApiPath.getHsnList,
        requestBody: requestBody,
        isFormData: true,
      );

      if (_disposed) return;

      if (response['error'] == true) {
        final data = HsnResponse.fromJson(response);

        controllerHsnList = data.hsnList;
        filteredHsnCodes = List<HsnModel>.from(controllerHsnList);

        _keepSelectedHsnVisible();
      } else {
        controllerHsnList = [];
        filteredHsnCodes =
        selectedHsn == null ? [] : [selectedHsn!];
      }

      _notify();
    } catch (e) {
      debugPrint('HSN list API error: $e');

      if (!_disposed) {
        filteredHsnCodes =
        selectedHsn == null ? [] : [selectedHsn!];

        _notify();
      }
    }
  }

  void _keepSelectedHsnVisible() {
    if (selectedHsn == null) return;

    final exists = filteredHsnCodes.any(
          (item) => item.hsnCode == selectedHsn!.hsnCode,
    );

    if (!exists) {
      filteredHsnCodes.insert(0, selectedHsn!);
    }
  }

  void searchHsn(String? query) {
    final search = (query ?? '').trim().toLowerCase();

    filteredHsnCodes = controllerHsnList.where((item) {
      return item.hsnCode.toLowerCase().contains(search);
    }).toList();

    _keepSelectedHsnVisible();

    _notify();
  }

  // ============================================================
  // PARTY DETAILS
  // ============================================================

  Future<Map<String, dynamic>?> getPartyDetails(String id) async {
    final requestId = ++_detailsRequestId;

    isLoadingPartyDetails = true;
    partyDetailsError = '';

    _notify();

    try {
      final response = await ApiProvider.createServerRequest(
        apiUrl: ApiPath.getPartyDetails,
        requestBody: {'id': id.trim()},
        isFormData: true,
      );

      if (_disposed || requestId != _detailsRequestId) {
        return null;
      }

      if (response['error'] == true) {
        final data = _responseData(response);

        if (data != null) {
          return data;
        }
      }

      partyDetailsError = response['message']?.toString() ??
          response['msg']?.toString() ??
          'Unable to load party details.';

      return null;
    } catch (e) {
      if (!_disposed && requestId == _detailsRequestId) {
        partyDetailsError = _errorMessage(
          e,
          'Unable to load party details.',
        );

        debugPrint('Party details API error: $e');
      }

      return null;
    } finally {
      if (!_disposed && requestId == _detailsRequestId) {
        isLoadingPartyDetails = false;
        _notify();
      }
    }
  }

  // ============================================================
  // CATEGORY METHODS
  // ============================================================

  Future<void> getCategoryList(String search) async {
    try {
      final response = await ApiProvider.createServerRequest(
        apiUrl: ApiPath.getCategoryList,
        requestBody: {
          'customer': '',
          'search': search,
        },
        isFormData: true,
      );

      if (_disposed) return;

      if (response['error'] == true) {
        categoryList =
            CategoryResponse.fromJson(response).categoryList;

        if (selectedCategory != null &&
            !categoryList.any(
                  (item) =>
              item.id.toString() == selectedCategory!.id.toString(),
            )) {
          categoryList.insert(0, selectedCategory!);
        }

        _notify();
      }
    } catch (e) {
      debugPrint('Category API error: $e');
    }
  }

  void setCategory(CategoryModel? value) {
    selectedCategory = value;
    _notify();
  }

  // ============================================================
  // BRAND METHODS
  // ============================================================

  Future<void> getBrandList() async {
    try {
      final json = await ApiProvider.createServerRequest(
        apiUrl: ApiPath.getBrandList,
      );

      if (_disposed) return;

      if (json['code'].toString() == '1' && json['error'] == true) {
        brands = (json['BrandList'] as List? ?? [])
            .whereType<Map>()
            .map(
              (item) => BrandItem.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
            .toList();

        _notify();
      }
    } catch (e) {
      debugPrint('Brand list error: $e');
    }
  }

  // ============================================================
  // SAVE PARTY COMMON METHOD
  // ============================================================

  Future<bool> _saveParty({
    required String apiUrl,
    required Map<String, String> body,
    required String action,
  }) async {
    if (_disposed || isUpdatingParty) return false;

    if ((body['company'] ?? '').trim().isEmpty) {
      updateError = 'Company is required.';
      _notify();
      return false;
    }

    if ((body['name'] ?? '').trim().isEmpty) {
      updateError = 'Party name is required.';
      _notify();
      return false;
    }

    if (action == 'Update') {
      final id = int.tryParse((body['id'] ?? '').trim());

      if (id == null || id <= 0) {
        updateError = 'Valid party ID is required.';
        _notify();
        return false;
      }
    }

    isUpdatingParty = true;
    updateError = '';
    updatedParty = null;

    _notify();

    try {
      debugPrint('$action party request: $body');

      final response = await ApiProvider.createServerRequest(
        apiUrl: apiUrl,
        requestBody: body,
        isFormData: true,
      );

      if (_disposed) return false;

      debugPrint('$action party response: $response');

      if (response['error'] == true) {
        updatedParty = _responseData(response) ?? body;
        return true;
      }

      updateError = response['message']?.toString() ??
          response['msg']?.toString() ??
          'Unable to ${action.toLowerCase()} party.';

      return false;
    } catch (e) {
      if (!_disposed) {
        updateError = _errorMessage(
          e,
          'Failed to ${action.toLowerCase()} party.',
        );

        debugPrint('$action party error: $e');
      }

      return false;
    } finally {
      if (!_disposed) {
        isUpdatingParty = false;
        _notify();
      }
    }
  }

  // ============================================================
  // COMMON PARTY REQUEST BODY
  // ============================================================

  Map<String, String> _partyBody({
    required String company,
    required String printName,
    required String name,
    required String mobile,
    required String gstNo,
    required String discount,
    required String address,
    required String pincode,
    required String stateId,
    required String cityId,
    required String transportId,
    required String agencyId,
    required List<String> brands,
    required List<Map<String, dynamic>> categoryMargins,
    required String dealerType,
    required String countryId,
    required String whatsappNo,
    required String email,
    required String panNo,
    required String aadhaarNo,
    required String remark,
    required String creditDays,
    required String creditLimit,
    required String openingBalance,
    required String openingType,
    required String username,
    required String password,
    required String bankName,
    required String bankAccountNo,
    required String branch,
    required String ifscCode,

    // GST Details
    required String gstType,
    required String gstPercentage,
    required String itcEligibility,
    required String rcmNature,
    required String hsnCode,
  }) {
    return {
      'company': company.trim(),
      'print_name': printName.trim(),
      'name': name.trim(),
      'mobile': mobile.trim(),
      'gst_no': gstNo.trim(),
      'discount': discount.trim(),
      'address': address.trim(),
      'pincode': pincode.trim(),
      'state_id': stateId.trim(),
      'city_id': cityId.trim(),
      'transport_id': transportId.trim(),
      'agency_id': agencyId.trim(),
      'brands': jsonEncode(brands
          .map((value) => value.trim())
          .where((value) => value.isNotEmpty)
          .toList()),
      'category_margins': jsonEncode(categoryMargins),
      'dealer_type': dealerType.trim(),
      'country_id': countryId.trim(),
      'whatsapp_no': whatsappNo.trim(),
      'email': email.trim(),
      'pan_no': panNo.trim(),
      'aadhaar_no': aadhaarNo.trim(),
      'remark': remark.trim(),
      'credit_days': creditDays.trim(),
      'credit_limit': creditLimit.trim(),
      'opening_balance': openingBalance.trim(),
      'opening_type': openingType.trim(),
      'username': username.trim(),
      'password': password,
      'bank_name': bankName.trim(),
      'bank_account_no': bankAccountNo.trim(),
      'branch': branch.trim(),
      'ifsc_code': ifscCode.trim(),

      // GST Details
      'gst_type': gstType.trim(),
      'gst_percentage': gstPercentage.trim(),
      'itc_eligibility': itcEligibility.trim(),
      'rcm_nature': rcmNature.trim(),
      'hsn_code': hsnCode.trim(),
    };
  }

  // ============================================================
  // UPDATE PARTY
  // ============================================================

  Future<bool> updateParty({
    required String id,
    required String company,
    required String printName,
    required String name,
    required String mobile,
    required String gstNo,
    required String discount,
    required String address,
    required String pincode,
    required String stateId,
    required String cityId,
    required String transportId,
    required String agencyId,
    required List<String> brands,
    required List<Map<String, dynamic>> categoryMargins,
    required String dealerType,
    required String countryId,
    required String whatsappNo,
    required String email,
    required String panNo,
    required String aadhaarNo,
    required String remark,
    required String creditDays,
    required String creditLimit,
    required String openingBalance,
    required String openingType,
    required String username,
    required String password,
    required String bankName,
    required String bankAccountNo,
    required String branch,
    required String ifscCode,
    String? partyType,

    // GST Details
    required String gstType,
    required String gstPercentage,
    required String itcEligibility,
    required String rcmNature,
    required String hsnCode,
  }) async {
    final body = _partyBody(
      company: company,
      printName: printName,
      name: name,
      mobile: mobile,
      gstNo: gstNo,
      discount: discount,
      address: address,
      pincode: pincode,
      stateId: stateId,
      cityId: cityId,
      transportId: transportId,
      agencyId: agencyId,
      brands: brands,
      categoryMargins: categoryMargins,
      dealerType: dealerType,
      countryId: countryId,
      whatsappNo: whatsappNo,
      email: email,
      panNo: panNo,
      aadhaarNo: aadhaarNo,
      remark: remark,
      creditDays: creditDays,
      creditLimit: creditLimit,
      openingBalance: openingBalance,
      openingType: openingType,
      username: username,
      password: password,
      bankName: bankName,
      bankAccountNo: bankAccountNo,
      branch: branch,
      ifscCode: ifscCode,

      // GST Details
      gstType: gstType,
      gstPercentage: gstPercentage,
      itcEligibility: itcEligibility,
      rcmNature: rcmNature,
      hsnCode: hsnCode,
    );

    body['id'] = id.trim();

    if (partyType != null) {
      body['party_type'] = partyType.trim();
    }

    return _saveParty(
      apiUrl: ApiPath.updateParty,
      action: 'Update',
      body: body,
    );
  }

  // ============================================================
  // CREATE PARTY
  // ============================================================

  Future<bool> createParty({
    required String partyType,
    required String company,
    required String printName,
    required String name,
    required String mobile,
    required String gstNo,
    required String discount,
    required String address,
    required String pincode,
    required String stateId,
    required String cityId,
    required String transportId,
    required String agencyId,
    required List<String> brands,
    required List<Map<String, dynamic>> categoryMargins,
    required String dealerType,
    required String countryId,
    required String whatsappNo,
    required String email,
    required String panNo,
    required String aadhaarNo,
    required String remark,
    required String creditDays,
    required String creditLimit,
    required String openingBalance,
    required String openingType,
    required String username,
    required String password,
    required String bankName,
    required String bankAccountNo,
    required String branch,
    required String ifscCode,

    // GST Details
    required String gstType,
    required String gstPercentage,
    required String itcEligibility,
    required String rcmNature,
    required String hsnCode,
  }) async {
    final body = _partyBody(
      company: company,
      printName: printName,
      name: name,
      mobile: mobile,
      gstNo: gstNo,
      discount: discount,
      address: address,
      pincode: pincode,
      stateId: stateId,
      cityId: cityId,
      transportId: transportId,
      agencyId: agencyId,
      brands: brands,
      categoryMargins: categoryMargins,
      dealerType: dealerType,
      countryId: countryId,
      whatsappNo: whatsappNo,
      email: email,
      panNo: panNo,
      aadhaarNo: aadhaarNo,
      remark: remark,
      creditDays: creditDays,
      creditLimit: creditLimit,
      openingBalance: openingBalance,
      openingType: openingType,
      username: username,
      password: password,
      bankName: bankName,
      bankAccountNo: bankAccountNo,
      branch: branch,
      ifscCode: ifscCode,

      // GST Details
      gstType: gstType,
      gstPercentage: gstPercentage,
      itcEligibility: itcEligibility,
      rcmNature: rcmNature,
      hsnCode: hsnCode,
    );

    body['party_type'] = partyType.trim();

    return _saveParty(
      apiUrl: ApiPath.createNewParty,
      action: 'Create',
      body: body,
    );
  }

  // ============================================================
  // STATE METHODS
  // ============================================================

  void setState(StateModelItem? state) {
    final changed =
        selectedState?.id.toString() != state?.id.toString();

    selectedState = state;

    if (changed) {
      clearCity();
    } else {
      _notify();
    }
  }

  Future<void> getStateList(String search) async {
    final requestId = ++_stateRequestId;

    isLoadingStates = true;
    stateError = '';

    _notify();

    try {
      final response = await ApiProvider.createServerRequest(
        apiUrl: ApiPath.getStateList,
        requestBody: {'search': search.trim()},
        isFormData: true,
      );

      if (_disposed || requestId != _stateRequestId) return;

      if (response['error'] == true) {
        states = List<StateModelItem>.from(
          StateListModel.fromJson(response).stateList,
        );

        if (selectedState != null &&
            !states.any(
                  (item) =>
              item.id.toString() == selectedState!.id.toString(),
            )) {
          states.insert(0, selectedState!);
        }
      } else {
        states = selectedState == null ? [] : [selectedState!];

        stateError = response['message']?.toString() ??
            response['msg']?.toString() ??
            '';
      }
    } catch (e) {
      if (_disposed || requestId != _stateRequestId) return;

      stateError = _errorMessage(e, 'Unable to load states.');
    } finally {
      if (!_disposed && requestId == _stateRequestId) {
        isLoadingStates = false;
        _notify();
      }
    }
  }

  void searchStates(String search) {
    _stateDebounce?.cancel();

    _stateDebounce = Timer(
      const Duration(milliseconds: 300),
          () => getStateList(search),
    );
  }

  // ============================================================
  // ACCOUNT GROUP METHODS
  // ============================================================

  void setSelectedAccountGroup(AccountGroup? group) {
    selectedAccountGroup = group;
    _notify();
  }

  Future<void> getAccountGroupList(String search) async {
    final requestId = ++_accountGroupRequestId;

    isLoadingAccountGroups = true;
    accountGroupError = '';

    _notify();

    try {
      final response = await ApiProvider.createServerRequest(
        apiUrl: ApiPath.getGroupAccountApi,
        requestBody: {'search': search.trim()},
        isFormData: true,
      );

      if (_disposed || requestId != _accountGroupRequestId) return;

      if (response['error'] == true) {
        final data = response['data'];

        accountGroups = data is List
            ? data
            .whereType<Map>()
            .map(
              (item) => AccountGroup.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
            .toList()
            : [];

        if (selectedAccountGroup != null &&
            !accountGroups.any(
                  (item) =>
              item.id.toString() ==
                  selectedAccountGroup!.id.toString(),
            )) {
          accountGroups.insert(0, selectedAccountGroup!);
        }
      } else {
        accountGroups =
        selectedAccountGroup == null ? [] : [selectedAccountGroup!];

        accountGroupError = response['message']?.toString() ??
            response['msg']?.toString() ??
            'Unable to load account groups.';
      }
    } catch (e) {
      if (_disposed || requestId != _accountGroupRequestId) return;

      accountGroupError = _errorMessage(
        e,
        'Unable to load account groups.',
      );
    } finally {
      if (!_disposed && requestId == _accountGroupRequestId) {
        isLoadingAccountGroups = false;
        _notify();
      }
    }
  }

  // ============================================================
  // CITY METHODS
  // ============================================================

  void setCity(CityModelItem? city) {
    selectedCity = city;
    _notify();
  }

  Future<void> getCityList(String stateId, String search) async {
    final requestedStateId = stateId.trim();
    final requestId = ++_cityRequestId;

    if (requestedStateId.isEmpty) {
      cities = [];
      selectedCity = null;
      isLoadingCities = false;
      cityError = '';

      _notify();
      return;
    }

    isLoadingCities = true;
    cityError = '';

    _notify();

    try {
      final response = await ApiProvider.createServerRequest(
        apiUrl: ApiPath.getCityList,
        requestBody: {
          'state_id': requestedStateId,
          'search': search.trim(),
        },
        isFormData: true,
      );

      if (_disposed ||
          requestId != _cityRequestId ||
          selectedState?.id.toString() != requestedStateId) {
        return;
      }

      if (response['error'] == true) {
        cities = List<CityModelItem>.from(
          CityListResponse.fromJson(response).cityList,
        );

        if (selectedCity != null &&
            !cities.any(
                  (item) =>
              item.id.toString() == selectedCity!.id.toString(),
            )) {
          cities.insert(0, selectedCity!);
        }
      } else {
        cities = selectedCity == null ? [] : [selectedCity!];

        cityError = response['message']?.toString() ??
            response['msg']?.toString() ??
            '';
      }
    } catch (e) {
      if (_disposed || requestId != _cityRequestId) return;

      cityError = _errorMessage(e, 'Unable to load cities.');
    } finally {
      if (!_disposed && requestId == _cityRequestId) {
        isLoadingCities = false;
        _notify();
      }
    }
  }

  void searchCities(String search) {
    _cityDebounce?.cancel();

    final stateId = selectedState?.id.toString() ?? '';

    if (stateId.isEmpty) {
      ++_cityRequestId;

      cities = [];
      selectedCity = null;
      isLoadingCities = false;
      cityError = 'Please select a state first.';

      _notify();
      return;
    }

    _cityDebounce = Timer(
      const Duration(milliseconds: 300),
          () => getCityList(stateId, search),
    );
  }

  void clearCity() {
    ++_cityRequestId;

    _cityDebounce?.cancel();

    cities = [];
    selectedCity = null;
    isLoadingCities = false;
    cityError = '';

    _notify();
  }

  // ============================================================
  // TRANSPORT METHODS
  // ============================================================

  void setTransport(TransportModel? transport) {
    selectedTransport = transport;
    _notify();
  }

  Future<void> getTransportList(String search) async {
    final requestId = ++_transportRequestId;

    isLoadingTransports = true;
    transportError = '';

    _notify();

    try {
      final response = await ApiProvider.createServerRequest(
        apiUrl: ApiPath.getTransportList,
        requestBody: {
          'search': search.trim(),
          'limit': '0',
        },
        isFormData: true,
      );

      if (_disposed || requestId != _transportRequestId) return;

      if (response['error'] == true) {
        transports = List<TransportModel>.from(
          TransportResponse.fromJson(response).transportList,
        );

        if (selectedTransport != null &&
            !transports.any(
                  (item) =>
              item.id.toString() == selectedTransport!.id.toString(),
            )) {
          transports.insert(0, selectedTransport!);
        }
      } else {
        transports =
        selectedTransport == null ? [] : [selectedTransport!];

        transportError = response['message']?.toString() ??
            response['msg']?.toString() ??
            '';
      }
    } catch (e) {
      if (_disposed || requestId != _transportRequestId) return;

      transportError = _errorMessage(
        e,
        'Unable to load transports.',
      );
    } finally {
      if (!_disposed && requestId == _transportRequestId) {
        isLoadingTransports = false;
        _notify();
      }
    }
  }

  void searchTransports(String search) {
    _transportDebounce?.cancel();

    _transportDebounce = Timer(
      const Duration(milliseconds: 300),
          () => getTransportList(search),
    );
  }

  // ============================================================
  // AGENT METHODS
  // ============================================================

  void setAgent(Agency? agency) {
    selectedAgent = agency;
    _notify();
  }

  Future<void> getAgentList(String search) async {
    final requestId = ++_agentRequestId;

    isLoadingAgents = true;
    agentError = '';

    _notify();

    try {
      final response = await ApiProvider.createServerRequest(
        apiUrl: ApiPath.getAgentList,
        requestBody: {
          'search': search.trim(),
          'limit': '0',
        },
        isFormData: true,
      );

      if (_disposed || requestId != _agentRequestId) return;

      if (response['error'] == true) {
        agents = List<Agency>.from(
          AgentResponseModel.fromJson(response).agentList,
        );

        if (selectedAgent != null &&
            !agents.any(
                  (item) =>
              item.id.toString() == selectedAgent!.id.toString(),
            )) {
          agents.insert(0, selectedAgent!);
        }
      } else {
        agents = selectedAgent == null ? [] : [selectedAgent!];

        agentError = response['message']?.toString() ??
            response['msg']?.toString() ??
            '';
      }
    } catch (e) {
      if (_disposed || requestId != _agentRequestId) return;

      agentError = _errorMessage(e, 'Unable to load agencies.');
    } finally {
      if (!_disposed && requestId == _agentRequestId) {
        isLoadingAgents = false;
        _notify();
      }
    }
  }

  void searchAgents(String search) {
    _agentDebounce?.cancel();

    _agentDebounce = Timer(
      const Duration(milliseconds: 300),
          () => getAgentList(search),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _disposed = true;

    _stateDebounce?.cancel();
    _cityDebounce?.cancel();
    _transportDebounce?.cancel();
    _agentDebounce?.cancel();

    _stateRequestId++;
    _cityRequestId++;
    _transportRequestId++;
    _agentRequestId++;
    _accountGroupRequestId++;
    _detailsRequestId++;

    super.dispose();
  }
}
