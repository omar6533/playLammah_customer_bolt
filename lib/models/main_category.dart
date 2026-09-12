import 'package:equatable/equatable.dart';

class MainCategory extends Equatable {
  final String id;
  final String name;
  final String nameAr;
  final bool isActive;
  final int order;

  const MainCategory({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.isActive,
    required this.order,
  });

  factory MainCategory.fromJson(Map<String, dynamic> json) {
    final nameAr = (json['name_ar'] as String?) ?? '';
    return MainCategory(
      id: json['id'] as String,
      name: (json['name'] as String?) ?? nameAr,
      nameAr: nameAr,
      isActive: (json['is_active'] as bool?) ?? true,
      order: (json['order'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_ar': nameAr,
      'is_active': isActive,
      'order': order,
    };
  }

  @override
  List<Object?> get props => [id, name, nameAr, isActive, order];
}
