import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:share_plus/share_plus.dart';
import 'package:open_filex/open_filex.dart';
import 'dart:io';
import '../../utils/app_theme.dart';
import '../../services/excel_service.dart';
import 'sheets_provider/sheets_provider.dart';
import 'month_tab.dart';
import 'date_range_tab.dart';
import 'payments_view_screen.dart';

class SheetsScreen extends StatefulWidget {
  const SheetsScreen({super.key});

  @override
  State<SheetsScreen> createState() => SheetsScreenState();
}

class SheetsScreenState extends State<SheetsScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  late SheetsProvider _provider;
  bool _isMonthFilter = true;
  DateTime? _lastRefreshTime;
  static const _refreshInterval = Duration(
    seconds: 30,
  ); // Refresh if more than 30 seconds passed

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _provider = SheetsProvider();
    _tabController.addListener(() {
      setState(() {
        _isMonthFilter = _tabController.index == 0;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _provider.dispose();
    super.dispose();
  }

  // Public method to refresh data when tab becomes visible
  void refreshDataIfNeeded() {
    print('🔄 [SHEETS TAB] Tab clicked - Checking if refresh is needed...');
    final now = DateTime.now();
    // Refresh if never refreshed or if more than refresh interval has passed
    if (_lastRefreshTime == null ||
        now.difference(_lastRefreshTime!) > _refreshInterval) {
      _lastRefreshTime = now;
      print('✅ [SHEETS TAB] Triggering API refresh...');
      // First fetch all data
      _provider.fetchAll();
    } else {
      final timeSinceLastRefresh = now.difference(_lastRefreshTime!);
      print(
        '⏸️ [SHEETS TAB] Skipping refresh - Only ${timeSinceLastRefresh.inSeconds}s since last refresh (cooldown: ${_refreshInterval.inSeconds}s)',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    // Refresh data when screen becomes visible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      refreshDataIfNeeded();
    });

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      body: Column(
        children: [
          // Header
          SizedBox(height: MediaQuery.of(context).padding.top),
          _buildHeader(),
          // Filter Buttons (Tabs)
          _buildFilterButtons(),
          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                MonthTab(provider: _provider),
                DateRangeTab(provider: _provider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sheets',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Extracted information',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onDownloadExcel() async {
    if (_provider.records.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No payments to download'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryBlue),
        ),
      );

      // Group payments by paymentDate
      Map<String, List<Map<String, dynamic>>> paymentsByDate = {};
      for (var record in _provider.records) {
        final paymentDate = record['paymentDate'] as String?;
        if (paymentDate != null && paymentDate.isNotEmpty) {
          try {
            // Extract date part (YYYY-MM-DD) from ISO format
            final date = DateTime.parse(paymentDate);
            final dateKey = DateFormat('yyyy-MM-dd').format(date);
            paymentsByDate.putIfAbsent(dateKey, () => []).add(record);
          } catch (e) {
            // Skip invalid dates
          }
        }
      }

      // If we have payments grouped by date, download all of them
      // Otherwise use all records
      List<Map<String, dynamic>> paymentsToDownload = _provider.records;
      String filterDate = DateFormat('dd-MM-yyyy').format(DateTime.now());

      if (paymentsByDate.isNotEmpty) {
        // Get all unique dates
        final dates = paymentsByDate.keys.toList()..sort();
        if (dates.length == 1) {
          // Single date - use that date
          filterDate = DateFormat(
            'dd-MM-yyyy',
          ).format(DateTime.parse(dates.first));
          paymentsToDownload = paymentsByDate[dates.first]!;
        } else {
          // Multiple dates - use date range
          final startDate = DateTime.parse(dates.first);
          final endDate = DateTime.parse(dates.last);
          filterDate =
              '${DateFormat('dd-MM-yyyy').format(startDate)} to ${DateFormat('dd-MM-yyyy').format(endDate)}';
          paymentsToDownload = _provider.records;
        }
      } else if (_provider.records.isNotEmpty) {
        // Fallback: use first record's date
        final firstRecord = _provider.records.first;
        final paymentDate = firstRecord['paymentDate'] as String?;
        if (paymentDate != null && paymentDate.isNotEmpty) {
          try {
            final date = DateTime.parse(paymentDate);
            filterDate = DateFormat('dd-MM-yyyy').format(date);
          } catch (e) {
            // Use current date if parsing fails
          }
        }
      }

      // Generate Excel file
      final filePath = await ExcelService.generatePaymentsExcel(
        payments: paymentsToDownload,
        filterDate: filterDate,
      );

      // Close loading dialog
      if (mounted) {
        Navigator.pop(context);
      }

      // Get file name from path
      final fileName = path.basename(filePath);

      // Show success message and share/open file
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Excel file saved: $fileName'),
            backgroundColor: AppTheme.primaryBlue,
            action: SnackBarAction(
              label: 'Open',
              textColor: Colors.white,
              onPressed: () async {
                await OpenFilex.open(filePath);
              },
            ),
          ),
        );

        // Share the file
        await Share.shareXFiles([
          XFile(filePath),
        ], text: 'Payments Report - $filterDate');
      }
    } catch (e) {
      // Close loading dialog if still open
      if (mounted) {
        Navigator.pop(context);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating Excel: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
      print('Error generating Excel: $e');
    }
  }

  void _onViewPayments() {
    if (_provider.records.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No payments to view'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    // Group payments by paymentDate to determine filter date
    Map<String, List<Map<String, dynamic>>> paymentsByDate = {};
    for (var record in _provider.records) {
      final paymentDate = record['paymentDate'] as String?;
      if (paymentDate != null && paymentDate.isNotEmpty) {
        try {
          final date = DateTime.parse(paymentDate);
          final dateKey = DateFormat('yyyy-MM-dd').format(date);
          paymentsByDate.putIfAbsent(dateKey, () => []).add(record);
        } catch (e) {
          // Skip invalid dates
        }
      }
    }

    String filterDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
    if (paymentsByDate.isNotEmpty) {
      final dates = paymentsByDate.keys.toList()..sort();
      if (dates.length == 1) {
        filterDate = DateFormat(
          'dd-MM-yyyy',
        ).format(DateTime.parse(dates.first));
      } else {
        final startDate = DateTime.parse(dates.first);
        final endDate = DateTime.parse(dates.last);
        filterDate =
            '${DateFormat('dd-MM-yyyy').format(startDate)} to ${DateFormat('dd-MM-yyyy').format(endDate)}';
      }
    } else if (_provider.records.isNotEmpty) {
      final firstRecord = _provider.records.first;
      final paymentDate = firstRecord['paymentDate'] as String?;
      if (paymentDate != null && paymentDate.isNotEmpty) {
        try {
          final date = DateTime.parse(paymentDate);
          filterDate = DateFormat('dd-MM-yyyy').format(date);
        } catch (e) {
          // Use current date if parsing fails
        }
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentsViewScreen(
          payments: _provider.records,
          filterDate: filterDate,
        ),
      ),
    );
  }

  Widget _buildFilterButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildFilterButton(
              label: 'Month',
              isSelected: _isMonthFilter,
              onTap: () {
                _tabController.animateTo(0);
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildFilterButton(
              label: 'Date Range',
              isSelected: !_isMonthFilter,
              onTap: () {
                _tabController.animateTo(1);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today,
              size: 18,
              color: isSelected ? Colors.white : AppTheme.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
