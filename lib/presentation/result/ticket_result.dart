import 'dart:convert';
import 'dart:typed_data';

import 'package:abushakir/abushakir.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunmi_printer_plus/column_maker.dart';
import 'package:sunmi_printer_plus/enums.dart';
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';
import 'package:sunmi_printer_plus/sunmi_style.dart';
import 'package:transport_app/models/report.dart';
import 'package:transport_app/presentation/result/sunmi_printer.dart';
import 'package:transport_app/utils/ticket_generator.dart';

import '../../core/my_colors.dart';
import '../../core/my_text.dart';
import '../../models/ticket.dart';
import '../../data/ticket_data_source.dart';

class ResultPage extends StatefulWidget {
  final int totalCapacity;
  final Ticket ticket;
  const ResultPage(
      {super.key, required this.ticket, required this.totalCapacity});

  @override
  ResultPageState createState() => ResultPageState();
}

class ResultPageState extends State<ResultPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController no_of_ticket = TextEditingController();
  bool printBinded = false;
  EtDatetime ethio_date = EtDatetime.now();
  DateTime ethio_time = DateTime.now();
  @override
  void initState() {
    super.initState();
    _bindingPrinter().then((bool? isBind) async {
      SunmiPrinter.paperSize().then((int size) {
        setState(() {
          printBinded = isBind!;
        });
      });
    });
  }

  // Updated validation function to return error message
  String? validateNoOfTicket(String? value, BuildContext context) {
    if (value == null || value.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter the number of tickets"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return 'Please enter the number of tickets';
    }
    int? numberOfTickets = int.tryParse(value);
    if (numberOfTickets == null || numberOfTickets <= 0) {
      return 'Please enter a valid number of tickets';
    }
    // Return null if validation passes
    return null;
  }

  /// must binding ur printer at first init in app
  Future<bool?> _bindingPrinter() async {
    final bool? result = await SunmiPrinter.bindingPrinter();
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.grey_5,
      appBar: AppBar(
        backgroundColor: Colors.blue,
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
          "Result".tr(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Enter Number of ticket".tr(),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
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
                            errorStyle: TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // User infomration Name: name, Phone: phone, Bus Number: busNumber and Seat Number: seatNumber
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          "Passenger Information".tr(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          "Tailor: ".tr(),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.ticket.tailure,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          "Bus Plate Number: ".tr(),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.ticket.plate,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          "Departure: ".tr(),
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          widget.ticket.departure.toString(),
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          "Destination: ".tr(),
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          widget.ticket.destination.toString(),
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          "Level: ".tr(),
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          widget.ticket.level.toString(),
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Text(
                          "Unique ID: ",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          widget.ticket.uniqueId.toString(),
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          "Tariff: ".tr(),
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          widget.ticket.tariff.toString(),
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          "Service Charge: ".tr(),
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${double.parse((widget.ticket.charge).toStringAsFixed(3))}',
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          "Total: ".tr(),
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${double.parse((widget.ticket.tariff + widget.ticket.charge).toStringAsFixed(3))}',
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          "Association: ".tr(),
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          widget.ticket.association.toString(),
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          "Distance: ".tr(),
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          widget.ticket.distance.toString(),
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          "Date: ".tr(),
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${ethio_date.day.toString()}/${ethio_date.month.toString()}/${ethio_date.year.toString()}-${gregorianDate.hour.toString()}:${gregorianDate.minute.toString()}:${gregorianDate.second.toString()}', // time goes here
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          "Total Passenger: ".tr(),
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${widget.totalCapacity}',
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // QR Code
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(
                    left: 10, right: 10, top: 40, bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: BarcodeWidget(
                    barcode: Barcode.code128(),
                    data: widget.ticket.uniqueId.toString(),
                    width: 200,
                    height: 80,
                  ),
                ),
              ),

              const SizedBox(height: 10),
              Container(height: 15),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    elevation: 0,
                  ),
                  child: Text(
                    "Print".tr(),
                    style:
                        MyText.subhead(context)!.copyWith(color: Colors.white),
                  ),
                  onPressed: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    DateTime today = DateTime.now();
                    int numberOfTickets = int.parse(no_of_ticket.text);
                    if (numberOfTickets > widget.totalCapacity) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              "Lakkoofsi tikkeettii maxxansuuf barbaachisu dandeettii waliigalaa caala"),
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 3),
                        ),
                      );
                      return;
                    }

                    final TicketDataSource ticketDataSource = TicketDataSource();
                    
                    // Calculate total commission for all tickets
                    double commissionPerTicket = widget.ticket.tariff * 0.02;
                    double totalNewCommission = commissionPerTicket * numberOfTickets;
                    
                    // Get current values from SharedPreferences
                    double previousCommission = prefs.getDouble('dailyReport') ?? 0.0;
                    int previousTicketCount = prefs.getInt('totalTicket') ?? 0;
                    
                    // Update SharedPreferences for all tickets
                    await prefs.setDouble('dailyReport', previousCommission + totalNewCommission);
                    await prefs.setInt('totalTicket', previousTicketCount + numberOfTickets);
                    
                    // Now handle ticket creation and printing
                    for (int i = 0; i < numberOfTickets - 1; i++) {
                      String uniqueCounter = generateUniqueCounter(today, i + 1);
                      print('$i = ticket printed');

                      // Create a new ticket for each print
                      final newTicket = Ticket(
                        uniqueId: uniqueCounter,
                        departure: widget.ticket.departure,
                        destination: widget.ticket.destination,
                        plate: widget.ticket.plate,
                        level: widget.ticket.level,
                        tailure: widget.ticket.tailure,
                        tariff: widget.ticket.tariff,
                        charge: widget.ticket.charge,
                        association: widget.ticket.association,
                        distance: widget.ticket.distance,
                        date: today,
                      );
                      
                      // Save each ticket to database
                      await ticketDataSource.saveTicket(newTicket);
                      
                      // Print the ticket
                      await printMultipleTickets(
                        uniqueCounter,
                        widget.totalCapacity,
                        i + 1,
                      );
                    }
                    // Navigator.pop(context);
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<Uint8List> _getImageFromAsset(String iconPath) async {
    return await readFileBytes(iconPath);
  }

  Future<void> printMultipleTickets(
      String ticketCode, int seat, int seatNumber) async {
    await SunmiPrinter.initPrinter();
    Uint8List dalex =
        await _getImageFromAsset('assets/images/Untitled-2@3x.jpg');
    await SunmiPrinter.startTransactionPrint(true);

    await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
    await SunmiPrinter.printImage(dalex);
    // await SunmiPrinter.lineWrap(1);

    // await SunmiPrinter.bold();
    await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
    await SunmiPrinter.printText('Tikeetii imaltootaa!');

    // await SunmiPrinter.line();
    await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
    await SunmiPrinter.bold();
    await SunmiPrinter.printText(
        "Ka'umsaa -------${widget.ticket.departure}",
        style: SunmiStyle(fontSize: SunmiFontSize.MD));
    await SunmiPrinter.bold();
    await SunmiPrinter.printText(
        "Gahumsaa -------${widget.ticket.destination}",
        style: SunmiStyle(fontSize: SunmiFontSize.MD));
    await SunmiPrinter.bold();
    await SunmiPrinter.printText("Tikeetii Lakk -------${ticketCode}",
        style: SunmiStyle(fontSize: SunmiFontSize.MD));
    await SunmiPrinter.bold();
    await SunmiPrinter.printText(
        "Lakkoofsa gabatee ------${widget.ticket.plate}",
        style: SunmiStyle(fontSize: SunmiFontSize.MD));
    await SunmiPrinter.bold();
    await SunmiPrinter.printText(
        "Sadarkaa --------------${widget.ticket.level}",
        style: SunmiStyle(fontSize: SunmiFontSize.MD));
    await SunmiPrinter.bold();
    await SunmiPrinter.printText("Teessoo ------------------$seatNumber",
        style: SunmiStyle(fontSize: SunmiFontSize.MD));
    await SunmiPrinter.bold();
    await SunmiPrinter.printText(
        "Guyyaa ----${ethio_date.day.toString()}/${ethio_date.month.toString()}/${ethio_date.year.toString()}:${gregorianDate.hour.toString()}:${gregorianDate.minute.toString()}:${gregorianDate.second.toString()}",
        style: SunmiStyle(fontSize: SunmiFontSize.MD));
    await SunmiPrinter.bold();
    await SunmiPrinter.printText(
        "Agent -------${widget.ticket.tailure}",
        style: SunmiStyle(fontSize: SunmiFontSize.MD));
    await SunmiPrinter.bold();
    await SunmiPrinter.printText(
        "Waldaa -------${widget.ticket.association}",
        style: SunmiStyle(fontSize: SunmiFontSize.MD));
    await SunmiPrinter.bold();
    await SunmiPrinter.printText(
        "Fageenya ---------${widget.ticket.distance.toString()} km",
        style: SunmiStyle(fontSize: SunmiFontSize.MD));
    await SunmiPrinter.bold();
    await SunmiPrinter.printText(
        "Taarifa ---------${widget.ticket.tariff} Birr",
        style: SunmiStyle(fontSize: SunmiFontSize.MD));
    await SunmiPrinter.bold();
    await SunmiPrinter.printText(
        "Kaffaltii tajaajilaa--${double.parse(widget.ticket.charge.toStringAsFixed(3))}Birr",
        style: SunmiStyle(fontSize: SunmiFontSize.MD));
    await SunmiPrinter.bold();
    await SunmiPrinter.printText(
        "Ida'ama --------${double.parse((widget.ticket.tariff + widget.ticket.charge).toStringAsFixed(3))} Birr",
        style: SunmiStyle(fontSize: SunmiFontSize.MD));

    await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);

    await SunmiPrinter.bold();

    await SunmiPrinter.resetBold();
    await SunmiPrinter.printBarCode(ticketCode, height: 20);
    //
    //line
    await SunmiPrinter.printText('==============================',
        style: SunmiStyle(fontSize: SunmiFontSize.SM));
    // await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
    await SunmiPrinter.printText(
        'Bilbila bilisaa --> 8556 Biiroo Geejjiba Oromiyaa YKN',
        style: SunmiStyle(fontSize: SunmiFontSize.MD));
    // await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
    // await SunmiPrinter.printText('0901878871 / 0912289830',
    //     style: SunmiStyle(fontSize: SunmiFontSize.MD));
    await SunmiPrinter.lineWrap(3);
    // await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
    // await SunmiPrinter.printText('Powered by: Dalex ',
    //     style: SunmiStyle(fontSize: SunmiFontSize.XS));
    // await SunmiPrinter.lineWrap(3);

    await SunmiPrinter.exitTransactionPrint(true);
  }
}
