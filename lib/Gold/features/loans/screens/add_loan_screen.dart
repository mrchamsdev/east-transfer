/*
import 'dart:io';
import 'package:bank_scan/Gold/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:country_picker/country_picker.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:bank_scan/Gold/core/utils/phone_validation_helper.dart';

import '../../../widgets/gold_dialogs.dart';
import '../../../widgets/gold_detail_input.dart';
import '../../../widgets/gold_back_button.dart';
import '../repository/loan_repository.dart';
import 'package:image_picker/image_picker.dart';

import '../models/loan_models.dart';

class AddLoanScreen extends StatefulWidget {
  final PersonDetails? person;
  final Loan? loan;

  const AddLoanScreen({super.key, this.person, this.loan});

  @override
  State<AddLoanScreen> createState() => _AddLoanScreenState();
}

class _AddLoanScreenState extends State<AddLoanScreen> {
  final _repository = LoanRepository();
  int _currentStep = 0;
  bool _isLoading = false;

  // Person Details
  final _personNameCtrl = TextEditingController();
  final _personMobileCtrl = TextEditingController();
  final _personAddressCtrl = TextEditingController();
  String? _idProofType;
  String? _idProofImagePath;
  
  final _witnessNameCtrl = TextEditingController();
  final _witnessMobileCtrl = TextEditingController();
  final _witnessRelationCtrl = TextEditingController();
  String? _witnessIdProofType;
  String? _witnessIdProofImagePath;

  // Country pickers
  Country _personCountry = Country(
    phoneCode: '91',
    countryCode: 'IN',
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: 'India',
    example: 'India',
    displayName: 'India (IN) [+91]',
    displayNameNoCountryCode: 'India (IN)',
    e164Key: '',
  );

  Country _witnessCountry = Country(
    phoneCode: '91',
    countryCode: 'IN',
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: 'India',
    example: 'India',
    displayName: 'India (IN) [+91]',
    displayNameNoCountryCode: 'India (IN)',
    e164Key: '',
  );

  String? _personPhoneError;
  String? _witnessPhoneError;

  void _validatePersonPhone(String val) {
    if (val.trim().isEmpty) {
      setState(() => _personPhoneError = null);
      return;
    }
    final isValid = _isPhoneNumberValid(val, _personCountry);
    setState(() {
      _personPhoneError = isValid ? null : 'Invalid mobile number for ${_personCountry.name}';
    });
  }

  void _validateWitnessPhone(String val) {
    if (val.trim().isEmpty) {
      setState(() => _witnessPhoneError = null);
      return;
    }
    final isValid = _isPhoneNumberValid(val, _witnessCountry);
    setState(() {
      _witnessPhoneError = isValid ? null : 'Invalid mobile number for ${_witnessCountry.name}';
    });
  }

  void _onPersonPhoneChanged() {
    _validatePersonPhone(_personMobileCtrl.text);
  }

  void _onWitnessPhoneChanged() {
    _validateWitnessPhone(_witnessMobileCtrl.text);
  }

  @override
  void initState() {
    super.initState();
    _personMobileCtrl.addListener(_onPersonPhoneChanged);
    _witnessMobileCtrl.addListener(_onWitnessPhoneChanged);
    if (widget.person != null) {
      _personNameCtrl.text = widget.person!.name;
      _personMobileCtrl.text = widget.person!.mobileNumber;
      _personAddressCtrl.text = widget.person!.address ?? '';
      _idProofType = widget.person!.idProof;
      _witnessNameCtrl.text = widget.person!.witnessName ?? '';
      _witnessMobileCtrl.text = widget.person!.witnessMobileNumber ?? '';
      _witnessRelationCtrl.text = widget.person!.witnessRelation ?? '';
      _witnessIdProofType = widget.person!.witnessIdProof;
    }
    if (widget.loan != null) {
      _loanPeriodType = widget.loan!.loanPeriodType;
      _loanPeriodCtrl.text = widget.loan!.loanPeriod?.toString() ?? '';
      _loanDateCtrl.text = widget.loan!.loanDate ?? '';
      _principalAmountType = widget.loan!.principalAmountType ?? 'INR';
      _principalAmountCtrl.text = widget.loan!.principalAmount.toString();
      _interestRateCtrl.text = widget.loan!.interestRate?.toString() ?? '';
      _interestPaymentPeriodType = widget.loan!.interestPaymentPeriodType;
      _interestPaymentPeriodCtrl.text = widget.loan!.interestPaymentPeriod?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _personMobileCtrl.removeListener(_onPersonPhoneChanged);
    _witnessMobileCtrl.removeListener(_onWitnessPhoneChanged);
    _personNameCtrl.dispose();
    _personMobileCtrl.dispose();
    _personAddressCtrl.dispose();
    _witnessNameCtrl.dispose();
    _witnessMobileCtrl.dispose();
    _witnessRelationCtrl.dispose();
    _loanPeriodCtrl.dispose();
    _loanDateCtrl.dispose();
    _principalAmountCtrl.dispose();
    _interestRateCtrl.dispose();
    _interestPaymentPeriodCtrl.dispose();
    super.dispose();
  }

  String _buildFormattedMobile(String rawMobile, Country country) {
    final raw = rawMobile.trim();
    if (raw.isEmpty) return '';
    var stripped = raw.replaceAll(RegExp(r'^\+'), '');
    final code = country.phoneCode;
    if (stripped.startsWith(code) && stripped.length > code.length) {
      stripped = stripped.substring(code.length);
    }
    return '+$code$stripped';
  }

  bool _isPhoneNumberValid(String rawNumber, Country country) {
    try {
      var cleanNumber = rawNumber.trim().replaceAll(RegExp(r'[^0-9]'), '');
      if (cleanNumber.isEmpty) return false;

      final code = country.phoneCode;
      if (cleanNumber.startsWith(code) && cleanNumber.length > code.length) {
        cleanNumber = cleanNumber.substring(code.length);
      }
      
      final parsed = PhoneNumber.parse('+$code$cleanNumber');
      return parsed.isValid();
    } catch (_) {
      return false;
    }
  }

  // Loan Details
  String? _loanPeriodType = 'MONTH';
  final _loanPeriodCtrl = TextEditingController(text: '12');
  final _loanDateCtrl = TextEditingController();
  String? _principalAmountType = 'INR';
  String _principalAmountSymbol = '₹';
  final _principalAmountCtrl = TextEditingController();
  final _interestRateCtrl = TextEditingController();
  String? _interestPaymentPeriodType = 'MONTHLY';
  final _interestPaymentPeriodCtrl = TextEditingController();
  String? _agreementImagePath;

  final ImagePicker _picker = ImagePicker();

  static const Map<String, String> _interestPeriodNames = {
    'MONTHLY': 'Monthly',
    'YEARLY': 'Yearly',
  };

  void _openCurrencyPicker() {
    showCurrencyPicker(
      context: context,
      showFlag: true,
      showCurrencyName: true,
      showCurrencyCode: true,
      onSelect: (Currency currency) {
        setState(() {
          _principalAmountType = currency.code;
          _principalAmountSymbol = currency.symbol;
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

  Widget _buildCombinedStaticInput({
    required String label,
    required String staticText,
    required TextEditingController textController,
    required String hintText,
    List<TextInputFormatter>? inputFormatters,
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
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    staticText,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
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
                      inputFormatters: inputFormatters,
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

  Widget _buildCombinedDropdownInput({
    required String label,
    required String dropdownText,
    required TextEditingController textController,
    required String hintText,
    required VoidCallback onDropdownTap,
    List<TextInputFormatter>? inputFormatters,
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
                      inputFormatters: inputFormatters,
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

  Future<void> _pickImage(bool isPersonId) async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 70,
    );
    if (image != null) {
      setState(() {
        if (isPersonId) {
          _idProofImagePath = image.path;
        } else {
          _witnessIdProofImagePath = image.path;
        }
      });
    }
  }

  Future<void> _pickAgreementImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 70,
    );
    if (image != null) {
      setState(() {
        _agreementImagePath = image.path;
      });
    }
  }

  void _showSelectionBottomSheet(String title, List<String> options, String? currentValue, ValueChanged<String> onSelected) {
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
                            option,
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
        );
      },
    );
  }

  bool _validatePersonDetails() {
    if (_personNameCtrl.text.trim().isEmpty) {
      GoldDialogs.showSnackBar(context, 'Please enter name.', isError: true);
      return false;
    }

    final personPhone = _personMobileCtrl.text.trim();
    if (personPhone.isEmpty) {
      setState(() => _personPhoneError = 'Please enter mobile number.');
      GoldDialogs.showSnackBar(context, 'Please enter mobile number.', isError: true);
      return false;
    }
    if (!_isPhoneNumberValid(personPhone, _personCountry)) {
      setState(() => _personPhoneError = 'Invalid mobile number for ${_personCountry.name}');
      GoldDialogs.showSnackBar(context, 'Please enter a valid mobile number.', isError: true);
      return false;
    }

    if (_idProofType == null) {
      GoldDialogs.showSnackBar(context, 'Please select ID proof type.', isError: true);
      return false;
    }

    if (_personAddressCtrl.text.trim().isEmpty) {
      GoldDialogs.showSnackBar(context, 'Please enter address.', isError: true);
      return false;
    }

    if (_witnessNameCtrl.text.trim().isEmpty) {
      GoldDialogs.showSnackBar(context, 'Please enter witness name.', isError: true);
      return false;
    }

    final witnessPhone = _witnessMobileCtrl.text.trim();
    if (witnessPhone.isEmpty) {
      setState(() => _witnessPhoneError = 'Please enter witness mobile number.');
      GoldDialogs.showSnackBar(context, 'Please enter witness mobile number.', isError: true);
      return false;
    }
    if (!_isPhoneNumberValid(witnessPhone, _witnessCountry)) {
      setState(() => _witnessPhoneError = 'Invalid mobile number for ${_witnessCountry.name}');
      GoldDialogs.showSnackBar(context, 'Please enter a valid witness mobile number.', isError: true);
      return false;
    }

    if (_witnessRelationCtrl.text.trim().isEmpty) {
      GoldDialogs.showSnackBar(context, 'Please enter witness relation.', isError: true);
      return false;
    }

    if (_witnessIdProofType == null) {
      GoldDialogs.showSnackBar(context, 'Please select witness ID proof type.', isError: true);
      return false;
    }

    if (_personNameCtrl.text.trim().toLowerCase() == _witnessNameCtrl.text.trim().toLowerCase()) {
      GoldDialogs.showSnackBar(context, 'Person and Witness names cannot be the same.', isError: true);
      return false;
    }

    if (personPhone == witnessPhone) {
      GoldDialogs.showSnackBar(context, 'Person and Witness mobile numbers cannot be the same.', isError: true);
      return false;
    }

    return true;
  }

  bool _validateLoanDetails() {
    if (_loanPeriodType == null) {
      GoldDialogs.showSnackBar(context, 'Please select loan period type.', isError: true);
      return false;
    }

    final loanPeriodText = _loanPeriodCtrl.text.trim();
    if (loanPeriodText.isEmpty) {
      GoldDialogs.showSnackBar(context, 'Please enter loan period.', isError: true);
      return false;
    }
    final loanPeriod = int.tryParse(loanPeriodText);
    if (loanPeriod == null || loanPeriod < 1 || loanPeriod > 12) {
      GoldDialogs.showSnackBar(context, 'Loan period must be between 1 and 12 months.', isError: true);
      return false;
    }

    if (_loanDateCtrl.text.trim().isEmpty) {
      GoldDialogs.showSnackBar(context, 'Please select loan date.', isError: true);
      return false;
    }

    final principalText = _principalAmountCtrl.text.trim();
    if (principalText.isEmpty) {
      GoldDialogs.showSnackBar(context, 'Please enter principal amount.', isError: true);
      return false;
    }
    final principal = double.tryParse(principalText);
    if (principal == null || principal <= 0.0) {
      GoldDialogs.showSnackBar(context, 'Please enter a valid principal amount.', isError: true);
      return false;
    }

    final rateText = _interestRateCtrl.text.trim();
    if (rateText.isEmpty) {
      GoldDialogs.showSnackBar(context, 'Please enter interest rate.', isError: true);
      return false;
    }
    final rate = double.tryParse(rateText);
    if (rate == null || rate < 0.0) {
      GoldDialogs.showSnackBar(context, 'Please enter a valid interest rate.', isError: true);
      return false;
    }

    if (_interestPaymentPeriodType == null) {
      GoldDialogs.showSnackBar(context, 'Please select interest period type.', isError: true);
      return false;
    }

    final interestPeriodText = _interestPaymentPeriodCtrl.text.trim();
    if (interestPeriodText.isEmpty) {
      GoldDialogs.showSnackBar(context, 'Please enter interest payment period.', isError: true);
      return false;
    }
    final interestPeriod = int.tryParse(interestPeriodText);
    if (interestPeriod == null || interestPeriod <= 0) {
      GoldDialogs.showSnackBar(context, 'Please enter a valid interest payment period.', isError: true);
      return false;
    }

    return true;
  }

  Future<void> _submitAll() async {
    if (!_validatePersonDetails() || !_validateLoanDetails()) {
      return;
    }
    setState(() => _isLoading = true);
    try {
      // 1. Create Person
      final personData = {
        'name': _personNameCtrl.text.trim(),
        'mobileNumber': _buildFormattedMobile(_personMobileCtrl.text, _personCountry),
        'idProof': _idProofType ?? 'Aadhaar',
        'address': _personAddressCtrl.text.trim(),
        'witnessName': _witnessNameCtrl.text.trim(),
        'witnessMobileNumber': _buildFormattedMobile(_witnessMobileCtrl.text, _witnessCountry),
        'witnessRelation': _witnessRelationCtrl.text.trim(),
        'witnessIdProof': _witnessIdProofType ?? 'Aadhaar',
      };

      // We actually need the person ID returned from the backend, but the API might not return it in the error/string response.
      // Wait, the API returns a string error message if it fails, and null if success.
      // BUT we need `personId` to create the loan! 
      // If the createPerson endpoint does not return the created person ID, how can we link the loan?
      // For now, I'll assume we can pass personId = 1 as a placeholder or we fetch the list to find it, 
      // but ideally the backend should return the ID.
      // Let's assume we create person, and then create loan with a dummy personId or the backend handles it.
      // Actually, since I have to strictly follow the provided payload format:
      // "personId": 1
      final Map<String, dynamic> loanData = {
        'loanPeriodType': _loanPeriodType ?? 'MONTH',
        'loanPeriod': _loanPeriodCtrl.text.trim(),
        'loanDate': _loanDateCtrl.text.trim(),
        'principalAmountType': _principalAmountType ?? 'INR',
        'principalAmount': _principalAmountCtrl.text.trim(),
        'interestRate': _interestRateCtrl.text.trim(),
        'interestPaymentPeriodType': _interestPaymentPeriodType ?? 'MONTHLY',
        'interestPaymentPeriod': _interestPaymentPeriodCtrl.text.trim(),
        'note': '',
      };

      if (widget.person != null && widget.loan != null) {
        // Update existing Person and Loan
        final updatePersonErr = await _repository.updatePerson(widget.person!.id, personData, idProofImagePath: _idProofImagePath, witnessIdProofImagePath: _witnessIdProofImagePath);
        if (updatePersonErr != null) {
          if (mounted) GoldDialogs.showErrorDialog(context: context, title: 'Error', message: updatePersonErr);
          return;
        }

        final updateLoanErr = await _repository.updateLoan(widget.loan!.id ?? 0, loanData, agreementImagePath: _agreementImagePath);
        if (updateLoanErr != null) {
          if (mounted) GoldDialogs.showErrorDialog(context: context, title: 'Error', message: updateLoanErr);
          return;
        }
      } else {
        final personResult = await _repository.createPerson(
          personData,
          idProofImagePath: _idProofImagePath,
          witnessIdProofImagePath: _witnessIdProofImagePath,
        );

        if (personResult.error != null) {
          if (mounted) GoldDialogs.showErrorDialog(context: context, title: 'Error', message: personResult.error!);
          return;
        }

        final createdPersonId = personResult.personId ?? 1;
        loanData['personId'] = createdPersonId;

        final loanErr = await _repository.createLoan(loanData, agreementImagePath: _agreementImagePath);
        if (loanErr != null) {
          if (mounted) GoldDialogs.showErrorDialog(context: context, title: 'Error', message: loanErr);
          return;
        }
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) GoldDialogs.showErrorDialog(context: context, title: 'Error', message: e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: GoldBackButton(
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Add Loan Details', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w500)),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            _buildStepper(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _currentStep == 0
                    ? _buildPersonDetailsForm()
                    : _currentStep == 1
                        ? _buildLoanDetailsForm()
                        : _buildSummaryForm(),
              ),
            ),
            if (MediaQuery.of(context).viewInsets.bottom == 0)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_currentStep > 0) {
                              setState(() => _currentStep--);
                            } else {
                              Navigator.pop(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF003366),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          ),
                          child: const Text('Back', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  if (_currentStep == 0) {
                                    if (!_validatePersonDetails()) return;
                                    setState(() => _currentStep = 1);
                                  } else if (_currentStep == 1) {
                                    if (!_validateLoanDetails()) return;
                                    setState(() => _currentStep = 2);
                                  } else {
                                    _submitAll();
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF003366),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(_currentStep < 2 ? 'Next' : 'Save', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepper() {
    return Container(
      color: const Color(0xFFF9F9F9),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStepIndicator(0, 'Basic details'),
          Container(width: 40, height: 2, color: _currentStep >= 1 ? AppColors.primaryBlue : Colors.grey.shade300),
          _buildStepIndicator(1, 'Loan Details'),
          Container(width: 40, height: 2, color: _currentStep >= 2 ? AppColors.primaryBlue : Colors.grey.shade300),
          _buildStepIndicator(2, 'Summary'),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int stepIndex, String label) {
    final isCompleted = _currentStep > stepIndex;
    final isActive = _currentStep >= stepIndex;
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryBlue : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: isCompleted
              ? const Icon(Icons.check, color: Colors.white, size: 14)
              : Text('${stepIndex + 1}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10, color: isActive ? AppColors.textPrimary : AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildPersonDetailsForm() {
    return GoldDetailInputGroup(
      title: 'Person Details',
      children: [
        GoldDetailInputField(
          label: 'Enter Name',
          controller: _personNameCtrl,
          hint: 'Enter Name',
        ),
        GoldDetailInputField(
          label: 'Mobile No.',
          controller: _personMobileCtrl,
          hint: 'Enter Here',
          keyboardType: TextInputType.phone,
          textAlign: TextAlign.start,
          errorText: _personPhoneError,
          maxLength: getPhoneNumberLengthLimit(_personCountry.countryCode),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          prefix: GestureDetector(
            onTap: () {
              showCountryPicker(
                context: context,
                showPhoneCode: true,
                countryListTheme: CountryListThemeData(
                  backgroundColor: Colors.white,
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                  searchTextStyle: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  bottomSheetHeight: MediaQuery.of(context).size.height * 0.85,
                  inputDecoration: InputDecoration(
                    labelText: 'Search Country',
                    labelStyle: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                    hintText: 'Search by country name or code',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 13,
                    ),
                    prefixIcon: const Icon(Icons.search, color: AppColors.primaryBlue, size: 20),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: const BorderSide(color: Color(0xFFF1F5F9), width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                onSelect: (Country country) {
                  setState(() {
                    _personCountry = country;
                    final limit = getPhoneNumberLengthLimit(country.countryCode);
                    if (_personMobileCtrl.text.length > limit) {
                      _personMobileCtrl.text = _personMobileCtrl.text.substring(0, limit);
                    }
                  });
                  _validatePersonPhone(_personMobileCtrl.text);
                },
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              margin: const EdgeInsets.only(right: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _personCountry.flagEmoji,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '+${_personCountry.phoneCode}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary, size: 14),
                  const SizedBox(width: 4),
                  Container(
                    width: 1.0,
                    height: 14,
                    color: const Color(0xFFE2E8F0),
                  ),
                ],
              ),
            ),
          ),
        ),
        GoldDetailInputField(
          label: 'Id Proof',
          value: _idProofType,
          hint: 'Select Here',
          onTap: () => _showSelectionBottomSheet(
            'Id Proof',
            ['Aadhaar', 'PAN', 'Passport'],
            _idProofType,
            (val) => setState(() => _idProofType = val),
          ),
        ),
        GoldDetailInputField(
          label: 'Id Proof Upload',
          value: _idProofImagePath?.split('/').last,
          hint: 'No file chosen',
          onTap: () => _pickImage(true),
        ),
        GoldDetailInputField(
          label: 'Address',
          controller: _personAddressCtrl,
          hint: 'Enter Address',
        ),
        const SizedBox(height: 16),
        //const Divider(color: Color(0xFFF1F2F5), height: 1),
        const SizedBox(height: 16),
        GoldDetailInputField(
          label: 'Witness Name',
          controller: _witnessNameCtrl,
          hint: 'Enter Witness Name',
        ),
        GoldDetailInputField(
          label: 'Witness Mobile No.',
          controller: _witnessMobileCtrl,
          hint: 'Enter Witness Mobile',
          keyboardType: TextInputType.phone,
          textAlign: TextAlign.start,
          errorText: _witnessPhoneError,
          maxLength: getPhoneNumberLengthLimit(_witnessCountry.countryCode),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          prefix: GestureDetector(
            onTap: () {
              showCountryPicker(
                context: context,
                showPhoneCode: true,
                countryListTheme: CountryListThemeData(
                  backgroundColor: Colors.white,
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                  searchTextStyle: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  bottomSheetHeight: MediaQuery.of(context).size.height * 0.85,
                  inputDecoration: InputDecoration(
                    labelText: 'Search Country',
                    labelStyle: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                    hintText: 'Search by country name or code',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 13,
                    ),
                    prefixIcon: const Icon(Icons.search, color: AppColors.primaryBlue, size: 20),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: const BorderSide(color: Color(0xFFF1F5F9), width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                onSelect: (Country country) {
                  setState(() {
                    _witnessCountry = country;
                    final limit = getPhoneNumberLengthLimit(country.countryCode);
                    if (_witnessMobileCtrl.text.length > limit) {
                      _witnessMobileCtrl.text = _witnessMobileCtrl.text.substring(0, limit);
                    }
                  });
                  _validateWitnessPhone(_witnessMobileCtrl.text);
                },
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              margin: const EdgeInsets.only(right: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _witnessCountry.flagEmoji,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '+${_witnessCountry.phoneCode}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary, size: 14),
                  const SizedBox(width: 4),
                  Container(
                    width: 1.0,
                    height: 14,
                    color: const Color(0xFFE2E8F0),
                  ),
                ],
              ),
            ),
          ),
        ),
        GoldDetailInputField(
          label: 'Witness Relation',
          controller: _witnessRelationCtrl,
          hint: 'Enter Relation',
        ),
        GoldDetailInputField(
          label: 'Witness Id Proof',
          value: _witnessIdProofType,
          hint: 'Select Here',
          onTap: () => _showSelectionBottomSheet(
            'Witness Id Proof',
            ['Aadhaar', 'PAN', 'Passport'],
            _witnessIdProofType,
            (val) => setState(() => _witnessIdProofType = val),
          ),
        ),
        GoldDetailInputField(
          label: 'Witness Id Proof Upload',
          value: _witnessIdProofImagePath?.split('/').last,
          hint: 'No file chosen',
          onTap: () => _pickImage(false),
          showBottomBorder: false,
        ),
      ],
    );
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

  Widget _buildLoanDetailsForm() {
    return GoldDetailInputGroup(
      title: 'Loan Details',
      children: [
        _buildCombinedStaticInput(
          label: 'Loan Period',
          staticText: 'Months',
          textController: _loanPeriodCtrl,
          hintText: 'Months',
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(2),
          ],
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
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')),
            LengthLimitingTextInputFormatter(15),
          ],
        ),
        GoldDetailInputField(
          label: 'Interest Rate',
          controller: _interestRateCtrl,
          hint: '0.00',
          keyboardType: TextInputType.number,
        ),
        _buildCombinedDropdownInput(
          label: 'Interest Payment Period',
          dropdownText: _interestPaymentPeriodType == 'MONTHLY' ? 'Monthly' : _interestPaymentPeriodType == 'YEARLY' ? 'Yearly' : _interestPaymentPeriodType ?? 'Monthly',
          textController: _interestPaymentPeriodCtrl,
          hintText: 'Enter period',
          onDropdownTap: _showInterestPeriodPicker,
        ),
        GoldDetailInputField(
          label: 'Agreement Image',
          value: _agreementImagePath?.split('/').last,
          hint: 'No file chosen',
          onTap: _pickAgreementImage,
          showBottomBorder: false,
        ),
      ],
    );
  }

  String _formatDate(String yyyymmdd) {
    try {
      final parts = yyyymmdd.split('-');
      if (parts.length != 3) return yyyymmdd;
      final year = parts[0];
      final monthInt = int.parse(parts[1]);
      final day = parts[2].padLeft(2, '0');
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      if (monthInt < 1 || monthInt > 12) return yyyymmdd;
      final monthName = months[monthInt - 1];
      return '$day $monthName $year';
    } catch (_) {
      return yyyymmdd;
    }
  }

  String _formatAmount(String amountText, String? symbol) {
    try {
      final amountVal = double.tryParse(amountText.replaceAll(',', ''));
      if (amountVal == null) return amountText;
      final parts = amountVal.toStringAsFixed(2).split('.');
      var whole = parts[0];
      final decimal = parts[1];
      
      // Indian numbering format (e.g. 2,33,000)
      if (whole.length > 3) {
        final lastThree = whole.substring(whole.length - 3);
        final other = whole.substring(0, whole.length - 3);
        final otherBuffer = StringBuffer();
        int count = 0;
        for (int i = other.length - 1; i >= 0; i--) {
          if (count > 0 && count % 2 == 0) {
            otherBuffer.write(',');
          }
          otherBuffer.write(other[i]);
          count++;
        }
        final otherReversed = otherBuffer.toString().split('').reversed.join('');
        whole = '$otherReversed,$lastThree';
      }
      return '${symbol ?? "₹"} $whole.$decimal';
    } catch (_) {
      return '${symbol ?? "₹"} $amountText';
    }
  }


  void _showFullImagePreview(String? localPath, String? networkUrl, String title) {
  final hasLocal = localPath != null && localPath.isNotEmpty;
  final hasNetwork = networkUrl != null && networkUrl.isNotEmpty;
  if (!hasLocal && !hasNetwork) return; // nothing to show

  showDialog(
    context: context,
    barrierColor: Colors.black,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Positioned.fill(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4,
                child: Center(
                  child: hasLocal
                      ? Image.file(File(localPath), fit: BoxFit.contain)
                      : Image.network(networkUrl!, fit: BoxFit.contain),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Container(
                  color: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 26),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48), // keeps title centered (balances close icon)
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
  Widget _buildSummaryImagePreview(String? localPath, String? networkUrl) {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F2F5),
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: (localPath != null && localPath.isNotEmpty)
          ? Image.file(
              File(localPath),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Center(
                child: Icon(Icons.broken_image_outlined, color: Colors.grey, size: 36),
              ),
            )
          : (networkUrl != null && networkUrl.isNotEmpty)
              ? Image.network(
                  networkUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(Icons.broken_image_outlined, color: Colors.grey, size: 36),
                  ),
                )
              : const Center(
                  child: Icon(
                    Icons.photo_library_outlined,
                    color: Colors.grey,
                    size: 36,
                  ),
                ),
    );
  }

  Widget _buildSummaryField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.isEmpty ? 'N/A' : value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
 

 Widget _buildSummaryImageField(String label, String? localPath, String? networkUrl) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showFullImagePreview(localPath, networkUrl, label),
          child: _buildSummaryImagePreview(localPath, networkUrl),
        ),
      ],
    ),
  );
}
 /* Widget _buildSummaryImageField(String label, String? localPath, String? networkUrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          _buildSummaryImagePreview(localPath, networkUrl),
        ],
      ),
    );
  }
*/
  Widget _buildSummaryGroup({required String title, required List<Widget> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFF1F2F5)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSummaryGroup(
          title: 'Person Details',
          items: [
            _buildSummaryField('Name', _personNameCtrl.text),
            _buildSummaryField('Mobile Number', _buildFormattedMobile(_personMobileCtrl.text, _personCountry)),
            _buildSummaryField('Id proof', _idProofType ?? 'N/A'),
            _buildSummaryImageField('id Proof upload', _idProofImagePath, widget.person?.idProofImage),
            _buildSummaryField('Address', _personAddressCtrl.text),
            _buildSummaryField('Witness Name', _witnessNameCtrl.text),
            _buildSummaryField('Witness Mobile Number', _buildFormattedMobile(_witnessMobileCtrl.text, _witnessCountry)),
            _buildSummaryField('witness relation', _witnessRelationCtrl.text),
            _buildSummaryField('Witness id Proof', _witnessIdProofType ?? 'N/A'),
            _buildSummaryImageField('witness id Front Upload', _witnessIdProofImagePath, widget.person?.witnessIdProofImage),
          ],
        ),
        const SizedBox(height: 24),
        _buildSummaryGroup(
          title: 'Loan Details',
          items: [
            _buildSummaryField('Loan Period', '${_loanPeriodCtrl.text} ${_loanPeriodType == 'MONTH' ? 'Months' : _loanPeriodType == 'YEAR' ? 'Years' : 'Days'}'),
            _buildSummaryField('Loan date', _formatDate(_loanDateCtrl.text)),
            _buildSummaryField('Principal Amount', _formatAmount(_principalAmountCtrl.text, _principalAmountSymbol)),
            _buildSummaryField('Interest Rate', '${_interestRateCtrl.text}%'),
            _buildSummaryField(
              'Interest Payment Period',
              '${_interestPaymentPeriodType == 'MONTHLY' ? 'Monthly' : _interestPaymentPeriodType == 'YEARLY' ? 'Yearly' : _interestPaymentPeriodType ?? 'Monthly'} / ${_interestPaymentPeriodCtrl.text}',
            ),
            _buildSummaryImageField('Agreement Image', _agreementImagePath, widget.loan?.agreementImage),
          ],
        ),
      ],
    );
  }
}
*/
import 'dart:io';
import 'package:bank_scan/Gold/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:country_picker/country_picker.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:bank_scan/Gold/core/utils/phone_validation_helper.dart';

