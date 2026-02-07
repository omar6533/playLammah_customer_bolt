import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/app_service.dart';
import 'category_event.dart';
import 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final AppService _appService;

  CategoryBloc({AppService? appService})
      : _appService = appService ?? AppService(),
        super(const CategoryInitial()) {
    on<LoadCategoriesEvent>(_onLoadCategories);
    on<SelectMainCategoryEvent>(_onSelectMainCategory);
    on<ToggleSubcategoryEvent>(_onToggleSubcategory);
    on<ClearSubcategorySelectionsEvent>(_onClearSelections);
  }

  Future<void> _onLoadCategories(
      LoadCategoriesEvent event, Emitter<CategoryState> emit) async {
    emit(const CategoryLoading());
    try {
      final categories = await _appService.getMainCategories();
      emit(CategoryLoaded(
        mainCategories: categories,
        selectedCategorySubcategories: [],
        selectedSubcategoryIds: [],
      ));
    } catch (e) {
      emit(CategoryError(message: e.toString()));
    }
  }

  Future<void> _onSelectMainCategory(
      SelectMainCategoryEvent event, Emitter<CategoryState> emit) async {
    final state = this.state;
    if (state is! CategoryLoaded) return;

    try {
      final subcategories = await _appService.getSubCategoriesForMainCategory(
        event.mainCategoryId,
      );

      emit(CategoryLoaded(
        mainCategories: state.mainCategories,
        selectedMainCategoryId: event.mainCategoryId,
        selectedCategorySubcategories: subcategories,
        selectedSubcategoryIds: [],
      ));
    } catch (e) {
      emit(CategoryError(message: e.toString()));
    }
  }

  Future<void> _onToggleSubcategory(
      ToggleSubcategoryEvent event, Emitter<CategoryState> emit) async {
    final state = this.state;
    if (state is! CategoryLoaded) return;

    final selected = List<String>.from(state.selectedSubcategoryIds);
    if (selected.contains(event.subcategoryId)) {
      selected.remove(event.subcategoryId);
    } else {
      selected.add(event.subcategoryId);
    }

    emit(CategoryLoaded(
      mainCategories: state.mainCategories,
      selectedMainCategoryId: state.selectedMainCategoryId,
      selectedCategorySubcategories: state.selectedCategorySubcategories,
      selectedSubcategoryIds: selected,
    ));
  }

  Future<void> _onClearSelections(
      ClearSubcategorySelectionsEvent event, Emitter<CategoryState> emit) async {
    final state = this.state;
    if (state is! CategoryLoaded) return;

    emit(CategoryLoaded(
      mainCategories: state.mainCategories,
      selectedMainCategoryId: state.selectedMainCategoryId,
      selectedCategorySubcategories: state.selectedCategorySubcategories,
      selectedSubcategoryIds: [],
    ));
  }
}
