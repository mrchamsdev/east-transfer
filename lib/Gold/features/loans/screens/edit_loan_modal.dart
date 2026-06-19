import 'package:flutter/material.dart';
import 'package:bank_scan/Gold/core/constants/app_colors.dart';
import '../../../widgets/gold_dialogs.dart';
import '../../../widgets/gold_detail_input.dart';
import '../models/loan_models.dart';
import '../repository/loan_repository.dart';
import 'package:image_picker/image_picker.dart';
import 'package:currency_picker/currency_picker.dart';

class EditLoanModal extends StatefulWidget {
  final Loan loan;

  const EditLoanModal({super.key, required this.loan});

  @override
  State<EditLoanModal> createState() => _EditLoanModalState();
}

class _EditLoanModalState extends State<EditLoanModal> {
  final _repository = LoanRepository();
  bool _isLoading = false;

  final _loanPeriodCtrl = TextEditingController();
  final _loanDateCtrl = TextEditingController();
  String? _principalAmountType;
  final _principalAmountCtrl = TextEditingController();
  final _interestRateCtrl = TextEditingController();
  String? _interestPaymentPeriodType;
  final _interestPaymentPeriodCtrl = TextEditingController();
  String? _agreementImagePath;

  final ImagePicker _picker = ImagePicker();

  static const Map<String, String> _interestPeriodNames = {
    'MONTHLY': 'Monthly',
    'YEARLY': 'Yearly',
  };

  @override
  void initState() {
    super.initState();
    _loanPeriodCtrl.text = widget.loan.loanPeriod?.toString() ?? '';
    _loanDateCtrl.text = widget.loan.loanDate ?? '';
    _principalAmountType = widget.loan.principalAmountType ?? 'INR';
    _principalAmountCtrl.text = widget.loan.principalAmount.toString();
    _interestRateCtrl.text = widget.loan.interestRate?.toString() ?? '';
    _interestPaymentPeriodType = widget.loan.interestPaymentPeriodType ?? 'MONTHLY';
    _interestPaymentPeriodCtrl.text = widget.loan.interestPaymentPeriod?.toString() ?? '';
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _agreementImagePath = image.path;
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

  void _openCurrencyPicker() {
    showCurrencyPicker(
      context: context,
      showFlag: true,
      showCurrencyName: true,
      showCurrencyCode: true,
      onSelect: (Currency currency) {
        setState(() {
          _principalAmountType = currency.code;
        });
      },
    );
  }

  String _getCurrencyDisplayText() {
    final code = _principalAmountType ?? 'INR';
    if (code == 'INR') return r'₹ Rupee';
    final currency = CurrencyService().findByCode(code);
    if (currency != null) {
      return '${currency.symbol} ${currency.code}';
    }
    return code;
  }

  void _showInterestPeriodPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Interest Period Type',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                ),
              ),
              const Divider(height: 1),
              ..._interestPeriodNames.entries.map((entry) => ListTile(
                    title: Text(
                      entry.value,
                      style: TextStyle(
                        fontWeight: entry.key == _interestPaymentPeriodType ? FontWeight.bold : FontWeight.normal,
                        color: entry.key == _interestPaymentPeriodType ? AppColors.primaryBlue : AppColors.textPrimary,
                      ),
                    ),
                    trailing: entry.key == _interestPaymentPeriodType ? const Icon(Icons.check, color: AppColors.primaryBlue) : null,
                    onTap: () {
                      setState(() {
                        _interestPaymentPeriodType = entry.key;
                      });
                      Navigator.pop(context);
                    },
                  )),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submit() async {
    final loanPeriod = _loanPeriodCtrl.text.trim();
    final loanDate = _loanDateCtrl.text.trim();
    final principal = _principalAmountCtrl.text.trim();
    final rate = _interestRateCtrl.text.trim();
    final period = _interestPaymentPeriodCtrl.text.trim();

    if (loanPeriod.isEmpty) {
      GoldDialogs.showSnackBar(context, 'Please enter loan period.', isError: true);
      return;
    }
    if (loanDate.isEmpty) {
      GoldDialogs.showSnackBar(context, 'Please select loan date.', isError: true);
      return;
    }
    if (principal.isEmpty || double.tryParse(principal) == null) {
      GoldDialogs.showSnackBar(context, 'Please enter a valid principal amount.', isError: true);
      return;
    }
    if (rate.isEmpty || double.tryParse(rate) == null) {
      GoldDialogs.showSnackBar(context, 'Please enter a valid interest rate.', isError: true);
      return;
    }
    if (period.isEmpty || int.tryParse(period) == null) {
      GoldDialogs.showSnackBar(context, 'Please enter a valid payment period (number of days).', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final data = {
        'personId': widget.loan.personId,
        'loanPeriodType': 'MONTH',
        'loanPeriod': loanPeriod,
        'loanDate': loanDate,
        'principalAmountType': _principalAmountType ?? 'INR',
        'principalAmount': principal,
        'interestRate': rate,
        'interestPaymentPeriodType': _interestPaymentPeriodType ?? 'MONTHLY',
        'interestPaymentPeriod': period,
        'note': widget.loan.note ?? '',
      };

      final err = await _repository.updateLoan(widget.loan.id ?? 0, data, agreementImagePath: _agreementImagePath);

      if (err != null) {
        if (mounted) GoldDialogs.showErrorDialog(context: context, title: 'Error', message: err);
      } else {
        if (mounted) {
          GoldDialogs.showSnackBar(context, 'Loan details updated successfully.');
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
                  const Text(
                    'Loan Details',
                    style: TextStyle(
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
                    label: 'Loan Period',
                    controller: _loanPeriodCtrl,
                    hint: 'Enter period',
                    keyboardType: TextInputType.number,
                  ),
                  GoldDetailInputField(
                    label: 'Loan Date',
                    value: _loanDateCtrl.text.isEmpty ? null : _loanDateCtrl.text,
                    hint: 'YYYY-MM-DD',
                    onTap: () => _selectDate(_loanDateCtrl),
                    isDate: true,
                  ),
                  _buildCombinedDropdownInput(
                    label: 'Principal Amount',
                    dropdownText: _getCurrencyDisplayText(),
                    textController: _principalAmountCtrl,
                    hintText: '0.00',
                    onDropdownTap: _openCurrencyPicker,
                  ),
                  GoldDetailInputField(
                    label: 'Interest Rate',
                    controller: _interestRateCtrl,
                    hint: '0.00 %',
                    keyboardType: TextInputType.number,
                  ),
                  _buildCombinedDropdownInput(
                    label: 'Interest Payment Period',
                    dropdownText: _interestPeriodNames[_interestPaymentPeriodType] ?? 'Monthly',
                    textController: _interestPaymentPeriodCtrl,
                    hintText: 'Enter period',
                    onDropdownTap: _showInterestPeriodPicker,
                  ),
                  GoldDetailInputField(
                    label: 'Agreement Image',
                    value: _agreementImagePath?.split('/').last,
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
