
class RoleFeaturePermissionModel {
  final String featureId;
  final String featureName;
  final String status;

  bool alls;
  bool shows;
  bool saves;
  bool updates;
  bool searchs;
  bool deletes;
  bool prints;

  RoleFeaturePermissionModel({
    required this.featureId,
    required this.featureName,
    this.status = '',
    this.alls = false,
    this.shows = false,
    this.saves = false,
    this.updates = false,
    this.searchs = false,
    this.deletes = false,
    this.prints = false,
  });

  factory RoleFeaturePermissionModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return RoleFeaturePermissionModel(
      featureId: _read(json, [
        'feature_id',
        'featureId',
        'id',
      ]),
      featureName: _read(json, [
        'features',
        'feature',
        'feature_name',
        'featureName',
        'Menus',
      ]),
      status: _read(json, ['status']),
      alls: _readPermission(json['Alls'] ?? json['alls']),
      shows: _readPermission(json['Shows'] ?? json['shows']),
      saves: _readPermission(json['Saves'] ?? json['saves']),
      updates: _readPermission(json['Updates'] ?? json['updates']),
      searchs: _readPermission(json['Searchs'] ?? json['searchs']),
      deletes: _readPermission(json['Deletes'] ?? json['deletes']),
      prints: _readPermission(json['Prints'] ?? json['prints']),
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

  static bool _readPermission(dynamic value) {
    if (value == true || value == 1) return true;

    final text = value?.toString().trim().toLowerCase() ?? '';

    return text == 'on' ||
        text == '1' ||
        text == 'true' ||
        text == 'yes';
  }

  void setPermission(String key, bool value) {
    switch (key.toLowerCase()) {
      case 'alls':
        setAll(value);
        return;
      case 'shows':
        shows = value;
        break;
      case 'saves':
        saves = value;
        break;
      case 'updates':
        updates = value;
        break;
      case 'searchs':
        searchs = value;
        break;
      case 'deletes':
        deletes = value;
        break;
      case 'prints':
        prints = value;
        break;
      default:
        return;
    }

    _syncAll();
  }

  void setAll(bool value) {
    alls = value;
    shows = value;
    saves = value;
    updates = value;
    searchs = value;
    deletes = value;
    prints = value;
  }

  void _syncAll() {
    alls = shows &&
        saves &&
        updates &&
        searchs &&
        deletes &&
        prints;
  }

  Map<String, dynamic> toPermissionJson() {
    return {
      'feature_id': featureId,
      'features': featureName,
      'Alls': alls ? 'on' : '',
      'Shows': shows ? 'on' : '',
      'Saves': saves ? 'on' : '',
      'Updates': updates ? 'on' : '',
      'Searchs': searchs ? 'on' : '',
      'Deletes': deletes ? 'on' : '',
      'Prints': prints ? 'on' : '',
    };
  }
}