import '../../../widgets/gold_dialogs.dart';
import '../../../widgets/gold_detail_input.dart';
import '../../../widgets/gold_back_button.dart';
import '../repository/loan_repository.dart';
import 'package:image_picker/image_picker.dart';

import '../models/loan_models.dart';

// NEW: holds the editable form state for a single loan.
// One of these is created per loan, so a person with multiple loans
// gets multiple independent form blocks instead of one shared set of fields.
class _LoanFormData {
  int? loanId;
  String? loanPeriodType;
  final TextEditingController loanPeriodCtrl;
  final TextEditingController loanDateCtrl;
  String? principalAmountType;
  String principalAmountSymbol;
  final TextEditingController principalAmountCtrl;
  final TextEditingController interestRateCtrl;
  String? interestPaymentPeriodType;
  final TextEditingController interestPaymentPeriodCtrl;
  String? agreementImagePath;

  _LoanFormData({this.loanId})
      : loanPeriodType = 'MONTH',
        loanPeriodCtrl = TextEditingController(text: '12'),
        loanDateCtrl = TextEditingController(),
        principalAmountType = 'INR',
        principalAmountSymbol = '₹',
        principalAmountCtrl = TextEditingController(),
        interestRateCtrl = TextEditingController(),
        interestPaymentPeriodType = 'MONTHLY',
        interestPaymentPeriodCtrl = TextEditingController();

