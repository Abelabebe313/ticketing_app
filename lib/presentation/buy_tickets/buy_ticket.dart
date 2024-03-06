import 'dart:convert';
import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transport_app/data/bus_data.dart';
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

  // String? TicketTailer;
  int totalCapacity = 0;
  List<Vehicle> _busList = [];
  List<String> destinationList = [];
  List<String> departureList = [];
  List<int> tariff_list = [];
  List<int> seat_capacity_list = [];
  // intial value variables
  Vehicle? selectedVehicle;
  String? selectedDestination;
  String? selectedDeparture;

  @override
  void initState() {
    String currentDate = DateTime.now().toLocal().toString().split(' ')[0];
    super.initState();
    level.text = "Level 2";

    _loadBusQueueList();
    _loadDestinationList();
    _loadDepartureList();
    _loadTailerData();
    _loadTariffData();
    _loadCapacityData();
    date.text = currentDate;
  }

  void _loadCapacityData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String capacityListJson = prefs.getString('capacity_list') ?? '[]';
    List<dynamic> decodedList = json.decode(capacityListJson);

    // Clear the existing list
    seat_capacity_list.clear();

    // Convert the decoded list elements to integers
    for (var item in decodedList) {
      if (item is int) {
        seat_capacity_list.add(item); // No need for parsing
      } else if (item is String) {
        seat_capacity_list.add(int.parse(item));
      }
    }

    setState(() {});
  }

  void _loadTariffData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String tariffListJson = prefs.getString('tariff_list') ?? '[]';
    List<dynamic> decodedList = json.decode(tariffListJson);

    // Clear the existing list
    tariff_list.clear();

    // Convert the decoded list elements to integers
    for (var item in decodedList) {
      if (item is int) {
        tariff_list.add(item);
      } else if (item is String) {
        tariff_list.add(int.parse(item));
      }
    }

    setState(() {});
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String departurepref = prefs.getString('departure') ?? '[]';

    print('departurepref:==== $departurepref');

    if (departurepref.isNotEmpty) {
      selectedDeparture = departurepref;
      departure.text = selectedDeparture!;
    } else {
      print('desparture list is empty');
    }
    setState(() {});
  }

  void _loadBusQueueList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String busQueueJson = prefs.getString('bus_queue') ?? '[]';
    List<dynamic> busQueueJsonList = json.decode(busQueueJson);
    _busList = busQueueJsonList.map((json) => Vehicle.fromJson(json)).toList();

    if (_busList.isNotEmpty) {
      selectedVehicle = _busList[0];
      plateNumber.text = _busList[0].plateNumber;
    }
    setState(() {});
  }

  void _loadDestinationList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String destinationpref = prefs.getString('destination_list') ?? '[]';
    List<dynamic> decodedList = json.decode(destinationpref);
    destinationList.addAll(decodedList.cast<String>());

    if (destinationList.isNotEmpty) {
      selectedDestination = destinationList[0];
      destination.text = destinationList[0];
    } else {
      print('destination list is empty');
    }
    setState(() {});
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
      body: SingleChildScrollView(
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
                          width: MediaQuery.of(context).size.width * 0.55,
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
                          child: TextField(
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
                    maxLines: 1,
                    controller: level,
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
                            padding: const EdgeInsets.symmetric(horizontal: 5),
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
                            padding: const EdgeInsets.symmetric(horizontal: 10),
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
                                contentPadding: EdgeInsets.fromLTRB(0, 5, 5, 5),
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
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Row(
                    children: <Widget>[
                      Container(width: 15),
                      Expanded(
                        child: DropdownButton<String>(
                          value: selectedDestination,
                          items: destinationList.map((String destination) {
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
                              int selectedIndex = destinationList.indexWhere(
                                  (destination) => destination == newValue);

                              // i added the following line to update the total capacity and service charge and tariff to update imediately after selecting destination
                              tariff.text =
                                  tariff_list[selectedIndex].toString();
                              totalCapacity = seat_capacity_list[selectedIndex];
                              serviceCharge.text =
                                  (tariff_list[selectedIndex] * 0.02)
                                      .toString();
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
              Container(height: 15),
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
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
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
              Container(height: 15),
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
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
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
              Container(height: 15),
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
                  onPressed: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
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
                    );

                    // String userJson =
                    //     prefs.getString('user_registration') ?? '[]';

                    // Parse the JSON string to a List of Users
                    // List<Ticket> ticketList =
                    //     (json.decode(userJson) as List<dynamic>)
                    //         .map((item) => Ticket.fromJson(item))
                    //         .toList();

                    // Add the new user to the list
                    // ticketList.add(ticket);

                    // Store the updated user list back to SharedPreferences
                    // prefs.setString(
                    //     'user_registration', json.encode(ticketList));

                    // ----------------==============================================
                    // Retrieve existing bus list from SharedPreferences
                    // String busJson = prefs.getString('bus_info') ?? '[]';

                    // // Parse the JSON string to a List of Buses
                    // List<Vehicle> busList =
                    //     (json.decode(busJson) as List<dynamic>)
                    //         .map((item) => Vehicle.fromJson(item))
                    //         .toList();

                    // Update the current capacity of the appropriate bus (you need to implement logic to find the correct bus to update)

                    // Add the updated bus back to the list

                    // Assuming you have some logic to find the appropriate bus to update

                    // String busNumberToUpdate = bus_no
                    //     .text; // Replace this with your logic to find the correct bus number to update
                    // Vehicle? busToUpdate = busList.firstWhere(
                    //   (bus) => bus.plateNumber == busNumberToUpdate,
                    //   orElse: () => Vehicle(
                    //     plateNumber: bus_no.text,
                    //     totalCapacity: 50,
                    //   ),
                    // );
                    // Update the current capacity of the appropriate bus
                    // busToUpdate.currentCapacity++;

                    // Add the updated bus back to the list
                    // busList.removeWhere(
                    //     (bus) => bus.plateNumber == busNumberToUpdate);
                    // busList.add(busToUpdate);

                    // Store the updated bus list back to SharedPreferences
                    // prefs.setString('bus_info', json.encode(busList));

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
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
