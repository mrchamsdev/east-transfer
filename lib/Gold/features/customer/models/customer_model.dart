import '../../gold/models/gold_purchase_model.dart';

class CustomerPaymentUpdate {
  final int? id;
  final int personId;
  final int loanId;
  final String paymentDate;
  final double interestAmount;
  final double principalAmount;
  final double? remainingBalance;
  final String paymentType;
  final String? referenceNumber;
  final String? file;
  final String? note;

  CustomerPaymentUpdate({
    this.id,
    required this.personId,
    required this.loanId,
    required this.paymentDate,
    required this.interestAmount,
    required this.principalAmount,
    this.remainingBalance,
    required this.paymentType,
    this.referenceNumber,
    this.file,
    this.note,
  });

  factory CustomerPaymentUpdate.fromJson(Map<String, dynamic> json) {
    return CustomerPaymentUpdate(
      id: json['id'],
      personId: json['personId'] ?? 0,
      loanId: json['loanId'] ?? 0,
      paymentDate: json['paymentDate'] ?? '',
      interestAmount: _toDouble(json['interestAmount']) ?? 0.0,
      principalAmount: _toDouble(json['principalAmount']) ?? 0.0,
      remainingBalance: _toDouble(json['remainingBalance']),
      paymentType: json['paymentTYpe'] ?? json['paymentType'] ?? '',
      referenceNumber: json['referenceNUmber'] ?? json['referenceNumber'],
      file: json['file'],
      note: json['note'],
    );
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}

class CustomerLoan {
  final int id;
  final int personId;
  final String loanPeriodType;
  final int loanPeriod;
  final String loanDate;
  final double principalAmount;
  final double interestRate;
  final String interestPaymentPeriodType;
  final int interestPaymentPeriod;
  final String? agreementImage;
  final double totalPaidAmount;
  final double pendingAmount;
  final String status;
  final String note;

  CustomerLoan({
    required this.id,
    required this.personId,
    required this.loanPeriodType,
    required this.loanPeriod,
    required this.loanDate,
    required this.principalAmount,
    required this.interestRate,
    required this.interestPaymentPeriodType,
    required this.interestPaymentPeriod,
    this.agreementImage,
    required this.totalPaidAmount,
    required this.pendingAmount,
    required this.status,
    required this.note,
  });

  factory CustomerLoan.fromJson(Map<String, dynamic> json) {
    return CustomerLoan(
      id: json['id'] ?? 0,
      personId: json['personId'] ?? 0,
      loanPeriodType: json['loanPeriodType'] ?? '',
      loanPeriod: json['loanPeriod'] ?? 0,
      loanDate: json['loanDate'] ?? '',
      principalAmount: _toDouble(json['principalAmount']) ?? 0.0,
      interestRate: _toDouble(json['interestRate']) ?? 0.0,
      interestPaymentPeriodType: json['interestPaymentPeriodType'] ?? '',
      interestPaymentPeriod: json['interestPaymentPeriod'] ?? 0,
      agreementImage: json['agreementImage'],
      totalPaidAmount: _toDouble(json['totalPaidAmount']) ?? 0.0,
      pendingAmount: _toDouble(json['pendingAmount']) ?? 0.0,
      status: json['status'] ?? '',
      note: json['note'] ?? '',
    );
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}

class Customer {
  final int? id;
  final String name;
  final String phoneNumber;
  final int? createdBy;
  final String? createdByName;
  final String? createdAt;

  // Stats / Bento Box Summaries
  final double? totalPurchase;
  final int? purchaseTransactionsCount;
  final double? totalSell;
  final int? sellTransactionsCount;
  final double? totalDue;
  final int? duePaymentsCount;

  // Sell History Headers
  final double? totalGoldSellWeight;
  final int? goldSellTransactionsCount;
  final double? totalReceivedAmount;
  final String? lastSellDate;

  // History Lists
  final List<GoldPurchase> purchaseHistory;
  final List<GoldPurchase> sellHistory;
  final List<CustomerLoan> loans;
  final List<CustomerPaymentUpdate> paymentUpdates;

