import 'package:equatable/equatable.dart';

class SubCategory extends Equatable {
  final String id;
  final String mainCategoryId;
  final String name;
  final String nameAr;
  final String icon;
  final bool isActive;
  final int order;

  const SubCategory({
    required this.id,
    required this.mainCategoryId,
    required this.name,
    required this.nameAr,
    required this.icon,
    required this.isActive,
    required this.order,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      id: json['id'] as String,
      mainCategoryId: json['main_category_id'] as String,
      name: json['name'] as String,
      nameAr: json['name_ar'] as String,
      icon: json['icon'] as String,
      isActive: json['is_active'] as bool,
      order: json['order'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'main_category_id': mainCategoryId,
      'name': name,
      'name_ar': nameAr,
      'icon': icon,
      'is_active': isActive,
      'order': order,
    };
  }

  @override
  List<Object?> get props => [
        id,
        mainCategoryId,
        name,
        nameAr,
        icon,
        isActive,
        order,
      ];
}
