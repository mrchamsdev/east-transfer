class CategoryModel {
  final String name;
  final String section;

  CategoryModel({required this.name, required this.section});
}

final List<CategoryModel> dummyCategories = [
  CategoryModel(name: 'Games', section: 'Entertainment'),
  CategoryModel(name: 'Movies', section: 'Entertainment'),
  CategoryModel(name: 'Music', section: 'Entertainment'),
  CategoryModel(name: 'Food', section: 'Lifestyle'),
  CategoryModel(name: 'Shopping', section: 'Lifestyle'),
  CategoryModel(name: 'Transport', section: 'Lifestyle'),
];
