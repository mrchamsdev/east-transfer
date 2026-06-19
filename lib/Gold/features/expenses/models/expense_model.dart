import '../../categories/models/category_model.dart';

class ExpenseHistoryChangeDetail {
  final String? newValue;
  final String? oldValue;

  ExpenseHistoryChangeDetail({this.newValue, this.oldValue});

  factory ExpenseHistoryChangeDetail.fromJson(Map<String, dynamic> json) {
    return ExpenseHistoryChangeDetail(
      newValue: json['newValue']?.toString(),
      oldValue: json['oldValue']?.toString(),
    );
  }
}

class ExpenseHistoryItem {
  final Map<String, ExpenseHistoryChangeDetail>? changes;
  final String? updatedAt;
  final int? updatedBy;

  ExpenseHistoryItem({this.changes, this.updatedAt, this.updatedBy});

  factory ExpenseHistoryItem.fromJson(Map<String, dynamic> json) {
    final rawChanges = json['changes'] as Map<String, dynamic>? ?? {};
    final changesMap = rawChanges.map(
      (key, value) => MapEntry(
        key,
        ExpenseHistoryChangeDetail.fromJson(value as Map<String, dynamic>),
      ),
    );
    return ExpenseHistoryItem(
      changes: changesMap,
      updatedAt: json['updatedAt'],
      updatedBy: json['updatedBy'],
    );
  }
}

class ExpenseCompany {
  final int? id;
  final int? userId;
  final String? companyName;
  final String? companyType;
  final String? logo;

  ExpenseCompany({
    this.id,
    this.userId,
    this.companyName,
    this.companyType,
    this.logo,
  });

  factory ExpenseCompany.fromJson(Map<String, dynamic> json) {
    return ExpenseCompany(
      id: json['id'],
      userId: json['userId'],
      companyName: json['companyName'],
      companyType: json['companyType'],
      logo: json['logo'],
    );
  }
}

class ExpenseUser {
  final int? id;
  final String? name;
  final String? email;
  final String? phoneNumber;

  ExpenseUser({this.id, this.name, this.email, this.phoneNumber});

  factory ExpenseUser.fromJson(Map<String, dynamic> json) {
    return ExpenseUser(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
    );
  }
}

class Expense {
  final int? id;
  final int companyId;
  final int expenseCategoryId;
  final String expenseDate;
  final String amountType;
  final double amount;
  final String description;
  final String? comment;
  final String? note;
  final String? file;
  final int? userId;
  final int? createdBy;
  final int? updatedBy;
  final bool? deleted;
  final String? deletedAt;
  final List<ExpenseHistoryItem>? history;
  final String? createdAt;
  final String? updatedAt;
  final ExpenseCategory? expenseCategory;
  final ExpenseCompany? company;
  final ExpenseUser? user;

  Expense({
    this.id,
    required this.companyId,
    required this.expenseCategoryId,
    required this.expenseDate,
    required this.amountType,
    required this.amount,
    required this.description,
    this.comment,
    this.note,
    this.file,
    this.userId,
    this.createdBy,
    this.updatedBy,
    this.deleted,
    this.deletedAt,
    this.history,
    this.createdAt,
    this.updatedAt,
    this.expenseCategory,
    this.company,
    this.user,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    final rawAmount = json['amount'];
    double parseAmount = 0.0;
    if (rawAmount != null) {
      if (rawAmount is num) {
        parseAmount = rawAmount.toDouble();
      } else {
        parseAmount = double.tryParse(rawAmount.toString()) ?? 0.0;
      }
    }

    final rawHistory = json['history'] as List<dynamic>? ?? [];

    return Expense(
      id: json['id'],
      companyId: json['companyId'] ?? 0,
      expenseCategoryId: json['expenseCategoryId'] ?? 0,
      expenseDate: json['expenseDate'] ?? '',
      amountType: json['amountType'] ?? 'Rupees',
      amount: parseAmount,
      description: json['description'] ?? '',
      comment: json['comment'],
      note: json['note'],
      file: json['file'],
      userId: json['userId'],
      createdBy: json['createdBy'],
      updatedBy: json['updatedBy'],
      deleted: json['deleted'],
      deletedAt: json['deletedAt'],
      history: rawHistory.map((item) => ExpenseHistoryItem.fromJson(item)).toList(),
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      expenseCategory: json['expenseCategory'] != null
          ? ExpenseCategory.fromJson(json['expenseCategory'])
          : null,
      company: json['company'] != null
          ? ExpenseCompany.fromJson(json['company'])
          : null,
      user: json['user'] != null
          ? ExpenseUser.fromJson(json['user'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'companyId': companyId,
      'expenseCategoryId': expenseCategoryId,
      'expenseDate': expenseDate,
      'amount': amount,
      'amountType': amountType,
      'description': description,
      if (comment != null) 'comment': comment,
      if (note != null) 'note': note,
      if (file != null) 'file': file,
    };
  }
}

class ExpenseMonthGroup {
  final String month;
  final List<Expense> records;

  ExpenseMonthGroup({required this.month, required this.records});

  factory ExpenseMonthGroup.fromJson(Map<String, dynamic> json) {
    final List<dynamic> recs = json['records'] ?? [];
    return ExpenseMonthGroup(
      month: json['month'] ?? '',
      records: recs.map((e) => Expense.fromJson(e)).toList(),
    );
  }
}
