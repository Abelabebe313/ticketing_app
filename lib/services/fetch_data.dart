import 'dart:developer';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transport_app/main.dart';
import 'package:transport_app/models/bus.dart';
import 'package:transport_app/models/data.dart';
import 'package:transport_app/models/queue_model.dart';

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

    print('ቶክኑ: $token');
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
        final vehicleListJson =
            await responseData['data']['data'][0]['vehicle_list'];
        final destinationList =
            await responseData['data']['data'][0]['destination'];
        final departure = await responseData['data']['data'][0]['departure'];
        final tarifListJson = await responseData['data']['data'][0]['tariff'];
        final capacityListJson =
            await responseData['data']['data'][0]['capacity_list'];
        final distanceListJson =
            await responseData['data']['data'][0]['distance_list'];
        final levelListJson =
            await responseData['data']['data'][0]['vehicle_level_list'];
        final associationListJson =
            await responseData['data']['data'][0]['vehicle_owner_list'];

        // ============vehicle list==============
        await Hive.openBox<String>('bus_queue');
        await Hive.openBox<String>('vehicle_list');

        final Box<String> busBox = Hive.box<String>('bus_queue');
        final Box<String> vehicleBox = Hive.box<String>('vehicle_list');

        // Check if the response has a 'vehicle_list' key
        if (vehicleListJson != null) {
          print('vehicleListJson bloc');
          // ==========  convert String to List<Vehicle>  ========== //
          List<Vehicle> carList = convertRegexToVehicleList(vehicleListJson);

          List<QueueModel> busQueueList = [];

          if (busQueueList.isEmpty) {
            for (Vehicle vehicle in carList) {
              // print('plate number: ${vehicle.plateNumber}');
              busQueueList.add(QueueModel(
                plateNumber: vehicle.plateNumber,
                date:
                    '${DateTime.now().month.toString()}/${DateTime.now().day.toString()}/${DateTime.now().year.toString()}',
                time:
                    "${TimeOfDay.now().hour.toString()}:${TimeOfDay.now().minute.toString()}",
              ));
            }

            // hive put
            busBox.put('bus_queue',
                json.encode(busQueueList.map((bus) => bus.toJson()).toList()));
            vehicleBox.put(
                'vehicle_list',
                json.encode(
                    carList.map((vehicle) => vehicle.toJson()).toList()));
          }
        }
        // Hive Imple for destination
        await Hive.openBox<String>('destination_list');
        final Box<String> destinationBox = Hive.box<String>('destination_list');
        // check if the response has Destination List and add to sharedpreference
        if (destinationList != null) {
          List<String> destination =
              convertRegexToDestinationList(destinationList);
          destinationBox.put('destination_list', json.encode(destination));
        }

        // check if the response has Tariff List and add to sharedpreference
        // Hive Imple for tariff
        await Hive.openBox<String>('tariff_list');
        final Box<String> tariffBox = Hive.box<String>('tariff_list');
        if (tarifListJson != null) {
          List<int> tariff = convertRegexToTariffList(tarifListJson);
          tariffBox.put('tariff_list', json.encode(tariff));
        }
        // Hive Imple for destination
        await Hive.openBox<String>('capacity_list');
        final Box<String> capacityBox = Hive.box<String>('capacity_list');
        if (capacityListJson != null) {
          List<int> tariff = convertRegexToCapacityList(capacityListJson);
          capacityBox.put('capacity_list', json.encode(tariff));
        }

        // check departure add to sharedpreference
        // Hive Imple for destination
        await Hive.openBox<String>('departure');
        final Box<String> departureBox = Hive.box<String>('departure');
        if (departure != null) {
          departureBox.put('departure', departure);
        }

        // ====== assocoation======
        await Hive.openBox<String>('association');
        final Box<String> assocoationBox = Hive.box<String>('association');
        if (associationListJson != null) {
          List<String> association = convertRegexToAssocoationList(associationListJson);
          assocoationBox.put('association', json.encode(association));
        }

        // ====== distance ======
        await Hive.openBox<String>('distance');
        final Box<String> distanceBox = Hive.box<String>('distance');
        //
        if (distanceListJson != null) {
          List<String> distance = convertRegexToDistanceList(distanceListJson);
          distanceBox.put('distance', json.encode(distance));
        }

        // ====== vehicle level ======
        await Hive.openBox<String>('level');
        final Box<String> levelBox = Hive.box<String>('level');
        //
        if (levelListJson != null) {
          List<String> level = convertRegexToLevelList(levelListJson);
          levelBox.put('level', json.encode(level));
        }
      } else {
        print("error: *********> $responseData");
        final errorMessage =
            responseData['message'] as String? ?? 'Unknown error';
        throw Exception(errorMessage);
      }
    } catch (e) {
      print("error::++++++++++> $e");
      throw Exception('An error occurred: $e');
    } finally {
      await Hive.close();
    }
  }
}

