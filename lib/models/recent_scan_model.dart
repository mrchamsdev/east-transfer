class RecentScan {
  final String id;
  final String bankName;
  final String accountNumber;
  final String date;
  final String? avatarInitial;

  RecentScan({
    required this.id,
    required this.bankName,
    required this.accountNumber,
    required this.date,
    this.avatarInitial,
  });

  String get displayInitial => avatarInitial ?? bankName[0].toUpperCase();
  
  String get maskedAccountNumber {
    if (accountNumber.length <= 4) return accountNumber;
    return '****${accountNumber.substring(accountNumber.length - 4)}';
  }
}

