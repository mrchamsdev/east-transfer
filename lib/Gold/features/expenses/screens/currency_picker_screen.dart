import 'package:flutter/material.dart';
import 'package:currency_picker/currency_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class CurrencyPickerScreen extends StatefulWidget {
  const CurrencyPickerScreen({super.key});

  @override
  State<CurrencyPickerScreen> createState() => _CurrencyPickerScreenState();
}

class _CurrencyPickerScreenState extends State<CurrencyPickerScreen> {
  final CurrencyService _currencyService = CurrencyService();
  late List<Currency> _allCurrencies;
  List<Currency> _filteredCurrencies = [];
  final List<Currency> _recentCurrencies = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _allCurrencies = _currencyService.getAll();
    _filteredCurrencies = _allCurrencies;

    // Prefill some popular / recent currencies
    final usd = _currencyService.findByCode('USD');
    final eur = _currencyService.findByCode('EUR');
    final inr = _currencyService.findByCode('INR');
    final gbp = _currencyService.findByCode('GBP');

    if (inr != null) _recentCurrencies.add(inr);
    if (usd != null) _recentCurrencies.add(usd);
    if (eur != null) _recentCurrencies.add(eur);
    if (gbp != null) _recentCurrencies.add(gbp);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCurrencies(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredCurrencies = _allCurrencies;
      });
      return;
    }

    final lowerQuery = query.toLowerCase();
    setState(() {
      _filteredCurrencies = _allCurrencies.where((currency) {
        final code = currency.code.toLowerCase();
        final name = currency.name.toLowerCase();
        return code.contains(lowerQuery) || name.contains(lowerQuery);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Column(
            children: [
              // Top Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: AppColors.primaryBlue,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Currency',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    // Invisible spacer to balance the "Cancel" button on the left
                    const Opacity(
                      opacity: 0,
                      child: Text(
                        'Cancel',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F2F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterCurrencies,
                    decoration: const InputDecoration(
                      hintText: 'Search',
                      hintStyle: AppTextStyles.searchHint,
                      prefixIcon: Icon(Icons.search, color: AppColors.textSecondary, size: 20),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),

              const Divider(color: AppColors.divider, height: 1),

              // Currency List
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    if (_searchController.text.isEmpty && _recentCurrencies.isNotEmpty) ...[
                      const Text(
                        'Recent',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._recentCurrencies.map((currency) => _buildCurrencyTile(currency)),
                      const SizedBox(height: 16),
                    ],

                    const Text(
                      'All',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._filteredCurrencies.map((currency) => _buildCurrencyTile(currency)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrencyTile(Currency currency) {
    return GestureDetector(
      onTap: () => Navigator.pop(context, currency),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14.0),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.divider, width: 0.5)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '${currency.name} (${currency.code})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Text(
              currency.code,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFFBBBBBB),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
