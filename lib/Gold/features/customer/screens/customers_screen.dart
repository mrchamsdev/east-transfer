import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive_extensions.dart';
import '../../../core/utils/screen_utility.dart';
import '../../../widgets/gold_back_button.dart';
import '../models/customer_model.dart';
import '../repository/customer_repository.dart';
import '../../../core/constants/app_routes.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final CustomerRepository _repository = CustomerRepository();
  final TextEditingController _searchController = TextEditingController();
  
  bool _isLoading = true;
  List<Customer> _allCustomers = [];
  List<Customer> _filteredCustomers = [];

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchCustomers() async {
    setState(() => _isLoading = true);
    try {
      final data = await _repository.getAllCustomers();
      setState(() {
        _allCustomers = data;
        _filteredCustomers = data;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCustomers = _allCustomers.where((c) {
        return c.name.toLowerCase().contains(query) ||
            c.phoneNumber.contains(query) ||
            (c.createdByName ?? '').toLowerCase().contains(query);
      }).toList();
    });
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '';
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  Color _getAvatarColor(int index) {
    final colors = [
      const Color(0xFF0F9D58), // Green
      const Color(0xFFA53B0E), // Red/Brown
      const Color(0xFF0D47A1), // Blue
      const Color(0xFF6A1B9A), // Purple
    ];
    return colors[index % colors.length];
  }

  String _formatJoinedDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '---';
    try {
      final date = DateTime.tryParse(dateString);
      if (date == null) return dateString;
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'June',
        'July', 'Aug', 'Sept', 'Oct', 'Nov', 'Dec'
      ];
      return '${date.day}, ${months[date.month - 1]}';
    } catch (_) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtility().init(context);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GoldBackButton(
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Customers',
          style: AppTextStyles.h1.copyWith(
            fontSize: 16,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar container
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
            child: Container(
              height: 5.2.h,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: TextField(
                controller: _searchController,
                style: AppTextStyles.bodyMedium.copyWith(fontSize: 12.sp),
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12.sp,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColors.textSecondary,
                    size: 18.sp,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 1.2.h),
                ),
              ),
            ),
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.divider),
          
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primaryBlue),
                  )
                : _filteredCustomers.isEmpty
                    ? Center(
                        child: Text(
                          'No customers found',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchCustomers,
                        color: AppColors.primaryBlue,
                        child: ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                          itemCount: _filteredCustomers.length,
                          itemBuilder: (context, index) {
                            final customer = _filteredCustomers[index];
                            final avatarColor = _getAvatarColor(index);
                            final initials = _getInitials(customer.name);
                            final joinedDate = _formatJoinedDate(customer.createdAt);

                            return GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.customerDetails,
                                  arguments: customer,
                                );
                              },
                              child: Container(
                                margin: EdgeInsets.only(bottom: 1.8.h),
                                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8.r),
                                  border: Border.all(
                                    color: const Color(0xFFF1F5F9),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF0F172A).withValues(alpha: 0.02),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    // Avatar
                                    Container(
                                      width: 10.w,
                                      height: 10.w,
                                      decoration: BoxDecoration(
                                        color: avatarColor,
                                        borderRadius: BorderRadius.circular(6.r),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        initials,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 4.w),
                                    // Details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            customer.name,
                                            style: AppTextStyles.h3.copyWith(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          SizedBox(height: 0.5.h),
                                          Text(
                                            'Created by: ${customer.createdByName ?? 'Admin'}',
                                            style: AppTextStyles.bodySmall.copyWith(
                                              fontSize: 10.sp,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Right side joined date
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'Joined on',
                                          style: TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 9.sp,
                                          ),
                                        ),
                                        SizedBox(height: 0.5.h),
                                        Text(
                                          joinedDate,
                                          style: TextStyle(
                                            color: AppColors.textPrimary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
