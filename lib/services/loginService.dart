// ignore_for_file: prefer_interpolation_to_compose_strings

import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transport_app/main.dart';
import 'package:transport_app/models/user.dart';

class UserLogin {
  static const String baseUrl =
      "https://api.noraticket.com/v1/public/api/auth/login";

  Future<bool> login(String phone, String password) async {
    final Dio dio = Dio();
    // hive box implementation
    await Hive.openBox<String>(tokenHive);
    await Hive.openBox<String>(pin_code);
    await Hive.openBox<String>('username');
    final Box<String> tokenBox = Hive.box<String>(tokenHive);
    final Box<String> pinBox = Hive.box<String>(pin_code);
    final Box<String> userBox = Hive.box<String>('username');
    print(
        'inside login service try block ========>${phone} ${password}=========');

    try {
      Map<String, dynamic> user = {
        "phone": phone,
        "password": password,
      };
      Map<String, dynamic> data = user;
      print('========= Data ======' + data.toString());
      final response = await dio.post(
        baseUrl,
        options: Options(
            validateStatus: (status) {
              return status! < 500;
            },
            headers: {'Content-Type': 'application/json'}),
        data: data,
      );

      print('========= Second part ======' + response.data.toString());
      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        // log("fetched: $responseData");

        final String token = await responseData['data']['access_token'];
        final String username = await responseData['data']['user']['name'];
        // Check if the response has a 'token' key
        if (token != null) {
          // final token = responseData['data'] as String;
          print('token: $token');
          // ==== hive storage for token and pin code!!!!!
          tokenBox.put('token', token);
          pinBox.put('pin', password);
          userBox.put('username', username);

          log("token is saved: $token");
        }

        return responseData['status'];
      } else {
        print('Unexpected status code: ${response.statusCode}');
        throw Exception('Unexpected status code: ${response.statusCode}');
      }
    } catch (e) {
      log("error:: $e");
      throw Exception('An error occurred: $e');
    } finally {
      await Hive.close();
    }
  }
}
