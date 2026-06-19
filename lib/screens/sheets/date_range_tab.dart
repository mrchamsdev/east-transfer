import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:share_plus/share_plus.dart';
import 'package:open_filex/open_filex.dart';
import '../../utils/app_theme.dart';
import '../../widgets/bank_loader.dart';
import '../../services/excel_service.dart';
import 'sheets_provider/sheets_provider.dart';
import 'payments_view_screen.dart';

class DateRangeTab extends StatefulWidget {
  final SheetsProvider provider;
  
  const DateRangeTab({super.key, required this.provider});

  @override
  State<DateRangeTab> createState() => _DateRangeTabState();
}

class _DateRangeTabState extends State<DateRangeTab> {
  DateTime? _startDate;
  DateTime? _endDate;

  String _formatDate(DateTime date) {
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

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) {
      setState(() {
        _startDate = picked;
        if (_endDate != null && _startDate!.isAfter(_endDate!)) {
          _endDate = null;
        }
      });
      _loadSheets();
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) {
      setState(() {
        _endDate = picked;
      });
      _loadSheets();
    }
  }

  @override
  void initState() {
    super.initState();
    // First ensure all data is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.provider.records.isEmpty && !widget.provider.isLoading) {
        await widget.provider.fetchAll();
      }
    });
  }

  void _loadSheets() {
    if (_startDate == null || _endDate == null) return;

    // Filter existing data by date range
    widget.provider.fetchByDateRange(
      startDate: _formatDateForApi(_startDate!),
      endDate: _formatDateForApi(_endDate!),
    );
  }

  String _getRecordDate(Map<String, dynamic> record) {
    // Prioritize paymentDate field (as per API response structure)
    dynamic dateValue = record['paymentDate'] ?? 
                       record['date'] ?? 
                       record['createdAt'] ?? 
                       record['createdDate'] ??
                       '';
    
    if (dateValue == null || dateValue.toString().isEmpty || dateValue.toString() == 'null') {
      return '';
    }
    
    try {
      // Try to parse as DateTime if it's a string
      DateTime? dateTime;
      if (dateValue is String) {
        String dateStr = dateValue.trim();
        // Try different date formats
        try {
          // Try ISO format first (2025-12-03T00:00:00.000Z)
          // DateTime.parse handles ISO 8601 format including 'Z' suffix
          dateTime = DateTime.parse(dateStr);
        } catch (e) {
          // Try other formats
          try {
            // Try YYYY-MM-DD format (split by space or T to get date part)
            final parts = dateStr.split(RegExp(r'[T\s]'));
            if (parts.isNotEmpty && parts[0].isNotEmpty) {
              dateTime = DateTime.parse(parts[0]);
            }
          } catch (e2) {
            // If parsing fails, return the original string
            return dateStr;
          }
        }
      } else if (dateValue is DateTime) {
        dateTime = dateValue;
      }
      
      if (dateTime != null) {
        return _formatDate(dateTime);
      }
    } catch (e) {
      // If all parsing fails, return the original value
      return dateValue.toString();
    }
    
    return dateValue.toString();
  }

  String _getRecordInitial(Map<String, dynamic> record) {
    final initial = record['iconInitial']?.toString();
    if (initial != null && initial.isNotEmpty) {
      return initial.toUpperCase();
    }
    // Try to get customer name from bankInfo
    final bankInfo = record['bankInfo'] as Map<String, dynamic>?;
    if (bankInfo != null) {
      final customerName = bankInfo['customerName']?.toString();
      if (customerName != null && customerName.isNotEmpty) {
        return customerName[0].toUpperCase();
      }
    }
    // Fallback to direct customerName
    final customerName = record['customerName']?.toString();
    if (customerName != null && customerName.isNotEmpty) {
      return customerName[0].toUpperCase();
    }
    return 'H';
  }

  Future<void> _onDownloadPayment(List<Map<String, dynamic>> payments, String date) async {
    if (payments.isEmpty) {
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

      // Generate Excel file
      final filePath = await ExcelService.generatePaymentsExcel(
        payments: payments,
        filterDate: date,
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
        ], text: 'Payments Report - $date');
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

  void _onViewPayment(List<Map<String, dynamic>> payments, String date) {
    if (payments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No payments to view'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentsViewScreen(
          payments: payments,
          filterDate: date,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.provider,
      builder: (context, child) {
        return Column(
          children: [
            // Date Range Inputs
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: _buildDateInput(
                      label: 'Start Date',
                      date: _startDate,
                      onTap: _selectStartDate,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDateInput(
                      label: 'End Date',
                      date: _endDate,
                      onTap: _selectEndDate,
                    ),
                  ),
                ],
              ),
            ),
            // Records List
            Expanded(
              child: widget.provider.isLoading
                  ? const Center(child: RefreshLoader(color: AppTheme.primaryBlue))
                  : widget.provider.records.isEmpty
                      ? _buildEmptyState()
                      : _buildRecordsList(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDateInput({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    date != null ? _formatDate(date) : 'dd-mm-yyyy',
                    style: TextStyle(
                      fontSize: 14,
                      color: date != null ? Colors.black : AppTheme.textHint,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  size: 18,
                  color: AppTheme.primaryBlue,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordsList() {
    // Get payments grouped by date
    final paymentsByDate = widget.provider.paymentsByDate;
    
    if (paymentsByDate.isEmpty) {
      return _buildEmptyState();
    }

    // Sort dates in descending order (newest first)
    final sortedDates = paymentsByDate.keys.toList()
      ..sort((a, b) {
        try {
          // Parse dates in format "dd-MM-yyyy"
          final partsA = a.split('-');
          final partsB = b.split('-');
          if (partsA.length == 3 && partsB.length == 3) {
            final dateA = DateTime(
              int.parse(partsA[2]),
              int.parse(partsA[1]),
              int.parse(partsA[0]),
            );
            final dateB = DateTime(
              int.parse(partsB[2]),
              int.parse(partsB[1]),
              int.parse(partsB[0]),
            );
            return dateB.compareTo(dateA);
          }
        } catch (e) {
          // If parsing fails, use string comparison
        }
        return b.compareTo(a);
      });

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final payments = paymentsByDate[date] ?? [];
        return _buildDateSection(date, payments);
      },
    );
  }

  Widget _buildDateSection(String date, List<Map<String, dynamic>> payments) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date Header (without view/download icons)
        Container(
          margin: const EdgeInsets.only(bottom: 8, top: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    date.split('-')[0], // Day number
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${payments.length} payment${payments.length != 1 ? 's' : ''}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // View and Download icons
              _buildActionIcon(
                icon: Icons.visibility,
                onTap: () => _onViewPayment(payments, date),
              ),
              const SizedBox(width: 8),
              _buildActionIcon(
                icon: Icons.download,
                onTap: () => _onDownloadPayment(payments, date),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionIcon({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, size: 20, color: AppTheme.textSecondary),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: 64,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'No records found',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

