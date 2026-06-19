import 'dart:io';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class ExcelService {
  /// Generate a professional bank statement Excel file
  static Future<String> generateBankStatementExcel({
    required String customerName,
    required Map<String, dynamic> bankInfo,
    required List<dynamic> futureTransactions,
    required List<dynamic> pastTransactions,
    String? entryPersonName,
  }) async {
    // Create Excel file
    final excel = Excel.createExcel();

    // Delete all default sheets
    final sheetNames = excel.sheets.keys.toList();
    for (final sheetName in sheetNames) {
      excel.delete(sheetName);
    }

    // Create the Bank Statement sheet
    final sheet = excel['Bank Statement'];

    // Define styles
    final titleStyle = CellStyle(
      bold: true,
      fontSize: 18,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );

    final sectionHeaderStyle = CellStyle(
      bold: true,
      fontSize: 14,
      backgroundColorHex: ExcelColor.fromHexString('D9E1F2'),
      fontColorHex: ExcelColor.fromHexString('000000'),
      horizontalAlign: HorizontalAlign.Left,
      verticalAlign: VerticalAlign.Center,
    );

    final labelStyle = CellStyle(
      bold: true,
      fontSize: 11,
      backgroundColorHex: ExcelColor.fromHexString('F2F2F2'),
      horizontalAlign: HorizontalAlign.Left,
      verticalAlign: VerticalAlign.Center,
    );

    final valueStyle = CellStyle(
      fontSize: 11,
      horizontalAlign: HorizontalAlign.Left,
      verticalAlign: VerticalAlign.Center,
    );

    final dataHeaderStyle = CellStyle(
      bold: true,
      fontSize: 11,
      backgroundColorHex: ExcelColor.fromHexString('4472C4'),
      fontColorHex: ExcelColor.fromHexString('FFFFFF'),
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );

    final dataRowStyle = CellStyle(
      fontSize: 11,
      horizontalAlign: HorizontalAlign.Left,
      verticalAlign: VerticalAlign.Center,
    );

    final amountStyle = CellStyle(
      fontSize: 11,
      horizontalAlign: HorizontalAlign.Right,
      verticalAlign: VerticalAlign.Center,
    );

    int currentRow = 0;

    // Title Row
    sheet.appendRow([
      TextCellValue('BANK STATEMENT'),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
    ]);
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow),
      CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: currentRow),
    );
    sheet
            .cell(
              CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow),
            )
            .cellStyle =
        titleStyle;
    currentRow++;

    // Empty row
    currentRow++;

    // Bank Details Section Header
    sheet.appendRow([
      TextCellValue('BANK DETAILS'),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
    ]);
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow),
      CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: currentRow),
    );
    sheet
            .cell(
              CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow),
            )
            .cellStyle =
        sectionHeaderStyle;
    currentRow++;

    // Bank Details
    _addDetailRow(
      sheet,
      currentRow,
      'Customer Name',
      customerName,
      labelStyle,
      valueStyle,
    );
    currentRow++;

    _addDetailRow(
      sheet,
      currentRow,
      'Account Number',
      bankInfo['accountNumber'] as String? ?? 'N/A',
      labelStyle,
      valueStyle,
    );
    currentRow++;

    _addDetailRow(
      sheet,
      currentRow,
      'IFSC Code',
      bankInfo['ifscCode'] as String? ?? 'N/A',
      labelStyle,
      valueStyle,
    );
    currentRow++;

    _addDetailRow(
      sheet,
      currentRow,
      'PAN Number',
      bankInfo['panNumber'] as String? ?? 'N/A',
      labelStyle,
      valueStyle,
    );
    currentRow++;

    _addDetailRow(
      sheet,
      currentRow,
      'Bank Name',
      bankInfo['bankName'] as String? ?? 'N/A',
      labelStyle,
      valueStyle,
    );
    currentRow++;

    // Empty row
    currentRow++;

    // Future Transactions Section
    if (futureTransactions.isNotEmpty) {
      sheet.appendRow([
        TextCellValue('FUTURE TRANSACTIONS'),
        TextCellValue(''),
        TextCellValue(''),
        TextCellValue(''),
        TextCellValue(''),
      ]);
      sheet.merge(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow),
        CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: currentRow),
      );
      sheet
              .cell(
                CellIndex.indexByColumnRow(
                  columnIndex: 0,
                  rowIndex: currentRow,
                ),
              )
              .cellStyle =
          sectionHeaderStyle;
      currentRow++;

      // Future Transactions Headers
      sheet.appendRow([
        TextCellValue('S.No'),
        TextCellValue('Amount'),
        TextCellValue('Payment Date'),
        TextCellValue('Entry Person'),
        TextCellValue('Status'),
      ]);
      for (int col = 0; col < 5; col++) {
        sheet
                .cell(
                  CellIndex.indexByColumnRow(
                    columnIndex: col,
                    rowIndex: currentRow,
                  ),
                )
                .cellStyle =
            dataHeaderStyle;
      }
      currentRow++;

      // Future Transactions Data
      for (int i = 0; i < futureTransactions.length; i++) {
        final transaction = futureTransactions[i] as Map<String, dynamic>;
        final amount = transaction['amountToPay'] as String? ?? '0';
        final paymentDate = transaction['paymentDate'] as String? ?? '';
        final entryPerson = entryPersonName ?? 'N/A';

        String formattedDate = '';
        if (paymentDate.isNotEmpty) {
          try {
            final date = DateTime.parse(paymentDate);
            formattedDate = DateFormat('MMM-dd-yyyy').format(date);
          } catch (e) {
            formattedDate = paymentDate;
          }
        }

        String formattedAmount = _formatAmount(amount);

        sheet.appendRow([
          IntCellValue(i + 1),
          TextCellValue(formattedAmount),
          TextCellValue(formattedDate),
          TextCellValue(entryPerson),
          TextCellValue('Pending'),
        ]);

        // Apply styles
        sheet
                .cell(
                  CellIndex.indexByColumnRow(
                    columnIndex: 0,
                    rowIndex: currentRow,
                  ),
                )
                .cellStyle =
            dataRowStyle;
        sheet
                .cell(
                  CellIndex.indexByColumnRow(
                    columnIndex: 1,
                    rowIndex: currentRow,
                  ),
                )
                .cellStyle =
            amountStyle;
        sheet
                .cell(
                  CellIndex.indexByColumnRow(
                    columnIndex: 2,
                    rowIndex: currentRow,
                  ),
                )
                .cellStyle =
            dataRowStyle;
        sheet
                .cell(
                  CellIndex.indexByColumnRow(
                    columnIndex: 3,
                    rowIndex: currentRow,
                  ),
                )
                .cellStyle =
            dataRowStyle;
        sheet
                .cell(
                  CellIndex.indexByColumnRow(
                    columnIndex: 4,
                    rowIndex: currentRow,
                  ),
                )
                .cellStyle =
            dataRowStyle;

        currentRow++;
      }

      // Empty row
      currentRow++;
    }

    // Past Transactions Section
    if (pastTransactions.isNotEmpty) {
      sheet.appendRow([
        TextCellValue('PAST TRANSACTIONS'),
        TextCellValue(''),
        TextCellValue(''),
        TextCellValue(''),
        TextCellValue(''),
      ]);
      sheet.merge(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow),
        CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: currentRow),
      );
      sheet
              .cell(
                CellIndex.indexByColumnRow(
                  columnIndex: 0,
                  rowIndex: currentRow,
                ),
              )
              .cellStyle =
          sectionHeaderStyle;
      currentRow++;

      // Past Transactions Headers
      sheet.appendRow([
        TextCellValue('S.No'),
        TextCellValue('Amount'),
        TextCellValue('Payment Date'),
        TextCellValue('Entry Person'),
        TextCellValue('Status'),
      ]);
      for (int col = 0; col < 5; col++) {
        sheet
                .cell(
                  CellIndex.indexByColumnRow(
                    columnIndex: col,
                    rowIndex: currentRow,
                  ),
                )
                .cellStyle =
            dataHeaderStyle;
      }
      currentRow++;

      // Past Transactions Data
      for (int i = 0; i < pastTransactions.length; i++) {
        final transaction = pastTransactions[i] as Map<String, dynamic>;
        final amount = transaction['amountToPay'] as String? ?? '0';
        final paymentDate = transaction['paymentDate'] as String? ?? '';
        final entryPerson = entryPersonName ?? 'N/A';

        String formattedDate = '';
        if (paymentDate.isNotEmpty) {
          try {
            final date = DateTime.parse(paymentDate);
            formattedDate = DateFormat('MMM-dd-yyyy').format(date);
          } catch (e) {
            formattedDate = paymentDate;
          }
        }

        String formattedAmount = _formatAmount(amount);

        sheet.appendRow([
          IntCellValue(i + 1),
          TextCellValue(formattedAmount),
          TextCellValue(formattedDate),
          TextCellValue(entryPerson),
          TextCellValue('Completed'),
        ]);

        // Apply styles
        sheet
                .cell(
                  CellIndex.indexByColumnRow(
                    columnIndex: 0,
                    rowIndex: currentRow,
                  ),
                )
                .cellStyle =
            dataRowStyle;
        sheet
                .cell(
                  CellIndex.indexByColumnRow(
                    columnIndex: 1,
                    rowIndex: currentRow,
                  ),
                )
                .cellStyle =
            amountStyle;
        sheet
                .cell(
                  CellIndex.indexByColumnRow(
                    columnIndex: 2,
                    rowIndex: currentRow,
                  ),
                )
                .cellStyle =
            dataRowStyle;
        sheet
                .cell(
                  CellIndex.indexByColumnRow(
                    columnIndex: 3,
                    rowIndex: currentRow,
                  ),
                )
                .cellStyle =
            dataRowStyle;
        sheet
                .cell(
                  CellIndex.indexByColumnRow(
                    columnIndex: 4,
                    rowIndex: currentRow,
                  ),
                )
                .cellStyle =
            dataRowStyle;

        currentRow++;
      }
    }

    // Set column widths
    sheet.setColumnWidth(0, 8.0); // S.No
    sheet.setColumnWidth(1, 18.0); // Amount
    sheet.setColumnWidth(2, 18.0); // Payment Date
    sheet.setColumnWidth(3, 20.0); // Entry Person
    sheet.setColumnWidth(4, 15.0); // Status

    // Save file
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final fileName =
        'Bank_Statement_${customerName.replaceAll(' ', '_')}_$timestamp.xlsx';
    final filePath = '${directory.path}/$fileName';
    final fileBytes = excel.encode();

    if (fileBytes != null) {
      final file = File(filePath);
      await file.writeAsBytes(fileBytes);
      return filePath;
    } else {
      throw Exception('Failed to encode Excel file');
    }
  }

  /// Helper method to add a detail row with label and value
  static void _addDetailRow(
    Sheet sheet,
    int row,
    String label,
    String value,
    CellStyle labelStyle,
    CellStyle valueStyle,
  ) {
    sheet.appendRow([
      TextCellValue(label),
      TextCellValue(value),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
    ]);
    sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
            .cellStyle =
        labelStyle;
    sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
            .cellStyle =
        valueStyle;
  }

  /// Format amount with currency symbol
  static String _formatAmount(String amount) {
    try {
      final value = double.parse(amount);
      return '₹${NumberFormat('#,##0.00').format(value)}';
    } catch (e) {
      return '₹$amount';
    }
  }

  /// Generate Excel file for payments filtered by date
  /// Columns: Payment Date, Amount, Account Number, IFSC Code, Customer Name
  static Future<String> generatePaymentsExcel({
    required List<Map<String, dynamic>> payments,
    required String filterDate,
  }) async {
    // Create Excel file
    final excel = Excel.createExcel();

    // Delete all default sheets
    final sheetNames = excel.sheets.keys.toList();
    for (final sheetName in sheetNames) {
      excel.delete(sheetName);
    }

    // Create the Payments sheet
    final sheet = excel['Payments'];

    // Define styles
    final titleStyle = CellStyle(
      bold: true,
      fontSize: 18,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );

    final headerStyle = CellStyle(
      bold: true,
      fontSize: 12,
      backgroundColorHex: ExcelColor.fromHexString('4472C4'),
      fontColorHex: ExcelColor.fromHexString('FFFFFF'),
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );

    final dataRowStyle = CellStyle(
      fontSize: 11,
      horizontalAlign: HorizontalAlign.Left,
      verticalAlign: VerticalAlign.Center,
    );

    final amountStyle = CellStyle(
      fontSize: 11,
      horizontalAlign: HorizontalAlign.Right,
      verticalAlign: VerticalAlign.Center,
    );

    final dateStyle = CellStyle(
      fontSize: 11,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );

    int currentRow = 0;

    // Title Row
    sheet.appendRow([
      TextCellValue('PAYMENTS REPORT'),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
    ]);
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow),
      CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: currentRow),
    );
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow))
        .cellStyle = titleStyle;
    currentRow++;

    // Filter Date Row
    sheet.appendRow([
      TextCellValue('Filter Date: $filterDate'),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
    ]);
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow),
      CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: currentRow),
    );
    currentRow++;

    // Empty row
    currentRow++;

    // Headers
    sheet.appendRow([
      TextCellValue('Payment Date'),
      TextCellValue('Amount'),
      TextCellValue('Account Number'),
      TextCellValue('IFSC Code'),
      TextCellValue('Customer Name'),
    ]);
    for (int col = 0; col < 5; col++) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: currentRow))
          .cellStyle = headerStyle;
    }
    currentRow++;

    // Data Rows
    for (final payment in payments) {
      final paymentDate = payment['paymentDate'] as String? ?? '';
      final amountToPay = payment['amountToPay'] as String? ?? '0';
      final bankInfo = payment['bankInfo'] as Map<String, dynamic>? ?? {};
      final accountNumber = bankInfo['accountNumber'] as String? ?? 'N/A';
      final ifscCode = bankInfo['ifscCode'] as String? ?? 'N/A';
      final customerName = bankInfo['customerName'] as String? ?? 'N/A';

      // Format date
      String formattedDate = '';
      if (paymentDate.isNotEmpty) {
        try {
          final date = DateTime.parse(paymentDate);
          formattedDate = DateFormat('dd-MM-yyyy').format(date);
        } catch (e) {
          formattedDate = paymentDate;
        }
      }

      // Format amount
      String formattedAmount = _formatAmount(amountToPay);

      sheet.appendRow([
        TextCellValue(formattedDate),
        TextCellValue(formattedAmount),
        TextCellValue(accountNumber),
        TextCellValue(ifscCode),
        TextCellValue(customerName),
      ]);

      // Apply styles
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow))
          .cellStyle = dateStyle;
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: currentRow))
          .cellStyle = amountStyle;
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: currentRow))
          .cellStyle = dataRowStyle;
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: currentRow))
          .cellStyle = dataRowStyle;
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: currentRow))
          .cellStyle = dataRowStyle;

      currentRow++;
    }

    // Set column widths
    sheet.setColumnWidth(0, 18.0); // Payment Date
    sheet.setColumnWidth(1, 18.0); // Amount
    sheet.setColumnWidth(2, 20.0); // Account Number
    sheet.setColumnWidth(3, 18.0); // IFSC Code
    sheet.setColumnWidth(4, 25.0); // Customer Name

    // Save file
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final fileName = 'Payments_${filterDate.replaceAll('-', '_')}_$timestamp.xlsx';
    final filePath = '${directory.path}/$fileName';
    final fileBytes = excel.encode();

    if (fileBytes != null) {
      final file = File(filePath);
      await file.writeAsBytes(fileBytes);
      return filePath;
    } else {
      throw Exception('Failed to encode Excel file');
    }
  }
}
