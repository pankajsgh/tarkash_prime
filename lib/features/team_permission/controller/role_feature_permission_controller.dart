import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../core/network/api_path.dart';
import '../../../core/network/api_repository.dart';
import '../model/role_model.dart';
import '../model/role_feature_permission_model.dart';

class RolePermissionsController extends ChangeNotifier {
  List<RoleModel> roles = [];
  List<RoleFeaturePermissionModel> features = [];

  RoleModel? selectedRole;

  bool loadingRoles = false;
  bool loadingPermissions = false;
  bool saving = false;

  String errorMessage = '';
  String successMessage = '';

  int _requestVersion = 0;

  final List<String> permissionKeys = const [
    'alls',
    'shows',
    'saves',
    'updates',
    'searchs',
    'deletes',
    'prints',
  ];

  final List<String> permissionLabels = const [
    'All',
    'Show',
    'Save',
    'Update',
    'Search',
    'Delete',
    'Print',
  ];

  final List<Map<String, String>> additionalSettings = const [
    {
      'key': 'price_edit',
      'label': 'Allow Price Change in Voucher',
    },
    {
      'key': 'disc_edit',
      'label': 'Allow Discount Change in Voucher',
    },
    {
      'key': 'report_export',
      'label': 'Allow Export of Reports',
    },
    {
      'key': 'doc_print',
      'label': 'Allow Printing of Documents',
    },
  ];

  final Map<String, Map<String, bool>> _settingsByRole = {};

  Map<String, bool> _defaultSettings() => {
    for (final setting in additionalSettings)
      setting['key']!: false,
  };

  Map<String, bool> get additionalPermissionValues {
    final roleId = selectedRole?.id;

    if (roleId == null || roleId.isEmpty) {
      return _defaultSettings();
    }

    return Map<String, bool>.from(
      _settingsByRole[roleId] ?? _defaultSettings(),
    );
  }

  bool additionalPermissionValue(String key) {
    return additionalPermissionValues[key] ?? false;
  }

  void changeAdditionalPermission(String key, bool value) {
    if (saving || loadingPermissions) return;

    final roleId = selectedRole?.id;
    if (roleId == null || roleId.isEmpty) return;

    final settings = _settingsByRole.putIfAbsent(
      roleId,
      _defaultSettings,
    );

    if (!settings.containsKey(key)) return;

    settings[key] = value;
    errorMessage = '';
    successMessage = '';
    notifyListeners();
  }

// ============================================================
// PARSE API RESPONSE
// ============================================================

  Map<String, dynamic> _parseResponse(dynamic response) {
    dynamic result = response;

    if (result is String) {
      result = jsonDecode(result);
    }

    if (result is! Map && result != null) {
      try {
        result = result.data;
      } catch (_) {}
    }

    if (result is String) {
      result = jsonDecode(result);
    }

    if (result is Map<String, dynamic>) return result;

    if (result is Map) {
      return Map<String, dynamic>.from(result);
    }

    throw const FormatException('Invalid API response.');
  }

  String _responseMessage(
      Map<String, dynamic> response, {
        String fallback = 'Something went wrong.',
      }) {
    return response['message']?.toString() ??
        response['msg']?.toString() ??
        response['error_message']?.toString() ??
        fallback;
  }

  bool _isSuccess(Map<String, dynamic> response) {
    final value = response['error'];

    if (value == true || value == 1) return true;

    final text = value?.toString().toLowerCase();

    return text == 'true' || text == '1';
  }

  List<dynamic> _readList(dynamic value) {
    if (value is List) return value;

    if (value is Map) {
      for (final key in [
        'data',
        'features',
        'Features',
        'roles',
        'Roles',
      ]) {
        final nested = value[key];
        if (nested is List) return nested;
      }
    }

    return [];
  }

  String _cleanError(Object error, String fallback) {
    final message =
    error.toString().replaceFirst('Exception: ', '').trim();

    return message.isEmpty ? fallback : message;
  }

