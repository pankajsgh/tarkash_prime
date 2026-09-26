
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager{
  static final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  static const String _hadIntro = '_hadIntro';
  static const String _id = 'ida';
  static const String _roleId = 'roleId';
  static const String _name = 'name';
  static const String _accessKey = '_accessKey';

  static Future<void> saveNotification(String id, String title, DateTime scheduledTime,) async {
    final SharedPreferences prefs = await _prefs;

    List<String> notifications = prefs.getStringList('scheduled_notifications') ?? [];

    notifications.add(
      jsonEncode({
        'id': id,
        'title': title,
        'scheduledTime': scheduledTime.toIso8601String(),
      }),
    );

    await prefs.setStringList(
      'scheduled_notifications',
      notifications,
    );
  }

  static Future<List<String>> getNotificationList() async {
    final SharedPreferences prefs = await _prefs;

    List<String> notifications = prefs.getStringList('scheduled_notifications') ?? [];

    print("this is notification list");
    print(notifications);
    return notifications;
  }

  static Future<void> clearAllNotificationList() async {
    final SharedPreferences prefs = await _prefs;

    await prefs.remove('scheduled_notifications');
  }

  static Future<void> clearAllNotificationById(String id) async {
    final SharedPreferences prefs = await _prefs;
    List<String> notifications =
        prefs.getStringList('scheduled_notifications') ?? [];

    notifications.removeWhere((item) {
      final data = jsonDecode(item);
      return data['id'] == id;
    });

    await prefs.setStringList('scheduled_notifications', notifications);
  }

  static Future<void> removeExpiredNotifications() async {
    final prefs = await SharedPreferences.getInstance();

    List<String> notifications = prefs.getStringList('scheduled_notifications') ?? [];

    final now = DateTime.now();

    notifications.removeWhere((item) {
      final data = jsonDecode(item);

      final scheduledTime = DateTime.parse(
        data['scheduledTime'],
      );

      return scheduledTime.isBefore(now);
    });

    await prefs.setStringList(
      'scheduled_notifications',
      notifications,
    );
  }

  static Future<void> setLoginId({required String userId, required String roleId, required accessKey, required name}) async{
    final SharedPreferences prefs = await _prefs;
    prefs.setString(_id, userId);
    prefs.setString(_accessKey, accessKey);
    prefs.setString(_roleId, roleId);
    prefs.setString(_name, name);
  }

  static Future<void> setRoleId({required String roleId, required name}) async{
    final SharedPreferences prefs = await _prefs;
    prefs.setString(_roleId, roleId);
    prefs.setString(_name, name);
  }

  static Future<String> getLoginId() async{
    final SharedPreferences prefs = await _prefs;
    return prefs.getString(_id) ?? '';
  }

  static Future<String> getRoleId() async{
    final SharedPreferences prefs = await _prefs;
    return prefs.getString(_roleId) ?? '';
  }

  static Future<String> getName() async{
    final SharedPreferences prefs = await _prefs;
    return prefs.getString(_name) ?? '';
  }

  static Future<Future<bool>> removeLogin() async{
    final SharedPreferences prefs = await _prefs;
    return prefs.clear();
  }

  static Future<void> setIntro() async{
    final SharedPreferences prefs = await _prefs;
    prefs.setString(_hadIntro, 'yes');
  }
  static Future<bool> hadIntro() async{
    final SharedPreferences prefs = await _prefs;
    return prefs.containsKey(_hadIntro);
  }
}