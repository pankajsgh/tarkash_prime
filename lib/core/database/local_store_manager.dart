  import 'dart:convert';

  import 'package:flutter/foundation.dart';
  import 'package:shared_preferences/shared_preferences.dart';

  class ChallanCartStorage {
    // ============================================================
    // SAVE DRAFT LIST
    // Storage key = challanType
    // ============================================================

    static Future<bool> saveDraft(DraftModel data) async {
      final prefs = await SharedPreferences.getInstance();

      try {
        return await prefs.setString(
          data.challanType,
          jsonEncode(data.toJson()),
        );
      } catch (e) {
        debugPrint('Save draft error: $e');
        return false;
      }
    }

    // ============================================================
    // GET DRAFT LIST
    // ============================================================

    static Future<DraftModel?> getDraft(String challanType) async {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(challanType);

      if (jsonString == null || jsonString.isEmpty) {
        return null;
      }

      try {
        final decoded = jsonDecode(jsonString);
        if (decoded is! Map) {
          return null;
        }

        return DraftModel.fromJson(
          Map<String, dynamic>.from(decoded),
        );
      } catch (e) {
        debugPrint('Get draft error: $e');
        return null;
      }
    }

    // ============================================================
    // ADD DRAFT NAME
    // ============================================================

    static Future<bool> addDraftName({
      required String challanType,
      required String draftId,
    }) async {
      final id = draftId.trim();

      if (id.isEmpty) {
        return false;
      }
      var challanKey = challanType;
      final draft = await getDraft(challanKey) ??
          DraftModel(
            challanType: challanType,
            draftName: [],
          );

      print(draft.toJson());
      draft.addDraft(id);

      return saveDraft(draft);
    }

    // ============================================================
    // DELETE DRAFT ITEM BY ID
    //
    // Removes the draft ID from the list stored under challanType.
    // Also removes the separate challan data stored under draftId.
    // ============================================================


    static Future<bool> deleteDraftItemById({
      required String challanType,
      required String draftId,
      required String supplierId,
    }) async {
      final prefs = await SharedPreferences.getInstance();

      final id = draftId.trim();
      final partyId = supplierId.trim();

      if (id.isEmpty || partyId.isEmpty) {
        return false;
      }

      final draft = await getDraft(challanType);

      if (draft == null || !draft.removeDraft(id)) {
        return false;
      }

      try {
        // Delete the actual named challan data.
        final dataKey = '${partyId}_$id';
        await prefs.remove(dataKey);

        // Update the draft-name list.
        if (draft.draftName.isEmpty) {
          await prefs.remove(challanType);
        } else {
          final saved = await saveDraft(draft);
          if (!saved) return false;
        }

        return true;
      } catch (e) {
        debugPrint('Delete draft error: $e');
        return false;
      }
    }


    // ============================================================
    // SAVE GENERIC JSON DATA
    // ============================================================

    static Future<bool> save(
        Map<String, dynamic> data, {required String key,}
        ) async {
      final prefs = await SharedPreferences.getInstance();

      try {
        return await prefs.setString(
          key,
          jsonEncode(data),
        );
      } catch (e) {
        debugPrint('Save storage error: $e');
        return false;
      }
    }

    static Future<bool> deleteById({required String key}) async {
      try {
        final prefs = await SharedPreferences.getInstance();
        return await prefs.remove(key);
      } catch (e) {
        debugPrint('Delete storage error: $e');
        return false;
      }
    }
    // ============================================================
    // GET GENERIC JSON DATA
    // ============================================================

    static Future<Map<String, dynamic>?> get(String key) async {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(key);

      if (jsonString == null || jsonString.isEmpty) {
        return null;
      }

      try {
        final decoded = jsonDecode(jsonString);

        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }

        return null;
      } catch (e) {
        debugPrint('Get storage error: $e');
        return null;
      }
    }

    // ============================================================
    // CLEAR A SPECIFIC KEY
    // ============================================================

    static Future<bool> clear(String key) async {
      final prefs = await SharedPreferences.getInstance();

      try {
        return await prefs.remove(key);
      } catch (e) {
        debugPrint('Clear storage error: $e');
        return false;
      }
    }

    // ============================================================
    // CLEAR ALL CHALLAN DRAFTS
    //
    // Removes only the supplied challan types and their draft data.
    // Other SharedPreferences settings remain untouched.
    // ============================================================

    static Future<void> clearAll({
      required List<String> challanTypes,
    }) async {
      final prefs = await SharedPreferences.getInstance();

      for (final challanType in challanTypes) {
        final draft = await getDraft(challanType);

        if (draft != null) {
          for (final draftId in draft.draftName) {
            await prefs.remove(draftId);
          }
        }

        await prefs.remove(challanType);
      }
    }
  }

  // ============================================================
  // DRAFT MODEL
  // ============================================================

  class DraftModel {
    String challanType;
    List<String> draftName;

    DraftModel({
      required this.challanType,
      List<String>? draftName,
    }) : draftName = draftName ?? [];

    // Convert model to JSON.
    Map<String, dynamic> toJson() {
      return {
        'challanType': challanType,
        'draftName': draftName,
      };
    }

    // Add a draft only if it does not already exist.
    void addDraft(String value) {
      final id = value.trim();

      if (id.isNotEmpty && !draftName.contains(id)) {
        draftName.add(id);
      }
    }

    // Remove a draft by ID.
    bool removeDraft(String value) {
      return draftName.remove(value);
    }

    // Check whether a draft exists.
    bool containsDraft(String value) {
      return draftName.contains(value);
    }

    // Create model from JSON.
    factory DraftModel.fromJson(Map<String, dynamic> json) {
      final rawDraftNames = json['draftName'];

      return DraftModel(
        challanType: json['challanType']?.toString() ?? '',
        draftName: rawDraftNames is List
            ? rawDraftNames
            .map((e) => e.toString())
            .toSet()
            .toList()
            : <String>[],
      );
    }
  }