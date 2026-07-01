class LoanRecord {
  final String month;
  final List<LoanPersonRecord> persons;

  LoanRecord({required this.month, required this.persons});

  factory LoanRecord.fromJson(Map<String, dynamic> json) => LoanRecord(
        month: json['month'] ?? '',
        persons: (json['persons'] as List?)?.map((e) => LoanPersonRecord.fromJson(e)).toList() ?? [],
      );
}

class LoanPersonRecord {
  final int personId;
  final String name;
  final num totalPrincipal;
  final num totalInterest;
  final num totalPaid;
  final num totalPending;
  final num totalAmount;
  final List<Loan> loans;

  LoanPersonRecord({
    required this.personId,
    required this.name,
    required this.totalPrincipal,
    required this.totalInterest,
    required this.totalPaid,
    required this.totalPending,
    required this.totalAmount,
    required this.loans,
  });

  factory LoanPersonRecord.fromJson(Map<String, dynamic> json) => LoanPersonRecord(
        personId: json['personId'] ?? 0,
        name: json['name'] ?? '',
        totalPrincipal: json['totalPrincipal'] ?? 0,
        totalInterest: json['totalInterest'] ?? 0,
        totalPaid: json['totalPaid'] ?? 0,
        totalPending: json['totalPending'] ?? 0,
        totalAmount: json['totalAmount'] ?? 0,
        loans: (json['loans'] as List?)?.map((e) => Loan.fromJson(e)).toList() ?? [],
      );
}

/*class Loan {
  final int? id;
  final int? loanId;
  final int? personId;
  final String? loanPeriodType;
  final num? loanPeriod;
  final String? loanDate;
  final String? principalAmountType; // Maps to principalAmountTYpe in details
  final num principalAmount;
  final num? interestRate;
  final num? interestAmount;
  final String? interestAmountType;
  final String? interestPaymentPeriodType;
  final num? interestPaymentPeriod;
  final String? agreementImage;
  final num? totalPaidAmount;
  final num? paid; // Used in records
  final num? pendingAmount;
  final num? totalAmount; // Used in records
  final String? status;
  final String? note;
  final List<PaymentUpdate> paymentUpdates;

  Loan({
    this.id,
    this.loanId,
    this.personId,
    this.loanPeriodType,
    this.loanPeriod,
    this.loanDate,
    this.principalAmountType,
    required this.principalAmount,
    this.interestRate,
    this.interestAmount,
    this.interestAmountType,
    this.interestPaymentPeriodType,
    this.interestPaymentPeriod,
    this.agreementImage,
    this.totalPaidAmount,
    this.paid,
    this.pendingAmount,
    this.totalAmount,
    this.status,
    this.note,
    this.paymentUpdates = const [],
  });

  factory Loan.fromJson(Map<String, dynamic> json) => Loan(
        id: json['id'],
        loanId: json['loanId'],
        personId: json['personId'],
        loanPeriodType: json['loanPeriodType'],
        loanPeriod: json['loanPeriod'] != null ? num.tryParse(json['loanPeriod'].toString()) : null,
        loanDate: json['loanDate'],
        principalAmountType: json['principalAmountType'] ?? json['principalAmountTYpe'],
        principalAmount: num.tryParse(json['principalAmount']?.toString() ?? '0') ?? 0,
        interestRate: json['interestRate'] != null ? num.tryParse(json['interestRate'].toString()) : null,
        interestAmount: json['interestAmount'] != null ? num.tryParse(json['interestAmount'].toString()) : null,
        interestAmountType: json['interestAmountType'],
        interestPaymentPeriodType: json['interestPaymentPeriodType'],
        interestPaymentPeriod: json['interestPaymentPeriod'] != null ? num.tryParse(json['interestPaymentPeriod'].toString()) : null,
        agreementImage: json['agreementImage'],
        totalPaidAmount: json['totalPaidAmount'] != null ? num.tryParse(json['totalPaidAmount'].toString()) : null,
        paid: json['paid'] != null ? num.tryParse(json['paid'].toString()) : null,
        pendingAmount: json['pendingAmount'] != null ? num.tryParse(json['pendingAmount'].toString()) : null,
        totalAmount: json['totalAmount'] != null ? num.tryParse(json['totalAmount'].toString()) : null,
        status: json['status'],
        note: json['note'],
        paymentUpdates: (json['paymentUpdates'] as List?)?.map((e) => PaymentUpdate.fromJson(e)).toList() ?? [],
      );
}
*/

