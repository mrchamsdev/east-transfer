import 'package:dio/dio.dart';
import 'package:bank_scan/Gold/core/network/gold_api_constants.dart';
import 'package:bank_scan/Gold/core/network/gold_dio_client.dart';
import 'package:bank_scan/Gold/core/network/gold_session.dart';
import '../models/customer_model.dart';
import '../../gold/models/gold_purchase_model.dart';

class CustomerRepository {
  final Dio _dio = GoldDioClient.instance.dio;

  /// Fetch all customers for a given createdBy user ID
  /// GET /customer/all?createdBy=X
  Future<List<Customer>> getAllCustomers() async {
    final createdBy = GoldSession.instance.userId ?? 9;
    try {
      final response = await _dio.get(
        GoldApiConstants.allCustomers,
        queryParameters: {'createdBy': createdBy},
      );

      if (response.statusCode == 200 && response.data != null) {
        final List? rawData = response.data['data'] ?? response.data;
        if (rawData != null) {
          return rawData
              .map((json) => Customer.fromJson(Map<String, dynamic>.from(json)))
              .toList();
        }
      }
      return _getMockCustomers();
    } catch (_) {
      return _getMockCustomers();
    }
  }

  /// Fetch a single customer details
  /// GET /customer/single?name=X&phoneNumber=Y&createdBy=Z
  Future<Customer> getSingleCustomer({
    required String name,
    required String phoneNumber,
  }) async {
    final createdBy = GoldSession.instance.userId ?? 9;
    try {
      final response = await _dio.get(
        GoldApiConstants.singleCustomer,
        queryParameters: {
          'name': name,
          'phoneNumber': phoneNumber,
          'createdBy': createdBy,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic>? data = response.data['data'] ?? response.data;
        if (data != null) {
          return Customer.fromJson(data);
        }
      }
      return _getMockSingleCustomer(name, phoneNumber);
    } catch (_) {
      return _getMockSingleCustomer(name, phoneNumber);
    }
  }

  // ── Mock Data Generation (matching screens) ───────────────────────────────

  List<Customer> _getMockCustomers() {
    return [
      Customer(
        id: 1,
        name: 'Girish Kumar',
        phoneNumber: '8106615949',
        createdBy: 9,
        createdByName: 'Sanjay',
        createdAt: '2026-05-26T00:00:00.000Z',
      ),
      Customer(
        id: 2,
        name: 'Soma Ranjith',
        phoneNumber: '9876543210',
        createdBy: 9,
        createdByName: 'Pallavi',
        createdAt: '2026-05-29T00:00:00.000Z',
      ),
      Customer(
        id: 3,
        name: 'Shaik Jainoddin',
        phoneNumber: '9998887776',
        createdBy: 9,
        createdByName: 'Chandana',
        createdAt: '2026-06-01T00:00:00.000Z',
      ),
      Customer(
        id: 4,
        name: 'Priya Singaram',
        phoneNumber: '7776665554',
        createdBy: 9,
        createdByName: 'Sai Anna',
        createdAt: '2026-06-16T00:00:00.000Z',
      ),
    ];
  }

  Customer _getMockSingleCustomer(String name, String phoneNumber) {
    // Standard mock list items for purchase and sell history
    final mockPurchases = [
      GoldPurchase(
        id: 101,
        purchaseDate: '2024-05-12',
        partyName: name,
        partyPhoneNumber: phoneNumber,
        dlNumber: '0000000',
        licenseNumber: '0000000',
        status: 'PURCHASE',
        totalGrossWeight: 8.5,
        totalPureWeight: 6.8,
        royaltyCifHiv: '0',
        tra: '0',
        svl: '0',
        amount: 125600.0,
        totalAmount: 125600.0,
        tax: 0.0,
        grandTotal: 125600.0,
        note: '',
        items: [
          GoldBilledItem(
            grossWeight: 79.76,
            side1: 90.3,
            side2: 70.2,
            averagePercentage: 90.5,
            pureWeight: 71.28,
          ),
          GoldBilledItem(
            grossWeight: 42.38,
            side1: 84.9,
            side2: 85.4,
            averagePercentage: 89.15,
            pureWeight: 36.08,
          ),
        ],
      )
    ];

    final mockSales = [
      GoldPurchase(
        id: 201,
        purchaseDate: '2024-05-08',
        partyName: name,
        partyPhoneNumber: phoneNumber,
        dlNumber: '0000000',
        licenseNumber: '0000000',
        status: 'SALE',
        saleDate: '2024-05-20',
        saleAmount: 98750.0,
        totalGrossWeight: 18.75,
        totalPureWeight: 15.0,
        royaltyCifHiv: '0',
        tra: '0',
        svl: '0',
        amount: 98750.0,
        totalAmount: 98750.0,
        tax: 0.0,
        grandTotal: 98750.0,
        note: 'Sold to: $name ($phoneNumber) | DL: 0000000',
        items: [
          GoldBilledItem(
            grossWeight: 79.76,
            side1: 90.3,
            side2: 70.2,
            averagePercentage: 90.5,
            pureWeight: 71.28,
          ),
          GoldBilledItem(
            grossWeight: 42.38,
            side1: 84.9,
            side2: 85.4,
            averagePercentage: 89.15,
            pureWeight: 36.08,
          ),
        ],
      )
    ];

    return Customer(
      id: 1,
      name: name,
      phoneNumber: phoneNumber,
      createdBy: 9,
      createdByName: 'Sanjay',
      createdAt: '2026-05-26T00:00:00.000Z',
      totalPurchase: 125600.0,
      purchaseTransactionsCount: 12,
      totalSell: 98750.0,
      sellTransactionsCount: 8,
      totalDue: 22850.0,
      duePaymentsCount: 3,
      totalGoldSellWeight: 18.750,
      goldSellTransactionsCount: 5,
      totalReceivedAmount: 98750.0,
      lastSellDate: '2024-05-20T12:45:00.000Z',
      purchaseHistory: mockPurchases,
      sellHistory: mockSales,
    );
  }
}