// Regex to extract plate numbers from the response
List<Vehicle> convertRegexToVehicleList(String regexString) {
  List<String> plateNumbers = [];

  // Extract plate numbers from the regex string
  RegExp plateNumberRegex = RegExp(r'"([^"]*)"');
  Iterable<Match> matches = plateNumberRegex.allMatches(regexString);

  for (Match match in matches) {
    plateNumbers.add(match.group(1)!);
  }
  // Create a list of Vehicle objects
  List<Vehicle> vehicleList = plateNumbers.map((plateNumber) {
    return Vehicle(
      plateNumber: plateNumber,
      totalCapacity: 20, // Set the default total capacity as needed
    );
  }).toList();

  return vehicleList;
}

List<String> convertRegexToDestinationList(String regexString) {
  List<String> destinations = [];

  // Extract plate numbers from the regex string
  RegExp destinationRegex = RegExp(r'"([^"]*)"');
  Iterable<Match> matches = destinationRegex.allMatches(regexString);

  for (Match match in matches) {
    destinations.add(match.group(1)!);
  }

  return destinations;
}

List<int> convertRegexToTariffList(String regexString) {
  List<int> tariff = [];

  // Extract plate numbers from the regex string
  RegExp tariffRegex = RegExp(r'"(\d+)"');
  Iterable<Match> matches = tariffRegex.allMatches(regexString);

  for (Match match in matches) {
    tariff.add(int.parse(match.group(1)!));
  }

  return tariff;
}

List<int> convertRegexToCapacityList(String regexString) {
  List<int> capacity = [];

  // Extract capacity numbers from the regex string
  RegExp capacityRegex = RegExp(r'"(\d+)"');
  Iterable<Match> matches = capacityRegex.allMatches(regexString);

  for (Match match in matches) {
    capacity.add(int.parse(match.group(1)!));
  }
  return capacity;
}

List<String> convertRegexToAssocoationList(String regexString) {
   List<String> associations = [];

  // Extract plate numbers from the regex string
  RegExp associationsRegex = RegExp(r'"([^"]*)"');
  Iterable<Match> matches = associationsRegex.allMatches(regexString);

  for (Match match in matches) {
    associations.add(match.group(1)!);
  }

  return associations;
}

List<String> convertRegexToDistanceList(String regexString) {
   List<String> distance = [];

  // Extract plate numbers from the regex string
  RegExp distanceRegex = RegExp(r'"([^"]*)"');
  Iterable<Match> matches = distanceRegex.allMatches(regexString);

  for (Match match in matches) {
    distance.add(match.group(1)!);
  }

  return distance;
}

List<String> convertRegexToLevelList(String regexString) {
   List<String> level = [];

  // Extract plate numbers from the regex string
  RegExp levelRegex = RegExp(r'"([^"]*)"');
  Iterable<Match> matches = levelRegex.allMatches(regexString);

  for (Match match in matches) {
    level.add(match.group(1)!);
  }

  return level;
}
