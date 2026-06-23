import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralised API constants for the Gold module.
///
/// Base URL is read from the `.env` file under the key `BASE_URL`.
/// Falls back to the hardcoded development URL if absent.
class GoldApiConstants {
  GoldApiConstants._(); // prevent instantiation

  // ── Base URL ───────────────────────────────────────────────────────────────

  static String get baseUrl =>
      dotenv.env['BASE_URL'] ?? 'https://dev.millorapay.com/api';

  // ── Auth (public – no token required) ─────────────────────────────────────

  /// POST /api/users → { email, name, phoneNumber, companyType, companyName }
  static String get register => '$baseUrl/users';

  /// POST  → { email, passWord }
  static String get login => '$baseUrl/users/login';

  /// POST  → { email }  – sends OTP for password reset
  static String get requestPassword => '$baseUrl/users/requestForPassword';

  /// POST  → { email, confirmationCode }
  static String get confirmForgotPassword =>
      '$baseUrl/users/confirmForgotPassword';

  /// POST  → { email, newPassword, confirmNewPassword }
  static String get resetPassword => '$baseUrl/users/resetPassword';

  /// PUT   → { email, temporaryPassword, newPassword }
  static String get setPassword => '$baseUrl/users/setPassword';

  /// POST   → { oldPassword, newPassword, reEnterNewPassword }
  static String get changeOldPassword => '$baseUrl/users/changeOldPassword';

  // ── Gold ──────────────────────────────────────────────────────────────────
  
  static String get createGold => '$baseUrl/gold/createGold';
  static String get createItems => '$baseUrl/gold/createItems';
  static String updateParty(String id) => '$baseUrl/gold/updateParty/$id';
  static String updateGold(String id) => '$baseUrl/gold/updateGold/$id';
  static String get updateItems => '$baseUrl/gold/updateItems';
  static String deleteGold(String id) => '$baseUrl/gold/gold/$id';
  static String deleteParty(String id) => '$baseUrl/gold/party/$id';
  static String get allGoldPurchases => '$baseUrl/gold/allGoldPurchases';
  static String goldPurchaseById(String id) => '$baseUrl/gold/goldPurchase/$id';

  

  // ── Loans ─────────────────────────────────────────────────────────────────

  static String get loanList => '$baseUrl/api/loans';
  static String loanById(String id) => '$baseUrl/api/loans/$id';
  static String get addLoan => '$baseUrl/api/loans';
  static String updateLoan(String id) => '$baseUrl/api/loans/$id';
  static String deleteLoan(String id) => '$baseUrl/api/loans/$id';

  // ── Categories ────────────────────────────────────────────────────────────

  static String get expenseCategory => '$baseUrl/expenseCategory';
  static String expenseCategoryById(String id) => '$baseUrl/expenseCategory/$id';

  // ── Dashboard ─────────────────────────────────────────────────────────────

  static String get dashboardSummary => '$baseUrl/api/dashboard/summary';

  // ── Customers ─────────────────────────────────────────────────────────────
  static String get allCustomers => '$baseUrl/customer/all';
  static String get singleCustomer => '$baseUrl/customer/single';
}
