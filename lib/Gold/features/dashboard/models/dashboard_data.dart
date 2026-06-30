/*class DashboardData {
  final double totalInvestment;
  final double totalProfitLoss;
  final double todayProfitLoss;
  
  final double goldInventoryValue;
  final double activeLoanPrincipal;
  final double totalExpenses;
  final double loansOutstanding;
  final double goldTradingProfitLoss;
  final double loanInterestEarned;
  final double todayGoldProfitLoss;
  final double todayInterestIncome;
  final double todayExpenses;

  DashboardData({
    required this.totalInvestment,
    required this.totalProfitLoss,
    required this.todayProfitLoss,
    required this.goldInventoryValue,
    required this.activeLoanPrincipal,
    required this.totalExpenses,
    required this.loansOutstanding,
    required this.goldTradingProfitLoss,
    required this.loanInterestEarned,
    required this.todayGoldProfitLoss,
    required this.todayInterestIncome,
    required this.todayExpenses,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    final summary = json['portfolioSummary'] ?? {};
    final breakdown = json['breakdown'] ?? {};
    
    double toDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    }

    return DashboardData(
      totalInvestment: toDouble(summary['totalInvestment']),
      totalProfitLoss: toDouble(summary['totalProfitLoss']),
      todayProfitLoss: toDouble(summary['todayProfitLoss']),
      goldInventoryValue: toDouble(breakdown['goldInventoryValue']),
      activeLoanPrincipal: toDouble(breakdown['activeLoanPrincipal']),
      totalExpenses: toDouble(breakdown['totalExpenses']),
      loansOutstanding: toDouble(breakdown['loansOutstanding']),
      goldTradingProfitLoss: toDouble(breakdown['goldTradingProfitLoss']),
      loanInterestEarned: toDouble(breakdown['loanInterestEarned']),
      todayGoldProfitLoss: toDouble(breakdown['todayGoldProfitLoss']),
      todayInterestIncome: toDouble(breakdown['todayInterestIncome']),
      todayExpenses: toDouble(breakdown['todayExpenses']),
    );
  }
}
*/
class DashboardData {
  final double totalInvestment;
  final double totalProfitLoss;
  final double todayProfitLoss;
  
  final double goldInventoryValue;
  final double activeLoanPrincipal;
  final double totalExpenses;
  final double loansOutstanding;
  final double goldTradingProfitLoss;
  final double loanInterestEarned;
  final double todayGoldProfitLoss;
  final double todayInterestIncome;
  final double todayExpenses;

  final int recentTransactionsCount;

  DashboardData({
    required this.totalInvestment,
    required this.totalProfitLoss,
    required this.todayProfitLoss,
    required this.goldInventoryValue,
    required this.activeLoanPrincipal,
    required this.totalExpenses,
    required this.loansOutstanding,
    required this.goldTradingProfitLoss,
    required this.loanInterestEarned,
    required this.todayGoldProfitLoss,
    required this.todayInterestIncome,
    required this.todayExpenses,
    required this.recentTransactionsCount,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    final summary = json['portfolioSummary'] ?? {};
    final breakdown = json['breakdown'] ?? {};
    final cards = json['cards'] ?? {};
    
    double toDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    }

    int toInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    return DashboardData(
      totalInvestment: toDouble(summary['totalInvestment']),
      totalProfitLoss: toDouble(summary['totalProfitLoss']),
      todayProfitLoss: toDouble(summary['todayProfitLoss']),
      goldInventoryValue: toDouble(breakdown['goldInventoryValue']),
      activeLoanPrincipal: toDouble(breakdown['activeLoanPrincipal']),
      totalExpenses: toDouble(breakdown['totalExpenses']),
      loansOutstanding: toDouble(breakdown['loansOutstanding']),
      goldTradingProfitLoss: toDouble(breakdown['goldTradingProfitLoss']),
      loanInterestEarned: toDouble(breakdown['loanInterestEarned']),
      todayGoldProfitLoss: toDouble(breakdown['todayGoldProfitLoss']),
      todayInterestIncome: toDouble(breakdown['todayInterestIncome']),
      todayExpenses: toDouble(breakdown['todayExpenses']),
      recentTransactionsCount: toInt(cards['recentTransactions']),
    );
  }
}