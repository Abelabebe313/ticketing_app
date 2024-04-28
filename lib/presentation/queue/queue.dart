// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transport_app/models/update_model.dart';
import 'package:transport_app/presentation/widgets/bus_queue_card.dart';
import '../../core/my_colors.dart';

class BusQueue extends StatefulWidget {
  const BusQueue({Key? key});

  @override
  BusQueueState createState() => BusQueueState();
}

class BusQueueState extends State<BusQueue> {
  List<VehicleList> _busList = [];
  List<VehicleList> _busQueueList = [];
  VehicleList? selectedVehicle;
  StationInfo? station_info;

  @override
  void initState() {
    super.initState();
    loadBusQueueList();
    fetchStationFromHive();
    print(selectedVehicle?.plateNo);
  }

  Future<void> fetchStationFromHive() async {
    try {
      // Open Hive box for station
      final box = await Hive.openBox<StationInfo>('station');

      // Check if the box is open
      if (!box.isOpen) {
        throw 'Hive box is not open';
      }
      // Get the station from the box
      final station = box.get('station');
      // Log the contents of the box
      print('Contents of the "station" box: $station');

      // Assign the retrieved station to the variable
      station_info = station;

      print('Station fetched from Hive successfully');
    } catch (e) {
      print('Error fetching station from Hive: $e');
    }
  }

  void loadBusQueueList() async {
    try {
      final box = await Hive.openBox<VehicleList>('vehicles');
      final busQueueBox = await Hive.openBox<VehicleList>('bus_queue');

      // Retrieve data for vehicle dropdown
      _busList = box.values.toList();

      // Retrieve data for vehicle queue
      _busQueueList = busQueueBox.values.toList();

      if (_busList.isNotEmpty) {
        selectedVehicle = _busList[0];
      }

      // Close the Hive boxes
      await box.close();
      await busQueueBox.close();

      setState(() {}); // Update the UI
    } catch (e) {
      print('Error loading data from Hive: $e');
    }
  }

  void _saveBusToQueue(VehicleList vehicle) async {
    try {
      final busQueueBox = await Hive.openBox<VehicleList>('bus_queue');

      // Check if the bus is not already in the queue
      if (!_busQueueList.any((bus) => bus.plateNo == vehicle.plateNo)) {
        final newBus = VehicleList(
          plateNo: vehicle.plateNo,
          date:
              '${DateTime.now().month}/${DateTime.now().day}/${DateTime.now().year}',
          level: vehicle.level, 
          capacity: vehicle.capacity,
          
        );

        _busQueueList.add(newBus);

        // Save the updated list to the Hive box
        await busQueueBox.addAll(_busQueueList);

        // Refresh the UI
        setState(() {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Success'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        });
      } else {
        // Show a Snackbar if the bus is already in the queue
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bus is already in the queue'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Close the Hive box
      await busQueueBox.close();
    } catch (e) {
      print('Error saving bus to queue: $e');
    }
  }

  Future<bool?> showConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'.tr()),
          content: Text('Are you sure?'.tr()),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // User canceled the deletion
              },
              child: Text('Cancel'.tr()),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // User confirmed the deletion
              },
              child: Text(
                'Delete'.tr(),
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _removeBusFromQueue(VehicleList bus) async {
    bool? confirmed = await showConfirmationDialog();
    if (confirmed != null && confirmed) {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Remove the bus from the list
      _busQueueList.remove(bus);

      // Save the updated list to SharedPreferences
      await prefs.setString('bus_queue',
          json.encode(_busQueueList.map((bus) => bus.toJson()).toList()));

      // Refresh the UI
      setState(() {});
    }
  }
  
  final now = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.primary,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Bus Queue'.tr(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            Container(
              height: MediaQuery.of(context).size.height * 0.07,
              width: MediaQuery.of(context).size.width * 0.95,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey.shade100,
              ),
              child: Row(
                children: <Widget>[
                  const Icon(
                    Icons.add_circle,
                    size: 40,
                    color: MyColors.primary,
                  ),
                  const SizedBox(width: 15),
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Text(
                      'Select Bus'.tr(),
                      style: const TextStyle(
                        // color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 50,
                  ),
                  Expanded(
                    child: DropdownButton<VehicleList>(
                      value: selectedVehicle,
                      items: _busList.map((VehicleList vehicle) {
                        return DropdownMenuItem<VehicleList>(
                          value: vehicle,
                          child: Text(
                            vehicle.plateNo,
                          ),
                        );
                      }).toList(),
                      onChanged: (VehicleList? newValue) {
                        setState(() {
                          selectedVehicle = newValue;
                          _saveBusToQueue(selectedVehicle!);
                        });
                      },
                      underline: Container(),
                    ),
                  ),
                ],
              ), // Handle the case when busList is empty
            ),
            const SizedBox(
              height: 20,
            ),
            // Bus Queue Order
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.95,
                height: MediaQuery.of(context).size.height * 0.08,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                  color: MyColors.primary,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        'Vehicle Order'.tr(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: Text(
                        _busQueueList.length.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.68,
              child: _busQueueList.isEmpty
                  ? Center(
                      child: Text(
                        'No Bus in Queue'.tr(),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _busQueueList.length,
                      itemBuilder: (context, index) {
                        return BusQueueCardWidget(
                          station: station_info?.name ?? '',
                          plateNo: _busQueueList[index].plateNo,
                          date: _busQueueList[index].date,
                          association: _busQueueList[index].associationName,
                          onRemove: () =>
                              _removeBusFromQueue(_busQueueList[index]), time: '',
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
