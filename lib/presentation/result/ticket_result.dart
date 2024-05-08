import 'dart:convert';
import 'dart:typed_data';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:ethiopian_calendar/ethiopian_date_converter.dart';
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
  DateTime ethio_date =
      EthiopianDateConverter.convertToEthiopianDate(DateTime.now());
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
                          '${ethio_date.day.toString()}/${ethio_date.month.toString()}/${ethio_date.year.toString()}-${ethio_date.hour.toString()}:${ethio_date.minute.toString()}:${ethio_date.second.toString()}', // time goes here
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
                    style: MyText.subhead(context)!.copyWith(color: Colors.white),
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
                    for (int i = 0; i < numberOfTickets; i++) {
                      String uniqueCounter =
                          generateUniqueCounter(today, numberOfTickets + i + 1);
                      print('$i = ticket printed');
                      double commission = widget.ticket.tariff * 0.02;
        
                      // Get the previous commission value from SharedPreferences
                      double previousCommission =
                          prefs.getDouble('dailyReport') ?? 0.0;
                      // Increment the commission by adding the new commission to the previous value
                      double updatedCommission = previousCommission + commission;
        
                      // Update the commission value in SharedPreferences
                      prefs.setDouble('dailyReport', updatedCommission);
                      //
                      // print ticket
                      await printMultipleTickets(
                        uniqueCounter,
                        widget.totalCapacity,
                      );
                    }
                    Navigator.pop(context);
                    
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

  Future<void> printMultipleTickets(String ticketCode, int seat) async {
    await SunmiPrinter.initPrinter();
    Uint8List dalex = await _getImageFromAsset('assets/images/Untitled-2.jpg');
    await SunmiPrinter.startTransactionPrint(true);

    await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
    await SunmiPrinter.printImage(dalex);
    await SunmiPrinter.lineWrap(1);

    await SunmiPrinter.bold();
    await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
    await SunmiPrinter.printText('Tikeetii imaltootaa!');

    await SunmiPrinter.line();
    await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);

    await SunmiPrinter.printRow(cols: [
      ColumnMaker(text: "Ka'umsaa", width: 16, align: SunmiPrintAlign.LEFT),
      ColumnMaker(
          text: widget.ticket.departure,
          width: 12,
          align: SunmiPrintAlign.RIGHT),
    ]);

    await SunmiPrinter.printRow(cols: [
      ColumnMaker(text: "Gahunsaa", width: 18, align: SunmiPrintAlign.LEFT),
      ColumnMaker(
          text: widget.ticket.destination,
          width: 12,
          align: SunmiPrintAlign.RIGHT),
    ]);

    await SunmiPrinter.printRow(cols: [
      ColumnMaker(
          text: "Tikeetii Lakk", width: 18, align: SunmiPrintAlign.LEFT),
      ColumnMaker(text: '$ticketCode', width: 12, align: SunmiPrintAlign.RIGHT),
    ]);

    await SunmiPrinter.printRow(cols: [
      ColumnMaker(
          text: "Lakkoofsa gabatee", width: 18, align: SunmiPrintAlign.LEFT),
      ColumnMaker(
          text: widget.ticket.plate, width: 12, align: SunmiPrintAlign.RIGHT),
    ]);

    await SunmiPrinter.printRow(cols: [
      ColumnMaker(text: "Sadarkaa", width: 18, align: SunmiPrintAlign.LEFT),
      ColumnMaker(
          text: widget.ticket.level, width: 12, align: SunmiPrintAlign.RIGHT),
    ]);

    await SunmiPrinter.printRow(cols: [
      ColumnMaker(text: "Teessoo", width: 18, align: SunmiPrintAlign.LEFT),
      ColumnMaker(text: '${seat}', width: 12, align: SunmiPrintAlign.RIGHT),
    ]);

    await SunmiPrinter.printRow(cols: [
      ColumnMaker(
        text: "Guyyaa",
        width: 13,
        align: SunmiPrintAlign.LEFT,
      ),
      ColumnMaker(
          text:
              '${ethio_date.day.toString()}/${ethio_date.month.toString()}/${ethio_date.year.toString()}:-${ethio_date.hour.toString()}:${ethio_date.minute.toString()}:${ethio_date.second.toString()}',
          width: 17,
          align: SunmiPrintAlign.RIGHT),
    ]);

    await SunmiPrinter.printRow(cols: [
      ColumnMaker(
        text: "Agent",
        width: 18,
        align: SunmiPrintAlign.LEFT,
      ),
      ColumnMaker(
          text: widget.ticket.tailure, width: 12, align: SunmiPrintAlign.RIGHT),
    ]);

    await SunmiPrinter.printRow(cols: [
      ColumnMaker(
        text: "Waldaa",
        width: 18,
        align: SunmiPrintAlign.LEFT,
      ),
      ColumnMaker(
          text: widget.ticket.association,
          width: 12,
          align: SunmiPrintAlign.RIGHT),
    ]);

    await SunmiPrinter.printRow(cols: [
      ColumnMaker(
        text: "fageenya",
        width: 18,
        align: SunmiPrintAlign.LEFT,
      ),
      ColumnMaker(
        text: '${widget.ticket.distance.toString()} km',
        width: 12,
        align: SunmiPrintAlign.RIGHT,
      ),
    ]);

    await SunmiPrinter.printRow(cols: [
      ColumnMaker(
        text: "Taarifa",
        width: 18,
        align: SunmiPrintAlign.LEFT,
      ),
      ColumnMaker(
          text: '${widget.ticket.tariff} Birr',
          width: 12,
          align: SunmiPrintAlign.RIGHT),
    ]);

    await SunmiPrinter.printRow(cols: [
      ColumnMaker(
        text: "Kaffaltii tajaajilaa",
        width: 20,
        align: SunmiPrintAlign.LEFT,
      ),
      ColumnMaker(
        text: '${double.parse(widget.ticket.charge.toStringAsFixed(3))} Birr',
        width: 10,
        align: SunmiPrintAlign.RIGHT,
      ),
    ]);

    await SunmiPrinter.printRow(cols: [
      ColumnMaker(
        text: "Ida'ama",
        width: 18,
        align: SunmiPrintAlign.LEFT,
      ),
      ColumnMaker(
        text:
            '${double.parse((widget.ticket.tariff + widget.ticket.charge).toStringAsFixed(3))} Birr',
        width: 12,
        align: SunmiPrintAlign.RIGHT,
      ),
    ]);

    await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);

    await SunmiPrinter.bold();

    await SunmiPrinter.resetBold();
    await SunmiPrinter.printBarCode(ticketCode, height: 30);
    await SunmiPrinter.printText('Nagahee dijitaalaa wajjiraan');
    await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
    await SunmiPrinter.printText('Alatti Hin Kafalinaa');
    await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
    await SunmiPrinter.printText('Inala gaarii!!');
    await SunmiPrinter.lineWrap(1);
    await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
    await SunmiPrinter.printText('Powered by: Dalex ',
        style: SunmiStyle(fontSize: SunmiFontSize.XS));
    await SunmiPrinter.lineWrap(3);

    await SunmiPrinter.exitTransactionPrint(true);
  }
}
