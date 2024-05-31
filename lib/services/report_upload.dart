import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:transport_app/models/report.dart';
import 'package:transport_app/models/update_model.dart';

class ReportService {
  static const String baseUrl =
      "https://api.noraticket.com/v1/public/api/tickets";
  static const String tokenHive = "token";

  Future<bool> upload(List<ReportModel> reportList) async {
    try {
      // Open Hive box for token
      await Hive.openBox<String>(tokenHive);

      final String? token = Hive.box<String>(tokenHive).get('token');
      await Hive.close();

      // Open Hive box for station info
      final stationBox = await Hive.openBox<StationInfo>('station');
      final String? stationId = stationBox.get('station_id')?.id ?? '1';

      print('Token: $token');
      print('Station ID: $stationId');

      for (var report in reportList) {
        Map<String, dynamic> data = {
          "station_id": stationId,
          "uploaded_by": report.name,
          "tota_price": report.total_amount,
          "service_fee": report.totalServiceFee,
          "no_of_ticket": report.no_of_ticket,
          "vehicle_plate_no": report.plate,
          "vehicle_level": report.level,
          "uplaoded_date": report.date,
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
          print('Successfully uploaded: $responseData');
        } else {
          print('Failed to upload: $responseData');
        }
        return responseData['status'];
      }
    } catch (e) {
      throw Exception('An error occurred: $e');
      
    }
    return false;
  }
}