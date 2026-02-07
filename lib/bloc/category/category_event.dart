import 'package:equatable/equatable.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadCategoriesEvent extends CategoryEvent {
  const LoadCategoriesEvent();
}

class SelectMainCategoryEvent extends CategoryEvent {
  final String mainCategoryId;

  const SelectMainCategoryEvent({required this.mainCategoryId});

  @override
  List<Object?> get props => [mainCategoryId];
}

class ToggleSubcategoryEvent extends CategoryEvent {
  final String subcategoryId;

  const ToggleSubcategoryEvent({required this.subcategoryId});

  @override
  List<Object?> get props => [subcategoryId];
}

class ClearSubcategorySelectionsEvent extends CategoryEvent {
  const ClearSubcategorySelectionsEvent();
}
