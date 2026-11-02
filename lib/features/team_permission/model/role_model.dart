class RoleModel {
  final String id;
  final String roleName;
  final String webLogin;
  final String description;
  final String status;

  const RoleModel({
    required this.id,
    required this.roleName,
    this.webLogin = '',
    this.description = '',
    this.status = '',
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: _read(json, ['id', 'rid']),
      roleName: _read(json, ['role_name', 'roleName', 'name']),
      webLogin: _read(json, ['web_login', 'webLogin']),
      description: _read(json, ['description']),
      status: _read(json, ['status']),
    );
  }

  static String _read(
      Map<String, dynamic> json,
      List<String> keys,
      ) {
    for (final key in keys) {
      final value = json[key];
      if (value != null) return value.toString();
    }
    return '';
  }
}