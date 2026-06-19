import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:bank_scan/myapp.dart';

class ApiService {
  static String get baseUrl => dotenv.env['API_URL'] ?? '';

  static String get storageUrl => dotenv.env['API_URL'] ?? '';

  static int get apiTimeout =>
      int.tryParse(dotenv.env['API_TIMEOUT'] ?? '30') ?? 30;

  static Future<Map<String, dynamic>> uploadImage(File imageFile) async {
    try {
      print('🔄 [IMAGE UPLOAD] Starting image upload process...');
      print('📁 [IMAGE INFO] File path: ${imageFile.path}');

      // Check if file exists
      if (!await imageFile.exists()) {
        throw Exception('Image file does not exist at path: ${imageFile.path}');
      }

      final fileSize = await imageFile.length();
      print('📁 [IMAGE INFO] File size: $fileSize bytes');

      if (fileSize == 0) {
        throw Exception('Image file is empty');
      }

      var scanURL = '${dotenv.env['API_URL']}scan';
      print('🌐 [API CALL] Making POST request to: $scanURL');

      var request = http.MultipartRequest('POST', Uri.parse(scanURL));

      // Add Authorization header with bearer token
      request.headers['Authorization'] = 'Bearer ${MyApp.authTokenValue ?? ""}';

      var imageBytes = await imageFile.readAsBytes();
      print('📊 [IMAGE DATA] Image bytes length: ${imageBytes.length}');

      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: 'passbook.jpg',
        ),
      );

      print('⏳ [UPLOAD] Sending request to server...');
      var streamedResponse = await request.send().timeout(
        Duration(seconds: apiTimeout),
        onTimeout: () {
          print('⏱️ [TIMEOUT] Request timed out after ${apiTimeout} seconds');
          throw TimeoutException(
            'Request timed out after ${apiTimeout} seconds',
            Duration(seconds: apiTimeout),
          );
        },
      );
      print('✅ [UPLOAD] Request sent, waiting for response...');

      var response = await http.Response.fromStream(streamedResponse).timeout(
        Duration(seconds: apiTimeout),
        onTimeout: () {
          print('⏱️ [TIMEOUT] Response timed out after ${apiTimeout} seconds');
          throw TimeoutException(
            'Response timed out after ${apiTimeout} seconds',
            Duration(seconds: apiTimeout),
          );
        },
      );

      print('📥 [RESPONSE] Received response from server');
      print('📊 [RESPONSE] Status Code: ${response.statusCode}');
      print('📄 [RESPONSE] Headers: ${response.headers}');
      print('📝 [RESPONSE] Body: ${response.body}');
      print('📝 [RESPONSE] Body length: ${response.body.length} characters');

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData;
        try {
          responseData = jsonDecode(response.body) as Map<String, dynamic>;
        } catch (e) {
          print('❌ [PARSE ERROR] Failed to parse JSON response: $e');
          print('❌ [PARSE ERROR] Response body: ${response.body}');
          throw Exception('Invalid response format from server: $e');
        }

        print('🎉 [SUCCESS] Image upload successful!');
        print('📋 [RESPONSE DATA] Full response: $responseData');

        // Print individual fields if they exist
        print('🔍 [EXTRACTED DATA] Parsing response:');
        print(
          '   👤 Customer Name: ${responseData['customerName'] ?? 'Not found'}',
        );
        print(
          '   🔢 Account Number: ${responseData['accountNumber'] ?? 'Not found'}',
        );
        print('   🏛️ IFSC Code: ${responseData['ifscCode'] ?? 'Not found'}');
        print(
          '   🏢 Branch Name: ${responseData['branchName'] ?? 'Not found'}',
        );
        print(
          '   📍 Branch Address: ${responseData['address'] ?? 'Not found'}',
        );

