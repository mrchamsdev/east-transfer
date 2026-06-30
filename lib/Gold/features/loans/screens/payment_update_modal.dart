import 'package:bank_scan/Gold/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import '../../../widgets/gold_dialogs.dart';
import '../../../widgets/gold_detail_input.dart';
import '../repository/loan_repository.dart';
import 'package:image_picker/image_picker.dart';

class PaymentUpdateModal extends StatefulWidget {
  final int personId;
  final int loanId;
  final Map<String, dynamic>? initialData;
  final int? paymentId;
  final num? currentPendingPrincipal;

  const PaymentUpdateModal({
    super.key,
    required this.personId,
    required this.loanId,
    this.initialData,
    this.paymentId,
    this.currentPendingPrincipal,
  });

  @override
  State<PaymentUpdateModal> createState() => _PaymentUpdateModalState();
}

class _PaymentUpdateModalState extends State<PaymentUpdateModal> {
  final _repository = LoanRepository();
  bool _isLoading = false;

  final _dateCtrl = TextEditingController();
  String? _interestAmountType;
  final _interestAmountCtrl = TextEditingController();
  String? _principalAmountType;
  final _principalAmountCtrl = TextEditingController();
  final _remainingBalanceCtrl = TextEditingController();
  final _referenceNumberCtrl = TextEditingController();
  String? _paymentType;
  String? _imagePath;

  final ImagePicker _picker = ImagePicker();

  static const Map<String, String> _typeNames = {
    'RUPEES': 'Rupees',
    // 'CASH': 'Cash',
    'USD': 'US Dollar (\$)',
    'EUR': 'Euro (€)',
    'GBP': 'UK Pound (£)',
    'JPY': 'Japanese Yen (¥)',
    'AUD': 'Australian Dollar (A\$)',
    'CAD': 'Canadian Dollar (C\$)',
    'CHF': 'Swiss Franc (CHF)',
    'CNY': 'Chinese Yuan (CN¥)',
    'HKD': 'Hong Kong Dollar (HK\$)',
    'NZD': 'New Zealand Dollar (NZ\$)',
    'SGD': 'Singapore Dollar (S\$)',
    'AED': 'UAE Dirham (د.إ)',
    'SAR': 'Saudi Riyal (﷼)',
    'ZAR': 'South African Rand (R)',
  };

  static const Map<String, String> _paymentTypeNames = {
    'CASH': 'Cash',
    'UPI': 'UPI',
    'BANK TRANSFER': 'Bank Transfer',
  };

  @override
  void initState() {
    super.initState();
    _interestAmountType = 'RUPEES';
    _principalAmountType = 'RUPEES';
    _paymentType = 'CASH';
    if (widget.initialData != null) {
      final data = widget.initialData!;
      _dateCtrl.text = data['paymentDate'] ?? '';
      _interestAmountType = data['interestAmountType'] ?? 'RUPEES';
      _interestAmountCtrl.text = data['interestAmount']?.toString() ?? '';
      _principalAmountType = data['principalAmountType'] ?? 'RUPEES';
      _principalAmountCtrl.text = data['principalAmount']?.toString() ?? '';
      _remainingBalanceCtrl.text = data['remainingBalance']?.toString() ?? '';
      _referenceNumberCtrl.text = data['referenceNUmber'] ?? '';
      _paymentType = data['paymentTYpe'] ?? 'CASH';
    }
    
    _principalAmountCtrl.addListener(_onPrincipalChanged);
  }

  void _onPrincipalChanged() {
    if (widget.currentPendingPrincipal != null) {
      final text = _principalAmountCtrl.text.trim();
      if (text.isEmpty) {
        _remainingBalanceCtrl.text = '';
      } else {
        final entered = double.tryParse(text) ?? 0.0;
        final remaining = widget.currentPendingPrincipal! - entered;
        // Format to 2 decimal places to keep it clean
        _remainingBalanceCtrl.text = remaining.toStringAsFixed(2);
      }
    }
  }