  factory _LoanFormData.fromLoan(Loan loan) {
    final form = _LoanFormData(loanId: loan.id);
    form.loanPeriodType = loan.loanPeriodType;
    form.loanPeriodCtrl.text = loan.loanPeriod?.toString() ?? '';
    form.loanDateCtrl.text = loan.loanDate ?? '';
    form.principalAmountType = loan.principalAmountType ?? 'INR';
    form.principalAmountCtrl.text = loan.principalAmount.toString();
    form.interestRateCtrl.text = loan.interestRate?.toString() ?? '';
    form.interestPaymentPeriodType = loan.interestPaymentPeriodType;
    form.interestPaymentPeriodCtrl.text = loan.interestPaymentPeriod?.toString() ?? '';
    return form;
  }

  void dispose() {
    loanPeriodCtrl.dispose();
    loanDateCtrl.dispose();
    principalAmountCtrl.dispose();
    interestRateCtrl.dispose();
    interestPaymentPeriodCtrl.dispose();
  }
}

class AddLoanScreen extends StatefulWidget {
  final PersonDetails? person;
  final List<Loan>? loans; // CHANGED: was `final Loan? loan;`

  const AddLoanScreen({super.key, this.person, this.loans});

  @override
  State<AddLoanScreen> createState() => _AddLoanScreenState();
}

