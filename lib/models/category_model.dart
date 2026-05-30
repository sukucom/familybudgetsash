class CategoryModel {
  final int? id;
  final String name;
  final String icon;
  final String type; // 'Income' or 'Expense'
  final double budgetLimit;

  CategoryModel({
    this.id,
    required this.name,
    required this.icon,
    required this.type,
    this.budgetLimit = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'type': type,
      'budget_limit': budgetLimit,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'],
      name: map['name'],
      icon: map['icon'],
      type: map['type'],
      budgetLimit: (map['budget_limit'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
