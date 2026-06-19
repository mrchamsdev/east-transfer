import 'package:bank_scan/Gold/core/constants/app_colors.dart';
import 'package:bank_scan/Gold/core/constants/app_text_styles.dart';
import 'package:bank_scan/Gold/core/utils/responsive_extensions.dart';
import 'package:bank_scan/Gold/core/utils/screen_utility.dart';
import 'package:bank_scan/Gold/core/utils/phone_validation_helper.dart';
import 'package:bank_scan/Gold/widgets/gold_dialogs.dart';
import 'package:bank_scan/Gold/widgets/gold_detail_input.dart';
import 'package:country_picker/country_picker.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/gold_purchase_model.dart';
import '../repository/gold_repository.dart';

class AddSaleModal extends StatefulWidget {
  final GoldPurchase purchase;

  const AddSaleModal({super.key, required this.purchase});

  static Future<void> show(BuildContext context, GoldPurchase purchase) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => AddSaleModal(purchase: purchase),
    );
  }

  @override
  State<AddSaleModal> createState() => _AddSaleModalState();
}

class _AddSaleModalState extends State<AddSaleModal> {
  final GoldRepository _repository = GoldRepository();
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _partyNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dlNumberController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  bool _isLoading = false;
  String? _phoneErrorText;

  void _validatePhone(String val) {
    if (val.trim().isEmpty) {
      setState(() => _phoneErrorText = null);
      return;
    }
    final isValid = _isPhoneNumberValid(val, _selectedCountry);
    setState(() {
      _phoneErrorText = isValid ? null : 'Invalid phone number for ${_selectedCountry.name}';
    });
  }

