import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ChallanCartStorage {

  static Future<void> saveDraft(DraftModel data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'draft_${data.partyId}',
      jsonEncode(data.toJson()),
    );
  }

  static Future<DraftModel?> getDraft(String partyId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('draft_$partyId');

    if (jsonString == null || jsonString.isEmpty) {
      return null;
    }
    try {

      var data = jsonDecode(jsonString);
      var draft = DraftModel.fromJson(data);

      return draft;
    } catch (e) {
      return null;
    }

  }


  static Future<bool> deleteDraftItemById({
    required String partyId,
    required String draftId,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final jsonString = prefs.getString('draft_$partyId');

    if (jsonString == null || jsonString.isEmpty) {
      return false;
    }

    try {
      final data = jsonDecode(jsonString);

      final draft = DraftModel.fromJson(data);

      // Check whether the draft ID exists
      final isRemoved = draft.draftName.remove(draftId);

      if (!isRemoved) {
        return false;
      }

      // Save the updated draft list
      await prefs.setString(
        'draft_$partyId',
        jsonEncode(draft.toJson()),
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<void> save(Map<String, dynamic> data, String key) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      key,
      jsonEncode(data),
    );
  }

  static Future<Map<String, dynamic>?> get( String key) async {
    final prefs = await SharedPreferences.getInstance();

    final jsonString = prefs.getString(key);

    if (jsonString == null || jsonString.isEmpty) {
      return null;
    }

    try {
      return jsonDecode(jsonString);
    } catch (e) {
      return null;
    }
  }

  static Future<void> clear(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  static Future<void> clearAll() async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.clear();
  }

}

class DraftModel {
  String partyId;
  List<String> draftName;

  DraftModel({
    required this.partyId,
    required this.draftName,
  });

  Map<String, dynamic> toJson() {
    return {
      'partyId': partyId,
      'draftName': draftName,
    };
  }

  void addDraft(String value){
    draftName.add(value);
  }

  factory DraftModel.fromJson(Map<String, dynamic> json) {
    return DraftModel(
      partyId: json['partyId']?.toString() ?? '',
      draftName: json['draftName'] != null
          ? List<String>.from(
        (json['draftName'] as List).map(
              (e) => e.toString(),
        ),
      )
          : [],
    );
  }
}