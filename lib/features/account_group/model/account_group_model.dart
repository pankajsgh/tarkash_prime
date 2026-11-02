
class AccountGroup {
  final String id;
  final String name;
  final String parentGroupId;
  final String parent;
  final bool isParent;
  final String description;
  final String notes;
  final bool isActive;

  const AccountGroup({
    required this.id,
    required this.name,
    this.parentGroupId = '',
    this.parent = '',
    this.isParent = false,
    this.description = '',
    this.notes = '',
    this.isActive = true,
  });

  factory AccountGroup.fromJson(Map<String, dynamic> json) {
    return AccountGroup(
      id: json['id']?.toString() ?? '',
      name: json['group_name']?.toString() ?? '',
      parentGroupId: json['parent_group_id']?.toString() ?? '',
      isParent: json['is_parent']?.toString() == '1',
      description: json['description']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
      isActive: json['is_active']?.toString() == '1',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id.toString(),
      'group_name': name,
      'parent_group_id': parentGroupId,
      'is_parent': isParent ? '1' : '0',
      'description': description,
      'notes': notes,
      'is_active': isActive ? '1' : '0',
    };
  }

  AccountGroup copyWith({
    String? id,
    String? name,
    String? parentGroupId,
    String? parent,
    bool? isParent,
    String? description,
    String? notes,
    bool? isActive,
  }) {
    return AccountGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      parentGroupId: parentGroupId ?? this.parentGroupId,
      parent: parent ?? this.parent,
      isParent: isParent ?? this.isParent,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
    );
  }
}
