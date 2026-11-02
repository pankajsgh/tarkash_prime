
import 'dart:convert';

import 'package:calculation_panel/core/network/api_path.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../model/account_group_model.dart';

class AccountGroupController extends ChangeNotifier {
  AccountGroupController() {
    loadAccountGroups();
  }

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
      headers: {'Accept': 'application/json'},
    ),
  );

  final formKey = GlobalKey<FormState>();

  final accountGroupNameController = TextEditingController();
  final descriptionController = TextEditingController();
  final notesController = TextEditingController();

  final List<AccountGroup> _accountGroups = [];

  bool isLoading = false;
  bool isSaving = false;
  bool isDeleting = false;

  String? errorMessage;
  String? parentAccountGroup;

  bool isParent = false;
  bool isActive = true;
  String? editingId;

  String searchQuery = '';
  String statusFilter = 'All';

  AccountGroup? selectedAccountGroup;

  List<AccountGroup> get accountGroups =>
      List.unmodifiable(_accountGroups);

  int get totalGroups => _accountGroups.length;

  int get activeGroups =>
      _accountGroups.where((group) => group.isActive).length;

  int get inactiveGroups =>
      _accountGroups.where((group) => !group.isActive).length;

  // ------------------------------------------------------------
  // RESPONSE HELPERS
  // ------------------------------------------------------------

  dynamic _decodeResponse(dynamic data) {
    if (data is String) return jsonDecode(data);
    return data;
  }

  Map<String, dynamic> _responseMap(dynamic data) {
    final decoded = _decodeResponse(data);

    if (decoded is Map<String, dynamic>) return decoded;

    if (decoded is Map) {
      return Map<String, dynamic>.from(decoded);
    }

    throw Exception('Invalid server response.');
  }

  bool _checkSuccess(Map<String, dynamic> response) {
    if (response['code']?.toString() == '1' &&
        response['error'] == true) {
      return true;
    }

    errorMessage = response['message']?.toString() ??
        response['msg']?.toString() ??
        'Request failed.';

    return false;
  }

  String _errorText(Object error, String fallback) {
    if (error is DioException) {
      final data = error.response?.data;

      try {
        final response = _responseMap(data);
        final message = response['message']?.toString() ??
            response['msg']?.toString();

        if (message != null && message.isNotEmpty) {
          return message;
        }
      } catch (_) {}

      return error.message ?? fallback;
    }

    return error.toString().replaceFirst('Exception: ', '');
  }

  // ------------------------------------------------------------
  // PARENT GROUP HELPERS
  // ------------------------------------------------------------

  List<String> get parentGroups => _accountGroups
      .where((group) => group.id != editingId)
      .map((group) => group.id.toString())
      .toList();

  String getParentName(String parentId) {
    if (parentId.isEmpty) return 'No parent';

    for (final group in _accountGroups) {
      if (group.id.toString() == parentId) {
        return group.name;
      }
    }

    return 'No parent';
  }

  // ------------------------------------------------------------
  // FILTERING
  // ------------------------------------------------------------

  List<AccountGroup> get filteredAccountGroups {
    final query = searchQuery.trim().toLowerCase();

    return _accountGroups.where((group) {
      final matchesSearch = query.isEmpty ||
          group.id.toString().contains(query) ||
          group.name.toLowerCase().contains(query) ||
          group.parent.toLowerCase().contains(query) ||
          group.description.toLowerCase().contains(query) ||
          group.notes.toLowerCase().contains(query);

      final matchesStatus = statusFilter == 'All' ||
          (statusFilter == 'Active' && group.isActive) ||
          (statusFilter == 'Inactive' && !group.isActive);

      return matchesSearch && matchesStatus;
    }).toList();
  }

  void _keepSelectionVisible() {
    final groups = filteredAccountGroups;

    if (groups.isEmpty) {
      selectedAccountGroup = null;
      return;
    }

    final selectedId = selectedAccountGroup?.id;

    final match = groups.where(
          (group) => group.id == selectedId,
    );

    if (match.isEmpty) {
      selectedAccountGroup = groups.first;
    } else {
      selectedAccountGroup = match.first;
    }
  }

  void selectAccountGroup(AccountGroup group) {
    selectedAccountGroup = group;
    notifyListeners();
  }

  void setSearchQuery(String value) {
    searchQuery = value;
    _keepSelectionVisible();
    notifyListeners();
  }

  void setStatusFilter(String value) {
    statusFilter = value;
    _keepSelectionVisible();
    notifyListeners();
  }

  void setParentAccountGroup(String? value) {
    parentAccountGroup = value;
    errorMessage = null;
    notifyListeners();
  }

  void setIsParent(bool value) {
    isParent = value;

    // A parent group cannot itself be assigned a parent.
    if (value) {
      parentAccountGroup = null;
    }

    notifyListeners();
  }

  void setActive(bool value) {
    isActive = value;
    notifyListeners();
  }

  // ------------------------------------------------------------
  // LOAD ACCOUNT GROUPS
  // ------------------------------------------------------------

  Future<void> loadAccountGroups() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await _dio.get(
        ApiPath.getGroupAccountApi,
      );

      final data = _responseMap(response.data);
      _checkSuccess(data);

      final rawData = data['data'];

      if (rawData is! List) {
        throw Exception('Account group data is missing.');
      }

      final fetchedGroups = rawData
          .whereType<Map>()
          .map(
            (item) => AccountGroup.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList();

      _accountGroups
        ..clear()
        ..addAll(fetchedGroups);

      // Resolve parent names after loading every group.
      for (var i = 0; i < _accountGroups.length; i++) {
        final group = _accountGroups[i];

        _accountGroups[i] = group.copyWith(
          parent: getParentName(group.parentGroupId),
        );
      }

      // Refresh selected object with the latest server record.
      final selectedId = selectedAccountGroup?.id;

      if (selectedId != null) {
        AccountGroup? updatedSelection;

        for (final group in _accountGroups) {
          if (group.id == selectedId) {
            updatedSelection = group;
            break;
          }
        }

        selectedAccountGroup = updatedSelection;
      }

      _keepSelectionVisible();
    } catch (e) {
      errorMessage = _errorText(
        e,
        'Unable to load account groups.',
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ------------------------------------------------------------
  // CREATE / UPDATE FORM
  // ------------------------------------------------------------

  void loadForEdit(AccountGroup group) {
    editingId = group.id;

    accountGroupNameController.text = group.name;
    descriptionController.text = group.description;
    notesController.text = group.notes;

    parentAccountGroup = group.parentGroupId.isEmpty
        ? null
        : group.parentGroupId;

    isParent = group.isParent;
    isActive = group.isActive;

    errorMessage = null;
    formKey.currentState?.reset();

    notifyListeners();
  }

  String? get duplicateNameError {
    final name = accountGroupNameController.text
        .trim()
        .toLowerCase();

    if (name.isEmpty) return null;

    final exists = _accountGroups.any(
          (group) =>
      group.name.trim().toLowerCase() == name &&
          group.id != editingId,
    );

    return exists
        ? 'This account group name already exists.'
        : null;
  }

  bool validateForm() {
    return formKey.currentState?.validate() ?? false;
  }

  // ------------------------------------------------------------
  // CREATE / UPDATE API
  //
  // No ID = INSERT
  // ID provided = UPDATE
  // ------------------------------------------------------------

  Future<bool> saveAccountGroup() async {
    if (isSaving) return false;

    if (!validateForm()) return false;

    final duplicateError = duplicateNameError;

    if (duplicateError != null) {
      errorMessage = duplicateError;
      notifyListeners();
      return false;
    }

    final operationId = editingId;
    final isUpdate = operationId != null;

    isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      final groupName = accountGroupNameController.text.trim();
      final description = descriptionController.text.trim();
      final notes = notesController.text.trim();

      final payload = <String, dynamic>{
        'group_name': groupName,
        'parent_group_id': parentAccountGroup?.toString() ?? '',
        'is_parent': isParent ? '1' : '0',
        'description': description,
        'notes': notes,
        'is_active': isActive ? '1' : '0',
      };

      late final String apiUrl;

      if (isUpdate) {

        apiUrl = ApiPath.updateGroupAccountApi;
        payload['id'] = operationId.toString();
      } else {
        apiUrl = ApiPath.createGroupAccountApi;
      }

      print(apiUrl);
      print(payload);
      final response = await _dio.post(
        apiUrl,
        data: FormData.fromMap(payload),

      );

      final responseMap = _responseMap(response.data);

      if (!_checkSuccess(responseMap)) {
        errorMessage = _errorText(
          responseMap,
          isUpdate
              ? 'Unable to update account group.'
              : 'Unable to add account group.',
        );
        return false;
      }

      // Preserve the original ID when updating.
      String? savedId = operationId;

      if (!isUpdate) {
        final responseData = responseMap['data'];

        if (responseData is Map) {
          savedId = responseData['id']?.toString() ?? '';
        }

        savedId ??=   responseMap['id']?.toString() ?? '';
      }

      await loadAccountGroups();

      // Select the saved/updated group without creating a duplicate locally.
      AccountGroup? savedGroup;

      if (savedId != null) {
        for (final item in _accountGroups) {
          if (item.id == savedId) {
            savedGroup = item;
            break;
          }
        }
      }

      // Fallback for APIs that do not return the new ID.
      if (savedGroup == null) {
        for (final item in _accountGroups) {
          if (item.name.trim().toLowerCase() ==
              groupName.toLowerCase()) {
            savedGroup = item;
            break;
          }
        }
      }

      selectedAccountGroup = savedGroup;

      resetAccountGroup();
      return true;
    } catch (e) {
      errorMessage = 'Unable to ${isUpdate ? 'update' : 'add'} '
          'account group: $e';
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }
  // ------------------------------------------------------------
  // DELETE API
  //
  // Requires get_group_account.php to support:
  // POST action=delete, id=<group ID>
  // ------------------------------------------------------------

  Future<bool> deleteAccountGroup(String id) async {
    if (isDeleting) return false;

    final index = _accountGroups.indexWhere(
          (group) => group.id == id,
    );

    if (index == -1) {
      errorMessage = 'Account group not found.';
      notifyListeners();
      return false;
    }

    isDeleting = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await _dio.post(
        ApiPath.getGroupAccountApi,
        data: FormData.fromMap({
          'action': 'delete',
          'id': id.toString(),
        }),
      );

      final data = _responseMap(response.data);
      _checkSuccess(data);

      // Remove locally only after the server confirms deletion.
      _accountGroups.removeWhere((group) => group.id == id);

      if (selectedAccountGroup?.id == id) {
        selectedAccountGroup = null;
      }

      _keepSelectionVisible();

      // Refresh the list from the database.
      await loadAccountGroups();

      // Deletion succeeded even if refreshing the list fails.
      errorMessage = null;
      notifyListeners();

      return true;
    } catch (e) {
      errorMessage = _errorText(
        e,
        'Unable to delete account group.',
      );

      notifyListeners();
      return false;
    } finally {
      isDeleting = false;
      notifyListeners();
    }
  }

  // ------------------------------------------------------------
  // RESET FORM
  // ------------------------------------------------------------

  void resetAccountGroup({bool notify = true}) {
    formKey.currentState?.reset();

    accountGroupNameController.clear();
    descriptionController.clear();
    notesController.clear();

    parentAccountGroup = null;
    isParent = false;
    isActive = true;
    editingId = null;
    errorMessage = null;

    if (notify) notifyListeners();
  }

  @override
  void dispose() {
    accountGroupNameController.dispose();
    descriptionController.dispose();
    notesController.dispose();
    _dio.close();
    super.dispose();
  }
}
