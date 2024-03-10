import 'dart:convert';
import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transport_app/data/bus_data.dart';
import 'package:transport_app/main.dart';
import '../../core/my_colors.dart';
import '../../models/bus.dart';
import '../../models/ticket.dart';
import '../result/ticket_result.dart';

class BuyTicket extends StatefulWidget {
  const BuyTicket({super.key});

  @override
  BuyTicketState createState() => BuyTicketState();
}

class BuyTicketState extends State<BuyTicket> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController Tailure = TextEditingController();
  final TextEditingController level = TextEditingController();
  final TextEditingController plateNumber = TextEditingController();
  final TextEditingController bus_no = TextEditingController();
  final TextEditingController destination = TextEditingController();
  final TextEditingController departure = TextEditingController();
  final TextEditingController date = TextEditingController();
  final TextEditingController tariff = TextEditingController();
  final TextEditingController serviceCharge = TextEditingController();
  final TextEditingController no_of_ticket = TextEditingController();
  final TextEditingController association = TextEditingController();
  final TextEditingController distance = TextEditingController();

  // String? TicketTailer;
  int totalCapacity = 0;
  List<Vehicle> _busList = [];
  List<String> destinationList = [];
  List<String> departureList = [];
  List<String> associationList = [];
  List<String> levelList = [];
  List<String> distanceList = [];
  List<int> tariff_list = [];
  List<int> seat_capacity_list = [];
  // intial value variables
  Vehicle? selectedVehicle;
  String? selectedDestination;
  String? selectedDeparture;
  String? selectedAssociation;
  String? selectedLevel;

  @override
  void initState() {
    String currentDate = DateTime.now().toLocal().toString().split(' ')[0];
    super.initState();
    _loadBusQueueList();
    _loadLevelList();
    _loadDestinationList();
    _loadDepartureList();
    _loadTailerData();
    _loadTariffData();
    _loadCapacityData();
    _loadAssociationList();
    _loadDistanceList();
    date.text = currentDate;
  }

  void _loadDistanceList() async {
    // Open the destination list Hive box
    final Box<String> distanceBox = await Hive.openBox<String>('distance');
    try {
      // Retrieve the destination list from Hive box
      String? distanceBoxJson = distanceBox.get('distance');

      if (distanceBoxJson != null) {
        List<dynamic> decodedList = json.decode(distanceBoxJson);

        for (var item in decodedList) {
          if (item is String) {
            distanceList.add(item);
          } else if (item is String) {
            distanceList.add(item);
          }
        }
      }
    } catch (e) {
      print('Error loading level list: $e');
    } finally {
      await distanceBox.close(); // Close the Hive box
      setState(() {}); // Update the UI
    }
  }

  void _loadLevelList() async {
    // Open the destination list Hive box
    final Box<String> levelBox = await Hive.openBox<String>('level');
    try {
      // Retrieve the destination list from Hive box
      String? levelBoxJson = levelBox.get('level');

      if (levelBoxJson != null) {
        List<dynamic> decodedList = json.decode(levelBoxJson);

        for (var item in decodedList) {
          if (item is String) {
            levelList.add(item);
          } else if (item is String) {
            levelList.add(item);
          }
        }
      }
    } catch (e) {
      print('Error loading level list: $e');
    } finally {
      await levelBox.close(); // Close the Hive box
      setState(() {}); // Update the UI
    }
  }

  void _loadAssociationList() async {
    // Open the destination list Hive box
    final Box<String> associationBox =
        await Hive.openBox<String>('association');

    try {
      // Retrieve the destination list from Hive box
      String? associationBoxJson = associationBox.get('association');
      if (associationBoxJson != null) {
        List<dynamic> decodedList = json.decode(associationBoxJson);
        associationList.addAll(decodedList.cast<String>());
      }

      if (associationList.isNotEmpty) {
        selectedAssociation = associationList[0];
        association.text = associationList[0];
      } else {
        print('association list is empty');
      }
    } catch (e) {
      print('Error loading association list: $e');
    } finally {
      await associationBox.close(); // Close the Hive box
      setState(() {}); // Update the UI
    }
  }

  void _loadCapacityData() async {
    final Box<String> capacityBox = await Hive.openBox<String>('capacity_list');

    try {
      // Retrieve capacity data from Hive box
      String? capacityListJson = capacityBox.get('capacity_list');

      // Clear the existing list
      seat_capacity_list.clear();

      if (capacityListJson != null) {
        List<dynamic> decodedList = json.decode(capacityListJson);

        // Convert the decoded list elements to integers
        for (var item in decodedList) {
          if (item is int) {
            seat_capacity_list.add(item);
          } else if (item is String) {
            seat_capacity_list.add(int.parse(item));
          }
        }
      }
    } catch (e) {
      print('Error loading capacity data: $e');
    } finally {
      await capacityBox.close(); // Close the Hive box
      setState(() {}); // Update the UI
    }
  }

  void _loadTariffData() async {
    final Box<String> tariffBox = await Hive.openBox<String>('tariff_list');

    try {
      // Retrieve tariff data from Hive box
      String? tariffListJson = tariffBox.get('tariff_list');

      // Clear the existing list
      tariff_list.clear();

      if (tariffListJson != null) {
        List<dynamic> decodedList = json.decode(tariffListJson);

        // Convert the decoded list elements to integers
        for (var item in decodedList) {
          if (item is int) {
            tariff_list.add(item);
          } else if (item is String) {
            tariff_list.add(int.parse(item));
          }
        }
      }
    } catch (e) {
      print('Error loading tariff data: $e');
    } finally {
      await tariffBox.close(); // Close the Hive box
      setState(() {}); // Update the UI
    }
  }

  void _loadTailerData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String tailorpref = prefs.getString('username') ?? '[]';

    if (tailorpref.isNotEmpty) {
      Tailure.text = tailorpref!;
    } else {
      print('desparture list is empty');
    }
    setState(() {});
  }

  void _loadDepartureList() async {
    final Box<String> departureBox = await Hive.openBox<String>('departure');

    try {
      // Retrieve departure data from Hive box
      String? selectedDeparture = departureBox.get('departure');

      if (selectedDeparture != null && selectedDeparture.isNotEmpty) {
        departure.text = selectedDeparture;
      } else {
        print('Departure list is empty');
      }
    } catch (e) {
      print('Error loading departure list: $e');
    } finally {
      await departureBox.close(); // Close the Hive box
      setState(() {}); // Update the UI
    }
  }

  void _loadBusQueueList() async {
    final box = await Hive.openBox<String>(busList);
    try {
      // Retrieve data from Hive box
      List<dynamic>? busQueueJsonList =
          json.decode(box.get('bus_queue') ?? "[]");
      _busList =
          busQueueJsonList!.map((json) => Vehicle.fromJson(json)).toList();

      if (_busList.isNotEmpty) {
        selectedVehicle = _busList[0];
        plateNumber.text = _busList[0].plateNumber;
      }
    } catch (e) {
      // Handle exceptions appropriately
      print("Error loading bus queue: $e");
    } finally {
      await box.close();
      setState(() {});
    }
  }

  void _loadDestinationList() async {
    // Open the destination list Hive box
    final Box<String> destinationBox =
        await Hive.openBox<String>('destination_list');

    try {
      // Retrieve the destination list from Hive box
      String? destinationJson = destinationBox.get('destination_list');
      if (destinationJson != null) {
        List<dynamic> decodedList = json.decode(destinationJson);
        destinationList.addAll(decodedList.cast<String>());
      }

      if (destinationList.isNotEmpty) {
        selectedDestination = destinationList[0];
        destination.text = destinationList[0];
      } else {
        print('Destination list is empty');
      }
    } catch (e) {
      print('Error loading destination list: $e');
    } finally {
      await destinationBox.close(); // Close the Hive box
      setState(() {}); // Update the UI
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2024),
    );

    if (picked != null && picked != DateTime.now()) {
      // Save only month and year to the text field
      final String formattedDate =
          "${picked.day}/${picked.month}/${picked.year}";
      date.text = formattedDate;
    }
  }

  String? validateNoOfTicket(String? value, BuildContext context) {
    if (value == null || value.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pleaseenterthenumberoftickets'.tr()),
          duration: Duration(seconds: 2),
        ),
      );
      return null;
    }
    int? numberOfTickets = int.tryParse(value);
    if (numberOfTickets == null || numberOfTickets <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pleaseenteravalidnumberoftickets'.tr()),
          duration: Duration(seconds: 2),
        ),
      );
      return null;
    }
    // Validation passed
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.grey_5,
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
            "Buy Ticket".tr(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontFamily: 'Poppins-Regular',
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: <Widget>[
            IconButton(
              icon: const Icon(
                Icons.more_vert,
                color: Colors.white,
              ),
              onPressed: () {},
            ),
          ]),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          scrollDirection: Axis.vertical,
          child: Align(
            alignment: Alignment.topCenter,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Tailor".tr(),
                          style: const TextStyle(
                            color: MyColors.grey_60,
                            fontSize: 14,
                            fontFamily: 'Poppins-Light',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3),
                          ),
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          margin: const EdgeInsets.all(0),
                          elevation: 0,
                          child: Container(
                            height: 50,
                            width: MediaQuery.of(context).size.width * 0.5,
                            alignment: Alignment.topRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: TextField(
                              maxLines: 1,
                              controller: Tailure,
                              style: const TextStyle(
                                fontSize: 16,
                                fontFamily: 'Poppins-Light',
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.all(-12),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Column(
                      children: [
                        Text(
                          "No of ticket".tr(),
                          style: const TextStyle(
                            color: MyColors.grey_60,
                            fontSize: 14,
                            fontFamily: 'Poppins-Light',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3),
                          ),
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          margin: const EdgeInsets.all(0),
                          elevation: 0,
                          child: Container(
                            width: 100,
                            height: 50,
                            alignment: Alignment.topLeft,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: TextFormField(
                              validator: (value) => validateNoOfTicket(value, context),
                              keyboardType: TextInputType.number,
                              maxLines: 1,
                              controller: no_of_ticket,
                              style: const TextStyle(
                                fontSize: 16,
                                fontFamily: 'Poppins-Light',
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.all(-12),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                Container(height: 15),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Bus Plate Number".tr(),
                            style: const TextStyle(
                              color: MyColors.grey_60,
                              fontSize: 14,
                              fontFamily: 'Poppins-Light',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(height: 5),
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(3),
                            ),
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            margin: const EdgeInsets.all(0),
                            elevation: 0,
                            child: Container(
                              height: 50,
                              alignment: Alignment.centerLeft,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              child: Row(
                                children: <Widget>[
                                  Container(width: 15),
                                  Expanded(
                                    child: DropdownButton<Vehicle>(
                                      value: selectedVehicle,
                                      items: _busList.map((Vehicle vehicle) {
                                        return DropdownMenuItem<Vehicle>(
                                          value: vehicle,
                                          child: Text(
                                            vehicle.plateNumber,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontFamily: 'Poppins-Light',
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (Vehicle? newValue) {
                                        setState(
                                          () {
                                            selectedVehicle = newValue;
                                            plateNumber.text =
                                                selectedVehicle!.plateNumber;
                                            totalCapacity =
                                                selectedVehicle!.totalCapacity;

                                            int selectedIndex =
                                                _busList.indexWhere((bus) =>
                                                    bus.plateNumber ==
                                                    selectedVehicle!
                                                        .plateNumber);
                                            level.text =
                                                levelList[selectedIndex]
                                                    .toString();
                                            totalCapacity = seat_capacity_list[
                                                selectedIndex];
                                          },
                                        );
                                      },
                                      underline: Container(),
                                    ),
                                  ),
                                ],
                              ), // Handle the case when busList is empty
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Date".tr(),
                            style: const TextStyle(
                              color: MyColors.grey_60,
                              fontSize: 14,
                              fontFamily: 'Poppins-Light',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(height: 5),
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(3),
                            ),
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            margin: const EdgeInsets.all(0),
                            elevation: 0,
                            child: Container(
                              height: 50,
                              alignment: Alignment.centerLeft,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: TextField(
                                maxLines: 1,
                                // keyboardType: TextInputType.phone,
                                controller: date,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Poppins-Light',
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: InputDecoration(
                                  contentPadding:
                                      EdgeInsets.fromLTRB(0, 5, 5, 5),
                                  border: InputBorder.none,
                                  suffixIcon: IconButton(
                                    icon: Icon(Icons.date_range),
                                    onPressed: () => _selectDate(context),
                                    color: Color(0xffB2B5BB),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                Container(height: 15),
                Text(
                  "Level".tr(),
                  style: const TextStyle(
                    color: MyColors.grey_60,
                    fontSize: 14,
                    fontFamily: 'Poppins-Light',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(height: 5),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3),
                  ),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  margin: const EdgeInsets.all(0),
                  elevation: 0,
                  child: Container(
                    height: 50,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      enabled: false,
                      maxLines: 1,
                      controller: level,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'Poppins-Light',
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.all(-12),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                Container(height: 15),
                Text(
                  "Departure".tr(),
                  style: const TextStyle(
                    color: MyColors.grey_60,
                    fontSize: 14,
                    fontFamily: 'Poppins-Light',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(height: 5),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3),
                  ),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  margin: const EdgeInsets.all(0),
                  elevation: 0,
                  child: Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width * 0.6,
                    alignment: Alignment.topRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      maxLines: 1,
                      controller: departure,
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'Poppins-Light',
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.all(-12),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                Container(height: 15),
                // ==== Destination Wideget ===========
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Destination".tr(),
                          style: const TextStyle(
                            color: MyColors.grey_60,
                            fontSize: 14,
                            fontFamily: 'Poppins-Light',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(height: 5),
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3),
                          ),
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          margin: const EdgeInsets.all(0),
                          elevation: 0,
                          child: Container(
                            height: 50,
                            width: MediaQuery.of(context).size.width * 0.5,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Row(
                              children: <Widget>[
                                Container(width: 15),
                                Expanded(
                                  child: DropdownButton<String>(
                                    value: selectedDestination,
                                    items: destinationList
                                        .map((String destination) {
                                      return DropdownMenuItem<String>(
                                        value: destination,
                                        child: Text(
                                          destination,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontFamily: 'Poppins-Light',
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        selectedDestination = newValue ?? '';
                                        destination.text = newValue!;

                                        // since the destination and tariff list are in the same order, we can use the index of the selected destination to get the corresponding tariff
                                        int selectedIndex = destinationList
                                            .indexWhere((destination) =>
                                                destination == newValue);

                                        // i added the following line to update the total capacity and service charge and tariff to update imediately after selecting destination
                                        distance.text =
                                            distanceList[selectedIndex]
                                                .toString();
                                        tariff.text = tariff_list[selectedIndex]
                                            .toString();

                                        serviceCharge.text =
                                            (tariff_list[selectedIndex] * 0.02)
                                                .toString();
                                      });
                                    },
                                    underline:
                                        Container(), // Removes the underline
                                  ),
                                ),
                                // const Icon(Icons.expand_more, color: MyColors.grey_40),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Distance".tr(),
                          style: const TextStyle(
                            color: MyColors.grey_60,
                            fontSize: 14,
                            fontFamily: 'Poppins-Light',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3),
                          ),
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          margin: const EdgeInsets.all(0),
                          elevation: 0,
                          child: Container(
                            width: 100,
                            height: 50,
                            alignment: Alignment.topLeft,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: TextField(
                              enabled: false,
                              maxLines: 1,
                              controller: distance,
                              style: const TextStyle(
                                fontSize: 16,
                                fontFamily: 'Poppins-Light',
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.all(-12),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(height: 15),
                // === Tarif and Service Charge Widgets ===
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Tariff".tr(),
                          style: const TextStyle(
                            color: MyColors.grey_60,
                            fontSize: 14,
                            fontFamily: 'Poppins-Light',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(height: 5),
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3),
                          ),
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          margin: const EdgeInsets.all(0),
                          elevation: 0,
                          child: Container(
                            height: 50,
                            width: MediaQuery.of(context).size.width * 0.5,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: TextField(
                              enabled: false,
                              maxLines: 1,
                              controller: tariff,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(
                                fontSize: 16,
                                fontFamily: 'Poppins-Light',
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.all(-12),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Column(
                      children: [
                        Text(
                          "Service Charge".tr(),
                          style: const TextStyle(
                            color: MyColors.grey_60,
                            fontSize: 14,
                            fontFamily: 'Poppins-Light',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(height: 5),
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3),
                          ),
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          margin: const EdgeInsets.all(0),
                          elevation: 0,
                          child: Container(
                            height: 50,
                            width: MediaQuery.of(context).size.width * 0.3,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: TextField(
                              enabled: false,
                              maxLines: 1,
                              controller: serviceCharge,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(
                                fontSize: 16,
                                fontFamily: 'Poppins-Light',
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.all(-12),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),

                Container(height: 15),
                Text(
                  "Association".tr(),
                  style: const TextStyle(
                    color: MyColors.grey_60,
                    fontSize: 14,
                    fontFamily: 'Poppins-Light',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(height: 5),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3),
                  ),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  margin: const EdgeInsets.all(0),
                  elevation: 0,
                  child: Container(
                    height: 50,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Row(
                      children: <Widget>[
                        Container(width: 15),
                        Expanded(
                          child: DropdownButton<String>(
                            value: selectedAssociation,
                            items: associationList.map((String associ) {
                              return DropdownMenuItem<String>(
                                value: associ,
                                child: Text(
                                  associ,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'Poppins-Light',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedAssociation = newValue ?? '';
                                association.text = newValue!;
                              });
                            },
                            underline: Container(), // Removes the underline
                          ),
                        ),
                        // const Icon(Icons.expand_more, color: MyColors.grey_40),
                      ],
                    ),
                  ),
                ),
                Container(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: MyColors.primary, elevation: 0),
                    child: Text(
                      "SUBMIT".tr(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontFamily: 'Poppins-Regular',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        String uniqueid =
                            '${DateTime.now().year.toString()}${DateTime.now().month.toString()}${DateTime.now().day.toString()}${Random().nextInt(10000000)}';
                        Ticket ticket = Ticket(
                          tailure: Tailure.text,
                          level: level.text,
                          plate: plateNumber.text,
                          date: DateTime.now(),
                          destination: destination.text,
                          departure: departure.text,
                          uniqueId: Random().nextInt(10000000),
                          tariff: double.parse(tariff.text),
                          charge: double.parse(serviceCharge.text),
                          association: association.text,
                          distance: distance.text,
                        );

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ResultPage(
                              numberOfTickets: int.parse(no_of_ticket.text),
                              ticket: ticket,
                              totalCapacity: totalCapacity,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
