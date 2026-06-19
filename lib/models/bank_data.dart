class BankData {
  String accountHolderName;
  String accountNumber;
  String ifscCode;
  String branchAddress;
  String branchName;

  BankData({
    this.accountHolderName = 'Not detected',
    this.accountNumber = 'Not detected',
    this.ifscCode = 'Not detected',
    this.branchAddress = 'Not detected',
    this.branchName = 'Not detected',
  });

  factory BankData.fromJson(Map<String, dynamic> json) {
    // Helper function to handle null/empty values
    String getValue(String? key) {
      final value = json[key]?.toString().trim() ?? '';
      return value.isEmpty ? 'Not detected' : value;
    }

    return BankData(
      accountHolderName: getValue('customerName'),
      accountNumber: getValue('accountNumber'),
      ifscCode: getValue('ifscCode'),
      branchAddress: getValue('address'),
      branchName: getValue('branchName'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerName': accountHolderName,
      'accountNumber': accountNumber,
      'ifscCode': ifscCode,
      'branchName': branchName,
      'address': branchAddress,
    };
  }

  BankData copyWith({
    String? accountHolderName,
    String? accountNumber,
    String? ifscCode,
    String? branchAddress,
    String? branchName,
  }) {
    return BankData(
      accountHolderName: accountHolderName ?? this.accountHolderName,
      accountNumber: accountNumber ?? this.accountNumber,
      ifscCode: ifscCode ?? this.ifscCode,
      branchAddress: branchAddress ?? this.branchAddress,
      branchName: branchName ?? this.branchName,
    );
  }
}