        return responseData;
      } else {
        print('❌ [API ERROR] Status Code: ${response.statusCode}');
        print('❌ [API ERROR] Response Body: ${response.body}');

        // Handle 413 specifically
        if (response.statusCode == 413) {
          throw Exception(
            'Image file is too large. Please use a smaller image or reduce the image quality.',
          );
        }

        // Try to parse error message
        String errorMessage = 'API Error: ${response.statusCode}';
        try {
          var errorData = jsonDecode(response.body);
          if (errorData is Map && errorData.containsKey('message')) {
            errorMessage = errorData['message'].toString();
          } else if (errorData is Map && errorData.containsKey('error')) {
            errorMessage = errorData['error'].toString();
          } else {
            errorMessage = response.body;
          }
        } catch (e) {
          errorMessage = response.body;
        }

        throw Exception('API Error: ${response.statusCode} - $errorMessage');
      }
    } catch (e) {
      print('💥 [UPLOAD FAILED] Exception: $e');
      print('🔄 [UPLOAD FAILED] Stack trace: ${e.toString()}');
      throw Exception('Upload failed: $e');
    } finally {
      print('🏁 [IMAGE UPLOAD] Process completed');
    }
  }

  static Future<bool> addPayment({
    required String accountNumber,
    required String ifscCode,
    required String customerName,
    required String paymentDate,
    required String amountToPay,
    File? photo,
    String? bankName,
    String? nickname,
    String? phoneNumber,
    String? panNumber,
    String? aadhaarNumber,
    String? comments,
    String? bankInfoId,
  }) async {
    try {
      print('🔄 [PAYMENT UPLOAD] Starting payment submission process...');

      var paymentURL = '${dotenv.env['API_URL']}bank/payment';
      print('🌐 [API CALL] Making POST request to: $paymentURL');

      var request = http.MultipartRequest('POST', Uri.parse(paymentURL));

      // Add Authorization header with bearer token
      request.headers['Authorization'] = 'Bearer ${MyApp.authTokenValue ?? ""}';

      // Add required text fields
      request.fields['accountNumber'] = accountNumber;
      request.fields['ifscCode'] = ifscCode;
      request.fields['customerName'] = customerName;
      request.fields['paymentDate'] = paymentDate;
      request.fields['amountToPay'] = amountToPay;

      // Add optional fields
      if (bankName != null && bankName.isNotEmpty) {
        request.fields['bankName'] = bankName;
      }
      if (nickname != null && nickname.isNotEmpty) {
        request.fields['nickname'] = nickname;
      }
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        request.fields['phoneNumber'] = phoneNumber;
      }
      if (panNumber != null && panNumber.isNotEmpty) {
        request.fields['panNumber'] = panNumber;
      }
      if (aadhaarNumber != null && aadhaarNumber.isNotEmpty) {
        request.fields['aadhaarNumber'] = aadhaarNumber;
      }
      if (comments != null && comments.isNotEmpty) {
        request.fields['comments'] = comments;
      }
      if (bankInfoId != null && bankInfoId.isNotEmpty) {
        request.fields['bankInfoId'] = bankInfoId;
      }

      // Log all fields being sent
      print('📋 [PAYMENT PAYLOAD] Fields being sent:');
      print('   🔢 Account Number: $accountNumber');
      print('   🏛️ IFSC Code: $ifscCode');
      print('   👤 Customer Name: $customerName');
      print('   📅 Payment Date: $paymentDate');
      print('   💰 Amount To Pay: $amountToPay');
      if (bankName != null && bankName.isNotEmpty) {
        print('   🏢 Bank Name: $bankName');
      }
      if (nickname != null && nickname.isNotEmpty) {
        print('   🏷️ Nickname: $nickname');
      }
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        print('   📱 Phone Number: $phoneNumber');
      }
      if (panNumber != null && panNumber.isNotEmpty) {
        print('   🆔 PAN Number: $panNumber');
      }
      if (aadhaarNumber != null && aadhaarNumber.isNotEmpty) {
        print('   🆔 Aadhaar Number: $aadhaarNumber');
      }
      if (comments != null && comments.isNotEmpty) {
        print('   💬 Comments: $comments');
      }
      if (bankInfoId != null && bankInfoId.isNotEmpty) {
        print('   🏦 Bank Info ID: $bankInfoId');
      }

      // Add photo file if provided
      if (photo != null) {
        print('📁 [PHOTO INFO] Photo file path: ${photo.path}');
        print('📁 [PHOTO INFO] Photo file size: ${await photo.length()} bytes');
        print('📁 [PHOTO INFO] Photo file exists: ${await photo.exists()}');

        var imageBytes = await photo.readAsBytes();
        print('📊 [PHOTO DATA] Photo bytes length: ${imageBytes.length}');

        request.files.add(
          http.MultipartFile.fromBytes(
            'photo',
            imageBytes,
            filename: 'payment_photo.jpg',
          ),
        );
        print('✅ [PHOTO] Photo file added to request');
      } else {
        print('ℹ️ [PHOTO] No photo provided - proceeding without photo');
      }

      print('⏳ [UPLOAD] Sending payment request to server...');
      var streamedResponse = await request.send();
      print('✅ [UPLOAD] Request sent, waiting for response...');

      var response = await http.Response.fromStream(streamedResponse);

      print('📥 [RESPONSE] Received response from server');
      print('📊 [RESPONSE] Status Code: ${response.statusCode}');
      print('📄 [RESPONSE] Headers: ${response.headers}');
      print('📝 [RESPONSE] Body: ${response.body}');
      print('📝 [RESPONSE] Body length: ${response.body.length} characters');

      final bool isSuccess =
          response.statusCode == 200 || response.statusCode == 201;

      if (isSuccess) {
        print('🎉 [SUCCESS] Payment submission successful!');
        try {
          var responseData = jsonDecode(response.body);
          print('📋 [RESPONSE DATA] Full response: $responseData');
          // Print individual fields from response
          if (responseData is Map<String, dynamic>) {
            print('🔍 [EXTRACTED DATA] Parsing response:');

            // Print top-level fields
            if (responseData.containsKey('statusCode')) {
              print('   📊 Status Code: ${responseData['statusCode']}');
            }
            if (responseData.containsKey('status')) {
              print('   ✅ Status: ${responseData['status']}');
            }
            if (responseData.containsKey('message')) {
              print('   💬 Message: ${responseData['message']}');
            }

            // Print payment object fields if it exists
            if (responseData.containsKey('payment') &&
                responseData['payment'] is Map) {
              var payment = responseData['payment'] as Map<String, dynamic>;
              print('   💳 Payment Details:');
              payment.forEach((key, value) {
                print('      • $key: $value');
              });
            }

            // Also check if fields are at top level
            if (responseData.containsKey('id')) {
              print('   🆔 Payment ID: ${responseData['id']}');
            }
            if (responseData.containsKey('userId')) {
              print('   👤 User ID: ${responseData['userId']}');
            }
            if (responseData.containsKey('bankInfoId')) {
              print('   🏦 Bank Info ID: ${responseData['bankInfoId']}');
            }
            if (responseData.containsKey('amountToPay')) {
              print('   💰 Amount To Pay: ${responseData['amountToPay']}');
            }
            if (responseData.containsKey('paymentDate')) {
              print('   📅 Payment Date: ${responseData['paymentDate']}');
            }
            if (responseData.containsKey('createdDate')) {
              print('   📅 Created Date: ${responseData['createdDate']}');
            }
            if (responseData.containsKey('updatedDate')) {
              print('   📅 Updated Date: ${responseData['updatedDate']}');
            }
          }
        } catch (e) {
          print('⚠️ [WARNING] Could not parse response JSON: $e');
        }
      } else {
        print('❌ [API ERROR] Status Code: ${response.statusCode}');
        print('❌ [API ERROR] Response Body: ${response.body}');

        // Try to parse error message
        String errorMessage = 'API Error: ${response.statusCode}';
        try {
          var errorData = jsonDecode(response.body);
          if (errorData is Map && errorData.containsKey('message')) {
            errorMessage = errorData['message'].toString();
          } else if (errorData is Map && errorData.containsKey('error')) {
            errorMessage = errorData['error'].toString();
          } else {
            errorMessage = response.body;
          }
        } catch (e) {
          errorMessage = response.body;
        }

        throw Exception('API Error: ${response.statusCode} - $errorMessage');
      }

      return isSuccess;
    } catch (e) {
      print('💥 [PAYMENT FAILED] Exception: $e');
      print('🔄 [PAYMENT FAILED] Stack trace: ${e.toString()}');
      throw Exception('Payment submission failed: $e');
    } finally {
      print('🏁 [PAYMENT UPLOAD] Process completed');
    }
  }

  /// Fetch all payments grouped by date (including future transactions)
  /// URL: /api/bank/payments/all
  static Future<Map<String, dynamic>> getAllPayments({
    String? startDate,
    String? endDate,
    int? month,
    int? year,
    String? paymentDate,
  }) async {
    try {
      print('🔄 [GET ALL PAYMENTS] Starting fetch process...');

      var paymentsURL = '${dotenv.env['API_URL']}bank/payments/all';

      // Build query parameters
      final queryParams = <String, String>{};
      if (startDate != null && startDate.isNotEmpty) {
        queryParams['startDate'] = startDate;
      }
      if (endDate != null && endDate.isNotEmpty) {
        queryParams['endDate'] = endDate;
      }
      if (month != null) {
        queryParams['month'] = month.toString();
        queryParams['type'] = 'month';
      }
      if (year != null) {
        queryParams['year'] = year.toString();
      }
      if (paymentDate != null && paymentDate.isNotEmpty) {
        queryParams['paymentDate'] = paymentDate;
      }

      // Add query parameters to URL
      if (queryParams.isNotEmpty) {
        final uri = Uri.parse(paymentsURL);
        paymentsURL = uri.replace(queryParameters: queryParams).toString();
      }

      print('🌐 [API CALL] Making GET request to: $paymentsURL');

      var request = http.Request('GET', Uri.parse(paymentsURL));

      // Add Authorization header with bearer token
      request.headers['Authorization'] = 'Bearer ${MyApp.authTokenValue ?? ""}';
      request.headers['Content-Type'] = 'application/json';

      print('⏳ [UPLOAD] Sending request to server...');
      var streamedResponse = await request.send().timeout(
        Duration(seconds: apiTimeout),
        onTimeout: () {
          print('⏱️ [TIMEOUT] Request timed out after ${apiTimeout} seconds');
          throw TimeoutException(
            'Request timed out after ${apiTimeout} seconds',
            Duration(seconds: apiTimeout),
          );
        },
      );
      print('✅ [UPLOAD] Request sent, waiting for response...');

      var response = await http.Response.fromStream(streamedResponse).timeout(
        Duration(seconds: apiTimeout),
        onTimeout: () {
          print('⏱️ [TIMEOUT] Response timed out after ${apiTimeout} seconds');
          throw TimeoutException(
            'Response timed out after ${apiTimeout} seconds',
            Duration(seconds: apiTimeout),
          );
        },
      );

      print('📥 [RESPONSE] Received response from server');
      print('📊 [RESPONSE] Status Code: ${response.statusCode}');
      print('📝 [RESPONSE] Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 404) {
        Map<String, dynamic> responseData;
        try {
          responseData = jsonDecode(response.body) as Map<String, dynamic>;
        } catch (e) {
          print('❌ [PARSE ERROR] Failed to parse JSON response: $e');
          throw Exception('Invalid response format from server: $e');
        }

        print('🎉 [SUCCESS] Payments fetched successfully!');
        print('📋 [RESPONSE DATA] Full response: $responseData');

        // Handle empty response (404)
        if (response.statusCode == 404 ||
            (responseData.containsKey('status') &&
                responseData['status'] == 'error')) {
          return {
            'status': 'success',
            'statusCode': 200,
            'count': 0,
            'paymentsByDate': <String, List<dynamic>>{},
          };
        }

        return responseData;
      } else {
        print('❌ [API ERROR] Status Code: ${response.statusCode}');
        print('❌ [API ERROR] Response Body: ${response.body}');

        String errorMessage = 'API Error: ${response.statusCode}';
        try {
          var errorData = jsonDecode(response.body);
          if (errorData is Map && errorData.containsKey('message')) {
            errorMessage = errorData['message'].toString();
          } else if (errorData is Map && errorData.containsKey('error')) {
            errorMessage = errorData['error'].toString();
          } else {
            errorMessage = response.body;
          }
        } catch (e) {
          errorMessage = response.body;
        }

        throw Exception('API Error: ${response.statusCode} - $errorMessage');
      }
    } catch (e) {
      print('💥 [GET ALL PAYMENTS FAILED] Exception: $e');
      print('🔄 [GET ALL PAYMENTS FAILED] Stack trace: ${e.toString()}');
      throw Exception('Failed to fetch payments: $e');
    } finally {
      print('🏁 [GET ALL PAYMENTS] Process completed');
    }
  }

  /// Add or update future transaction for a specific bank info
  /// URL: /api/users/transactions/:bankInfoId/addOrUpdate
  static Future<Map<String, dynamic>> addOrUpdateTransaction({
    required int bankInfoId,
    required String paymentDate,
    required double amountToPay,
  }) async {
    try {
      print('🔄 [ADD/UPDATE TRANSACTION] Starting process...');
      print('   🏦 Bank Info ID: $bankInfoId');
      print('   📅 Payment Date: $paymentDate');
      print('   💰 Amount: $amountToPay');

      final url =
          '${dotenv.env['API_URL']}users/transactions/$bankInfoId/addOrUpdate';
      print('🌐 [API CALL] Making PUT request to: $url');

      final request = http.Request('PUT', Uri.parse(url));
      request.headers['Authorization'] = 'Bearer ${MyApp.authTokenValue ?? ""}';
      request.headers['Content-Type'] = 'application/json';

      final payload = {'paymentDate': paymentDate, 'amountToPay': amountToPay};

      request.body = jsonEncode(payload);
      print('📦 [PAYLOAD] $payload');

      print('⏳ [UPLOAD] Sending request to server...');
      final streamedResponse = await request.send().timeout(
        Duration(seconds: apiTimeout),
        onTimeout: () {
          print('⏱️ [TIMEOUT] Request timed out after ${apiTimeout} seconds');
          throw TimeoutException(
            'Request timed out after ${apiTimeout} seconds',
            Duration(seconds: apiTimeout),
          );
        },
      );

      final response = await http.Response.fromStream(streamedResponse).timeout(
        Duration(seconds: apiTimeout),
        onTimeout: () {
          print('⏱️ [TIMEOUT] Response timed out after ${apiTimeout} seconds');
          throw TimeoutException(
            'Response timed out after ${apiTimeout} seconds',
            Duration(seconds: apiTimeout),
          );
        },
      );

      print('📥 [RESPONSE] Received response from server');
      print('📊 [RESPONSE] Status Code: ${response.statusCode}');
      print('📝 [RESPONSE] Body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        Map<String, dynamic> responseData;
        try {
          responseData = jsonDecode(response.body) as Map<String, dynamic>;
        } catch (e) {
          print('❌ [PARSE ERROR] Failed to parse JSON response: $e');
          throw Exception('Invalid response format from server: $e');
        }

        print('🎉 [SUCCESS] Transaction added/updated successfully!');
        print('📋 [RESPONSE DATA] Full response: $responseData');

        return responseData;
      } else {
        print('❌ [API ERROR] Status Code: ${response.statusCode}');
        print('❌ [API ERROR] Response Body: ${response.body}');

        String errorMessage = 'API Error: ${response.statusCode}';
        try {
          var errorData = jsonDecode(response.body);
          if (errorData is Map && errorData.containsKey('message')) {
            errorMessage = errorData['message'].toString();
          } else if (errorData is Map && errorData.containsKey('error')) {
            errorMessage = errorData['error'].toString();
          } else {
            errorMessage = response.body;
          }
        } catch (e) {
          errorMessage = response.body;
        }

        throw Exception('API Error: ${response.statusCode} - $errorMessage');
      }
    } catch (e) {
      print('💥 [ADD/UPDATE TRANSACTION FAILED] Exception: $e');
      print('🔄 [ADD/UPDATE TRANSACTION FAILED] Stack trace: ${e.toString()}');
      throw Exception('Failed to add/update transaction: $e');
    } finally {
      print('🏁 [ADD/UPDATE TRANSACTION] Process completed');
    }
  }

  /// Send contact form message
  /// URL: /api/contact/send
  static Future<Map<String, dynamic>> sendContactMessage({
    required String name,
    required String email,
    required String subject,
    required String message,
    String? receiverEmail,
  }) async {
    try {
      print('🔄 [CONTACT] Starting contact form submission...');
      print('   👤 Name: $name');
      print('   📧 Email: $email');
      print('   📝 Subject: $subject');

      final url = '${dotenv.env['API_URL']}contact/send';
      print('🌐 [API CALL] Making POST request to: $url');

      final request = http.Request('POST', Uri.parse(url));
      request.headers['Content-Type'] = 'application/json';

      final payload = {
        'name': name,
        'email': email,
        'subject': subject,
        'message': message,
        if (receiverEmail != null && receiverEmail.isNotEmpty)
          'receiverEmail': receiverEmail,
      };

      request.body = jsonEncode(payload);
      print('📦 [PAYLOAD] Contact form data sent');

      print('⏳ [UPLOAD] Sending request to server...');
      final streamedResponse = await request.send().timeout(
        Duration(seconds: apiTimeout),
        onTimeout: () {
          print('⏱️ [TIMEOUT] Request timed out after ${apiTimeout} seconds');
          throw TimeoutException(
            'Request timed out after ${apiTimeout} seconds',
            Duration(seconds: apiTimeout),
          );
        },
      );

      final response = await http.Response.fromStream(streamedResponse).timeout(
        Duration(seconds: apiTimeout),
        onTimeout: () {
          print('⏱️ [TIMEOUT] Response timed out after ${apiTimeout} seconds');
          throw TimeoutException(
            'Response timed out after ${apiTimeout} seconds',
            Duration(seconds: apiTimeout),
          );
        },
      );

      print('📥 [RESPONSE] Received response from server');
      print('📊 [RESPONSE] Status Code: ${response.statusCode}');
      print('📝 [RESPONSE] Body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        Map<String, dynamic> responseData;
        try {
          responseData = jsonDecode(response.body) as Map<String, dynamic>;
        } catch (e) {
          print('❌ [PARSE ERROR] Failed to parse JSON response: $e');
          throw Exception('Invalid response format from server: $e');
        }

        print('🎉 [SUCCESS] Contact message sent successfully!');
        print('📋 [RESPONSE DATA] Full response: $responseData');

        return responseData;
      } else {
        print('❌ [API ERROR] Status Code: ${response.statusCode}');
        print('❌ [API ERROR] Response Body: ${response.body}');

        String errorMessage = 'API Error: ${response.statusCode}';
        try {
          var errorData = jsonDecode(response.body);
          if (errorData is Map && errorData.containsKey('message')) {
            errorMessage = errorData['message'].toString();
          } else if (errorData is Map && errorData.containsKey('error')) {
            errorMessage = errorData['error'].toString();
          } else {
            errorMessage = response.body;
          }
        } catch (e) {
          errorMessage = response.body;
        }

        throw Exception('API Error: ${response.statusCode} - $errorMessage');
      }
    } catch (e) {
      print('💥 [CONTACT FAILED] Exception: $e');
      print('🔄 [CONTACT FAILED] Stack trace: ${e.toString()}');
      throw Exception('Failed to send contact message: $e');
    } finally {
      print('🏁 [CONTACT] Process completed');
    }
  }
}
