import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunmi_printer_plus/column_maker.dart';
import 'package:sunmi_printer_plus/enums.dart';
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';
import 'package:sunmi_printer_plus/sunmi_style.dart';
import 'package:transport_app/models/report.dart';
import 'package:transport_app/presentation/result/sunmi_printer.dart';
import '../../core/my_colors.dart';
import '../../core/my_text.dart';
import 'package:barcode_widget/barcode_widget.dart';
import '../../models/ticket.dart';

class ResultPage extends StatefulWidget {
  final int numberOfTickets;
  final int totalCapacity;
  final Ticket ticket;
  const ResultPage(
      {super.key,
      required this.ticket,
      required this.numberOfTickets,
      required this.totalCapacity});

  @override
  ResultPageState createState() => ResultPageState();
}

class ResultPageState extends State<ResultPage> {
  bool printBinded = false;
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
                        "Association: ",
                        style: TextStyle(
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
                      const Text(
                        "Distance: ",
                        style: TextStyle(
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
                  "Print Ticket",
                  style: MyText.subhead(context)!.copyWith(color: Colors.white),
                ),
                onPressed: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  String plateNumber = widget.ticket.plate;
                  int currentCount = prefs.getInt(plateNumber) ?? 0;

                  int remainingCapacity = widget.totalCapacity - currentCount;
                  int ticketsToPrint = widget.numberOfTickets;

                  if (ticketsToPrint > remainingCapacity) {
                    ticketsToPrint = remainingCapacity;
                  }

                  for (int i = 0; i < ticketsToPrint; i++) {
                    if (currentCount + i == widget.totalCapacity) {
                      saveReport();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("የትኬት ቁጥሩ ስለሞላ አባኮትን መውጫ ይቁረጡለት"),
                          backgroundColor: Colors.blue,
                          duration: Duration(seconds: 2),
                        ),
                      );
                      prefs.setInt(plateNumber, 0);
                      Navigator.pop(context);
                      break;
                    } else {
                      await printMultipleTickets();
                      // Store vehicle ticket count
                      prefs.setInt(plateNumber, currentCount + i + 1);
                      Navigator.pop(context);
                    }
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> saveReport() async {
    String currentDate = DateTime.now().toLocal().toString().split(' ')[0];
    ReportModel report = ReportModel(
      name: widget.ticket.tailure, // Add the actual name
      amount: widget.totalCapacity, // Add the actual amount
      date: currentDate, // Add the actual date
      plate: widget.ticket.plate,
    );
    _saveReportLocally(report);
  }

  void _saveReportLocally(ReportModel report) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> reportsJson = prefs.getStringList('reports') ?? [];
    reportsJson.add(jsonEncode(report.toJson()));
    prefs.setStringList('reports', reportsJson);
  }

  Future<Uint8List> _getImageFromAsset(String iconPath) async {
    return await readFileBytes(iconPath);
  }

  Future<void> printMultipleTickets() async {
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
      ColumnMaker(text: "Ka'unsaa", width: 18, align: SunmiPrintAlign.LEFT),
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
      ColumnMaker(
          text: '${widget.ticket.uniqueId}',
          width: 12,
          align: SunmiPrintAlign.RIGHT),
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
      ColumnMaker(text: '24', width: 12, align: SunmiPrintAlign.RIGHT),
    ]);

    await SunmiPrinter.printRow(cols: [
      ColumnMaker(
        text: "Guyyaa",
        width: 13,
        align: SunmiPrintAlign.LEFT,
      ),
      ColumnMaker(
          text:
              '${widget.ticket.date.day}/${widget.ticket.date.month}/${widget.ticket.date.year}-${widget.ticket.date.hour}:${widget.ticket.date.minute}:${widget.ticket.date.second}',
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
        text: '100 km',
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
        text: '${widget.ticket.charge} Birr',
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
        text: '${widget.ticket.tariff + widget.ticket.charge} Birr',
        width: 12,
        align: SunmiPrintAlign.RIGHT,
      ),
    ]);

    await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);

    await SunmiPrinter.bold();

    await SunmiPrinter.resetBold();
    await SunmiPrinter.printBarCode('${widget.ticket.uniqueId}', height: 30);
    await SunmiPrinter.printText('Nagahee dijitaalaa wajjiraan');
    await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
    await SunmiPrinter.printText('Alatti Hin Kafalinaa');
    await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
    await SunmiPrinter.printText('Inala gaarii!!');
    await SunmiPrinter.lineWrap(1);
    await SunmiPrinter.setAlignment(SunmiPrintAlign.LEFT);
    await SunmiPrinter.printText('Powered by: Dalex ',
        style: SunmiStyle(fontSize: SunmiFontSize.XS));
    await SunmiPrinter.printText('General Import and Wholesale',
        style: SunmiStyle(fontSize: SunmiFontSize.XS));
    await SunmiPrinter.lineWrap(3);

    await SunmiPrinter.exitTransactionPrint(true);
  }
}
