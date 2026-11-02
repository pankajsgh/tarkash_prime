
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/network/api_path.dart';
import '../../../core/network/api_repository.dart';
import '../model/tema_model.dart';


class TeamListController extends ChangeNotifier {
  TeamListController();

  List<TeamMember> members = [];
  List<TeamMember> filteredMembers = [];
  TeamMember? selectedMember;
  bool isLoading = false;
  bool isSaving = false;

  String errorMessage = '';
  String searchQuery = '';

  Future<void> loadMembers({bool showLoader = true}) async {
    if (showLoader) {
      isLoading = true;
      notifyListeners();
    }

    errorMessage = '';

    try {
      final response = await ApiProvider.createServerRequest(
        apiUrl: ApiPath.teamListApi,
        requestBody: {},
        isFormData: true,
      );


      if (response['error'] == true) {
        final rawData = response['data'];

        members = rawData is List
            ? rawData
            .whereType<Map>()
            .map(
              (item) => TeamMember.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
            .toList()
            : [];

        _applySearch();

        if (selectedMember != null) {
          final id = selectedMember!.id;
          final matches = members.where((item) => item.id == id);

          selectedMember =
          matches.isEmpty ? null : matches.first;
        }

        if (selectedMember == null && members.isNotEmpty) {
          selectedMember = members.first;
        }
      } else {
        errorMessage = response is Map
            ? (response['message']?.toString() ?? 'Unable to load team')
            : 'Invalid team response';
      }
    } catch (e) {
      errorMessage = 'Unable to load team members: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void selectMember(TeamMember member) {
    selectedMember = member;
    notifyListeners();
  }

  void searchMembers(String value) {
    searchQuery = value;
    _applySearch();
    notifyListeners();
  }

  void _applySearch() {
    final query = searchQuery.trim().toLowerCase();

    if (query.isEmpty) {
      filteredMembers = List<TeamMember>.from(members);
      return;
    }

    filteredMembers = members.where((member) {
      return [
        member.name,
        member.employeeCode,
        member.loginMobile,
        member.mobile,
        member.designation,
        member.department,
      ].any(
            (value) => value.toLowerCase().contains(query),
      );
    }).toList();
  }

  Future<bool> saveMember({
    String id = '',
    required String name,
    required String mobile,
    required Map<String, String> fields,
  }) async {
    isSaving = true;
    errorMessage = '';
    notifyListeners();

    try {
      final data = <String, String>{
        ...fields,
        'name': name.trim(),
        'login_mobile': mobile.trim(),
        'role_id': fields['role_id'] ?? '2',
      };

      final isEdit = id.trim().isNotEmpty;

      if (isEdit) {
        data['id'] = id;
      }

      final response = await ApiProvider.createServerRequest(
        apiUrl:  isEdit ? ApiPath.updateTeamApi : ApiPath.createTeamApi,
        requestBody:  data,
        isFormData: true,
      );


      if (response['error'] == true) {
        await loadMembers(showLoader: false);

        if (isEdit) {
          selectedMember = members.cast<TeamMember?>().firstWhere(
                (item) => item?.id == id,
            orElse: () => selectedMember,
          );
        }

        return true;
      }

      errorMessage = (response['message']?.toString() ?? 'Unable to save team member');

      return false;
    } catch (e) {
      errorMessage = 'Unable to save team member: $e';
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> clearDeviceId(TeamMember member) async {
    isSaving = true;
    errorMessage = '';
    notifyListeners();

    try {
      final response = await ApiProvider.createServerRequest(
        apiUrl:  ApiPath.clearTeamDeviceIdApi,
        requestBody: {
          'id': member.id,
          'device_id': '',
        },
         isFormData: true,
      );


      if (response['error'] == true) {
        await loadMembers(showLoader: false);
        return true;
      }

      errorMessage = (response['message']?.toString() ?? 'Unable to clear device ID');

      return false;
    } catch (e) {
      errorMessage = 'Unable to clear device ID: $e';
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }
}