class Loan {
  final int? id;
  final int? loanId;
  final int? personId;
  final String? loanPeriodType;
  final num? loanPeriod;
  final String? loanDate;
  final String? principalAmountType;
  final num principalAmount;
  final num? interestRate;
  final num? interestAmount;
  final String? interestAmountType;
  final String? interestPaymentPeriodType;
  final num? interestPaymentPeriod;
  final String? agreementImage;
  final num? totalPaidAmount;
  final num? paid;
  final num? pendingAmount;
  final num? totalAmount;
  final String? status;
  final String? note;
  final List<PaymentUpdate> paymentUpdates;
  final PersonDetails? person; // NEW: present when fetched via /loan/loan/{id}

  Loan({
    this.id,
    this.loanId,
    this.personId,
    this.loanPeriodType,
    this.loanPeriod,
    this.loanDate,
    this.principalAmountType,
    required this.principalAmount,
    this.interestRate,
    this.interestAmount,
    this.interestAmountType,
    this.interestPaymentPeriodType,
    this.interestPaymentPeriod,
    this.agreementImage,
    this.totalPaidAmount,
    this.paid,
    this.pendingAmount,
    this.totalAmount,
    this.status,
    this.note,
    this.paymentUpdates = const [],
    this.person,
  });

  factory Loan.fromJson(Map<String, dynamic> json) => Loan(
        id: json['id'],
        loanId: json['loanId'],
        personId: json['personId'],
        loanPeriodType: json['loanPeriodType'],
        loanPeriod: json['loanPeriod'] != null ? num.tryParse(json['loanPeriod'].toString()) : null,
        loanDate: json['loanDate'],
        principalAmountType: json['principalAmountType'] ?? json['principalAmountTYpe'],
        principalAmount: num.tryParse(json['principalAmount']?.toString() ?? '0') ?? 0,
        interestRate: json['interestRate'] != null ? num.tryParse(json['interestRate'].toString()) : null,
        interestAmount: json['interestAmount'] != null ? num.tryParse(json['interestAmount'].toString()) : null,
        interestAmountType: json['interestAmountType'],
        interestPaymentPeriodType: json['interestPaymentPeriodType'],
        interestPaymentPeriod: json['interestPaymentPeriod'] != null ? num.tryParse(json['interestPaymentPeriod'].toString()) : null,
        agreementImage: json['agreementImage'],
        totalPaidAmount: json['totalPaidAmount'] != null ? num.tryParse(json['totalPaidAmount'].toString()) : null,
        paid: json['paid'] != null ? num.tryParse(json['paid'].toString()) : null,
        //pendingAmount: json['pendingAmount'] != null ? num.tryParse(json['pendingAmount'].toString()) : null,
        pendingAmount: json['pendingAmount'] != null
            ? num.tryParse(json['pendingAmount'].toString())
            : (json['principalAmount'] != null && json['totalPaidAmount'] != null
                ? (num.tryParse(json['principalAmount'].toString()) ?? 0) -
                  (num.tryParse(json['totalPaidAmount'].toString()) ?? 0)
                : null),
        totalAmount: json['totalAmount'] != null ? num.tryParse(json['totalAmount'].toString()) : null,
        status: json['status'],
        note: json['note'],
        paymentUpdates: (json['paymentUpdates'] as List?)?.map((e) => PaymentUpdate.fromJson(e)).toList() ?? [],
        person: json['person'] != null && json['person'] is Map<String, dynamic>
            ? PersonDetails.fromJson(json['person'] as Map<String, dynamic>)
            : null,
      );
}

