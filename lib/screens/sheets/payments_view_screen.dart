import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/app_theme.dart';

class PaymentsViewScreen extends StatelessWidget {
  final List<Map<String, dynamic>> payments;
  final String filterDate;

  const PaymentsViewScreen({
    super.key,
    required this.payments,
    required this.filterDate,
  });

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd-MM-yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  String _formatAmount(String amount) {
    try {
      final value = double.parse(amount);
      return '₹${NumberFormat('#,##0.00').format(value)}';
    } catch (e) {
      return '₹$amount';
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
              'Payments View',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            Text(
              'Date: $filterDate',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
      body: payments.isEmpty
          ? _buildEmptyState()
          : Column(
              children: [
                // Summary Card
                Container(
                  margin: const EdgeInsets.all(16),
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
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            '${payments.length}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Total Payments',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: AppTheme.borderColor,
                      ),
                      Column(
                        children: [
                          Text(
                            _formatAmount(
                              payments
                                  .fold<double>(
                                    0.0,
                                    (sum, payment) =>
                                        sum +
                                        (double.tryParse(
                                              payment['amountToPay']
                                                      as String? ??
                                                  '0',
                                            ) ??
                                            0.0),
                                  )
                                  .toString(),
                            ),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Total Amount',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Excel-like Table View
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(16),
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
                    child: _buildExcelTable(),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildExcelTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Table Header
            _buildTableHeader(),
            // Table Rows
            ...payments.asMap().entries.map((entry) {
              final index = entry.key;
              final payment = entry.value;
              return _buildTableRow(payment, index + 1);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF4472C4), // Excel-like blue header
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          _buildHeaderCell('S.No', 60),
          _buildHeaderCell('Payment Date', 120),
          _buildHeaderCell('Amount', 120),
          _buildHeaderCell('Account Number', 150),
          _buildHeaderCell('IFSC Code', 120),
          _buildHeaderCell('Customer Name', 180),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.white.withOpacity(0.3), width: 1),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTableRow(Map<String, dynamic> payment, int index) {
    final paymentDate = payment['paymentDate'] as String? ?? '';
    final amountToPay = payment['amountToPay'] as String? ?? '0';
    final bankInfo = payment['bankInfo'] as Map<String, dynamic>? ?? {};
    final accountNumber = bankInfo['accountNumber'] as String? ?? 'N/A';
    final ifscCode = bankInfo['ifscCode'] as String? ?? 'N/A';
    final customerName = bankInfo['customerName'] as String? ?? 'N/A';

    final isEven = index % 2 == 0;
    final backgroundColor = isEven ? Colors.white : const Color(0xFFF2F2F2);

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      child: Row(
        children: [
          _buildDataCell(index.toString(), 60, TextAlign.center),
          _buildDataCell(_formatDate(paymentDate), 120, TextAlign.center),
          _buildDataCell(
            _formatAmount(amountToPay),
            120,
            TextAlign.right,
            textColor: const Color(0xFF2E7D32),
            isBold: true,
          ),
          _buildDataCell(accountNumber, 150, TextAlign.left),
          _buildDataCell(ifscCode, 120, TextAlign.center),
          _buildDataCell(customerName, 180, TextAlign.left),
        ],
      ),
    );
  }

  Widget _buildDataCell(
    String text,
    double width,
    TextAlign align, {
    Color? textColor,
    bool isBold = false,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
          color: textColor ?? Colors.black87,
        ),
        textAlign: align,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.payment_outlined, size: 64, color: AppTheme.textSecondary),
          const SizedBox(height: 16),
          Text(
            'No payments found',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Date: $filterDate',
            style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}
