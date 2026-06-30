import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/network/gold_session.dart';
import '../../../core/utils/responsive_extensions.dart';
import '../../../core/utils/screen_utility.dart';
import '../../../widgets/gold_app_bar.dart';
import '../../../widgets/gold_dialogs.dart';
import '../models/expense_model.dart';
import '../repository/expense_repository.dart';
import '../widgets/detail_header.dart';
import '../widgets/detail_note.dart';
import '../widgets/history_item.dart';

class ExpenseDetailsScreen extends StatefulWidget {
  final Expense expense;

  const ExpenseDetailsScreen({super.key, required this.expense});

  @override
  State<ExpenseDetailsScreen> createState() => _ExpenseDetailsScreenState();
}

class _ExpenseDetailsScreenState extends State<ExpenseDetailsScreen> {
  final ExpenseRepository _repository = ExpenseRepository();
  late Expense _expense;
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _expense = widget.expense;
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    if (_expense.id == null) return;
    setState(() => _isLoading = true);
    try {
      final updated = await _repository.getExpenseById(_expense.id!);
      if (updated != null) setState(() => _expense = updated);
    } catch (_) {
      // Keep using current state as fallback
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleDelete() async {
    if (_expense.id == null) return;

    final confirm = await GoldDialogs.showPermissionDialog(
      context: context,
      title: 'Delete Expense?',
      message: 'Are you sure you want to delete this expense record?',
      confirmLabel: 'Delete',
      icon: Icons.delete_outline,
    );
    if (!confirm) return;

    setState(() => _isLoading = true);
    try {
      final success = await _repository.deleteExpense(_expense.id!);
      if (success) {
        if (mounted) {
          GoldDialogs.showSnackBar(context, 'Expense deleted successfully');
          AppRoutes.pop(context, true);
        }
      } else {
        if (mounted) {
          GoldDialogs.showSnackBar(context, 'Failed to delete expense',
              isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        GoldDialogs.showSnackBar(context, 'Error: ${e.toString()}',
            isError: true);
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleEdit() async {
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.addExpense,
      arguments: _expense,
    );
    if (result == true) {
      _hasChanges = true;
      _fetchDetails();
    }
  }

  String _formatDateString(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
    } catch (_) {
      return dateStr;
    }
  }

  String _formatChangeHistory(ExpenseHistoryItem historyItem) {
    if (historyItem.changes == null || historyItem.changes!.isEmpty) {
      return 'Modified record details';
    }

    final List<String> changeTexts = [];
    historyItem.changes!.forEach((field, detail) {
      final oldVal = detail.oldValue ?? 'none';
      final newVal = detail.newValue ?? 'none';
      if (field == 'amount') {
        changeTexts.add('Amount changed from ₹$oldVal to ₹$newVal');
      } else if (field == 'description') {
        changeTexts.add("Description updated to '$newVal'");
      } else if (field == 'expenseCategoryId') {
        changeTexts.add('Category updated');
      } else if (field == 'file') {
        changeTexts.add('Receipt image updated');
      } else {
        changeTexts
            .add('${field[0].toUpperCase()}${field.substring(1)} changed');
      }
    });

    return '- ' + changeTexts.join('\n- ');
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtility().init(context);

    final displayNote =
        (_expense.note != null && _expense.note!.isNotEmpty)
            ? _expense.note!
            : '';

    return WillPopScope(
      onWillPop: () async {
        AppRoutes.pop(context, _hasChanges);
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        appBar: GoldAppBar(
          showSearch: false,
          
          title: 'View Details',
 // titleFontSize: 16.sp,
  //titleFontWeight: FontWeight.w500,
          
          showBackButton: true,
          onBackPressed: () => AppRoutes.pop(context, _hasChanges),
          centerTitle: true,
          showNotification: false,
          actions: [
            if (GoldSession.instance.canWrite('Expenses')) ...[
              IconButton(
                icon: Image.asset(
                  'assets/images/delete.png',
                  width: 18.sp,
                  height: 18.sp,
                  fit: BoxFit.contain,
                ),
                onPressed: _handleDelete,
              ),
              IconButton(
                icon: Image.asset(
                  'assets/images/edit.png',
                  width: 18.sp,
                  height: 18.sp,
                  fit: BoxFit.contain,
                ),
                onPressed: _handleEdit,
              ),
            ],
          ],
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primaryBlue))
            : SingleChildScrollView(
                padding: EdgeInsets.all(ScreenUtility.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DetailHeader(
                      // Show description if available, otherwise show category name or empty string
                      title: (_expense.description != null && _expense.description!.isNotEmpty)
                          ? _expense.description!
                          : (_expense.expenseCategory?.name ?? ''),
                      amount: _expense.amount.toStringAsFixed(2),
                      date: _formatDateString(_expense.expenseDate),
                      addedBy: _expense.user?.name ?? '',
                      fileUrl: _expense.file,
                      iconUrl: _expense.expenseCategory?.icon,
                    ),
                    SizedBox(height: 1.5.h),
                    const Divider(color: Color(0xFFF1F2F5)),
                    SizedBox(height: 2.h),

                    if (displayNote.trim().isNotEmpty) ...[
                      DetailNote(note: displayNote),
                      SizedBox(height: 3.h),
                    ],

                    Text('History',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13.sp)),
                    SizedBox(height: 2.h),
                    _expense.history == null || _expense.history!.isEmpty
                        ? Padding(
                            padding: EdgeInsets.symmetric(vertical: 1.5.h),
                            child: Text(
                              'No modification history for this expense.',
                              style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12.sp),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _expense.history!.length,
                            itemBuilder: (context, idx) {
                              final item = _expense.history![idx];
                              final dateFormatted = item.updatedAt != null
                                  ? _formatDateString(item.updatedAt!)
                                  : 'Recent';
                              return HistoryItem(
                                status:
                                    'Updated this Transaction: $dateFormatted',
                                subtext: _formatChangeHistory(item),
                              );
                            },
                          ),
                  ],
                ),
              ),
      ),
    );
  }
}