class _AddLoanScreenState extends State<AddLoanScreen> {
  final _repository = LoanRepository();
  int _currentStep = 0;
  bool _isLoading = false;

  // Person Details
  final _personNameCtrl = TextEditingController();
  final _personMobileCtrl = TextEditingController();
  final _personAddressCtrl = TextEditingController();
  String? _idProofType;
  String? _idProofImagePath;
  
  final _witnessNameCtrl = TextEditingController();
  final _witnessMobileCtrl = TextEditingController();
  final _witnessRelationCtrl = TextEditingController();
  String? _witnessIdProofType;
  String? _witnessIdProofImagePath;

  // Country pickers
  Country _personCountry = Country(
    phoneCode: '91',
    countryCode: 'IN',
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: 'India',
    example: 'India',
    displayName: 'India (IN) [+91]',
    displayNameNoCountryCode: 'India (IN)',
    e164Key: '',
  );

  Country _witnessCountry = Country(
    phoneCode: '91',
    countryCode: 'IN',
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: 'India',
    example: 'India',
    displayName: 'India (IN) [+91]',
    displayNameNoCountryCode: 'India (IN)',
    e164Key: '',
  );

  String? _personPhoneError;
  String? _witnessPhoneError;

  void _validatePersonPhone(String val) {
    if (val.trim().isEmpty) {
      setState(() => _personPhoneError = null);
      return;
    }
    final isValid = _isPhoneNumberValid(val, _personCountry);
    setState(() {
      _personPhoneError = isValid ? null : 'Invalid mobile number for ${_personCountry.name}';
    });
  }

