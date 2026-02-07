import 'package:equatable/equatable.dart';
import '../../models/main_category.dart';
import '../../models/sub_category.dart';

abstract class CategoryState extends Equatable {
  const CategoryState();

  @override
  List<Object?> get props => [];
}

class CategoryInitial extends CategoryState {
  const CategoryInitial();
}

class CategoryLoading extends CategoryState {
  const CategoryLoading();
}

class CategoryLoaded extends CategoryState {
  final List<MainCategory> mainCategories;
  final String? selectedMainCategoryId;
  final List<SubCategory> selectedCategorySubcategories;
  final List<String> selectedSubcategoryIds;

  const CategoryLoaded({
    required this.mainCategories,
    this.selectedMainCategoryId,
    required this.selectedCategorySubcategories,
    required this.selectedSubcategoryIds,
  });

  @override
  List<Object?> get props => [
        mainCategories,
        selectedMainCategoryId,
        selectedCategorySubcategories,
        selectedSubcategoryIds,
      ];
}

class CategoryError extends CategoryState {
  final String message;

  const CategoryError({required this.message});

  @override
  List<Object?> get props => [message];
}
