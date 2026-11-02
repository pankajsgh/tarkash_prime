
extension ObjectExt on Object? {
  bool get isNullOrEmpty {
    final value = this;

    if (value == null) return false;

    if (value is String) {
      return value.trim().isNotEmpty;
    }

    return true;
  }
}