  Customer({
    this.id,
    required this.name,
    required this.phoneNumber,
    this.createdBy,
    this.createdByName,
    this.createdAt,
    this.totalPurchase,
    this.purchaseTransactionsCount,
    this.totalSell,
    this.sellTransactionsCount,
    this.totalDue,
    this.duePaymentsCount,
    this.totalGoldSellWeight,
    this.goldSellTransactionsCount,
    this.totalReceivedAmount,
    this.lastSellDate,
    this.purchaseHistory = const [],
    this.sellHistory = const [],
    this.loans = const [],
    this.paymentUpdates = const [],
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    // Parse name: match "customerName" first as returned by the API
    final parsedName = json['customerName'] ?? json['name'] ?? json['partyName'] ?? '';
    final parsedPhone = json['phoneNumber'] ?? json['partyPhoneNumber'] ?? '';

    // Parse purchaseHistory list from either "purchases" or "purchaseHistory"
    final List<GoldPurchase> purchases = [];
    final rawPurchases = json['purchases'] ?? json['purchaseHistory'];
    if (rawPurchases != null && rawPurchases is List) {
      for (final item in rawPurchases) {
        purchases.add(GoldPurchase.fromJson(Map<String, dynamic>.from(item)));
      }
    }

    // Parse sellHistory list from either "sales" or "sellHistory"
    final List<GoldPurchase> sales = [];
    final rawSales = json['sales'] ?? json['sellHistory'];
    if (rawSales != null && rawSales is List) {
      for (final item in rawSales) {
        sales.add(GoldPurchase.fromJson(Map<String, dynamic>.from(item)));
      }
    }

    // Parse loans list from "loans"
    final List<CustomerLoan> parsedLoans = [];
    final rawLoans = json['loans'];
    if (rawLoans != null && rawLoans is List) {
      for (final item in rawLoans) {
        parsedLoans.add(CustomerLoan.fromJson(Map<String, dynamic>.from(item)));
      }
    }

    // Parse paymentUpdates list from "paymentUpdates"
    final List<CustomerPaymentUpdate> parsedPaymentUpdates = [];
    final rawPayments = json['paymentUpdates'];
    if (rawPayments != null && rawPayments is List) {
      for (final item in rawPayments) {
        parsedPaymentUpdates.add(CustomerPaymentUpdate.fromJson(Map<String, dynamic>.from(item)));
      }
    }

    // If stats are not returned by the backend, dynamically compute them from history
    double computedPurchase = 0.0;
    for (final p in purchases) {
      computedPurchase += p.grandTotal ?? p.totalAmount ?? p.amount ?? 0.0;
    }

    double computedSell = 0.0;
    for (final s in sales) {
      computedSell += s.saleAmount ?? 0.0;
    }

    double computedDue = computedPurchase - computedSell;
    if (computedDue < 0) computedDue = 0.0;

    double computedGoldSellWeight = 0.0;
    for (final s in sales) {
      computedGoldSellWeight += s.totalGrossWeight ?? 0.0;
    }

    // Map stats from backend keys
    final double? totalPurchaseVal = _toDouble(json['totalPurchaseAmount']) ?? _toDouble(json['totalPurchase']);
    final int? purchaseCountVal = json['totalPurchaseCount'] ?? json['purchaseTransactionsCount'];
    
    final double? totalSaleVal = _toDouble(json['totalSaleAmount']) ?? _toDouble(json['totalSell']);
    final int? saleCountVal = json['totalSaleCount'] ?? json['sellTransactionsCount'];

    final double? totalDueVal = _toDouble(json['totalLoanDue']) ?? _toDouble(json['totalDue']);
    final int? dueCountVal = json['totalLoanCount'] ?? json['duePaymentsCount'];

    return Customer(
      id: json['id'],
      name: parsedName,
      phoneNumber: parsedPhone,
      createdBy: json['createdBy'],
      createdByName: json['createdByName'] ?? json['createdByUserName'],
      createdAt: json['createdDate'] ?? json['createdAt'] ?? json['purchaseDate'],
      totalPurchase: totalPurchaseVal ?? computedPurchase,
      purchaseTransactionsCount: purchaseCountVal ?? purchases.length,
      totalSell: totalSaleVal ?? computedSell,
      sellTransactionsCount: saleCountVal ?? sales.length,
      totalDue: totalDueVal ?? computedDue,
      duePaymentsCount: dueCountVal ?? (computedDue > 0 ? 1 : 0),
      totalGoldSellWeight: _toDouble(json['totalGoldSellWeight']) ?? computedGoldSellWeight,
      goldSellTransactionsCount: json['goldSellTransactionsCount'] ?? sales.length,
      totalReceivedAmount: _toDouble(json['totalReceivedAmount']) ?? computedSell,
      lastSellDate: json['lastSellDate'] ?? (sales.isNotEmpty ? sales.first.saleDate : null),
      purchaseHistory: purchases,
      sellHistory: sales,
      loans: parsedLoans,
      paymentUpdates: parsedPaymentUpdates,
    );
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
