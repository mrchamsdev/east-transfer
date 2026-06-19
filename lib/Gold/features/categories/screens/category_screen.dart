import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/network/gold_session.dart';
import '../../../widgets/gold_app_bar.dart';
import '../../../widgets/gold_dialogs.dart';
import '../../../widgets/no_access_widget.dart';
import '../models/category_model.dart';
import '../repository/category_repository.dart';
import 'add_category_modal.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final CategoryRepository _repository = CategoryRepository();
  List<ExpenseCategory> _categories = [];
  List<ExpenseCategory> _filteredCategories = [];
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    setState(() => _isLoading = true);
    try {
      final data = await _repository.getCategories();
      setState(() {
        _categories = data;
        _filteredCategories = data;
      });
    } catch (e) {
      if (mounted) GoldDialogs.showSnackBar(context, "Error fetching categories", isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filterCategories(String query) {
    setState(() {
      _filteredCategories = _categories
          .where((cat) => cat.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> _handleDelete(ExpenseCategory category) async {
    if (category.id == null) return;

    final confirm = await GoldDialogs.showPermissionDialog(
      context: context,
      title: "Delete Category?",
      message: "Are you sure you want to delete '${category.name}'?",
      confirmLabel: "Delete",
      icon: Icons.delete_outline,
    );

    if (!confirm) return;

    setState(() => _isLoading = true);
    try {
      final success = await _repository.deleteCategory(category.id!);
      if (success) {
        if (mounted) GoldDialogs.showSnackBar(context, "Category deleted successfully");
        _fetchCategories();
      } else {
        if (mounted) GoldDialogs.showSnackBar(context, "Failed to delete category", isError: true);
      }
    } catch (e) {
      if (mounted) GoldDialogs.showSnackBar(context, "Error: ${e.toString()}", isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!GoldSession.instance.canRead('Category')) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: NoAccessWidget(moduleName: 'Category'),
      );
    }

    final canWrite = GoldSession.instance.canWrite('Category');

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: GoldAppBar(
        title: 'Category',
        showSearch: false,
        showBackButton: true,
        actions: [
          if (canWrite) ...[
            _buildAddButton(),
            const SizedBox(width: 16),
          ],
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F2F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _filterCategories,
                decoration: const InputDecoration(
                  hintText: 'Search',
                  prefixIcon: Icon(Icons.search, color: Colors.grey, size: 20),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('Recent', style: AppTextStyles.label.copyWith(color: AppColors.textPrimary)),
          ),
          Expanded(
            child: _isLoading && _categories.isEmpty
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
                : RefreshIndicator(
                    onRefresh: _fetchCategories,
                    color: AppColors.primaryBlue,
                    child: ListView.separated(
                      padding: const EdgeInsets.only(bottom: 20),
                      itemCount: _filteredCategories.length,
                      separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.divider),
                      itemBuilder: (context, index) {
                        final category = _filteredCategories[index];
                        return ListTile(
                          onTap: canWrite ? () => _showAddEditModal(category: category) : null,
                          leading: category.icon != null && category.icon!.isNotEmpty
                              ? SizedBox(
                                  width: 30,
                                  height: 30,
                                  child: category.icon!.toLowerCase().endsWith('.svg')
                                      ? SvgPicture.network(
                                          category.icon!.replaceAll(' ', '%20'),
                                          fit: BoxFit.contain,
                                          placeholderBuilder: (context) => const Center(
                                            child: SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(strokeWidth: 2),
                                            ),
                                          ),
                                        )
                                      : Image.network(
                                          category.icon!.replaceAll(' ', '%20'),
                                          fit: BoxFit.contain,
                                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.category, color: Colors.grey, size: 28),
                                        ),
                                )
                              : Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.category, color: Colors.grey, size: 20),
                                ),
                          title: Text(
                            category.name,
                            style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                          ),
                          trailing: canWrite
                              ? IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 22),
                                  onPressed: () => _handleDelete(category),
                                )
                              : null,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return SizedBox(
      height: 36,
      child: ElevatedButton(
        onPressed: () => _showAddEditModal(),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        child: const Text('+ Add', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showAddEditModal({ExpenseCategory? category}) async {
    final result = await showDialog(
      context: context,
      builder: (context) => AddCategoryModal(category: category),
    );
    if (result == true) {
      _fetchCategories();
    }
  }
}