  void _validateWitnessPhone(String val) {
    if (val.trim().isEmpty) {
      setState(() => _witnessPhoneError = null);
      return;
    }
    final isValid = _isPhoneNumberValid(val, _witnessCountry);
    setState(() {
      _witnessPhoneError = isValid ? null : 'Invalid mobile number for ${_witnessCountry.name}';
    });
  }

  void _onPersonPhoneChanged() {
    _validatePersonPhone(_personMobileCtrl.text);
  }

  void _onWitnessPhoneChanged() {
    _validateWitnessPhone(_witnessMobileCtrl.text);
  }

  // CHANGED: list of per-loan form data instead of a single set of loan fields
  late List<_LoanFormData> _loanForms;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _personMobileCtrl.addListener(_onPersonPhoneChanged);
    _witnessMobileCtrl.addListener(_onWitnessPhoneChanged);
    if (widget.person != null) {
      _personNameCtrl.text = widget.person!.name;
      _personMobileCtrl.text = widget.person!.mobileNumber;
      _personAddressCtrl.text = widget.person!.address ?? '';
      _idProofType = widget.person!.idProof;
      _witnessNameCtrl.text = widget.person!.witnessName ?? '';
      _witnessMobileCtrl.text = widget.person!.witnessMobileNumber ?? '';
      _witnessRelationCtrl.text = widget.person!.witnessRelation ?? '';
      _witnessIdProofType = widget.person!.witnessIdProof;
    }

