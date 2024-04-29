import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:transport_app/main.dart';
import 'package:transport_app/models/report.dart';

import '../models/update_model.dart';

class ReportService {
  static const String baseUrl =
      "https://api.noraticket.com/v1/public/api/tickets";
  Future<bool> upload(ReportModel report) async {
    await Hive.openBox<String>(tokenHive);
    final String? token = Hive.box<String>(tokenHive).get('token');
    await Hive.close();
    print('---------------------token: $token');
    final station_box = await Hive.openBox<StationInfo>('station');
    final String? station_id = station_box.get('station_id')?.id;

    try {
      print('======= Uploading report:  ======');
      Map<String, dynamic> data = {
        "station_id": station_id,
        "uploaded_by": report.name,
        "no_of_ticket": report.amount,
        "total_service_fee": "100",
        "date": report.date,
        "plate_no": report.plate,
        "validation": "ok"
      };
      final response = await http.post(
        Uri.parse('$baseUrl'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );
      final responseData = json.decode(response.body) as Map<String, dynamic>;
      if (responseData['status'] == true) {
        print('======= Successfull uploaded: $responseData ======');
      }
      return responseData['status'];
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }
}
