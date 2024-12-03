import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:transport_app/main.dart';
import 'package:transport_app/models/update_model.dart';
import 'package:transport_app/utils/save_destinaiton_hive.dart';
import 'package:transport_app/utils/save_tariffinfo_hive.dart';
import 'package:transport_app/utils/save_vehicle_hive.dart';

class DataService {
  static const vehiclesList = 'vehicle_list';
  static const busList = 'bus_queue';
  static const String baseUrl =
      "https://api.noraticket.com/v1/public/api/updates";

  Future<void> fetchData() async {
    // hive box token
    await Hive.openBox<String>(tokenHive);

    // String token = prefs.getString('access_token') ?? '';

    final String? token = Hive.box<String>(tokenHive).get('token');

    // print('ቶክኑ:- $token');
    try {
      final response = await http.get(
        Uri.parse('$baseUrl'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final responseData = json.decode(response.body);

      if (responseData['status'] == true) {
        /// ==== Vehicle List ==== /

        // Extract vehicle list
        List<VehicleList> vehicleList =
            (responseData['data']['vehicle_list'] as List)
                .map((data) => VehicleList.fromJson(data))
                .toList();
        // Save vehicle list to Hive
        await saveVehicleListToHive(vehicleList);

        /// ==== destination List ==== ///
        // Extract destination list
        List<DestinationList> destinationList =
            (responseData['data']['destination_list'] as List)
                .map((data) => DestinationList.fromJson(data))
                .toList();
        // Save destination list to Hive
        await saveDestinationListToHive(destinationList);
        print('Destination List: $destinationList');

        /// ==== Tariff List ==== ///
        /// Extract Tariff list
        List<TariffInfo> tariffList =
            (responseData['data']['tariff_info'] as List)
                .map((data) => TariffInfo.fromJson(data))
                .toList();
        // Save Tariff list to Hive
        await saveTariffListToHive(tariffList);
        print('Tariff List: $tariffList');
      }
    } catch (e) {
      print("error::++++++++++> $e");
      throw Exception('An error occurred: $e');
    } finally {
      await Hive.close();
    }
  }
}
