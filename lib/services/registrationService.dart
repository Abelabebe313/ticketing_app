import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transport_app/main.dart';
import 'package:transport_app/models/update_model.dart';
import 'package:transport_app/models/user.dart';

class UserRegistration {
  static const String baseUrl =
      "https://api.noraticket.com/v1/public/api/auth/register";
  Future<bool> register(UserModel user) async {
    // hive box implementation
    await Hive.openBox<String>(tokenHive);
    await Hive.openBox<String>(pin_code);
    await Hive.openBox<String>('username');
    final Box<String> tokenBox = Hive.box<String>(tokenHive);
    final Box<String> pinBox = Hive.box<String>(pin_code);
    final Box<String> userBox = Hive.box<String>('username');
    try {
      print('========> inside try bloc');
      final response = await http.post(
        Uri.parse('$baseUrl'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user),
      );

      final responseData = json.decode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && responseData['status'] == true) {
        // log("fetched: $responseData");
        final prefs = await SharedPreferences.getInstance();

        // ===== Check if the response has a 'access_token' key =====
        if (responseData['data'].containsKey('access_token')) {
          final token = responseData['data']['access_token'] as String;

          // Store token in SharedPreferences
          // prefs.setString('access_token', token);
          // log("token is saved: $token");

          // ===== store token to hive  =======
          tokenBox.put('token', token);
        }
        // ===== store pin and user to hive  =======
        pinBox.put('pin', user.password);
        userBox.put('username', user.name);

        // return responseData['data'];
        await Hive.close();
        return true;
      } else {
        final errorMessage =
            responseData['message'] as String? ?? 'Unknown error';
        throw Exception(errorMessage);
      }
    } catch (e) {
      log("error:: $e");
      throw Exception('An error occurred: $e');
    }
  }

  Future<List<StationInfo>> fetchStationInfo() async {
    try {
      final response = await http
          .get(Uri.parse('https://api.noraticket.com/v1/public/api/updates'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final station_Info = (data['data']['station_info'] as List)
            .map((stationJson) => StationInfo.fromJson(stationJson))
            .toList();
        return station_Info;
      } else {
        throw Exception('Failed to load station information');
      }
    } catch (e) {
      print('Error fetching station information: $e');
      throw Exception('An error occurred: $e');
      
    }
  }
}
