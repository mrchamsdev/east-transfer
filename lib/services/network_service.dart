import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:bank_scan/myapp.dart';

// GET call

class ServiceWithHeader {
  final String url;

  ServiceWithHeader(this.url);

  Future<List<dynamic>> data() async {
    print("authTokenValue network page ${MyApp.authTokenValue}");

    try {
      final response = await http.get( 
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${MyApp.authTokenValue ?? ""}',
        },
      );

      print(url);
      print('authToken');
      print(MyApp.authTokenValue);

      if (response.body.isNotEmpty) {
        print("API RESPONSE STATUS CODE: ${response.statusCode}");
        print("API RESPONSE BODY: ${response.body}");
        return [response.statusCode, jsonDecode(response.body)];
      } else {
        print("Empty response body from API");
        return [response.statusCode, null];
      }
    } catch (e) {
      print("Error in API call: $e");
      return [500, null];
    }
  }
}

// POST Call

class ServiceWithDataPost {
  final String url;
  final Map<String, dynamic> b;

  ServiceWithDataPost(this.url, this.b);

  Future data() async {
    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(b),
    );

    print(this.url);
    print(this.b);
    print(response.body);

    String data = response.body;

    if (data.length > 0) {
      return [response.statusCode, jsonDecode(data)];
    } else {
      return [response.statusCode, jsonDecode(data)];
    }
  }
}

// PUT call without auth

class ServiceWithDataPut {
  final String url;
  final Map<String, dynamic> b;

  ServiceWithDataPut(this.url, this.b);

  Future data() async {
    final response = await http.put(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(b),
    );

    print(this.url);
    print(this.b);
    print(response.body);

    String data = response.body;

    if (data.length > 0) {
      return [response.statusCode, jsonDecode(data)];
    } else {
      return [response.statusCode, jsonDecode(data)];
    }
  }
}

// PUT call with auth

class ServiceWithPutHeader {
  final String url;
  final Map<String, dynamic> body;

  ServiceWithPutHeader(this.url, this.body);

  Future data() async {
    final response = await http.put(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'authorization': 'Bearer ' + (MyApp.authTokenValue ?? ""),
      },
      body: jsonEncode(body), // Send the body as JSON
    );

    print(url);
    print(response.body);

    String data = response.body;

    if (data.isNotEmpty) {
      return [response.statusCode, jsonDecode(data)];
    } else {
      return [response.statusCode, {}];
    }
  }
}

class ServiceWithDeleteHeader {
  final String url;
  final Map<String, dynamic> body;

  // Constructor to accept both URL and body
  ServiceWithDeleteHeader(this.url, this.body);

  Future data() async {
    final response = await http.delete(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'authorization': 'Bearer ' + (MyApp.authTokenValue ?? ""),
      },
      body: jsonEncode(body),
    );

    print(url);
    print(response.body);

    String data = response.body;

    if (data.isNotEmpty) {
      return [response.statusCode, jsonDecode(data)];
    } else {
      return [response.statusCode, {}];
    }
  }
}

class ServiceWithDataPostAuth {
  final String url;
  final Map<String, dynamic> b;

  ServiceWithDataPostAuth(this.url, this.b);

  Future data() async {
    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'authorization': 'Bearer ' + (MyApp.authTokenValue ?? ""),
      },
      body: jsonEncode(b),
    );

    print(this.url);
    print(this.b);
    print(response.body);

    String data = response.body;

    if (data.length > 0) {
      return [response.statusCode, jsonDecode(data)];
    } else {
      return [response.statusCode, jsonDecode(data)];
    }
  }
}

// Delete file lib/utilities/networking.dart

class ServiceWithDataDelete {
  final String url;
  final Map<String, dynamic> b;

  ServiceWithDataDelete(this.url, this.b);

  Future data() async {
    final response = await http.delete(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'authorization': 'Bearer ' + (MyApp.authTokenValue ?? ""),
      },
      body: jsonEncode(b),
    );

    print(this.url);
    print(this.b);
    print(response.body);

    String data = response.body;

    if (data.length > 0) {
      return [response.statusCode, jsonDecode(data)];
    } else {
      return [response.statusCode, jsonDecode(data)];
    }
  }
}

// -----------------------------------------   chat application URL's  -------------------------------------//

class ChatGetService {
  final String url;

  ChatGetService(this.url);

  Future<List<dynamic>> data() async {
    print("authTokenValue: ${MyApp.authTokenValue}");

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${MyApp.authTokenValue ?? ""}',
        },
      );

      print("GET $url");
      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.body.isNotEmpty) {
        try {
          final decoded = jsonDecode(response.body);
          return [response.statusCode, decoded];
        } catch (e) {
          print("JSON Decode Error: $e");
          return [response.statusCode, null];
        }
      } else {
        return [response.statusCode, null];
      }
    } catch (e) {
      print("HTTP GET Error: $e");
      return [500, null];
    }
  }
}

class ChatPostService {
  final String url;
  final Map<String, dynamic> b;

  ChatPostService(this.url, this.b);

  Future data() async {
    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'authorization': 'Bearer ' + (MyApp.authTokenValue ?? ""),
      },
      body: jsonEncode(b),
    );

    print(this.url);
    print(this.b);
    print(response.body);

    String data = response.body;

    if (data.length > 0) {
      return [response.statusCode, jsonDecode(data)];
    } else {
      return [response.statusCode, jsonDecode(data)];
    }
  }
}
