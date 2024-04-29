import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:transport_app/models/report.dart';
import 'package:transport_app/models/update_model.dart';

class ReportService {
  static const String baseUrl =
      "https://api.noraticket.com/v1/public/api/tickets";
  static const String tokenHive = "token";

  Future<bool> upload(ReportModel report) async {
    try {
      // Open Hive box for token
      await Hive.openBox<String>(tokenHive);

      // String token = prefs.getString('access_token') ?? '';

      final String? token = Hive.box<String>(tokenHive).get('token');

      await Hive.close();

      // Open Hive box for station info
      final stationBox = await Hive.openBox<StationInfo>('station');
      final String? stationId = stationBox.get('station_id')?.id ?? '1';

      print('Token: $token');
      print('Station ID: $stationId');

      Map<String, dynamic> data = {
        "station_id": stationId,
        "uploaded_by": report.name,
        "no_of_ticket": report.amount,
        "total_service_fee": report.totalServiceFee,
        "date": report.date,
        "plate_no": report.plate,
        "validate": "ok"
      };

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );
      print("Processing ... Uploading Report");
      final responseData = json.decode(response.body) as Map<String, dynamic>;

      if (responseData['status'] == true) {
        print('Successful uploaded: $responseData');
      } else {
        print('Failed to upload: $responseData');
      }

      return responseData['status'];
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }
}
