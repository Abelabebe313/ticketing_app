import 'package:dropdown_search/dropdown_search.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:transport_app/models/update_model.dart';

import '../../core/my_colors.dart';
import '../result/sunmi_printer.dart';

class BusQueue extends StatefulWidget {
  const BusQueue({Key? key});

  @override
  BusQueueState createState() => BusQueueState();
}

class BusQueueState extends State<BusQueue> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController level = TextEditingController();
  final TextEditingController plateNumber = TextEditingController();
  final TextEditingController destination = TextEditingController();
  final TextEditingController departure = TextEditingController();
  final TextEditingController date = TextEditingController();
  final TextEditingController tariff = TextEditingController();
  final TextEditingController serviceCharge = TextEditingController();
  final TextEditingController association = TextEditingController();
  final TextEditingController distance = TextEditingController();
  final TextEditingController Tailure = TextEditingController();

  int totalCapacity = 0;
  // vehicle list
  List<VehicleList> vehicles_list = [];
  List<VehicleList> vehiclesToShow = [];
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
    // BlocProvider.of<DataBloc>(context).add(GetAllDataEvent());
    fetchStationFromHive();
    getUser();
    getVehicleListFromHive();
    fetchDestinationListFromHive();
    getTariffFromHive();
    date.text = currentDate;
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
   Future<void> getTariffByDestinationId(String destinationId) async {
    // Search for the tariff information with the given destination ID
    for (TariffInfo tariffInfo in tariffList) {
      if (tariffInfo.destinationId == destinationId) {
        print('============> Tariff id: ${tariffInfo!.destinationId}');
        print('============> Tariff found: ${tariffInfo.tariff}');

        print('============> Tariff found: ${tariffInfo.level_1}');
        print('============> Selected destination ID: $destinationId');
        print('============> selectedVehicle: ${selectedVehicle!.level!}');
        setState(() {
          if (selectedVehicle != null) {
            if (selectedVehicle!.level == 'Level 1') {
              tariff.text = tariffInfo.level_1 ?? '';
              serviceCharge.text =
                  (double.parse(tariffInfo.level_1!) * 0.02).toString();
            } else if (selectedVehicle!.level == 'Level 2') {
              tariff.text = tariffInfo.level_2 ?? '';
              serviceCharge.text =
                  (double.parse(tariffInfo.level_2!) * 0.02).toString();
            } else if (selectedVehicle!.level == 'Level 3') {
              tariff.text = tariffInfo.level_3 ?? '';
              serviceCharge.text =
                  (double.parse(tariffInfo.level_3!) * 0.02).toString();
            } else {
              tariff.text = tariffInfo.tariff ?? '';
              serviceCharge.text =
                  (double.parse(tariffInfo.tariff!) * 0.02).toString();
            }
          }
        });
      }
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
    plateNumber.text = vehicle.plateNo!;
    level.text = vehicle.level!;
    totalCapacity = int.tryParse(vehicle.capacity!) ?? 0;
    association.text = vehicle.associationName ?? '';
  }

  void updateDestinationFields(DestinationList destiantion) {
    destination.text = destiantion.destination;
    distance.text = destiantion.distance!;
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

  final now = DateTime.now();
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
          'Bus Queue'.tr(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                                child: DropdownSearch<VehicleList>(
                                  popupProps: PopupProps.menu(
                                    showSearchBox: true,
                                    searchFieldProps: const TextFieldProps(
                                      // keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        hintText: "Searchss...",
                                        hintStyle: TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'Poppins-Light',
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    showSelectedItems: true,
                                    disabledItemFn: (VehicleList s) =>
                                        s.plateNo == 'Plate No',
                                  ),
                                  compareFn: (VehicleList? i, VehicleList? s) =>
                                      i!.plateNo == s!.plateNo,
                                  items: vehicles_list,
                                  dropdownDecoratorProps:
                                      const DropDownDecoratorProps(
                                    dropdownSearchDecoration: InputDecoration(
                                      hintText: "Gabatee",
                                    ),
                                  ),
                                  onChanged: (VehicleList? newValue) {
                                    setState(
                                      () {
                                        selectedVehicle = newValue;
                                        getTariffByDestinationId(
                                                  selectedDestination!.id!);
                                        updateVehicleFields(newValue!);
                                      },
                                    );
                                  },
                                  selectedItem: selectedVehicle,
                                  itemAsString: (VehicleList vehicle) =>
                                      vehicle.plateNo!,
                                ),
                              ),
                            ],
                          ), // Handle the case when busList is empty
                        ),
                      ),
                    ],
                  ),
                ),
                Container(width: 10),
              ],
            ),
            //
            // ===== Destination and Distace =====
            //
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
                                onChanged: (DestinationList? newValue) async {
                                  setState(
                                    () {
                                      selectedDestination = newValue;
                                      updateDestinationFields(newValue!);
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
            //
            // ====== Association ======
            //
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
            const SizedBox(
              height: 15,
            ),
            //
            //  ==== submit button ====
            //
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
                  // DateTime today = DateTime.now();
                  // String uniqueCounter =
                  //     generateUniqueCounter(today, counter);
                  // int counter = await CounterService.generateNextNumber();

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SunmiPrinterPage(
                        time: now.toString().split(' ')[1].substring(0, 5),
                        date: date.text,
                        station: station_info!.name!,
                        plateNo: plateNumber.text,
                        level: level.text,
                        tariff: tariff.text,
                        totalCapacity:selectedVehicle!.capacity ?? '',
                        association: association.text,
                        distance: distance.text,
                        destination: destination.text, agent: Tailure.text,
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
