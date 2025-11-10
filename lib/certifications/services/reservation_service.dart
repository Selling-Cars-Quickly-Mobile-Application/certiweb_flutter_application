import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ReservationService {
  ReservationService();

  String get _baseUrl => kIsWeb ? 'http://localhost:3000' : 'http://10.0.2.2:3000';

  Future<Map<String, dynamic>> createReservation(Map<String, dynamic> payload) async {
    // Endpoint backend: api/v1/reservations
    final uri = Uri.parse('$_baseUrl/reservations');
    final res = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(payload),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to create reservation: ${res.statusCode} - ${res.body}');
    }
  }
}