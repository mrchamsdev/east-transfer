import 'package:bank_scan/Gold/widgets/gold_detail_input.dart';
import 'package:bank_scan/Gold/widgets/gold_dialogs.dart';
import 'package:bank_scan/Gold/widgets/gold_shimmer.dart';
import 'package:country_picker/country_picker.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import '../repository/gold_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bank_scan/Gold/core/constants/app_colors.dart';
import 'package:bank_scan/Gold/core/constants/app_routes.dart';
import 'package:bank_scan/Gold/core/utils/responsive_extensions.dart';
import 'package:bank_scan/Gold/core/utils/screen_utility.dart';
import 'package:bank_scan/Gold/core/utils/phone_validation_helper.dart';
import '../models/gold_purchase_model.dart';
import '../widgets/billed_item_card.dart';

class AddGoldPurchaseScreen extends StatefulWidget {
  final GoldPurchase? purchase;

  const AddGoldPurchaseScreen({super.key, this.purchase});

  @override
  State<AddGoldPurchaseScreen> createState() => _AddGoldPurchaseScreenState();
}

class _AddGoldPurchaseScreenState extends State<AddGoldPurchaseScreen> {
  final GoldRepository _repository = GoldRepository();
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _partyNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _licenseController = TextEditingController();
  final TextEditingController _dlNumberController = TextEditingController();

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

  List<GoldBilledItem> _billedItems = [];
  int? _activeItemIndex;

  // Financial fields
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _royaltyPercentController =
      TextEditingController();
  final TextEditingController _traPercentController = TextEditingController();
  final TextEditingController _svlPercentController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  // Derived values
  double _totalTax = 0.0;
  double _grandTotal = 0.0;
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
    _amountController.addListener(_calculateTotals);
    _royaltyPercentController.addListener(_calculateTotals);
    _traPercentController.addListener(_calculateTotals);
    _svlPercentController.addListener(_calculateTotals);
    _phoneController.addListener(_onPhoneChanged);

