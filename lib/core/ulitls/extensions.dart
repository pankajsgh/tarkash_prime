
extension JsonStringExtension on Map<String, dynamic> {
  String getString(String key) {
    final value = this[key];
    if (value == null) return '';
    if (value is String) return value;
    return value.toString();
  }
  List<T> getList<T>(String key, T Function(Map<String, dynamic>) fromJson) {
    final value = this[key];
    if (value == null || value is! List) return <T>[];

    return value
        .whereType<Map<String, dynamic>>()
        .map<T>((item) => fromJson(item))
        .toList();
  }

  T getObject<T>(String key, T Function(Map<String, dynamic>) fromJson) {
    final value = this[key];

    if (value == null || value is! Map<String, dynamic>) {
      return fromJson({});
    }

    return fromJson(value);
  }
}