  void _onPhoneChanged() {
    _validatePhone(_phoneController.text);
  }

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_onPhoneChanged);

    final purchase = widget.purchase;
    if (purchase.status?.toUpperCase() == 'SALE') {
      if (purchase.saleDate != null) {
        _selectedDate = DateTime.tryParse(purchase.saleDate!) ?? DateTime.now();
      }
      if (purchase.saleAmount != null) {
        _amountController.text = purchase.saleAmount!.toStringAsFixed(2);
      }

      String buyerName = '';
      String buyerPhone = '';
      String buyerDl = '';

      if (purchase.saleParty != null) {
        buyerName = purchase.saleParty!.partyName;
        buyerPhone = purchase.saleParty!.partyPhoneNumber;
        buyerDl = purchase.saleParty!.dlNumber;
      } else {
        final note = purchase.note ?? '';
        if (note.startsWith('Sold to:')) {
          final content = note.replaceFirst('Sold to:', '').trim();
          final dlParts = content.split('| DL:');
          if (dlParts.length > 1) {
            buyerDl = dlParts[1].trim();
          }
          final mainPart = dlParts[0].trim();
          final phoneMatch = RegExp(r'\(([^)]+)\)$').firstMatch(mainPart);
          if (phoneMatch != null) {
            buyerPhone = phoneMatch.group(1) ?? '';
            buyerName = mainPart.substring(0, mainPart.lastIndexOf('(')).trim();
          } else {
            buyerName = mainPart;
          }
        }
        if (buyerDl.isEmpty) {
          buyerDl = purchase.dlNumber;
        }
      }

      _partyNameController.text = buyerName;
      _dlNumberController.text = buyerDl;

      if (buyerPhone.isNotEmpty) {
        final defaultCode = _selectedCountry.phoneCode;
        if (buyerPhone.startsWith('+$defaultCode')) {
          _phoneController.text = buyerPhone.substring(defaultCode.length + 1);
        } else if (buyerPhone.startsWith('+')) {
          Country? found;
          for (final c in CountryService().getAll()) {
            if (buyerPhone.startsWith('+${c.phoneCode}')) {
              found = c;
              break;
            }
          }
          if (found != null) {
            _selectedCountry = found;
            _phoneController.text = buyerPhone.substring(found.phoneCode.length + 1);
          } else {
            _phoneController.text = buyerPhone.replaceFirst('+', '');
          }
        } else {
          _phoneController.text = buyerPhone;
        }
      }
    }
  }

  Country _selectedCountry = Country(
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

  @override
  void dispose() {
    _partyNameController.dispose();
    _phoneController.dispose();
    _dlNumberController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
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

  String _getFormattedDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  String _getDisplayDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _buildPhoneNumber() {
    final raw = _phoneController.text.trim();
    if (raw.isEmpty) return '';
    var stripped = raw.replaceAll(RegExp(r'^\+'), '');
    final code = _selectedCountry.phoneCode;
    if (stripped.startsWith(code) && stripped.length > code.length) {
      stripped = stripped.substring(code.length);
    }
    return '+$code$stripped';
  }

  bool _isPhoneNumberValid(String rawNumber, Country country) {
    try {
      final raw = rawNumber.trim();
      if (raw.isEmpty) return false;

      final isoString = country.countryCode.toUpperCase();
      final isoCode = IsoCode.values.firstWhere(
        (e) => e.name == isoString,
        orElse: () => IsoCode.IN,
      );

      final phoneNumber = PhoneNumber.parse(
        raw,
        destinationCountry: isoCode,
      );
      return phoneNumber.isValid();
    } catch (_) {
      return false;
    }
  }

  Future<void> _handleSoldOut() async {
    if (_partyNameController.text.trim().isEmpty) {
      GoldDialogs.showSnackBar(context, 'Please enter party name',
          isError: true);
      return;
    }

    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      setState(() => _phoneErrorText = 'Please enter phone number');
      GoldDialogs.showSnackBar(context, 'Please enter phone number',
          isError: true);
      return;
    }

    if (!_isPhoneNumberValid(phone, _selectedCountry)) {
      setState(() => _phoneErrorText = 'Invalid phone number for ${_selectedCountry.name}');
      GoldDialogs.showSnackBar(
          context,
          'Please enter a valid phone number for ${_selectedCountry.name}',
          isError: true);
      return;
    }

    if (_amountController.text.isEmpty) {
      GoldDialogs.showSnackBar(context, 'Please enter sale amount',
          isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final partyId = widget.purchase.party?.id ?? widget.purchase.id ?? 1;
      final payload = {
        "status": "SALE",
        "soldOut": true,
        "saleDate": _getFormattedDate(_selectedDate),
        "saleAmount": double.tryParse(_amountController.text) ?? 0,
        "salePartyName": _partyNameController.text.trim(),
        "salePartyPhoneNumber": _buildPhoneNumber(),
        "saleDlNumber": _dlNumberController.text.trim(),
      };

      final success = await _repository.updateParty(partyId, payload);

      if (success) {
        if (mounted) {
          GoldDialogs.showSnackBar(context, 'Marked as Sold Out!');
          Navigator.pop(context, true); // Close modal
          if (Navigator.canPop(context)) {
            Navigator.pop(context, true); // Refresh parent screen safely
          }
        }
      } else {
        if (mounted) {
          GoldDialogs.showSnackBar(context, 'Failed to update sale.',
              isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        GoldDialogs.showSnackBar(context, 'Error: ${e.toString()}',
            isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtility().init(context);
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(6.r)),
        ),
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
        child: Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(width: 8.w),
                    Text(
                      'Add Sale Details',
                      style: AppTextStyles.h2.copyWith(fontSize: 12.sp),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: EdgeInsets.all(1.w),
                        decoration: BoxDecoration(
                          color: AppColors.iconBackground
                              .withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close,
                            size: 18.sp, color: AppColors.primaryBlue),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                const Divider(color: AppColors.divider),
                SizedBox(height: 2.h),

                GoldDetailInputGroup(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  children: [
                    GoldDetailInputField(
                      label: 'Date',
                      value: _getDisplayDate(_selectedDate),
                      isDate: true,
                      onTap: _selectDate,
                    ),
                    GoldDetailInputField(
                      label: 'Party Name',
                      controller: _partyNameController,
                      hint: 'Enter name',
                    ),
                    GoldDetailInputField(
                      label: 'Party Phone Number',
                      controller: _phoneController,
                      hint: 'Enter phone number',
                      keyboardType: TextInputType.phone,
                      textAlign: TextAlign.start,
                      errorText: _phoneErrorText,
                      maxLength: getPhoneNumberLengthLimit(_selectedCountry.countryCode),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      prefix: GestureDetector(
                        onTap: () {
                          showCountryPicker(
                            context: context,
                            showPhoneCode: true,
                            countryListTheme: CountryListThemeData(
                              backgroundColor: Colors.white,
                              textStyle: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                              searchTextStyle: TextStyle(
                                fontSize: 14.sp,
                                color: AppColors.textPrimary,
                              ),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(24),
                                topRight: Radius.circular(24),
                              ),
                              bottomSheetHeight:
                                  MediaQuery.of(context).size.height * 0.85,
                              inputDecoration: InputDecoration(
                                labelText: 'Search Country',
                                labelStyle: TextStyle(
                                  fontSize: 13.sp,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                                hintText: 'Search by country name or code',
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 13.sp,
                                ),
                                prefixIcon: Icon(Icons.search,
                                    color: AppColors.primaryBlue, size: 20.sp),
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4.r),
                                  borderSide: const BorderSide(
                                      color: Color(0xFFF1F5F9), width: 1.5),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4.r),
                                  borderSide: const BorderSide(
                                      color: AppColors.primaryBlue, width: 1.5),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 4.w, vertical: 1.5.h),
                              ),
                            ),
                            onSelect: (Country country) {
                              setState(() {
                                _selectedCountry = country;
                                final limit = getPhoneNumberLengthLimit(country.countryCode);
                                if (_phoneController.text.length > limit) {
                                  _phoneController.text = _phoneController.text.substring(0, limit);
                                }
                              });
                              _validatePhone(_phoneController.text);
                            },
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 1.w, vertical: 1.h),
                          margin: EdgeInsets.only(right: 1.5.w),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _selectedCountry.flagEmoji,
                                style: TextStyle(fontSize: 14.sp),
                              ),
                              SizedBox(width: 0.8.w),
                              Text(
                                '+${_selectedCountry.phoneCode}',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Icon(Icons.arrow_drop_down,
                                  color: AppColors.textSecondary, size: 14.sp),
                              SizedBox(width: 1.w),
                              Container(
                                width: 0.25.w,
                                height: 1.5.h,
                                color: const Color(0xFFE2E8F0),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    GoldDetailInputField(
                      label: 'DL Number',
                      controller: _dlNumberController,
                      hint: '0000000',
                    ),
                    GoldDetailInputField(
                      label: 'Amount',
                      controller: _amountController,
                      hint: '0.00',
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      showBottomBorder: false,
                    ),
                  ],
                ),

                SizedBox(height: 4.h),

                // Bottom Button
                SizedBox(
                  width: double.infinity,
                  height: 7.h,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSoldOut,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r)),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white)
                        : Text(
                            'Sold Out',
                            style: AppTextStyles.label.copyWith(
                                color: AppColors.white, fontSize: 12.sp),
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