    if (widget.purchase != null) {
      final p = widget.purchase!;
      _selectedDate = DateTime.tryParse(p.purchaseDate) ?? DateTime.now();
      _partyNameController.text = p.partyName;

      final phone = p.partyPhoneNumber;
      if (phone.startsWith('+')) {
        final code = _selectedCountry.phoneCode;
        final withCode = '+$code';
        if (phone.startsWith(withCode)) {
          _phoneController.text = phone.substring(withCode.length);
        } else {
          _phoneController.text = phone.replaceFirst('+', '');
        }
      } else {
        _phoneController.text = phone;
      }

      _licenseController.text = p.licenseNumber;
      _dlNumberController.text = p.dlNumber;
      
      double? initialAmount = p.grandTotal;
      if (initialAmount == null || initialAmount == 0.0) {
        initialAmount = p.totalAmount;
      }
      if (initialAmount == null || initialAmount == 0.0) {
        initialAmount = p.amount;
      }
      _amountController.text = (initialAmount != null && initialAmount > 0.0)
          ? initialAmount.toStringAsFixed(2)
          : '';

      _royaltyPercentController.text = p.royaltyCifHiv ?? '';
      _traPercentController.text = p.tra ?? '';
      _svlPercentController.text = p.svl ?? '';
      _noteController.text = p.note ?? '';
      _billedItems = List.from(p.items ?? []);
      _calculateTotals();
    }
  }

  void _calculateTotals() {
    final totalAmountVal = double.tryParse(_amountController.text) ?? 0.0;
    final rP = double.tryParse(_royaltyPercentController.text) ?? 0.0;
    final tP = double.tryParse(_traPercentController.text) ?? 0.0;
    final sP = double.tryParse(_svlPercentController.text) ?? 0.0;

    final totalTaxPercent = rP + tP + sP;
    final taxVal = (totalAmountVal * totalTaxPercent) / 100;

    setState(() {
      _totalTax = taxVal;
      _grandTotal = totalAmountVal;
    });
  }

  @override
  void dispose() {
    _partyNameController.dispose();
    _phoneController.removeListener(_onPhoneChanged);
    _phoneController.dispose();
    _licenseController.dispose();
    _dlNumberController.dispose();
    _amountController.dispose();
    _royaltyPercentController.dispose();
    _traPercentController.dispose();
    _svlPercentController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  double get _totalGrossWeight =>
      _billedItems.fold(0, (sum, item) => sum + item.grossWeight);
  double get _totalPureWeight =>
      _billedItems.fold(0, (sum, item) => sum + item.pureWeight);

  String _buildPhoneNumber() {
    final raw = _phoneController.text.trim();
    if (raw.isEmpty) {
      if (widget.purchase != null) return widget.purchase!.partyPhoneNumber;
      return '+${_selectedCountry.phoneCode}';
    }
    var stripped = raw.replaceAll(RegExp(r'^\+'), '');
    final code = _selectedCountry.phoneCode;
    if (stripped.startsWith(code) && stripped.length > code.length) {
      stripped = stripped.substring(code.length);
    }
    return '+$code$stripped';
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

  Future<void> _addItem() async {
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.addGoldItem,
      arguments: _billedItems,
    );
    if (result != null && result is List<GoldBilledItem>) {
      setState(() => _billedItems = List.from(result));
    }
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

  Future<void> _handleSubmit() async {
    // 1. Party Name
    final partyName = _partyNameController.text.trim();
    if (partyName.isEmpty) {
      GoldDialogs.showSnackBar(context, 'Please enter party name', isError: true);
      return;
    }
    if (partyName.length < 3) {
      GoldDialogs.showSnackBar(context, 'Party Name must contain at least 3 characters', isError: true);
      return;
    }
    if (partyName.length > 100) {
      GoldDialogs.showSnackBar(context, 'Party Name cannot exceed 100 characters', isError: true);
      return;
    }
    if (!RegExp(r'^[a-zA-Z\s&.-]+$').hasMatch(partyName)) {
      GoldDialogs.showSnackBar(context, 'Party Name contains invalid characters', isError: true);
      return;
    }

    // 2. Phone Number
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      setState(() => _phoneErrorText = 'Please enter phone number');
      GoldDialogs.showSnackBar(context, 'Please enter phone number', isError: true);
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
    setState(() => _phoneErrorText = null);

    // 3. LIC No
    final licNo = _dlNumberController.text.trim();
    if (licNo.isEmpty) {
      GoldDialogs.showSnackBar(context, 'Please enter LIC No', isError: true);
      return;
    }
    if (licNo.length < 5 || licNo.length > 30) {
      GoldDialogs.showSnackBar(context, 'LIC No must be between 5 and 30 characters', isError: true);
      return;
    }
    if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(licNo)) {
      GoldDialogs.showSnackBar(context, 'LIC No must be alphanumeric', isError: true);
      return;
    }

    // 4. Weight Summary
    if (_billedItems.isEmpty || _totalGrossWeight <= 0) {
      GoldDialogs.showSnackBar(context, 'Please add at least one item', isError: true);
      return;
    }
    if (_totalPureWeight <= 0) {
      GoldDialogs.showSnackBar(context, 'Total Pure Weight cannot be zero', isError: true);
      return;
    }

    // 5. Amount
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      GoldDialogs.showSnackBar(context, 'Please enter Amount', isError: true);
      return;
    }
    final amountVal = double.tryParse(amountText);
    if (amountVal == null || amountVal <= 0) {
      GoldDialogs.showSnackBar(context, 'Amount must be greater than 0', isError: true);
      return;
    }
    if (amountVal > 99999999999.99) {
      GoldDialogs.showSnackBar(context, 'Amount cannot exceed 11 digits', isError: true);
      return;
    }

    // 7. Royalty CIF / HIV (Optional)
    final royaltyText = _royaltyPercentController.text.trim();
    double royaltyVal = 0.0;
    if (royaltyText.isNotEmpty) {
      final parsed = double.tryParse(royaltyText);
      if (parsed == null || parsed < 0) {
        GoldDialogs.showSnackBar(context, 'Royalty CIF / HIV must be a valid non-negative number', isError: true);
        return;
      }
      royaltyVal = parsed;
    }

    // 8. TRA (Optional)
    final traText = _traPercentController.text.trim();
    double traVal = 0.0;
    if (traText.isNotEmpty) {
      final parsed = double.tryParse(traText);
      if (parsed == null || parsed < 0) {
        GoldDialogs.showSnackBar(context, 'TRA must be a valid non-negative number', isError: true);
        return;
      }
      traVal = parsed;
    }

    // 9. SVL (Optional)
    final svlText = _svlPercentController.text.trim();
    double svlVal = 0.0;
    if (svlText.isNotEmpty) {
      final parsed = double.tryParse(svlText);
      if (parsed == null || parsed < 0) {
        GoldDialogs.showSnackBar(context, 'SVL must be a valid non-negative number', isError: true);
        return;
      }
      svlVal = parsed;
    }

    // 10. Note
    final noteText = _noteController.text;
    if (noteText.length > 500) {
      GoldDialogs.showSnackBar(context, 'Note cannot exceed 500 characters', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final taxPercentVal = royaltyVal + traVal + svlVal;
      final taxVal = (amountVal * taxPercentVal) / 100;
      final calculatedAmountVal = amountVal - taxVal;

      final purchase = GoldPurchase(
        purchaseDate: _getFormattedDate(_selectedDate),
        partyName: partyName,
        partyPhoneNumber: _buildPhoneNumber(),
        dlNumber: licNo,
        licenseNumber: licNo,
        status: widget.purchase?.status ?? 'PURCHASE',
        totalGrossWeight: _totalGrossWeight,
        totalPureWeight: _totalPureWeight,
        royaltyCifHiv: royaltyText,
        tra: traText,
        svl: svlText,
        amount: calculatedAmountVal,
        totalAmount: amountVal,
        tax: taxVal,
        grandTotal: amountVal,
        note: noteText,
        saleDate: widget.purchase?.saleDate,
        saleAmount: widget.purchase?.saleAmount,
        soldOut: widget.purchase?.soldOut,
        partyId: widget.purchase?.partyId,
        salePartyId: widget.purchase?.salePartyId,
        profitLossStatus: widget.purchase?.profitLossStatus,
        profitLossAmount: widget.purchase?.profitLossAmount,
        profitAmount: widget.purchase?.profitAmount,
        lossAmount: widget.purchase?.lossAmount,
      );

      if (widget.purchase != null) {
        final success =
            await _repository.updateGold(widget.purchase!.id!, purchase);
        if (success) {
          final newItems =
              _billedItems.where((item) => item.id == null).toList();
          if (newItems.isNotEmpty) {
            await _repository.createItems(widget.purchase!.id!, newItems);
          }
          if (mounted) {
            GoldDialogs.showSnackBar(context, 'Purchase updated successfully!');
            Navigator.pop(context, true);
          }
        } else {
          if (mounted) {
            GoldDialogs.showSnackBar(context, 'Failed to update purchase.',
                isError: true);
          }
        }
        return;
      }

      final purchaseId = await _repository.createGold(purchase);

      if (purchaseId != null) {
        if (_billedItems.isNotEmpty) {
          final itemsSuccess =
              await _repository.createItems(purchaseId, _billedItems);
          if (itemsSuccess) {
            GoldDialogs.showSnackBar(context, 'Purchase created successfully!');
            Navigator.pop(context, true);
          } else {
            GoldDialogs.showSnackBar(
              context,
              'Purchase created, but failed to add items.',
              isError: true,
            );
          }
        } else {
          GoldDialogs.showSnackBar(context, 'Purchase created successfully!');
          Navigator.pop(context, true);
        }
      } else {
        GoldDialogs.showSnackBar(context, 'Failed to create purchase.',
            isError: true);
      }
    } catch (e) {
      GoldDialogs.showSnackBar(context, 'Error: ${e.toString()}',
          isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtility().init(context);
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        if (_activeItemIndex != null) {
          setState(() => _activeItemIndex = null);
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            widget.purchase != null
                ? 'Edit Gold Purchase'
                : 'Add Gold Purchase',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          centerTitle: true,
          automaticallyImplyLeading: false,
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 4.w),
              child: Center(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 9.w,
                    height: 4.5.h,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      color: AppColors.textPrimary,
                      size: 20.sp,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
            if (_activeItemIndex != null) {
              setState(() => _activeItemIndex = null);
            }
          },
          behavior: HitTestBehavior.opaque,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(5.w, 2.5.h, 5.w, 2.5.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              _buildPartyDetailsCard(),
              SizedBox(height: 3.h),
              if (_billedItems.isNotEmpty) ...[
                _buildBilledItemsSection(),
                SizedBox(height: 3.h),
              ],
              _buildAddItemsButton(),
              SizedBox(height: 4.h),
              if (_billedItems.isNotEmpty) ...[
                _buildWeightSummary(),
                SizedBox(height: 3.h),
                _buildSummaryForm(),
                SizedBox(height: 3.h),
             
                _buildFinalAmountSummary(),
                SizedBox(height: 2.h),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: (_billedItems.isNotEmpty && MediaQuery.of(context).viewInsets.bottom == 0)
          ? Padding(
              padding: EdgeInsets.fromLTRB(5.w, 0, 5.w, 2.h),
              child: _buildSubmitButton(),
            )
          : null,
    ));
  }

  Widget _buildPartyDetailsCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Customer Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12.sp,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 1.5.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(4.w, 1.h, 4.w, 2.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4.r),
            border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
          ),
          child: Column(
            children: [
              _buildCustomerRow(
                label: 'Purchase Date',
                child: TextFormField(
                  readOnly: true,
                  onTap: _selectDate,
                  controller: TextEditingController(
                      text: _selectedDate.toString().split(' ')[0]),
                  style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    suffixIcon: Icon(Icons.calendar_today_outlined,
                        color: AppColors.textSecondary, size: 20.sp),
                    enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFF1F5F9))),
                    focusedBorder: const UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: AppColors.primaryBlue, width: 1.5)),
                    filled: false,
                    fillColor: Colors.transparent,
                    contentPadding: EdgeInsets.symmetric(vertical: 1.h),
                  ),
                ),
              ),
              SizedBox(height: 1.5.h),
              _buildCustomerRow(
                label: 'Customer Name',
                child: TextFormField(
                  controller: _partyNameController,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.words,
                  style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Enter name',
                    hintStyle: TextStyle(
                        color: Colors.grey.shade400, fontSize: 14.sp),
                    enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFF1F5F9))),
                    focusedBorder: const UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: AppColors.primaryBlue, width: 1.5)),
                    filled: false,
                    fillColor: Colors.transparent,
                    contentPadding: EdgeInsets.symmetric(vertical: 1.h),
                  ),
                ),
              ),
              SizedBox(height: 1.5.h),
              _buildCustomerRow(
                label: 'Ph No',
                child: TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(getPhoneNumberLengthLimit(_selectedCountry.countryCode)),
                  ],
                  style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    prefixIcon: GestureDetector(
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
                    hintText: 'Enter phone number',
                    hintStyle: TextStyle(
                        color: Colors.grey.shade400, fontSize: 14.sp),
                    errorText: _phoneErrorText,
                    errorStyle: TextStyle(fontSize: 10.sp, color: Colors.redAccent),
                    enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFF1F5F9))),
                    focusedBorder: const UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: AppColors.primaryBlue, width: 1.5)),
                    filled: false,
                    fillColor: Colors.transparent,
                    contentPadding: EdgeInsets.symmetric(vertical: 1.h),
                  ),
                ),
              ),
              SizedBox(height: 1.5.h),
              _buildCustomerRow(
                label: 'LIC No',
                child: TextFormField(
                  controller: _dlNumberController,
                  onChanged: (val) => _licenseController.text = val,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.characters,
                  style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'LIC0000',
                    hintStyle: TextStyle(
                        color: Colors.grey.shade400, fontSize: 14.sp),
                    enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFF1F5F9))),
                    focusedBorder: const UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: AppColors.primaryBlue, width: 1.5)),
                    filled: false,
                    fillColor: Colors.transparent,
                    contentPadding: EdgeInsets.symmetric(vertical: 1.h),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerRow({required String label, required Widget child}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 28.w,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        SizedBox(width: 4.w),
        Expanded(child: child),
      ],
    );
  }

  Widget _buildBilledItemsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding:
              EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 4.w),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue,
            borderRadius: BorderRadius.vertical(top: Radius.circular(2.r)),
          ),
          child: Text('Billed Items',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.sp)),
        ),
        Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            // color: AppColors.white,
            borderRadius:
                BorderRadius.vertical(bottom: Radius.circular(2.r)),
            // border: Border.all(
            //     color: AppColors.primaryBlue.withValues(alpha: 0.1)),
          ),
          child: Column(
            children: List.generate(_billedItems.length, (index) {
              final item = _billedItems[index];
              return BilledItemCard(
                index: index + 1,
                weight: item.grossWeight.toStringAsFixed(2),
                pureWeight: item.pureWeight.toStringAsFixed(2),
                side1: item.side1.toStringAsFixed(2),
                side2: item.side2.toStringAsFixed(2),
                average: item.averagePercentage.toStringAsFixed(2),
                showActions: _activeItemIndex == index,
                onTap: () {
                  if (_activeItemIndex != null) {
                    setState(() => _activeItemIndex = null);
                  } else {
                    _addItem();
                  }
                },
                onLongPress: () {
                  setState(() => _activeItemIndex = index);
                },
                onDelete: () async {
                  final confirm = await GoldDialogs.showPermissionDialog(
                    context: context,
                    title: 'Delete Item?',
                    message: 'Are you sure you want to delete this item?',
                  );
                  if (confirm == true) {
                    setState(() {
                      _billedItems.removeAt(index);
                      _activeItemIndex = null;
                    });
                  }
                },
                onEdit: () async {
                  final result = await Navigator.pushNamed(
                    context,
                    AppRoutes.addGoldItem,
                    arguments: _billedItems,
                  );
                  if (result != null && result is List<GoldBilledItem>) {
                    setState(() {
                      _billedItems = List.from(result);
                      _activeItemIndex = null;
                    });
                  }
                },
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildAddItemsButton() {
    return SizedBox(
      width: double.infinity,
      height: 6.5.h,
      child: TextButton(
        onPressed: _addItem,
        style: TextButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
        ),
        child: Text(
          '+ Add Items',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildWeightSummary() {
    return Column(
      children: [
        _buildWeightSummaryRow(
            'Total Gross Weight', _totalGrossWeight.toStringAsFixed(2)),
        SizedBox(height: 1.h),
        _buildWeightSummaryRow(
            'Total Pure Weight', _totalPureWeight.toStringAsFixed(2)),
      ],
    );
  }

  Widget _buildWeightSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 13.sp, color: AppColors.textSecondary)),
        Text(value,
            style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary)),
      ],
    );
  }

  Widget _buildSummaryForm() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
      ),
      child: Column(
        children: [
          GoldDetailInputField(
            label: 'Total Amount', 
            controller: _amountController, 
            hint: '0.00',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
          ),
          GoldDetailInputField(
            label: 'Royalty CIF / HIV',
            controller: _royaltyPercentController,
            hint: '0.00',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
          ),
          GoldDetailInputField(
            label: 'TRA', 
            controller: _traPercentController, 
            hint: '0.00',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
          ),
          GoldDetailInputField(
            label: 'SVL', 
            controller: _svlPercentController, 
            hint: '0.00',
            showBottomBorder: false,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
          ),
        ],
      ),
    );
  }

  Widget _buildFinalAmountSummary() {
    final baseAmountVal = double.tryParse(_amountController.text) ?? 0.0;
    final rP = double.tryParse(_royaltyPercentController.text) ?? 0.0;
    final tP = double.tryParse(_traPercentController.text) ?? 0.0;
    final sP = double.tryParse(_svlPercentController.text) ?? 0.0;
    final totalTaxPercent = rP + tP + sP;
    final taxVal = (baseAmountVal * totalTaxPercent) / 100;
    final calculatedAmount = baseAmountVal - taxVal;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Amount',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${calculatedAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tax',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${taxVal.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Amount',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF003366),
                  ),
                ),
                Text(
                  '${baseAmountVal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF003366),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Note: Total Amount = Tax + Amount',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Color(0xFF003366),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 7.h,
      child: _isLoading
          ? GoldShimmer(
              width: double.infinity, height: 7.h, borderRadius: 8.r)
          : ElevatedButton(
              onPressed: _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF003366),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r)),
                elevation: 0,
              ),
              child: Text(
                widget.purchase != null ? 'Update' : 'Submit',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp),
              ),
            ),
    );
  }
}