  bool _readBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;

    final text = value?.toString().trim().toLowerCase();

    return text == '1' ||
        text == 'true' ||
        text == 'yes' ||
        text == 'on';
  }

// ============================================================
// APPLY ROLE SETTINGS
//
// Handles the API response:
// data.role.price_edit
// data.role.disc_edit
// data.role.report_export
// data.role.doc_print
// ============================================================

  void _applySettingsFromResponse(
      String roleId,
      Map<String, dynamic> response,
      ) {
    final data = response['data'];

    dynamic rawSettings;

    if (data is Map) {
// The permissions-load API returns settings inside data.role.
      rawSettings = data['role'];

// Also support alternate response formats.
      rawSettings ??= data['role_settings'];
      rawSettings ??= data['roleSettings'];
      rawSettings ??= data['settings'];
    }

// Support settings directly at the response root.
    rawSettings ??= response['role'];
    rawSettings ??= response['role_settings'];
    rawSettings ??= response['roleSettings'];
    rawSettings ??= response['settings'];

    if (rawSettings is String) {
      try {
        rawSettings = jsonDecode(rawSettings);
      } catch (_) {
        return;
      }
    }

    if (rawSettings is! Map) return;

// Preserve existing values if a response omits a setting.
    final settings = Map<String, bool>.from(
      _settingsByRole[roleId] ?? _defaultSettings(),
    );

    const aliases = {
      'allow_price_change_in_voucher': 'price_edit',
      'allow_discount_change_in_voucher': 'disc_edit',
      'allow_export_of_reports': 'report_export',
      'allow_printing_of_documents': 'doc_print',
    };

    for (final entry in rawSettings.entries) {
      final originalKey = entry.key.toString();
      final key = aliases[originalKey] ?? originalKey;

      if (settings.containsKey(key)) {
        settings[key] = _readBool(entry.value);
      }
    }

    _settingsByRole[roleId] = settings;
  }

