import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunmi_printer_plus/column_maker.dart';
import 'package:sunmi_printer_plus/enums.dart';
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';
import 'package:transport_app/models/report.dart';
import '../../core/my_colors.dart';
import '../../core/my_text.dart';
import 'package:barcode_widget/barcode_widget.dart';
import '../../models/ticket.dart';

class ResultPage extends StatefulWidget {
  final int numberOfTickets;
  final int totalCapacity;
  final Ticket ticket;
  const ResultPage(
      {required this.ticket,
      required this.numberOfTickets,
      required this.totalCapacity});

  @override
  ResultPageState createState() => ResultPageState();
}

class ResultPageState extends State<ResultPage> {
  @override
  void initState() {
    super.initState();
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
        title: const Text(
          "Result",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        scrollDirection: Axis.vertical,
        child: Container(
          child: Column(
            children: [
              // User infomration Name: name, Phone: phone, Bus Number: busNumber and Seat Number: seatNumber
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Text(
                          "Passenger Information",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text(
                          "Tailure: ",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          widget.ticket.tailure,
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
                          "Plate No: ",
                          style: TextStyle(
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
                        const Text(
                          "Departure: ",
                          style: TextStyle(
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
                        const Text(
                          "Destination: ",
                          style: TextStyle(
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
                        const Text(
                          "Level: ",
                          style: TextStyle(
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
                        const Text(
                          "Tariff: ",
                          style: TextStyle(
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
                        const Text(
                          "Service Charge: ",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          widget.ticket.charge.toString(),
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
                          "Date: ",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          widget.ticket.date.toString(),
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
                    left: 10, right: 10, top: 40, bottom: 40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: BarcodeWidget(
                    barcode: Barcode.code128(),
                    data: widget.ticket.uniqueId.toString(),
                    width: 200,
                    height: 100,
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
                    "Print Ticket",
                    style:
                        MyText.subhead(context)!.copyWith(color: Colors.white),
                  ),
                  onPressed: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    for (int i = 0; i < widget.numberOfTickets; i++) {
                      await printMultipleTickets();
                      // Store vehicle ticket count
                      String plateNumber = widget.ticket.plate;
                      int currentCount = prefs.getInt(plateNumber) ?? 0;
                      prefs.setInt(plateNumber, currentCount + 1);

                      int count = prefs.getInt(widget.ticket.plate) ?? 0;
                      print(
                          'Selected vehicle ticket current count ========>$count');

                      if (widget.totalCapacity == count) {
                        String currentDate =
                            DateTime.now().toLocal().toString().split(' ')[0];
                        // Create a ReportModel
                        ReportModel report = ReportModel(
                          name: widget.ticket.tailure, // Add the actual name
                          amount: count, // Add the actual amount
                          date: currentDate, // Add the actual date
                          plate: plateNumber,
                        );
                        // Save the ReportModel locally using shared_preferences
                        _saveReportLocally(report);

                        // prefs.remove(plateNumber);
                        // _removeBusFromQueueByPlateNumber(plateNumber);
                        // prefs.setInt(plateNumber, 0);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("የትኬት ቁጥሩ ስለሞላ አባኮትን መውጫ ይቁረጡለት"),
                            backgroundColor: Colors.blue,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _saveReportLocally(ReportModel report) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> reportsJson = prefs.getStringList('reports') ?? [];
    reportsJson.add(jsonEncode(report.toJson()));
    prefs.setStringList('reports', reportsJson);
  }

  Future<void> printMultipleTickets() async {
    await SunmiPrinter.initPrinter();

    await SunmiPrinter.startTransactionPrint(true);
    await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
    await SunmiPrinter.bold();
    await SunmiPrinter.printText('Tikeetii imaltootaa!');
    await SunmiPrinter.line();
    await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);

    await SunmiPrinter.printRow(cols: [
      ColumnMaker(text: "Ka'unsaa", width: 18, align: SunmiPrintAlign.LEFT),
      ColumnMaker(
          text: '${widget.ticket.departure}',
          width: 12,
          align: SunmiPrintAlign.RIGHT),
    ]);

    await SunmiPrinter.printRow(cols: [
      ColumnMaker(text: "Gahunsaa", width: 18, align: SunmiPrintAlign.LEFT),
      ColumnMaker(
          text: '${widget.ticket.destination}',
          width: 12,
          align: SunmiPrintAlign.RIGHT),
    ]);

    await SunmiPrinter.printRow(cols: [
      ColumnMaker(
          text: "Tikeetii Lakk", width: 18, align: SunmiPrintAlign.LEFT),
      ColumnMaker(
          text: '${widget.ticket.uniqueId}',
          width: 12,
          align: SunmiPrintAlign.RIGHT),
    ]);

    await SunmiPrinter.printRow(cols: [
      ColumnMaker(
          text: "Lakkoofsa gabatee", width: 18, align: SunmiPrintAlign.LEFT),
      ColumnMaker(
          text: '${widget.ticket.plate}',
          width: 12,
          align: SunmiPrintAlign.RIGHT),
    ]);

    await SunmiPrinter.printRow(cols: [
      ColumnMaker(text: "Sadarkaa", width: 18, align: SunmiPrintAlign.LEFT),
      ColumnMaker(
          text: '${widget.ticket.level}',
          width: 12,
          align: SunmiPrintAlign.RIGHT),
    ]);

    await SunmiPrinter.printRow(cols: [
      ColumnMaker(text: "Teessoo", width: 18, align: SunmiPrintAlign.LEFT),
      ColumnMaker(text: '24', width: 12, align: SunmiPrintAlign.RIGHT),
    ]);

    await SunmiPrinter.printRow(cols: [
      ColumnMaker(
        text: "Guyyoo",
        width: 18,
        align: SunmiPrintAlign.LEFT,
      ),
      ColumnMaker(
          text:
              '${widget.ticket.date.day}/${widget.ticket.date.month}/${widget.ticket.date.year}',
          width: 12,
          align: SunmiPrintAlign.RIGHT),
    ]);

    await SunmiPrinter.printRow(cols: [
      ColumnMaker(
        text: "Agent",
        width: 18,
        align: SunmiPrintAlign.LEFT,
      ),
      ColumnMaker(
          text: '${widget.ticket.tailure}',
          width: 12,
          align: SunmiPrintAlign.RIGHT),
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
        width: 18,
        align: SunmiPrintAlign.LEFT,
      ),
      ColumnMaker(
        text: '${widget.ticket.charge} Birr',
        width: 12,
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
        text: '${widget.ticket.tariff + widget.ticket.charge} Birr',
        width: 12,
        align: SunmiPrintAlign.RIGHT,
      ),
    ]);

    await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);

    await SunmiPrinter.bold();

    await SunmiPrinter.resetBold();
    await SunmiPrinter.printBarCode('${widget.ticket.uniqueId}',
        barcodeType: SunmiBarcodeType.CODE128,
        // textPosition: SunmiBarcodeTextPos.TEXT_UNDER,
        height: 30);
    await SunmiPrinter.printText('Nagahee dijitaalaa wajjiraan');
    await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
    await SunmiPrinter.printText('Alatti Hin Kafalinaa');
    await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
    await SunmiPrinter.printText('Inala gaarii!!');
    await SunmiPrinter.lineWrap(2);

    await SunmiPrinter.exitTransactionPrint(true);
  }
}