    // CHANGED: build one _LoanFormData per existing loan, or a single blank one when creating
    if (widget.loans != null && widget.loans!.isNotEmpty) {
      _loanForms = widget.loans!.map((loan) => _LoanFormData.fromLoan(loan)).toList();
    } else {
      _loanForms = [_LoanFormData()];
    }
  }

  @override
  void dispose() {
    _personMobileCtrl.removeListener(_onPersonPhoneChanged);
    _witnessMobileCtrl.removeListener(_onWitnessPhoneChanged);
    _personNameCtrl.dispose();
    _personMobileCtrl.dispose();
    _personAddressCtrl.dispose();
    _witnessNameCtrl.dispose();
    _witnessMobileCtrl.dispose();
    _witnessRelationCtrl.dispose();
    // CHANGED: dispose every loan form's controllers
    for (final form in _loanForms) {
      form.dispose();
    }
    super.dispose();
  }

  String _buildFormattedMobile(String rawMobile, Country country) {
    final raw = rawMobile.trim();
    if (raw.isEmpty) return '';
    var stripped = raw.replaceAll(RegExp(r'^\+'), '');
    final code = country.phoneCode;
    if (stripped.startsWith(code) && stripped.length > code.length) {
      stripped = stripped.substring(code.length);
    }
    return '+$code$stripped';
  }

  bool _isPhoneNumberValid(String rawNumber, Country country) {
    try {
      var cleanNumber = rawNumber.trim().replaceAll(RegExp(r'[^0-9]'), '');
      if (cleanNumber.isEmpty) return false;

      final code = country.phoneCode;
      if (cleanNumber.startsWith(code) && cleanNumber.length > code.length) {
        cleanNumber = cleanNumber.substring(code.length);
      }
      
      final parsed = PhoneNumber.parse('+$code$cleanNumber');
      return parsed.isValid();
    } catch (_) {
      return false;
    }
  }

  static const Map<String, String> _interestPeriodNames = {
    'MONTHLY': 'Monthly',
    'YEARLY': 'Yearly',
  };

  // CHANGED: now takes the specific loan form to update
  void _openCurrencyPicker(_LoanFormData form) {
    showCurrencyPicker(
      context: context,
      showFlag: true,
      showCurrencyName: true,
      showCurrencyCode: true,
      onSelect: (Currency currency) {
        setState(() {
          form.principalAmountType = currency.code;
          form.principalAmountSymbol = currency.symbol;
        });
      },
    );
  }

  // CHANGED: now takes the specific loan form
  String _getCurrencyDisplayText(_LoanFormData form) {
    final code = form.principalAmountType ?? 'INR';
    if (code == 'INR') return r'₹ Rupee';
    final currency = CurrencyService().findByCode(code);
    if (currency != null) {
      return '${currency.symbol} ${currency.code}';
    }
    return code;
  }

  // CHANGED: now takes the specific loan form to update
  void _showInterestPeriodPicker(_LoanFormData form) {
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
                        fontWeight: entry.key == form.interestPaymentPeriodType ? FontWeight.bold : FontWeight.normal,
                        color: entry.key == form.interestPaymentPeriodType ? AppColors.primaryBlue : AppColors.textPrimary,
                      ),
                    ),
                    trailing: entry.key == form.interestPaymentPeriodType ? const Icon(Icons.check, color: AppColors.primaryBlue) : null,
                    onTap: () {
                      setState(() {
                        form.interestPaymentPeriodType = entry.key;
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

  Widget _buildCombinedStaticInput({
    required String label,
    required String staticText,
    required TextEditingController textController,
    required String hintText,
    List<TextInputFormatter>? inputFormatters,
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
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    staticText,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
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
                      inputFormatters: inputFormatters,
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

  Widget _buildCombinedDropdownInput({
    required String label,
    required String dropdownText,
    required TextEditingController textController,
    required String hintText,
    required VoidCallback onDropdownTap,
    List<TextInputFormatter>? inputFormatters,
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
                      inputFormatters: inputFormatters,
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

  Future<void> _pickImage(bool isPersonId) async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 70,
    );
    if (image != null) {
      setState(() {
        if (isPersonId) {
          _idProofImagePath = image.path;
        } else {
          _witnessIdProofImagePath = image.path;
        }
      });
    }
  }

  // CHANGED: now takes the specific loan form to update
  Future<void> _pickAgreementImage(_LoanFormData form) async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 70,
    );
    if (image != null) {
      setState(() {
        form.agreementImagePath = image.path;
      });
    }
  }

  void _showSelectionBottomSheet(String title, List<String> options, String? currentValue, ValueChanged<String> onSelected) {
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
                            option,
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
        );
      },
    );
  }

  bool _validatePersonDetails() {
    if (_personNameCtrl.text.trim().isEmpty) {
      GoldDialogs.showSnackBar(context, 'Please enter name.', isError: true);
      return false;
    }

    final personPhone = _personMobileCtrl.text.trim();
    if (personPhone.isEmpty) {
      setState(() => _personPhoneError = 'Please enter mobile number.');
      GoldDialogs.showSnackBar(context, 'Please enter mobile number.', isError: true);
      return false;
    }
    if (!_isPhoneNumberValid(personPhone, _personCountry)) {
      setState(() => _personPhoneError = 'Invalid mobile number for ${_personCountry.name}');
      GoldDialogs.showSnackBar(context, 'Please enter a valid mobile number.', isError: true);
      return false;
    }

    if (_idProofType == null) {
      GoldDialogs.showSnackBar(context, 'Please select ID proof type.', isError: true);
      return false;
    }

    if (_personAddressCtrl.text.trim().isEmpty) {
      GoldDialogs.showSnackBar(context, 'Please enter address.', isError: true);
      return false;
    }

    if (_witnessNameCtrl.text.trim().isEmpty) {
      GoldDialogs.showSnackBar(context, 'Please enter witness name.', isError: true);
      return false;
    }

    final witnessPhone = _witnessMobileCtrl.text.trim();
    if (witnessPhone.isEmpty) {
      setState(() => _witnessPhoneError = 'Please enter witness mobile number.');
      GoldDialogs.showSnackBar(context, 'Please enter witness mobile number.', isError: true);
      return false;
    }
    if (!_isPhoneNumberValid(witnessPhone, _witnessCountry)) {
      setState(() => _witnessPhoneError = 'Invalid mobile number for ${_witnessCountry.name}');
      GoldDialogs.showSnackBar(context, 'Please enter a valid witness mobile number.', isError: true);
      return false;
    }

    if (_witnessRelationCtrl.text.trim().isEmpty) {
      GoldDialogs.showSnackBar(context, 'Please enter witness relation.', isError: true);
      return false;
    }

    if (_witnessIdProofType == null) {
      GoldDialogs.showSnackBar(context, 'Please select witness ID proof type.', isError: true);
      return false;
    }

    if (_personNameCtrl.text.trim().toLowerCase() == _witnessNameCtrl.text.trim().toLowerCase()) {
      GoldDialogs.showSnackBar(context, 'Person and Witness names cannot be the same.', isError: true);
      return false;
    }

    if (personPhone == witnessPhone) {
      GoldDialogs.showSnackBar(context, 'Person and Witness mobile numbers cannot be the same.', isError: true);
      return false;
    }

    return true;
  }

  // CHANGED: validates every loan form, not just one
  bool _validateLoanDetails() {
    for (var i = 0; i < _loanForms.length; i++) {
      final form = _loanForms[i];
      final prefix = _loanForms.length > 1 ? 'Loan #${i + 1}: ' : '';

      if (form.loanPeriodType == null) {
        GoldDialogs.showSnackBar(context, '${prefix}Please select loan period type.', isError: true);
        return false;
      }

      final loanPeriodText = form.loanPeriodCtrl.text.trim();
      if (loanPeriodText.isEmpty) {
        GoldDialogs.showSnackBar(context, '${prefix}Please enter loan period.', isError: true);
        return false;
      }
      final loanPeriod = int.tryParse(loanPeriodText);
      if (loanPeriod == null || loanPeriod < 1 || loanPeriod > 12) {
        GoldDialogs.showSnackBar(context, '${prefix}Loan period must be between 1 and 12 months.', isError: true);
        return false;
      }

      if (form.loanDateCtrl.text.trim().isEmpty) {
        GoldDialogs.showSnackBar(context, '${prefix}Please select loan date.', isError: true);
        return false;
      }

      final principalText = form.principalAmountCtrl.text.trim();
      if (principalText.isEmpty) {
        GoldDialogs.showSnackBar(context, '${prefix}Please enter principal amount.', isError: true);
        return false;
      }
      final principal = double.tryParse(principalText);
      if (principal == null || principal <= 0.0) {
        GoldDialogs.showSnackBar(context, '${prefix}Please enter a valid principal amount.', isError: true);
        return false;
      }

      final rateText = form.interestRateCtrl.text.trim();
      if (rateText.isEmpty) {
        GoldDialogs.showSnackBar(context, '${prefix}Please enter interest rate.', isError: true);
        return false;
      }
      final rate = double.tryParse(rateText);
      if (rate == null || rate < 0.0) {
        GoldDialogs.showSnackBar(context, '${prefix}Please enter a valid interest rate.', isError: true);
        return false;
      }

      if (form.interestPaymentPeriodType == null) {
        GoldDialogs.showSnackBar(context, '${prefix}Please select interest period type.', isError: true);
        return false;
      }

      final interestPeriodText = form.interestPaymentPeriodCtrl.text.trim();
      if (interestPeriodText.isEmpty) {
        GoldDialogs.showSnackBar(context, '${prefix}Please enter interest payment period.', isError: true);
        return false;
      }
      final interestPeriod = int.tryParse(interestPeriodText);
      if (interestPeriod == null || interestPeriod <= 0) {
        GoldDialogs.showSnackBar(context, '${prefix}Please enter a valid interest payment period.', isError: true);
        return false;
      }
    }

    return true;
  }

  // CHANGED: loops through all loan forms; updates each existing loan, or creates one new loan
  Future<void> _submitAll() async {
    if (!_validatePersonDetails() || !_validateLoanDetails()) {
      return;
    }
    setState(() => _isLoading = true);
    try {
      final personData = {
        'name': _personNameCtrl.text.trim(),
        'mobileNumber': _buildFormattedMobile(_personMobileCtrl.text, _personCountry),
        'idProof': _idProofType ?? 'Aadhaar',
        'address': _personAddressCtrl.text.trim(),
        'witnessName': _witnessNameCtrl.text.trim(),
        'witnessMobileNumber': _buildFormattedMobile(_witnessMobileCtrl.text, _witnessCountry),
        'witnessRelation': _witnessRelationCtrl.text.trim(),
        'witnessIdProof': _witnessIdProofType ?? 'Aadhaar',
      };

      if (widget.person != null && widget.loans != null && widget.loans!.isNotEmpty) {
        // Update existing Person
        final updatePersonErr = await _repository.updatePerson(widget.person!.id, personData, idProofImagePath: _idProofImagePath, witnessIdProofImagePath: _witnessIdProofImagePath);
        if (updatePersonErr != null) {
          if (mounted) GoldDialogs.showErrorDialog(context: context, title: 'Error', message: updatePersonErr);
          return;
        }

        // Update every existing loan, one by one
        for (final form in _loanForms) {
          final loanData = {
            'loanPeriodType': form.loanPeriodType ?? 'MONTH',
            'loanPeriod': form.loanPeriodCtrl.text.trim(),
            'loanDate': form.loanDateCtrl.text.trim(),
            'principalAmountType': form.principalAmountType ?? 'INR',
            'principalAmount': form.principalAmountCtrl.text.trim(),
            'interestRate': form.interestRateCtrl.text.trim(),
            'interestPaymentPeriodType': form.interestPaymentPeriodType ?? 'MONTHLY',
            'interestPaymentPeriod': form.interestPaymentPeriodCtrl.text.trim(),
            'note': '',
          };

          final updateLoanErr = await _repository.updateLoan(form.loanId ?? 0, loanData, agreementImagePath: form.agreementImagePath);
          if (updateLoanErr != null) {
            if (mounted) GoldDialogs.showErrorDialog(context: context, title: 'Error', message: updateLoanErr);
            return;
          }
        }
      } else {
        final personResult = await _repository.createPerson(
          personData,
          idProofImagePath: _idProofImagePath,
          witnessIdProofImagePath: _witnessIdProofImagePath,
        );

        if (personResult.error != null) {
          if (mounted) GoldDialogs.showErrorDialog(context: context, title: 'Error', message: personResult.error!);
          return;
        }

        final createdPersonId = personResult.personId ?? 1;

        // Create mode only ever has a single loan form
        final form = _loanForms.first;
        final loanData = {
          'loanPeriodType': form.loanPeriodType ?? 'MONTH',
          'loanPeriod': form.loanPeriodCtrl.text.trim(),
          'loanDate': form.loanDateCtrl.text.trim(),
          'principalAmountType': form.principalAmountType ?? 'INR',
          'principalAmount': form.principalAmountCtrl.text.trim(),
          'interestRate': form.interestRateCtrl.text.trim(),
          'interestPaymentPeriodType': form.interestPaymentPeriodType ?? 'MONTHLY',
          'interestPaymentPeriod': form.interestPaymentPeriodCtrl.text.trim(),
          'note': '',
          'personId': createdPersonId,
        };

        final loanErr = await _repository.createLoan(loanData, agreementImagePath: form.agreementImagePath);
        if (loanErr != null) {
          if (mounted) GoldDialogs.showErrorDialog(context: context, title: 'Error', message: loanErr);
          return;
        }
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) GoldDialogs.showErrorDialog(context: context, title: 'Error', message: e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: GoldBackButton(
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Add Loan Details', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w500)),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            _buildStepper(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _currentStep == 0
                    ? _buildPersonDetailsForm()
                    : _currentStep == 1
                        ? _buildLoanDetailsForm()
                        : _buildSummaryForm(),
              ),
            ),
            if (MediaQuery.of(context).viewInsets.bottom == 0)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_currentStep > 0) {
                              setState(() => _currentStep--);
                            } else {
                              Navigator.pop(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF003366),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          ),
                          child: const Text('Back', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  if (_currentStep == 0) {
                                    if (!_validatePersonDetails()) return;
                                    setState(() => _currentStep = 1);
                                  } else if (_currentStep == 1) {
                                    if (!_validateLoanDetails()) return;
                                    setState(() => _currentStep = 2);
                                  } else {
                                    _submitAll();
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF003366),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(_currentStep < 2 ? 'Next' : 'Save', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepper() {
    return Container(
      color: const Color(0xFFF9F9F9),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStepIndicator(0, 'Basic details'),
          Container(width: 40, height: 2, color: _currentStep >= 1 ? AppColors.primaryBlue : Colors.grey.shade300),
          _buildStepIndicator(1, 'Loan Details'),
          Container(width: 40, height: 2, color: _currentStep >= 2 ? AppColors.primaryBlue : Colors.grey.shade300),
          _buildStepIndicator(2, 'Summary'),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int stepIndex, String label) {
    final isCompleted = _currentStep > stepIndex;
    final isActive = _currentStep >= stepIndex;
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryBlue : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: isCompleted
              ? const Icon(Icons.check, color: Colors.white, size: 14)
              : Text('${stepIndex + 1}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10, color: isActive ? AppColors.textPrimary : AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildPersonDetailsForm() {
    return GoldDetailInputGroup(
      title: 'Person Details',
      children: [
        GoldDetailInputField(
          label: 'Enter Name',
          controller: _personNameCtrl,
          hint: 'Enter Name',
        ),
        GoldDetailInputField(
          label: 'Mobile No.',
          controller: _personMobileCtrl,
          hint: 'Enter Here',
          keyboardType: TextInputType.phone,
          textAlign: TextAlign.start,
          errorText: _personPhoneError,
          maxLength: getPhoneNumberLengthLimit(_personCountry.countryCode),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          prefix: GestureDetector(
            onTap: () {
              showCountryPicker(
                context: context,
                showPhoneCode: true,
                countryListTheme: CountryListThemeData(
                  backgroundColor: Colors.white,
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                  searchTextStyle: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  bottomSheetHeight: MediaQuery.of(context).size.height * 0.85,
                  inputDecoration: InputDecoration(
                    labelText: 'Search Country',
                    labelStyle: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                    hintText: 'Search by country name or code',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 13,
                    ),
                    prefixIcon: const Icon(Icons.search, color: AppColors.primaryBlue, size: 20),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: const BorderSide(color: Color(0xFFF1F5F9), width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                onSelect: (Country country) {
                  setState(() {
                    _personCountry = country;
                    final limit = getPhoneNumberLengthLimit(country.countryCode);
                    if (_personMobileCtrl.text.length > limit) {
                      _personMobileCtrl.text = _personMobileCtrl.text.substring(0, limit);
                    }
                  });
                  _validatePersonPhone(_personMobileCtrl.text);
                },
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              margin: const EdgeInsets.only(right: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _personCountry.flagEmoji,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '+${_personCountry.phoneCode}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary, size: 14),
                  const SizedBox(width: 4),
                  Container(
                    width: 1.0,
                    height: 14,
                    color: const Color(0xFFE2E8F0),
                  ),
                ],
              ),
            ),
          ),
        ),
        GoldDetailInputField(
          label: 'Id Proof',
          value: _idProofType,
          hint: 'Select Here',
          onTap: () => _showSelectionBottomSheet(
            'Id Proof',
            ['Aadhaar', 'PAN', 'Passport'],
            _idProofType,
            (val) => setState(() => _idProofType = val),
          ),
        ),
        GoldDetailInputField(
          label: 'Id Proof Upload',
          value: _idProofImagePath?.split('/').last,
          hint: 'No file chosen',
          onTap: () => _pickImage(true),
        ),
        GoldDetailInputField(
          label: 'Address',
          controller: _personAddressCtrl,
          hint: 'Enter Address',
        ),
        const SizedBox(height: 16),
        const SizedBox(height: 16),
        GoldDetailInputField(
          label: 'Witness Name',
          controller: _witnessNameCtrl,
          hint: 'Enter Witness Name',
        ),
        GoldDetailInputField(
          label: 'Witness Mobile No.',
          controller: _witnessMobileCtrl,
          hint: 'Enter Witness Mobile',
          keyboardType: TextInputType.phone,
          textAlign: TextAlign.start,
          errorText: _witnessPhoneError,
          maxLength: getPhoneNumberLengthLimit(_witnessCountry.countryCode),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          prefix: GestureDetector(
            onTap: () {
              showCountryPicker(
                context: context,
                showPhoneCode: true,
                countryListTheme: CountryListThemeData(
                  backgroundColor: Colors.white,
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                  searchTextStyle: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  bottomSheetHeight: MediaQuery.of(context).size.height * 0.85,
                  inputDecoration: InputDecoration(
                    labelText: 'Search Country',
                    labelStyle: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                    hintText: 'Search by country name or code',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 13,
                    ),
                    prefixIcon: const Icon(Icons.search, color: AppColors.primaryBlue, size: 20),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: const BorderSide(color: Color(0xFFF1F5F9), width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                onSelect: (Country country) {
                  setState(() {
                    _witnessCountry = country;
                    final limit = getPhoneNumberLengthLimit(country.countryCode);
                    if (_witnessMobileCtrl.text.length > limit) {
                      _witnessMobileCtrl.text = _witnessMobileCtrl.text.substring(0, limit);
                    }
                  });
                  _validateWitnessPhone(_witnessMobileCtrl.text);
                },
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              margin: const EdgeInsets.only(right: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _witnessCountry.flagEmoji,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '+${_witnessCountry.phoneCode}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary, size: 14),
                  const SizedBox(width: 4),
                  Container(
                    width: 1.0,
                    height: 14,
                    color: const Color(0xFFE2E8F0),
                  ),
                ],
              ),
            ),
          ),
        ),
        GoldDetailInputField(
          label: 'Witness Relation',
          controller: _witnessRelationCtrl,
          hint: 'Enter Relation',
        ),
        GoldDetailInputField(
          label: 'Witness Id Proof',
          value: _witnessIdProofType,
          hint: 'Select Here',
          onTap: () => _showSelectionBottomSheet(
            'Witness Id Proof',
            ['Aadhaar', 'PAN', 'Passport'],
            _witnessIdProofType,
            (val) => setState(() => _witnessIdProofType = val),
          ),
        ),
        GoldDetailInputField(
          label: 'Witness Id Proof Upload',
          value: _witnessIdProofImagePath?.split('/').last,
          hint: 'No file chosen',
          onTap: () => _pickImage(false),
          showBottomBorder: false,
        ),
      ],
    );
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

  // CHANGED: renders one "Loan Details" block per loan form
  Widget _buildLoanDetailsForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < _loanForms.length; i++) ...[
          if (i > 0) const SizedBox(height: 24),
          GoldDetailInputGroup(
            title: _loanForms.length > 1 ? 'Loan Details ${i + 1}' : 'Loan Details',
            children: [
              _buildCombinedStaticInput(
                label: 'Loan Period',
                staticText: 'Months',
                textController: _loanForms[i].loanPeriodCtrl,
                hintText: 'Months',
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2),
                ],
              ),
              GoldDetailInputField(
                label: 'Loan Date',
                value: _loanForms[i].loanDateCtrl.text.isEmpty ? null : _loanForms[i].loanDateCtrl.text,
                hint: 'YYYY-MM-DD',
                onTap: () => _selectDate(_loanForms[i].loanDateCtrl),
                isDate: true,
              ),
              _buildCombinedDropdownInput(
                label: 'Principal Amount',
                dropdownText: _getCurrencyDisplayText(_loanForms[i]),
                textController: _loanForms[i].principalAmountCtrl,
                hintText: '0.00',
                onDropdownTap: () => _openCurrencyPicker(_loanForms[i]),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')),
                  LengthLimitingTextInputFormatter(15),
                ],
              ),
              GoldDetailInputField(
                label: 'Interest Rate',
                controller: _loanForms[i].interestRateCtrl,
                hint: '0.00',
                keyboardType: TextInputType.number,
              ),
              _buildCombinedDropdownInput(
                label: 'Interest Payment Period',
                dropdownText: _loanForms[i].interestPaymentPeriodType == 'MONTHLY'
                    ? 'Monthly'
                    : _loanForms[i].interestPaymentPeriodType == 'YEARLY'
                        ? 'Yearly'
                        : _loanForms[i].interestPaymentPeriodType ?? 'Monthly',
                textController: _loanForms[i].interestPaymentPeriodCtrl,
                hintText: 'Enter period',
                onDropdownTap: () => _showInterestPeriodPicker(_loanForms[i]),
              ),
              GoldDetailInputField(
                label: 'Agreement Image',
                value: _loanForms[i].agreementImagePath?.split('/').last,
                hint: 'No file chosen',
                onTap: () => _pickAgreementImage(_loanForms[i]),
                showBottomBorder: false,
              ),
            ],
          ),
        ],
      ],
    );
  }

  String _formatDate(String yyyymmdd) {
    try {
      final parts = yyyymmdd.split('-');
      if (parts.length != 3) return yyyymmdd;
      final year = parts[0];
      final monthInt = int.parse(parts[1]);
      final day = parts[2].padLeft(2, '0');
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      if (monthInt < 1 || monthInt > 12) return yyyymmdd;
      final monthName = months[monthInt - 1];
      return '$day $monthName $year';
    } catch (_) {
      return yyyymmdd;
    }
  }

  String _formatAmount(String amountText, String? symbol) {
    try {
      final amountVal = double.tryParse(amountText.replaceAll(',', ''));
      if (amountVal == null) return amountText;
      final parts = amountVal.toStringAsFixed(2).split('.');
      var whole = parts[0];
      final decimal = parts[1];
      
      if (whole.length > 3) {
        final lastThree = whole.substring(whole.length - 3);
        final other = whole.substring(0, whole.length - 3);
        final otherBuffer = StringBuffer();
        int count = 0;
        for (int i = other.length - 1; i >= 0; i--) {
          if (count > 0 && count % 2 == 0) {
            otherBuffer.write(',');
          }
          otherBuffer.write(other[i]);
          count++;
        }
        final otherReversed = otherBuffer.toString().split('').reversed.join('');
        whole = '$otherReversed,$lastThree';
      }
      return '${symbol ?? "₹"} $whole.$decimal';
    } catch (_) {
      return '${symbol ?? "₹"} $amountText';
    }
  }

  void _showFullImagePreview(String? localPath, String? networkUrl, String title) {
    final hasLocal = localPath != null && localPath.isNotEmpty;
    final hasNetwork = networkUrl != null && networkUrl.isNotEmpty;
    if (!hasLocal && !hasNetwork) return;

    showDialog(
      context: context,
      barrierColor: Colors.black,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            children: [
              Positioned.fill(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4,
                  child: Center(
                    child: hasLocal
                        ? Image.file(File(localPath), fit: BoxFit.contain)
                        : Image.network(networkUrl!, fit: BoxFit.contain),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Container(
                    color: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white, size: 26),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: Text(
                            title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryImagePreview(String? localPath, String? networkUrl) {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F2F5),
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: (localPath != null && localPath.isNotEmpty)
          ? Image.file(
              File(localPath),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Center(
                child: Icon(Icons.broken_image_outlined, color: Colors.grey, size: 36),
              ),
            )
          : (networkUrl != null && networkUrl.isNotEmpty)
              ? Image.network(
                  networkUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(Icons.broken_image_outlined, color: Colors.grey, size: 36),
                  ),
                )
              : const Center(
                  child: Icon(
                    Icons.photo_library_outlined,
                    color: Colors.grey,
                    size: 36,
                  ),
                ),
    );
  }

  Widget _buildSummaryField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.isEmpty ? 'N/A' : value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryImageField(String label, String? localPath, String? networkUrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _showFullImagePreview(localPath, networkUrl, label),
            child: _buildSummaryImagePreview(localPath, networkUrl),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryGroup({required String title, required List<Widget> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFF1F2F5)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items,
          ),
        ),
      ],
    );
  }

  // CHANGED: shows a summary group per loan instead of just one
  Widget _buildSummaryForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSummaryGroup(
          title: 'Person Details',
          items: [
            _buildSummaryField('Name', _personNameCtrl.text),
            _buildSummaryField('Mobile Number', _buildFormattedMobile(_personMobileCtrl.text, _personCountry)),
            _buildSummaryField('Id proof', _idProofType ?? 'N/A'),
            _buildSummaryImageField('id Proof upload', _idProofImagePath, widget.person?.idProofImage),
            _buildSummaryField('Address', _personAddressCtrl.text),
            _buildSummaryField('Witness Name', _witnessNameCtrl.text),
            _buildSummaryField('Witness Mobile Number', _buildFormattedMobile(_witnessMobileCtrl.text, _witnessCountry)),
            _buildSummaryField('witness relation', _witnessRelationCtrl.text),
            _buildSummaryField('Witness id Proof', _witnessIdProofType ?? 'N/A'),
            _buildSummaryImageField('witness id Front Upload', _witnessIdProofImagePath, widget.person?.witnessIdProofImage),
          ],
        ),
        for (var i = 0; i < _loanForms.length; i++) ...[
          const SizedBox(height: 24),
          _buildSummaryGroup(
            title: _loanForms.length > 1 ? 'Loan Details ${i + 1}' : 'Loan Details',
            items: [
              _buildSummaryField(
                'Loan Period',
                '${_loanForms[i].loanPeriodCtrl.text} ${_loanForms[i].loanPeriodType == 'MONTH' ? 'Months' : _loanForms[i].loanPeriodType == 'YEAR' ? 'Years' : 'Days'}',
              ),
              _buildSummaryField('Loan date', _formatDate(_loanForms[i].loanDateCtrl.text)),
              _buildSummaryField('Principal Amount', _formatAmount(_loanForms[i].principalAmountCtrl.text, _loanForms[i].principalAmountSymbol)),
              _buildSummaryField('Interest Rate', '${_loanForms[i].interestRateCtrl.text}%'),
              _buildSummaryField(
                'Interest Payment Period',
                '${_loanForms[i].interestPaymentPeriodType == 'MONTHLY' ? 'Monthly' : _loanForms[i].interestPaymentPeriodType == 'YEARLY' ? 'Yearly' : _loanForms[i].interestPaymentPeriodType ?? 'Monthly'} / ${_loanForms[i].interestPaymentPeriodCtrl.text}',
              ),
              _buildSummaryImageField(
                'Agreement Image',
                _loanForms[i].agreementImagePath,
                widget.loans != null && i < widget.loans!.length ? widget.loans![i].agreementImage : null,
              ),
            ],
          ),
        ],
      ],
    );
  }
}
