class ExpenseCategory {
  final int? id;
  final String name;
  final String? type;
  final String? icon;
  final int? createdBy;
  final String? createdAt;
  final String? updatedAt;

  ExpenseCategory({
    this.id,
    required this.name,
    this.type,
    this.icon,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  factory ExpenseCategory.fromJson(Map<String, dynamic> json) {
    return ExpenseCategory(
      id: json['id'],
      name: json['name'] ?? '',
      type: json['type'],
      icon: json['icon'],
      createdBy: json['createdBy'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'type': type ?? 'Personal',
      if (icon != null) 'icon': icon,
    };
  }
}
