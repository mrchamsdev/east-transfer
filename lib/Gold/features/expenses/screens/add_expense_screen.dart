import 'dart:io';

import 'package:bank_scan/Gold/widgets/gold_app_bar.dart';
import 'package:bank_scan/Gold/widgets/gold_dialogs.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/network/gold_session.dart';
import '../../categories/models/category_model.dart';
import '../models/expense_model.dart';
import '../repository/expense_repository.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AddExpenseScreen extends StatefulWidget {
  final Expense? expense;

  const AddExpenseScreen({super.key, this.expense});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  // ─── State ───────────────────────────────────────────────────────────────
  final ExpenseRepository _repository = ExpenseRepository();
  final ImagePicker _picker = ImagePicker();

  ExpenseCategory? _selectedCategory;
  String _selectedCurrency = 'INR';
  DateTime _selectedDate = DateTime.now();
  String? _imagePath;
  String? _currentImageUrl;
  bool _isLoading = false;

  // ─── Controllers ─────────────────────────────────────────────────────────
  final TextEditingController _amountController = TextEditingController(
    text: '',
  );
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  bool get _isEditMode => widget.expense != null;

  // ─── Lifecycle ───────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _populateEditFields(widget.expense!);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _categoryController.dispose();
    _commentController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _populateEditFields(Expense exp) {
    _amountController.text = exp.amount.toStringAsFixed(2);
    _commentController.text = exp.comment ?? '';
    _noteController.text = exp.note ?? '';
    _selectedCurrency = exp.amountType;
    _selectedCategory = exp.expenseCategory;
    _categoryController.text = exp.description.isNotEmpty ? exp.description : (exp.expenseCategory?.name ?? '');
    _currentImageUrl = exp.file;
    try {
      _selectedDate = DateTime.parse(exp.expenseDate);
    } catch (_) {
      _selectedDate = DateTime.now();
    }
  }

  // ─── Actions ─────────────────────────────────────────────────────────────

  /// Opens the category picker and updates selected category on return.
  Future<void> _openCategoryPicker() async {
    final result = await Navigator.pushNamed(context, AppRoutes.categoryPicker);
    if (result != null && result is ExpenseCategory) {
      setState(() {
        _selectedCategory = result;
      });
    }
  }

  /// Opens the currency picker and updates selected currency on return.
  Future<void> _openCurrencyPicker() async {
    final result = await Navigator.pushNamed(context, AppRoutes.currencyPicker);
    if (result != null && result is Currency) {
      setState(() => _selectedCurrency = result.code);
    }
  }

  /// Opens a date picker dialog.
  Future<void> _openDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primaryBlue,
            onPrimary: AppColors.white,
            onSurface: AppColors.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  /// Opens the image picker bottom sheet.
  Future<void> _openImagePicker() async {
    try {
      final XFile? image = await showModalBottomSheet<XFile?>(
        context: context,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (_) => SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: AppColors.primaryBlue,
                ),
                title: const Text('Photo Gallery'),
                onTap: () async {
                  final img = await _picker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 80,
                  );
                  if (context.mounted) AppRoutes.pop(context, img);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_camera,
                  color: AppColors.primaryBlue,
                ),
                title: const Text('Camera'),
                onTap: () async {
                  final img = await _picker.pickImage(
                    source: ImageSource.camera,
                    imageQuality: 80,
                  );
                  if (context.mounted) AppRoutes.pop(context, img);
                },
              ),
            ],
          ),
        ),
      );
      if (image != null) setState(() => _imagePath = image.path);
    } catch (_) {
      GoldDialogs.showSnackBar(context, 'Failed to pick image', isError: true);
    }
  }

  /// Opens the note screen.
  Future<void> _openNoteScreen() async {
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.addNote,
      arguments: {'note': _noteController.text},
    );
    if (result != null && result is Map<String, String>) {
      setState(() => _noteController.text = result['note'] ?? '');
    }
  }

  /// Validates and submits the expense form.
  Future<void> _handleSubmit() async {
    if (_selectedCategory == null) {
      GoldDialogs.showSnackBar(
        context,
        'Please select a category',
        isError: true,
      );
      return;
    }

    final amountText = _amountController.text.trim();
    final digitCount = amountText.replaceAll(RegExp(r'[^0-9]'), '').length;
    if (digitCount > 15) {
      GoldDialogs.showSnackBar(
        context,
        'Amount cannot exceed 15 digits',
        isError: true,
      );
      return;
    }

    final amount = double.tryParse(amountText) ?? 0.0;
    if (amount <= 0.0) {
      GoldDialogs.showSnackBar(
        context,
        'Please enter a valid amount greater than 0',
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final dateStr =
          '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

      Expense? savedExpense;

      // description = whatever the user typed in the category text field (falls back to category name if empty)
      final description = _categoryController.text.trim().isNotEmpty
          ? _categoryController.text.trim()
          : (_selectedCategory?.name ?? '');

      if (_isEditMode) {
        savedExpense = await _repository.updateExpense(
          widget.expense!.id!,
          expenseCategoryId: _selectedCategory!.id!,
          companyId: widget.expense!.companyId,
          expenseDate: dateStr,
          amount: amount,
          amountType: _selectedCurrency,
          description: description,
          comment: _commentController.text.trim().isEmpty
              ? null
              : _commentController.text.trim(),
          note: _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim(),
          file: _imagePath != null ? null : _currentImageUrl,
        );
      } else {
        savedExpense = await _repository.createExpense(
          expenseCategoryId: _selectedCategory!.id!,
          companyId: 1,
          expenseDate: dateStr,
          amount: amount,
          amountType: _selectedCurrency,
          description: description,
          comment: _commentController.text.trim().isEmpty
              ? null
              : _commentController.text.trim(),
          note: _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim(),
        );
      }

      if (savedExpense != null) {
        if (_imagePath != null) {
          final uploaded = await _repository.uploadExpenseFile(
            savedExpense.id!,
            _imagePath!,
          );
          if (!uploaded && mounted) {
            GoldDialogs.showSnackBar(
              context,
              'Expense saved, but receipt upload failed.',
              isError: true,
            );
          }
        }
        if (mounted) {
          GoldDialogs.showSnackBar(
            context,
            _isEditMode
                ? 'Expense updated successfully!'
                : 'Expense created successfully!',
          );
          AppRoutes.pop(context, true);
        }
      } else {
        if (mounted) {
          GoldDialogs.showSnackBar(
            context,
            _isEditMode
                ? 'Failed to update expense.'
                : 'Failed to create expense.',
            isError: true,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        GoldDialogs.showSnackBar(
          context,
          'Error: ${e.toString()}',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  String _getFormattedDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }

  String _getCurrencySymbol(String code) {
    if (code == 'Rupees' || code == 'INR') return '₹';
    final currency = CurrencyService().findByCode(code);
    return currency?.symbol ?? code;
  }

  // ─── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: AppColors.white,
        appBar: GoldAppBar(
          showSearch: false,
          title: _isEditMode ? 'Edit Expense' : 'Add Expense',
          showBackButton: true,
          centerTitle: true,
          showNotification: false,
          actions: [
            if (!_isLoading)
              IconButton(
                onPressed: _handleSubmit,
                icon: const Icon(
                  Icons.check,
                  color: AppColors.textPrimary,
                  size: 28,
                ),
              ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Category Row ──────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 36,
                        vertical: 8,
                      ),
                      child: _FormRow(
                        iconWidget: _selectedCategory?.icon != null && _selectedCategory!.icon!.isNotEmpty
                            ? _selectedCategory!.icon!.toLowerCase().endsWith('.svg')
                                ? SvgPicture.network(
                                    _selectedCategory!.icon!.replaceAll(' ', '%20'),
                                    width: 20,
                                    height: 20,
                                    placeholderBuilder: (context) => const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  )
                                : Image.network(
                                    _selectedCategory!.icon!.replaceAll(' ', '%20'),
                                    width: 20,
                                    height: 20,
                                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.menu_book_outlined, color: AppColors.textPrimary, size: 20),
                                  )
                            : const Icon(Icons.menu_book_outlined, color: AppColors.textPrimary, size: 20),
                        onIconTap: _openCategoryPicker,
                        child: TextField(
                          controller: _categoryController,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          onTap: () {
                            if (_selectedCategory == null) {
                              _openCategoryPicker();
                            }
                          },
                          decoration: InputDecoration(
                            hintText: 'Enter a Category',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 16,
                            ),
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: AppColors.primaryBlue,
                                width: 1.5,
                              ),
                            ),
                            filled: false,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 8,
                            ),
                            // show checkmark when a category is selected
                            suffixIcon: _selectedCategory != null
                                ? const Icon(
                                    Icons.check_circle,
                                    color: AppColors.primaryBlue,
                                    size: 18,
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Amount Row ────────────────────────────────────────
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 36,
                        vertical: 8,
                      ),
                      child: _FormRow(
                        iconWidget: Text(
                          _getCurrencySymbol(_selectedCurrency),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        onIconTap: _openCurrencyPicker,
                        child: TextFormField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            DigitLimitFormatter(15),
                          ],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          decoration: _inputDecoration('0.00'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Date Row ──────────────────────────────────────────
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 36,
                        vertical: 8,
                      ),
                      child: _FormRow(
                        icon: Icons.calendar_today_outlined,
                        onIconTap: _openDatePicker,
                        child: GestureDetector(
                          onTap: _openDatePicker,
                          child: AbsorbPointer(
                            child: TextFormField(
                              key: ValueKey(_selectedDate),
                              readOnly: true,
                              initialValue: _getFormattedDate(_selectedDate),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              decoration: _inputDecoration('Select Date'),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Note Preview ──────────────────────────────────────
                    if (_noteController.text.isNotEmpty) ...[
                      const Text(
                        'Note:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          _noteController.text,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // ── Receipt Preview ───────────────────────────────────
                    if (_imagePath != null || _currentImageUrl != null) ...[
                      const Text(
                        'Receipt Attachment:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (_) => Dialog(
                                  backgroundColor: Colors.transparent,
                                  insetPadding: EdgeInsets.zero,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      InteractiveViewer(
                                        child: _imagePath != null
                                            ? Image.file(File(_imagePath!))
                                            : Image.network(_currentImageUrl!),
                                      ),
                                      Positioned(
                                        top: 40,
                                        right: 20,
                                        child: IconButton(
                                          icon: const Icon(Icons.close, color: Colors.white, size: 30),
                                          onPressed: () => Navigator.pop(context),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: _imagePath != null
                                  ? Image.file(
                                      File(_imagePath!),
                                      height: 120,
                                      width: 120,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.network(
                                      _currentImageUrl!,
                                      height: 120,
                                      width: 120,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => setState(() {
                                _imagePath = null;
                                _currentImageUrl = null;
                              }),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // ── Bottom Action Bar ─────────────────────────────────────────
            _BottomActionBar(
              onCamera: _openImagePicker,
              onNote: _openNoteScreen,
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 16),
    enabledBorder: const UnderlineInputBorder(
      borderSide: BorderSide(color: Color(0xFFE2E8F0)),
    ),
    focusedBorder: const UnderlineInputBorder(
      borderSide: BorderSide(color: AppColors.primaryBlue, width: 1.5),
    ),
    filled: false,
    fillColor: Colors.transparent,
    contentPadding: const EdgeInsets.symmetric(vertical: 8),
  );
}

// ─── _FormRow ─────────────────────────────────────────────────────────────────
/// A reusable row with a tappable icon on the left and a child widget on the right.
class _FormRow extends StatelessWidget {
  final IconData? icon;
  final Widget? iconWidget;
  final VoidCallback onIconTap;
  final Widget child;

  const _FormRow({
    this.icon,
    this.iconWidget,
    required this.onIconTap,
    required this.child,
  }) : assert(
         icon != null || iconWidget != null,
         'Provide either icon or iconWidget',
       );

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left icon — tapping it opens the corresponding picker
        GestureDetector(
          onTap: onIconTap,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(color: const Color(0xFFE2E8F0)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child:
                  iconWidget ??
                  Icon(icon!, color: AppColors.textPrimary, size: 20),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(child: child),
      ],
    );
  }
}

// ─── _BottomActionBar ─────────────────────────────────────────────────────────
class _BottomActionBar extends StatelessWidget {
  final VoidCallback onCamera;
  final VoidCallback onNote;

  const _BottomActionBar({required this.onCamera, required this.onNote});

  @override
  Widget build(BuildContext context) {
    final displayName = (GoldSession.instance.userName?.isNotEmpty ?? false)
        ? GoldSession.instance.userName!
        : 'Thug';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          const Icon(Icons.account_circle, color: Color(0xFF003366), size: 30),
          const SizedBox(width: 12),
          Text(displayName, style: AppTextStyles.bodyMedium),
          const Spacer(),
          IconButton(
            onPressed: onCamera,
            icon: Image.asset(
              'assets/images/camera.png',
              width: 24,
              height: 24,
              fit: BoxFit.contain,
            ),
          ),
          IconButton(
            onPressed: onNote,
            icon: Image.asset(
              'assets/images/note.png',
              width:20,
              height: 20,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── DigitLimitFormatter ──────────────────────────────────────────────────────
/// A custom formatter that restricts input to a specified number of digits.
class DigitLimitFormatter extends TextInputFormatter {
  final int maxDigits;
  DigitLimitFormatter(this.maxDigits);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digitCount = newValue.text.replaceAll(RegExp(r'[^0-9]'), '').length;
    if (digitCount > maxDigits) {
      return oldValue;
    }
    return newValue;
  }
}
