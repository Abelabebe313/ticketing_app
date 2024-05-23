import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../models/update_model.dart';
import '../models/user.dart';


class UserRegistration {
  static const String baseUrl =
      "https://api.noraticket.com/v1/public/api/auth/register";
  Future<bool> register(UserModel user) async {
    final Dio dio = Dio();
    await Hive.openBox<String>(tokenHive);
    await Hive.openBox<String>(pin_code);
    await Hive.openBox<String>('username');
    final Box<String> tokenBox = Hive.box<String>(tokenHive);
    final Box<String> pinBox = Hive.box<String>(pin_code);
    final Box<String> userBox = Hive.box<String>('username');


    try {
  print('========= Registration Service on failure status ======');
  Map<String, dynamic> data = user.toJson();
  print('========= Data ======' + data.toString());
  final response = await dio.post(
    baseUrl,
    options: Options(
      validateStatus: (status) {
            return status! < 500;
          },
      headers: {'Content-Type': 'application/json'}
      ),
    data: data,
  );
  print('========= Second part ======' + response.data.toString());
  // Check the response status code
  if (response.statusCode == 200) {
    print('========= Second part ======' + response.data.toString());

    final responseData = response.data as Map<String, dynamic>;
    print('--------------------${responseData['status']}');
    if (responseData['status'] == true) {
      if (responseData['data'].containsKey('access_token')) {
        final token = responseData['data']['access_token'] as String;
        tokenBox.put('token', token);
      }
      pinBox.put('pin', user.password);
      userBox.put('username', user.name);

      await Hive.close();
      return true;
    } else {
      final errorMessage =
          responseData['message'] as String? ?? 'Unknown error';
      throw Exception(errorMessage);
    }
  } else {
    // Handle non-200 status codes
    print('Unexpected status code: ${response.statusCode}');
    throw Exception('Unexpected status code: ${response.statusCode}');
  }
} catch (e) {
  print("Error: $e");
  throw Exception('An error occurred: $e');
}
  }

  Future<List<StationInfo>> fetchStationInfo() async {
    try {
      final Dio dio = Dio();
      final response = await dio.get(
          'https://api.noraticket.com/v1/public/api/updates');

      if (response.statusCode == 200) {
        final data = response.data;

        final stationInfoList = (data['data']['station_info'] as List)
            .map((stationJson) => StationInfo.fromJson(stationJson))
            .toList();
        return stationInfoList;
      } else {
        throw Exception('Failed to load station information');
      }
    } catch (e) {
      print('Error fetching station information: $e');
      throw Exception('An error occurred: $e');
    }
  }
}
