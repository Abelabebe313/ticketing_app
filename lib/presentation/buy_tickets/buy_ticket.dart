import 'dart:convert';
import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:transport_app/models/update_model.dart';
import 'package:transport_app/utils/ticket_generator.dart';
import '../../core/my_colors.dart';
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

  int totalCapacity = 0;
  // vehicle list
  List<VehicleList> vehicles_list = [];
  VehicleList? selectedVehicle;
  // destination list
  List<DestinationList> destinationList = [];
  DestinationList? selectedDestination;
  List<TariffInfo> tariffList = [];
  StationInfo? station_info;

  @override
  void initState() {
    String currentDate = DateTime.now().toLocal().toString().split(' ')[0];
    super.initState();
    fetchStationFromHive();
    getUser();
    getVehicleListFromHive();
    fetchDestinationListFromHive();
    getTariffFromHive();
    date.text = currentDate;
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
      if (station_info != null) {
        setState(() {
          departure.text = station_info!.name!;
          print('=station_info=> ${station_info!.name}');
        });
      } else {
        print('Station data is null');
      }

      print('Station fetched from Hive successfully');
    } catch (e) {
      print('Error fetching station from Hive: $e');
    }
  }

  Future<void> getUser() async {
    final Box<String> userBox = await Hive.openBox<String>('username');
    String? storedUsername = userBox.get('username');
    // Check if username is retrieved successfully
    if (storedUsername != null) {
      print('Stored username: $storedUsername');
      setState(() {
        Tailure.text = storedUsername;
      });
    } else {
      print('No username found in the box.');
    }
  }

  Future<void> getTariffFromHive() async {
    try {
      // Open Hive box for tariffs
      final box = await Hive.openBox<TariffInfo>('tariffs');

      final List<TariffInfo> allDestinations = box.values.toList();
      setState(() {
        tariffList = allDestinations;
      });
    } catch (e) {
      print('Error fetching tariff by destination ID from Hive: $e');
    }
  }

  Future<void> fetchDestinationListFromHive() async {
    try {
      // Open Hive box for destinations
      final box = await Hive.openBox<DestinationList>('destinations');

      // Retrieve all destination items from the box
      final List<DestinationList> allDestinations = box.values.toList();

      // Filter destinations based on ID
      final List<DestinationList> filteredDestinations = allDestinations
          .where((destination) => destination.stationId == station_info!.id)
          .toList();

      // Set destinationList to the filtered list
      setState(() {
        destinationList = filteredDestinations;
        selectedDestination = filteredDestinations[0];
      });
    } catch (e) {
      print('Error retrieving and filtering destination list from Hive: $e');
      // Handle error accordingly
    }
  }

  // retrive vehicle list from hive

  void getVehicleListFromHive() async {
    try {
      // Open Hive box for vehicles
      final box = await Hive.openBox<VehicleList>('vehicles');

      // Retrieve vehicle list from Hive
      final List<VehicleList> vehicleList = box.values.toList();

      // Filter destinations based on ID
      final List<VehicleList> filteredVehicles = vehicleList
          .where((vehicle) => vehicle.stationId == station_info!.id)
          .toList();

      print('Vehicle list retrieved from Hive successfully');
      setState(() {
        vehicles_list = filteredVehicles;
        selectedVehicle = filteredVehicles[0];
      });
    } catch (e) {
      print('Error retrieving vehicle list from Hive: $e');
    }
  }

  // update vehicle list
  void updateVehicleFields(VehicleList vehicle) {
    plateNumber.text = vehicle.plateNo;
    level.text = vehicle.level;
    totalCapacity = int.tryParse(vehicle.capacity) ?? 0;
    association.text = vehicle.associationName ?? '';
  }

  void updateDestinationFields(DestinationList destiantion) {
    destination.text = destiantion.destination;
    distance.text = destiantion.distance!;
  }

  Future<void> getTariffByDestinationId(String destinationId) async {
    // Search for the tariff information with the given destination ID
    for (TariffInfo tariffInfo in tariffList) {
      if (tariffInfo.destinationId == destinationId) {
        setState(() {
          tariff.text = tariffInfo.tariff!;
        });
      }
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
                              validator: (value) =>
                                  validateNoOfTicket(value, context),
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
                                    child: DropdownButton<VehicleList>(
                                      value: selectedVehicle,
                                      items: vehicles_list
                                          .map((VehicleList vehicle) {
                                        return DropdownMenuItem<VehicleList>(
                                          value: vehicle,
                                          child: Text(
                                            vehicle.plateNo,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontFamily: 'Poppins-Light',
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (VehicleList? newValue) {
                                        setState(
                                          () {
                                            selectedVehicle = newValue;
                                            updateVehicleFields(newValue!);
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
                                  child: DropdownButton<DestinationList>(
                                    value: selectedDestination,
                                    items: destinationList
                                        .map((DestinationList destination) {
                                      return DropdownMenuItem<DestinationList>(
                                        value: destination,
                                        child: Text(
                                          destination.destination,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontFamily: 'Poppins-Light',
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged:
                                        (DestinationList? newValue) async {
                                      
                                      setState(
                                        () {
                                          selectedDestination = newValue;
                                          updateDestinationFields(newValue!);
                                           getTariffByDestinationId(
                                          selectedDestination!.id!);
                                        },
                                      );
                                    },
                                    underline: Container(),
                                  ),
                                ),
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
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      enabled: false,
                      maxLines: 1,
                      controller: association,
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
                        DateTime today = DateTime.now();
                        int counter = 100;
                        String uniqueCounter =
                            generateUniqueCounter(today, counter);

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