// ============================================================
// LOAD ROLES
// ============================================================

  Future<void> loadRoles() async {
    if (loadingRoles) return;

    loadingRoles = true;
    errorMessage = '';
    successMessage = '';
    notifyListeners();

    try {
      final response = await ApiProvider.createServerRequest(
        apiUrl: ApiPath.roleListUrl,
        requestBody: <String, dynamic>{},
        isFormData: true,
      );

      final result = _parseResponse(response);

      if (!_isSuccess(result)) {
        throw Exception(
          _responseMessage(result, fallback: 'Unable to load roles.'),
        );
      }

      final roleList = _readList(result['data']);

      roles = roleList
          .whereType<Map>()
          .map(
            (item) => RoleModel.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .where((role) => role.id.isNotEmpty)
          .toList();

      if (selectedRole != null) {
        final selectedId = selectedRole!.id;
        final matches = roles.where((role) => role.id == selectedId);

        selectedRole = matches.isEmpty ? null : matches.first;
      }

      selectedRole ??= roles.isNotEmpty ? roles.first : null;

      if (selectedRole != null) {
        await _loadPermissionsForSelectedRole(notify: false);
      } else {
        features = [];
        loadingPermissions = false;
      }
    } catch (e) {
      errorMessage = _cleanError(e, 'Unable to load roles.');
    } finally {
      loadingRoles = false;
      notifyListeners();
    }
  }

// ============================================================
// SELECT ROLE
// ============================================================

  Future<void> selectRole(RoleModel role) async {
    if (saving) return;

    if (selectedRole?.id == role.id && !loadingPermissions) return;

    selectedRole = role;
    features = [];
    errorMessage = '';
    successMessage = '';

    notifyListeners();

    await _loadPermissionsForSelectedRole();
  }

// ============================================================
// LOAD FEATURE PERMISSIONS + ROLE SETTINGS
// ============================================================

  Future<void> _loadPermissionsForSelectedRole({
    bool notify = true,
  }) async {
    final role = selectedRole;

    if (role == null) {
      features = [];
      loadingPermissions = false;

      if (notify) notifyListeners();
      return;
    }

    final requestVersion = ++_requestVersion;

    loadingPermissions = true;
    errorMessage = '';
    successMessage = '';

    if (notify) notifyListeners();

    try {
      final response = await ApiProvider.createServerRequest(
        apiUrl: ApiPath.roleFeaturePermissions,
        requestBody: {'rid': role.id},
        isFormData: true,
      );

      final result = _parseResponse(response);

      if (!_isSuccess(result)) {
        throw Exception(
          _responseMessage(
            result,
            fallback: 'Unable to load role permissions.',
          ),
        );
      }

      if (requestVersion != _requestVersion ||
          selectedRole?.id != role.id) {
        return;
      }

      final data = result['data'];

      if (data is! Map) {
        throw const FormatException(
          'Invalid role permissions response data.',
        );
      }

// Features are inside data.features.
      final featureList = _readList(data['features']);

      features = featureList
          .whereType<Map>()
          .map(
            (item) => RoleFeaturePermissionModel.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList();

// Settings are inside data.role.
      _applySettingsFromResponse(role.id, result);
    } catch (e) {
      if (requestVersion == _requestVersion) {
        features = [];
        errorMessage = _cleanError(
          e,
          'Unable to load role permissions.',
        );
      }
    } finally {
      if (requestVersion == _requestVersion) {
        loadingPermissions = false;
        if (notify) notifyListeners();
      }
    }
  }

// ============================================================
// CHANGE FEATURE PERMISSION
// ============================================================

  void changePermission(
      RoleFeaturePermissionModel feature,
      String key,
      bool value,
      ) {
    if (saving || loadingPermissions) return;

    feature.setPermission(key, value);

    errorMessage = '';
    successMessage = '';

    notifyListeners();
  }

// ============================================================
// SELECT ALL / CLEAR ALL
// ============================================================

  void setAllFeatures(bool value) {
    if (saving || loadingPermissions) return;

    for (final feature in features) {
      feature.setAll(value);
    }

    errorMessage = '';
    successMessage = '';

    notifyListeners();
  }

// ============================================================
// SAVE PERMISSIONS + ROLE SETTINGS
// ============================================================

  Future<void> savePermissions() async {
    final role = selectedRole;

    if (role == null) {
      errorMessage = 'Please select a role first.';
      successMessage = '';
      notifyListeners();
      return;
    }

    if (loadingPermissions || loadingRoles || saving) return;

    saving = true;
    errorMessage = '';
    successMessage = '';

    notifyListeners();

    try {
// Send only features with at least one selected permission.
      final permissions = features
          .where(
            (feature) =>
        feature.alls ||
            feature.shows ||
            feature.saves ||
            feature.updates ||
            feature.searchs ||
            feature.deletes ||
            feature.prints,
      )
          .map((feature) => feature.toPermissionJson())
          .toList();

      final settings = additionalPermissionValues;

      final requestBody = <String, dynamic>{
        'rid': role.id,
        'permissions': jsonEncode(permissions),
        for (final entry in settings.entries)
          entry.key: entry.value ? '1' : '0',
      };

      final response = await ApiProvider.createServerRequest(
        apiUrl: ApiPath.saveRoleFeaturePermissions,
        requestBody: requestBody,
        isFormData: true,
      );

      final result = _parseResponse(response);

      if (!_isSuccess(result)) {
        throw Exception(
          _responseMessage(
            result,
            fallback: 'Unable to save permissions.',
          ),
        );
      }

      _applySettingsFromResponse(role.id, result);

      successMessage = _responseMessage(
        result,
        fallback: 'Permissions saved successfully.',
      );
    } catch (e) {
      errorMessage = _cleanError(
        e,
        'Unable to save permissions.',
      );
    } finally {
      saving = false;
      notifyListeners();
    }
  }
}