  @override
  void dispose() {
    _principalAmountCtrl.removeListener(_onPrincipalChanged);
    _dateCtrl.dispose();
    _interestAmountCtrl.dispose();
    _principalAmountCtrl.dispose();
    _remainingBalanceCtrl.dispose();
    _referenceNumberCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 70,
    );
    if (image != null) {
      setState(() {
        _imagePath = image.path;
      });
    }
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controller.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  void _showSelectionBottomSheet(
    String title,
    List<String> options,
    String? currentValue,
    Map<String, String> displayNames,
    ValueChanged<String> onSelected,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                  ),
                ),
                const Divider(height: 1),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: options.map((option) => ListTile(
                        title: Text(
                          displayNames[option] ?? option,
                          style: TextStyle(
                            fontWeight: option == currentValue ? FontWeight.bold : FontWeight.normal,
                            color: option == currentValue ? AppColors.primaryBlue : AppColors.textPrimary,
                          ),
                        ),
                        trailing: option == currentValue ? const Icon(Icons.check, color: AppColors.primaryBlue) : null,
                        onTap: () {
                          onSelected(option);
                          Navigator.pop(context);
                        },
                      )).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _submit() async {
    final dateStr = _dateCtrl.text.trim();
    final interestStr = _interestAmountCtrl.text.trim();
    final principalStr = _principalAmountCtrl.text.trim();
    final balanceStr = _remainingBalanceCtrl.text.trim();
    final refStr = _referenceNumberCtrl.text.trim();

    if (dateStr.isEmpty) {
      GoldDialogs.showSnackBar(context, 'Please select payment date.', isError: true);
      return;
    }
    if (interestStr.isEmpty || double.tryParse(interestStr) == null) {
      GoldDialogs.showSnackBar(context, 'Please enter a valid interest amount.', isError: true);
      return;
    }
    if (principalStr.isEmpty || double.tryParse(principalStr) == null) {
      GoldDialogs.showSnackBar(context, 'Please enter a valid principal amount.', isError: true);
      return;
    }
    if (balanceStr.isNotEmpty && double.tryParse(balanceStr) == null) {
      GoldDialogs.showSnackBar(context, 'Please enter a valid remaining balance.', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final data = {
        'loanId': widget.loanId,
        'paymentDate': dateStr,
        'interestAmountType': _interestAmountType ?? 'RUPEES',
        'interestAmount': interestStr,
        'principalAmountType': _principalAmountType ?? 'RUPEES',
        'principalAmount': principalStr,
        'paymentTYpe': _paymentType ?? 'CASH',
        'referenceNUmber': refStr,
        'note': 'Payment Update',
      };

      String? err;
      if (widget.paymentId != null) {
        err = await _repository.editPaymentUpdate(widget.paymentId!, data, filePath: _imagePath);
      } else {
        err = await _repository.createPaymentUpdate(data, filePath: _imagePath);
      }

      if (err != null) {
        if (mounted) GoldDialogs.showErrorDialog(context: context, title: 'Error', message: err);
      } else {
        if (mounted) {
          GoldDialogs.showSnackBar(context, widget.paymentId != null ? 'Payment updated successfully.' : 'Payment added successfully.');
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) GoldDialogs.showErrorDialog(context: context, title: 'Error', message: e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildCombinedDropdownInput({
    required String label,
    required String dropdownText,
    required TextEditingController textController,
    required String hintText,
    required VoidCallback onDropdownTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                GestureDetector(
                  onTap: onDropdownTap,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          dropdownText,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.keyboard_arrow_down,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Color(0xFFF1F2F5),
                          width: 1.0,
                        ),
                      ),
                    ),
                    child: TextField(
                      controller: textController,
                      textAlign: TextAlign.end,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        filled: false,
                        fillColor: Colors.transparent,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        isDense: true,
                        hintText: hintText,
                        hintStyle: const TextStyle(
                          color: AppColors.textHint,
                          fontSize: 10,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.paymentId != null ? 'Payment Edit' : 'Payment Update',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textSecondary, size: 20),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              GoldDetailInputGroup(
                padding: EdgeInsets.zero,
                children: [
                  GoldDetailInputField(
                    label: 'Select Date',
                    value: _dateCtrl.text.isEmpty ? null : _dateCtrl.text,
                    hint: 'YYYY-MM-DD',
                    onTap: () => _selectDate(_dateCtrl),
                    isDate: true,
                  ),
                  _buildCombinedDropdownInput(
                    label: 'Interest Amount',
                    dropdownText: _typeNames[_interestAmountType] ?? 'Cash',
                    textController: _interestAmountCtrl,
                    hintText: '0.00',
                    onDropdownTap: () => _showSelectionBottomSheet(
                      'Interest Type',
                      ['RUPEES', 'USD', 'EUR', 'GBP', 'JPY', 'AUD', 'CAD', 'CHF', 'CNY', 'HKD', 'NZD', 'SGD', 'AED', 'SAR', 'ZAR'],
                      _interestAmountType,
                      _typeNames,
                      (val) => setState(() => _interestAmountType = val),
                    ),
                  ),
                  _buildCombinedDropdownInput(
                    label: 'Principal Amount',
                    dropdownText: _typeNames[_principalAmountType] ?? 'Cash',
                    textController: _principalAmountCtrl,
                    hintText: '0.00',
                    onDropdownTap: () => _showSelectionBottomSheet(
                      'Principal Type',
                      ['RUPEES', 'USD', 'EUR', 'GBP', 'JPY', 'AUD', 'CAD', 'CHF', 'CNY', 'HKD', 'NZD', 'SGD', 'AED', 'SAR', 'ZAR'],
                      _principalAmountType,
                      _typeNames,
                      (val) => setState(() => _principalAmountType = val),
                    ),
                  ),
                  GoldDetailInputField(
                    label: 'Remaining Balance',
                    controller: _remainingBalanceCtrl,
                    hint: '0.00',
                    keyboardType: TextInputType.number,
                  ),
                  if (_paymentType != 'CASH')
                    GoldDetailInputField(
                      label: 'Reference Number',
                      controller: _referenceNumberCtrl,
                      hint: 'Enter reference',
                    ),
                  GoldDetailInputField(
                    label: 'Payment Type',
                    value: _paymentTypeNames[_paymentType] ?? 'Select Type',
                    hint: 'Select type',
                    onTap: () => _showSelectionBottomSheet(
                      'Payment Type',
                      ['CASH', 'UPI', 'BANK TRANSFER'],
                      _paymentType,
                      _paymentTypeNames,
                      (val) => setState(() => _paymentType = val),
                    ),
                  ),
                  GoldDetailInputField(
                    label: 'Upload Image',
                    value: _imagePath?.split('/').last,
                    hint: 'No file choosen',
                    onTap: _pickImage,
                    showBottomBorder: false,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF003366),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'SUBMIT',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
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
}
