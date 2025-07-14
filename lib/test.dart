import 'dart:convert';

import 'package:artist/core/api_service/base_url.dart';
import 'package:flutter/material.dart';
import 'core/api_service/api_service.dart';
import 'core/models/customer_modell.dart';
import 'package:http/http.dart' as http;

class Test extends StatefulWidget {
  const Test({super.key});

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  CustomerData? customerData;
  bool isLoading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    fetchCustomerData();
  }

  Future<CustomerData> getCustomerData(String customerUniqueId) async {
    final url = Uri.parse('$serverUrl/customer_data');

    print("customerUniqueId: $customerUniqueId");
    print(
        "token : eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczovL2FwaS5taXJhbW9uZXQuY29tL2FwaS9sb2dpbl9jdXN0b21lciIsImlhdCI6MTc0NDcwMDAzMSwiZXhwIjoxNzQ5ODg0MDMxLCJuYmYiOjE3NDQ3MDAwMzEsImp0aSI6IjVDRHRodklwRUZXMW9CMmoiLCJzdWIiOiIxOSIsInBydiI6IjFkMGEwMjBhY2Y1YzRiNmM0OTc5ODlkZjFhYmYwZmJkNGU4YzhkNjMifQ.mlmWWJz0FViNwUfD1garMaXFKU7cm1unsqBKHrtYyy0");

    // if (token == null || token.isEmpty) {
    //   throw Exception('Authorization token is missing or empty');
    // }

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization':
            'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczovL2FwaS5taXJhbW9uZXQuY29tL2FwaS9sb2dpbl9jdXN0b21lciIsImlhdCI6MTc0NDcwMDAzMSwiZXhwIjoxNzQ5ODg0MDMxLCJuYmYiOjE3NDQ3MDAwMzEsImp0aSI6IjVDRHRodklwRUZXMW9CMmoiLCJzdWIiOiIxOSIsInBydiI6IjFkMGEwMjBhY2Y1YzRiNmM0OTc5ODlkZjFhYmYwZmJkNGU4YzhkNjMifQ.mlmWWJz0FViNwUfD1garMaXFKU7cm1unsqBKHrtYyy0',
      },
      body: json.encode({
        'customer_unique_id': customerUniqueId,
      }),
    );

    print(response.body);
    print(response.statusCode);

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['status'] == true) {
        return CustomerData.fromJson(responseData['customer_data']);
      } else {
        throw Exception('Error: ${responseData['message']}');
      }
    } else {
      throw Exception('Failed to load customer data: ${response.body}');
    }
  }

  Future<void> fetchCustomerData() async {
    try {
      CustomerData data = await getCustomerData("4675498425");
      setState(() {
        customerData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (error.isNotEmpty) {
      return Scaffold(
        body: Center(child: Text("Error: $error")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Customer Data")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Name: ${customerData?.name ?? 'N/A'}",
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text("Email: ${customerData?.email ?? 'N/A'}",
                style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
