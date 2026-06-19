import 'package:bank_scan/Gold/widgets/gold_app_bar.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive_extensions.dart';
import '../../../core/utils/screen_utility.dart';
import '../../categories/models/category_model.dart';
import '../../categories/repository/category_repository.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CategoryPickerScreen extends StatefulWidget {
  const CategoryPickerScreen({super.key});

  @override
  State<CategoryPickerScreen> createState() => _CategoryPickerScreenState();
}

class _CategoryPickerScreenState extends State<CategoryPickerScreen> {
  final CategoryRepository _repository = CategoryRepository();
  final TextEditingController _searchController = TextEditingController();

  List<ExpenseCategory> _categories = [];
  List<ExpenseCategory> _filtered = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchCategories() async {
    setState(() => _isLoading = true);
    try {
      final data = await _repository.getCategories();
      setState(() {
        _categories = data;
        _filtered = data;
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error loading categories'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _filtered = query.isEmpty
          ? _categories
          : _categories
              .where((c) => c.name.toLowerCase().contains(query.toLowerCase()))
              .toList();
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _onSearchChanged('');
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtility().init(context);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: GoldAppBar(
          showSearch: false,
          title: 'Category',
          showBackButton: true,
          centerTitle: true,
          showNotification: false,
          onBackPressed: () => AppRoutes.pop(context),
          actions: [
            TextButton(
              onPressed: () => AppRoutes.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 15.sp,
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // ── Search Bar ────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 5.w,
                vertical: 1.5.h,
              ),
              child: Container(
                height: 6.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F2F5),
                  borderRadius: BorderRadius.circular(ScreenUtility.radiusMedium.r),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search category',
                    hintStyle: AppTextStyles.searchHint,
                    prefixIcon: Icon(Icons.search,
                        color: AppColors.textSecondary, size: 20.sp),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.close,
                                color: AppColors.textSecondary, size: 18.sp),
                            onPressed: _clearSearch,
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 1.8.h),
                  ),
                ),
              ),
            ),

            // ── Category List ─────────────────────────────────────────────
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primaryBlue))
                  : _filtered.isEmpty
                      ? Center(
                          child: Text(
                            'No categories found.',
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: AppColors.textSecondary),
                          ),
                        )
                      : ListView.separated(
                          padding: EdgeInsets.only(bottom: 3.h),
                          itemCount: _filtered.length,
                          separatorBuilder: (_, __) => const Divider(
                              height: 1,
                              indent: 72,
                              color: AppColors.divider),
                          itemBuilder: (context, index) {
                            final category = _filtered[index];
                            return _CategoryTile(
                              category: category,
                              onTap: () => AppRoutes.pop(context, category),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── _CategoryTile ────────────────────────────────────────────────────────────
class _CategoryTile extends StatelessWidget {
  final ExpenseCategory category;
  final VoidCallback onTap;

  const _CategoryTile({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 0.5.h),
      leading: category.icon != null && category.icon!.isNotEmpty
          ? SizedBox(
              width: 5.w,
              height: 5.h,
              child: category.icon!.toLowerCase().endsWith('.svg')
                  ? SvgPicture.network(
                      category.icon!.replaceAll(' ', '%20'),
                      fit: BoxFit.contain,
                      placeholderBuilder: (context) => Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryBlue),
                        ),
                      ),
                    )
                  : Image.network(
                      category.icon!.replaceAll(' ', '%20'),
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 10.w,
                        height: 5.h,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Center(
                          child: Icon(Icons.shopping_bag_outlined, color: AppColors.primaryBlue, size: 20.sp),
                        ),
                      ),
                    ),
            )
          : Container(
              width: 10.w,
              height: 5.h,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Center(
                child: Icon(Icons.shopping_bag_outlined,
                    color: AppColors.primaryBlue, size: 20.sp),
              ),
            ),
      title: Text(
        category.name,
        style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}
