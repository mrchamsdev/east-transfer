import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../services/network_service.dart';

class SheetsProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _allRecords = [];
  List<Map<String, dynamic>> _records = [];
  Map<String, List<Map<String, dynamic>>> _paymentsByDate = {};
  bool _isLoading = false;
  String? _errorMessage;
  String? _currentFilterType;
  int? _filterMonth;
  int? _filterYear;
  String? _filterStartDate;
  String? _filterEndDate;

  List<Map<String, dynamic>> get records => _records;
  Map<String, List<Map<String, dynamic>>> get paymentsByDate => _paymentsByDate;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Fetch all payment data without filters
  /// URL: /api/bank/payments/all
  Future<void> fetchAll() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final url = '${dotenv.env['API_URL']}bank/payments/all';
      print('📋 [SHEETS API] ==========================================');
      print('📋 [SHEETS API] Fetching all data');
      print('🌐 [SHEETS API] URL: $url');

      var response = await ServiceWithHeader(url).data();
      final statusCode = response[0] as int;
      final responseData = response[1];

      print('📥 [SHEETS API] Response Status: $statusCode');
      print('📄 [SHEETS API] Response Data: $responseData');
      print('📋 [SHEETS API] ==========================================');

      if (statusCode == 200 && responseData != null) {
        if (responseData is Map &&
            responseData.containsKey('status') &&
            responseData['status'] == 'error') {
          _allRecords = [];
          _records = [];
          _paymentsByDate = {};
          _errorMessage = null;
        } else {
          // Check if response has paymentsByDate structure
          if (responseData is Map && responseData.containsKey('paymentsByDate')) {
            final paymentsByDateData = responseData['paymentsByDate'] as Map<String, dynamic>? ?? {};
            _paymentsByDate = {};
            _allRecords = [];
            
            // Convert paymentsByDate to flat list and store grouped data
            paymentsByDateData.forEach((dateKey, paymentsList) {
              if (paymentsList is List) {
                final payments = paymentsList
                    .map((json) => json as Map<String, dynamic>)
                    .toList();
                _paymentsByDate[dateKey] = payments;
                _allRecords.addAll(payments);
              }
            });
          } else {
            // Handle old format
            List<dynamic> dataList = [];
            if (responseData is List) {
              dataList = responseData;
            } else if (responseData is Map &&
                responseData.containsKey('payments')) {
              dataList = responseData['payments'] as List? ?? [];
            } else if (responseData is Map && responseData.containsKey('data')) {
              dataList = responseData['data'] as List;
            } else if (responseData is Map) {
              dataList = [responseData];
            }

            _allRecords = dataList
                .map((json) => json as Map<String, dynamic>)
                .toList();
            
            // Group by date for old format
            _paymentsByDate = {};
            for (var record in _allRecords) {
              final paymentDate = record['paymentDate'] as String?;
              if (paymentDate != null && paymentDate.isNotEmpty) {
                try {
                  final date = DateTime.parse(paymentDate);
                  final day = date.day.toString().padLeft(2, '0');
                  final month = date.month.toString().padLeft(2, '0');
                  final year = date.year.toString();
                  final dateKey = '$day-$month-$year';
                  _paymentsByDate.putIfAbsent(dateKey, () => []).add(record);
                } catch (e) {
                  // Skip invalid dates
                }
              }
            }
          }

          // Initially show all records
          _records = List.from(_allRecords);
          _currentFilterType = 'all';
          _errorMessage = null;
        }
      } else if (statusCode == 404) {
        _allRecords = [];
        _records = [];
        _errorMessage = null;
      } else {
        throw Exception('Failed to fetch sheets: Status $statusCode');
      }
    } catch (e) {
      _errorMessage = e.toString();
      _allRecords = [];
      _records = [];
      print('Error fetching all data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchByDateRange({
    required String startDate,
    required String endDate,
  }) async {
    // Filter existing data by date range
    _filterStartDate = startDate;
    _filterEndDate = endDate;
    _currentFilterType = 'dateRange';
    _filterMonth = null;
    _filterYear = null;

    _applyDateRangeFilter(startDate, endDate);
    notifyListeners();
  }

  void _applyDateRangeFilter(String startDate, String endDate) {
    try {
      final start = DateTime.parse(startDate);
      final end = DateTime.parse(endDate);
      // Normalize to start of day for comparison
      final startOfDay = DateTime(start.year, start.month, start.day);
      final endOfDay = DateTime(end.year, end.month, end.day);

      _records = _allRecords.where((record) {
        final recordDate = _getRecordDateTime(record);
        if (recordDate == null) return false;

        // Normalize record date to start of day
        final recordDay = DateTime(
          recordDate.year,
          recordDate.month,
          recordDate.day,
        );

        // Check if record date is within range (inclusive)
        return recordDay.isAtSameMomentAs(startOfDay) ||
            recordDay.isAtSameMomentAs(endOfDay) ||
            (recordDay.isAfter(startOfDay) && recordDay.isBefore(endOfDay));
      }).toList();
      
      // Update paymentsByDate for filtered records
      _paymentsByDate = {};
      for (var record in _records) {
        final paymentDate = record['paymentDate'] as String?;
        if (paymentDate != null && paymentDate.isNotEmpty) {
          try {
            final date = DateTime.parse(paymentDate);
            final day = date.day.toString().padLeft(2, '0');
            final month = date.month.toString().padLeft(2, '0');
            final year = date.year.toString();
            final dateKey = '$day-$month-$year';
            _paymentsByDate.putIfAbsent(dateKey, () => []).add(record);
          } catch (e) {
            // Skip invalid dates
          }
        }
      }
    } catch (e) {
      print('Error filtering by date range: $e');
      _records = [];
      _paymentsByDate = {};
    }
  }

  DateTime? _getRecordDateTime(Map<String, dynamic> record) {
    dynamic dateValue =
        record['paymentDate'] ??
        record['date'] ??
        record['createdAt'] ??
        record['createdDate'];

    if (dateValue == null ||
        dateValue.toString().isEmpty ||
        dateValue.toString() == 'null') {
      return null;
    }

    try {
      if (dateValue is String) {
        String dateStr = dateValue.trim();
        try {
          return DateTime.parse(dateStr);
        } catch (e) {
          final parts = dateStr.split(RegExp(r'[T\s]'));
          if (parts.isNotEmpty && parts[0].isNotEmpty) {
            return DateTime.parse(parts[0]);
          }
        }
      } else if (dateValue is DateTime) {
        return dateValue;
      }
    } catch (e) {
      return null;
    }

    return null;
  }

  void fetchByMonth({required int month, required int year}) {
    // Filter existing data by month
    _filterMonth = month;
    _filterYear = year;
    _currentFilterType = 'month';
    _filterStartDate = null;
    _filterEndDate = null;

    _applyMonthFilter(month, year);
    notifyListeners();
  }

  void _applyMonthFilter(int month, int year) {
    _records = _allRecords.where((record) {
      final recordDate = _getRecordDateTime(record);
      if (recordDate == null) return false;

      return recordDate.month == month && recordDate.year == year;
    }).toList();
    
    // Update paymentsByDate for filtered records
    _paymentsByDate = {};
    for (var record in _records) {
      final paymentDate = record['paymentDate'] as String?;
      if (paymentDate != null && paymentDate.isNotEmpty) {
        try {
          final date = DateTime.parse(paymentDate);
          final day = date.day.toString().padLeft(2, '0');
          final month = date.month.toString().padLeft(2, '0');
          final year = date.year.toString();
          final dateKey = '$day-$month-$year';
          _paymentsByDate.putIfAbsent(dateKey, () => []).add(record);
        } catch (e) {
          // Skip invalid dates
        }
      }
    }
  }

  /// Clear filter and show all records
  void clearFilter() {
    _currentFilterType = 'all';
    _filterMonth = null;
    _filterYear = null;
    _filterStartDate = null;
    _filterEndDate = null;
    _records = List.from(_allRecords);
    notifyListeners();
  }

  void clearRecords() {
    _allRecords = [];
    _records = [];
    _paymentsByDate = {};
    _errorMessage = null;
    _currentFilterType = null;
    _filterMonth = null;
    _filterYear = null;
    _filterStartDate = null;
    _filterEndDate = null;
    notifyListeners();
  }
}
