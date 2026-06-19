import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import '../utils/app_theme.dart';
import '../services/network_service.dart';
import '../widgets/bank_loader.dart';
import 'widgets/user_avatar.dart';

class AddTransactionScreen extends StatefulWidget {
  final int bankInfoId;
  final String displayName;
  final String initials;
  final Map<String, dynamic>? bankInfo;

  const AddTransactionScreen({
    super.key,
    required this.bankInfoId,
    required this.displayName,
    required this.initials,
    this.bankInfo,
  });

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _paymentDateController = TextEditingController();
  final _amountController = TextEditingController();

  DateTime? _selectedDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _paymentDateController.text = _formatDateForDisplay(_selectedDate!);
  }

  @override
  void dispose() {
    _paymentDateController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  String _formatDateForDisplay(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day-$month-$year';
  }

  String _formatDateForApi(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
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
        _paymentDateController.text = _formatDateForDisplay(picked);
      });
    }
  }

  String? _validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter amount to pay';
    }
    final cleanedValue = value.replaceAll(',', '').trim();
    if (cleanedValue.isEmpty) {
      return 'Please enter amount to pay';
    }
    final amount = double.tryParse(cleanedValue);
    if (amount == null) {
      return 'Please enter a valid amount';
    }
    if (amount <= 0) {
      return 'Amount must be greater than 0';
    }
    return null;
  }

  void _formatAmountInput(String value) {
    final cleanedValue = value.replaceAll(',', '').trim();
    if (cleanedValue.isEmpty) {
      _amountController.text = '';
      return;
    }
    final amount = double.tryParse(cleanedValue);
    if (amount != null) {
      final formatted = NumberFormat('#,##0').format(amount.toInt());
      if (_amountController.text != formatted) {
        _amountController.value = TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      }
    }
  }

  Future<void> _addToSheet() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a payment date'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final cleanedAmount = _amountController.text.replaceAll(',', '').trim();
      final amount = double.parse(cleanedAmount).toInt();

      final url =
          '${dotenv.env['API_URL']}users/transactions/${widget.bankInfoId}/addOrUpdate';
      print('🌐 [ADD TRANSACTION] PUT to: $url');

      final payload = {
        'paymentDate': _formatDateForApi(_selectedDate!),
        'amountToPay': amount,
      };

      print('📦 [ADD TRANSACTION] Payload: $payload');

      var response = await ServiceWithPutHeader(url, payload).data();

      print('✅ [ADD TRANSACTION] Response: $response');

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (response is List && response.length >= 2) {
          int statusCode = response[0];
          dynamic responseBody = response[1];

          if (statusCode >= 200 && statusCode < 300) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Transaction added successfully'),
                backgroundColor: AppTheme.successColor,
              ),
            );
            Navigator.pop(context, true); // Return true to indicate success
          } else {
            String errorMessage = 'Failed to add transaction';
            if (responseBody is Map && responseBody.containsKey('message')) {
              errorMessage = responseBody['message'].toString();
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to add transaction'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    } catch (e) {
      print('❌ [ADD TRANSACTION] Error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'User Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            Text(
              'Add Transaction',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Details Card - Matching Image Design (Responsive)
              LayoutBuilder(
                builder: (context, constraints) {
                  final screenWidth = MediaQuery.of(context).size.width;
                  final isSmallScreen = screenWidth < 360;
                  final isMediumScreen = screenWidth < 400;

                  // Responsive sizes
                  final avatarSize = isSmallScreen
                      ? 48.0
                      : (isMediumScreen ? 52.0 : 56.0);
                  final avatarFontSize = isSmallScreen
                      ? 24.0
                      : (isMediumScreen ? 26.0 : 28.0);
                  final nameFontSize = isSmallScreen
                      ? 20.0
                      : (isMediumScreen ? 22.0 : 24.0);
                  final roleFontSize = isSmallScreen ? 12.0 : 14.0;
                  final cardPadding = isSmallScreen
                      ? 16.0
                      : (isMediumScreen ? 20.0 : 24.0);
                  final horizontalSpacing = isSmallScreen
                      ? 12.0
                      : (isMediumScreen ? 14.0 : 16.0);
                  final verticalSpacing = isSmallScreen ? 16.0 : 20.0;
                  final infoItemSpacing = isSmallScreen
                      ? 8.0
                      : (isMediumScreen ? 12.0 : 16.0);

                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF002E6E), Color(0xFF2A66B9)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.all(cardPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Section: Avatar, Name, and Role
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Profile Initial Avatar (White square with dark blue initial)
                            Container(
                              width: avatarSize,
                              height: avatarSize,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  firstInitial,
                                  style: TextStyle(
                                    fontSize: avatarFontSize,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryBlue,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: horizontalSpacing),
                            // Name and Role
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.displayName,
                                    style: TextStyle(
                                      fontSize: nameFontSize,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    role,
                                    style: TextStyle(
                                      fontSize: roleFontSize,
                                      fontWeight: FontWeight.normal,
                                      color: const Color(
                                        0xFFB0B0B0,
                                      ), // Light gray
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: verticalSpacing),
                        // Divider
                        Container(
                          height: 1,
                          color: Colors.white.withOpacity(0.2),
                        ),
                        SizedBox(height: verticalSpacing),
                        // Bottom Section: PAN, AC, IFSC (Horizontal Layout - Always Row)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 1,
                              child: _buildInfoItem(
                                'PAN',
                                widget.bankInfo?['panNumber'] as String? ??
                                    'N/A',
                                isSmallScreen: isSmallScreen,
                                isMediumScreen: isMediumScreen,
                                screenWidth: screenWidth,
                              ),
                            ),
                            SizedBox(width: infoItemSpacing),
                            Expanded(
                              flex: 1,
                              child: _buildInfoItem(
                                'AC',
                                widget.bankInfo?['accountNumber'] as String? ??
                                    'N/A',
                                isSmallScreen: isSmallScreen,
                                isMediumScreen: isMediumScreen,
                                screenWidth: screenWidth,
                              ),
                            ),
                            SizedBox(width: infoItemSpacing),
                            Expanded(
                              flex: 1,
                              child: _buildInfoItem(
                                'IFSC',
                                widget.bankInfo?['ifscCode'] as String? ??
                                    'N/A',
                                isSmallScreen: isSmallScreen,
                                isMediumScreen: isMediumScreen,
                                screenWidth: screenWidth,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Payment Date Section
              const Text(
                'Payment Date',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _paymentDateController,
                readOnly: true,
                onTap: _selectDate,
                decoration: InputDecoration(
                  hintText: 'dd-mm-yyyy',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppTheme.primaryBlue,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Amount to Pay Section
              const Text(
                'Amount to Pay',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d,]')),
                ],
                validator: _validateAmount,
                onChanged: _formatAmountInput,
                decoration: InputDecoration(
                  hintText: 'Enter amount',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppTheme.primaryBlue,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Add to Sheet Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _addToSheet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: RefreshLoader(
                            size: 20,
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Add to Sheet',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get firstInitial {
    if (widget.displayName.isEmpty) return 'U';
    return widget.displayName.trim()[0].toUpperCase();
  }

  String get role {
    // Check if there's a role field in bankInfo, otherwise use default
    if (widget.bankInfo == null) return 'Dealer';
    return widget.bankInfo!['role'] as String? ??
        widget.bankInfo!['designation'] as String? ??
        'Dealer';
  }

  Widget _buildInfoItem(
    String label,
    String value, {
    bool isSmallScreen = false,
    bool isMediumScreen = false,
    double? screenWidth,
  }) {
    // More aggressive font size reduction for very small screens
    final isVerySmallScreen = (screenWidth ?? 400) < 320;

    final labelFontSize = isVerySmallScreen
        ? 9.0
        : (isSmallScreen ? 10.0 : (isMediumScreen ? 11.0 : 12.0));
    final valueFontSize = isVerySmallScreen
        ? 11.0
        : (isSmallScreen ? 12.0 : (isMediumScreen ? 13.0 : 16.0));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label :',
          style: TextStyle(
            fontSize: labelFontSize,
            color: const Color(0xFFB0B0B0), // Light gray
            fontWeight: FontWeight.normal,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: TextStyle(
              fontSize: valueFontSize,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.left,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}
