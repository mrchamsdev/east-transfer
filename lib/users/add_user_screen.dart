import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../widgets/bank_loader.dart';
import '../services/api_service.dart';
import '../utils/custom_dialog.dart';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({super.key});

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _customerNameController;
  late TextEditingController _accountNumberController;
  late TextEditingController _ifscCodeController;
  late TextEditingController _paymentDateController;
  late TextEditingController _amountToPayController;
  late TextEditingController _nicknameController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _aadharController;
  late TextEditingController _panController;
  late TextEditingController _commentController;

  DateTime? _selectedDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _customerNameController = TextEditingController();
    _accountNumberController = TextEditingController();
    _ifscCodeController = TextEditingController();
    _selectedDate = DateTime.now();
    _paymentDateController = TextEditingController(
      text: _formatDate(_selectedDate!),
    );
    _amountToPayController = TextEditingController();
    _nicknameController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _aadharController = TextEditingController();
    _panController = TextEditingController();
    _commentController = TextEditingController();
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _accountNumberController.dispose();
    _ifscCodeController.dispose();
    _paymentDateController.dispose();
    _amountToPayController.dispose();
    _nicknameController.dispose();
    _phoneNumberController.dispose();
    _aadharController.dispose();
    _panController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day-$month-$year';
  }

  String _formatDateForApi(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$year-$month-$day';
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _paymentDateController.text = _formatDate(picked);
      });
    }
  }

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Format amount - remove commas and convert to string
      String amountText = _amountToPayController.text.trim().replaceAll(
        ',',
        '',
      );

      final success = await ApiService.addPayment(
        accountNumber: _accountNumberController.text.trim(),
        ifscCode: _ifscCodeController.text.trim(),
        customerName: _customerNameController.text.trim(),
        paymentDate: _formatDateForApi(_selectedDate!),
        amountToPay: amountText,
        photo: null, // No photo upload
        nickname: _nicknameController.text.trim().isNotEmpty
            ? _nicknameController.text.trim()
            : null,
        phoneNumber: _phoneNumberController.text.trim().isNotEmpty
            ? _phoneNumberController.text.trim()
            : null,
        panNumber: _panController.text.trim().isNotEmpty
            ? _panController.text.trim()
            : null,
        aadhaarNumber: _aadharController.text.trim().isNotEmpty
            ? _aadharController.text.trim()
            : null,
        comments: _commentController.text.trim().isNotEmpty
            ? _commentController.text.trim()
            : null,
        bankInfoId: null,
      );
      Navigator.of(context).pop();
      if (mounted) {
        setState(() => _isSaving = false);
        if (success) {
          CustomDialog.show(
            context: context,
            message: 'User and payment details saved successfully!',
            type: DialogType.success,
            title: 'Success',
            buttonText: 'OK',
            barrierDismissible: false,
            onButtonPressed: () {
              Navigator.of(context).pop(true);
            },
          );
        } else {
          CustomDialog.show(
            context: context,
            message: 'Failed to save user details',
            type: DialogType.error,
            title: 'Error',
            buttonText: 'OK',
            barrierDismissible: true,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        CustomDialog.show(
          context: context,
          message: 'Error: ${e.toString()}',
          type: DialogType.error,
          title: 'Error',
          buttonText: 'OK',
          barrierDismissible: true,
        );
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isRequired = false,
    bool isOptional = false,
    TextInputType? keyboardType,
    int? maxLength,
    TextCapitalization textCapitalization = TextCapitalization.none,
    int? maxLines,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(color: Colors.red, fontSize: 14),
              ),
            if (isOptional)
              Text(
                ' (Optional)',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLength: maxLength,
          textCapitalization: textCapitalization,
          maxLines: maxLines ?? 1,
          validator: validator,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey[600], size: 20),
            filled: true,
            fillColor: Colors.grey[100],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.primaryBlue,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.errorColor,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.errorColor,
                width: 2,
              ),
            ),
            counterText: '',
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Add User',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            // Dismiss keyboard when tapping outside text fields
            FocusScope.of(context).unfocus();
          },
          behavior: HitTestBehavior.opaque,
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Customer Name
                        _buildTextField(
                          controller: _customerNameController,
                          label: 'Customer Name',
                          icon: Icons.person_outline,
                          isRequired: true,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter customer name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Account Number
                        _buildTextField(
                          controller: _accountNumberController,
                          label: 'Account Number',
                          icon: Icons.account_balance_outlined,
                          isRequired: true,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter account number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // IFSC Code
                        _buildTextField(
                          controller: _ifscCodeController,
                          label: 'IFSC Code',
                          icon: Icons.account_balance,
                          isRequired: true,
                          textCapitalization: TextCapitalization.characters,
                          maxLength: 11,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter IFSC code';
                            }
                            final ifscPattern = RegExp(
                              r'^[A-Z]{4}0[A-Z0-9]{6}$',
                            );
                            if (!ifscPattern.hasMatch(
                              value.trim().toUpperCase(),
                            )) {
                              return 'Please enter a valid IFSC code';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Payment Date
                        GestureDetector(
                          onTap: _selectDate,
                          child: AbsorbPointer(
                            child: _buildTextField(
                              controller: _paymentDateController,
                              label: 'Payment Date',
                              icon: Icons.calendar_today_outlined,
                              isRequired: true,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please select payment date';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Amount to Pay
                        _buildTextField(
                          controller: _amountToPayController,
                          label: 'Amount to Pay',
                          icon: Icons.currency_rupee_outlined,
                          isRequired: true,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter amount to pay';
                            }
                            final amount = double.tryParse(
                              value.trim().replaceAll(',', ''),
                            );
                            if (amount == null || amount <= 0) {
                              return 'Please enter a valid amount';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Nickname
                        _buildTextField(
                          controller: _nicknameController,
                          label: 'Nickname',
                          icon: Icons.label_outline,
                          isOptional: true,
                        ),
                        const SizedBox(height: 20),

                        // Phone Number
                        _buildTextField(
                          controller: _phoneNumberController,
                          label: 'Phone Number',
                          icon: Icons.phone_outlined,
                          isOptional: true,
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          validator: (value) {
                            if (value != null && value.trim().isNotEmpty) {
                              if (value.trim().length != 10 ||
                                  !RegExp(r'^[0-9]+$').hasMatch(value.trim())) {
                                return 'Please enter a valid 10-digit phone number';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Aadhar Number
                        _buildTextField(
                          controller: _aadharController,
                          label: 'Aadhar Number',
                          icon: Icons.credit_card_outlined,
                          isOptional: true,
                          keyboardType: TextInputType.number,
                          maxLength: 12,
                          validator: (value) {
                            if (value != null && value.trim().isNotEmpty) {
                              if (value.trim().length != 12 ||
                                  !RegExp(r'^[0-9]+$').hasMatch(value.trim())) {
                                return 'Please enter a valid 12-digit Aadhar number';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // PAN Number
                        _buildTextField(
                          controller: _panController,
                          label: 'PAN Number',
                          icon: Icons.badge_outlined,
                          isOptional: true,
                          maxLength: 10,
                          textCapitalization: TextCapitalization.characters,
                          validator: (value) {
                            if (value != null && value.trim().isNotEmpty) {
                              final panPattern = RegExp(
                                r'^[A-Z]{5}\d{4}[A-Z]$',
                              );
                              if (!panPattern.hasMatch(
                                value.trim().toUpperCase(),
                              )) {
                                return 'Please enter a valid PAN (e.g., ABCDE1234F)';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Comment
                        _buildTextField(
                          controller: _commentController,
                          label: 'Add Comment',
                          icon: Icons.comment_outlined,
                          isOptional: true,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                // Save Button
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: RefreshLoader(
                                size: 24,
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Save Changes',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