class LoanDue {
  final int personId;
  final String personName;
  final int loanId;
  final String dueDate;
  final String dueMonth;
  final num principalAmount;
  final num interestAmount;
  final num totalAmount;
  final String status;

  LoanDue({
    required this.personId,
    required this.personName,
    required this.loanId,
    required this.dueDate,
    required this.dueMonth,
    required this.principalAmount,
    required this.interestAmount,
    required this.totalAmount,
    required this.status,
  });

  factory LoanDue.fromJson(Map<String, dynamic> json) => LoanDue(
        personId: json['personId'] ?? 0,
        personName: json['personName'] ?? '',
        loanId: json['loanId'] ?? 0,
        dueDate: json['dueDate'] ?? '',
        dueMonth: json['dueMonth'] ?? '',
        principalAmount: num.tryParse(json['principalAmount']?.toString() ?? '0') ?? 0,
        interestAmount: num.tryParse(json['interestAmount']?.toString() ?? '0') ?? 0,
        totalAmount: num.tryParse(json['totalAmount']?.toString() ?? '0') ?? 0,
        status: json['status'] ?? '',
      );
}

class PersonDetails {
  final int id;
  final String name;
  final String mobileNumber;
  final String? address;
  final String? idProof;
  final String? idProofImage;
  final String? witnessName;
  final String? witnessMobileNumber;
  final String? witnessRelation;
  final String? witnessIdProof;
  final String? witnessIdProofImage;
  final List<Loan> loans;

  PersonDetails({
    required this.id,
    required this.name,
    required this.mobileNumber,
    this.address,
    this.idProof,
    this.idProofImage,
    this.witnessName,
    this.witnessMobileNumber,
    this.witnessRelation,
    this.witnessIdProof,
    this.witnessIdProofImage,
    required this.loans,
  });

  factory PersonDetails.fromJson(Map<String, dynamic> json) => PersonDetails(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        mobileNumber: json['mobileNumber'] ?? '',
        address: json['address'],
        idProof: json['idProof'],
        idProofImage: json['idProofImage'],
        witnessName: json['witnessName'],
        witnessMobileNumber: json['witnessMobileNumber'] ?? json['witnessMobileNo'],
        witnessRelation: json['witnessRelation'],
        witnessIdProof: json['witnessIdProof'],
        witnessIdProofImage: json['witnessIdProofImage'],
        loans: (json['loans'] as List?)?.map((e) => Loan.fromJson(e)).toList() ?? [],
      );
}

class PaymentUpdate {
  final int? id;
  final int personId;
  final int loanId;
  final String paymentDate;
  final String? interestAmountType;
  final num interestAmount;
  final String? principalAmountType;
  final num principalAmount;
  final num? remainingBalance;
  final String paymentType;
  final String? referenceNumber; // referenceNUmber in JSON
  final String? file;
  final String? note;

  PaymentUpdate({
    this.id,
    required this.personId,
    required this.loanId,
    required this.paymentDate,
    this.interestAmountType,
    required this.interestAmount,
    this.principalAmountType,
    required this.principalAmount,
    this.remainingBalance,
    required this.paymentType,
    this.referenceNumber,
    this.file,
    this.note,
  });

  factory PaymentUpdate.fromJson(Map<String, dynamic> json) => PaymentUpdate(
        id: json['id'],
        personId: json['personId'] ?? 0,
        loanId: json['loanId'] ?? 0,
        paymentDate: json['paymentDate'] ?? '',
        interestAmountType: json['interestAmountType'],
        interestAmount: num.tryParse(json['interestAmount']?.toString() ?? '0') ?? 0,
        principalAmountType: json['principalAmountType'],
        principalAmount: num.tryParse(json['principalAmount']?.toString() ?? '0') ?? 0,
        remainingBalance: json['remainingBalance'] != null ? num.tryParse(json['remainingBalance'].toString()) : null,
        paymentType: json['paymentTYpe'] ?? json['paymentType'] ?? '',
        referenceNumber: json['referenceNUmber'] ?? json['referenceNumber'],
        file: json['file'],
        note: json['note'],
      );
}
