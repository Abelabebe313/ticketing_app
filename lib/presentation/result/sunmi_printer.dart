import 'dart:async';

import 'package:barcode_widget/barcode_widget.dart' as Bbar;
import 'package:ethiopian_calendar/ethiopian_date_converter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sunmi_printer_plus/column_maker.dart';
import 'package:sunmi_printer_plus/enums.dart';
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';
import 'package:sunmi_printer_plus/sunmi_style.dart';

import '../../data/report.dart';
import '../../models/report.dart';
import '../../utils/ticket_generator.dart';

class SunmiPrinterPage extends StatefulWidget {
  final String time;
  final String date;
  final String station;
  final String plateNo;
  final String totalCapacity;
  final String level;
  final String tariff;
  final String association;
  final String distance;
  final String destination;
  final String agent;
  const SunmiPrinterPage(
      {Key? key,
      required this.time,
      required this.date,
      required this.station,
      required this.plateNo,
      required this.totalCapacity,
      required this.level,
      required this.tariff,
      required this.association,
      required this.distance,
      required this.destination,
      required this.agent})
      : super(key: key);

  @override
  _SunmiPrinterPageState createState() => _SunmiPrinterPageState();
}

class _SunmiPrinterPageState extends State<SunmiPrinterPage> {
  bool printBinded = false;
  int paperSize = 0;
  String serialNumber = "";
  String printerVersion = "";
  final now = DateTime.now();
  DateTime ethio_date =
      EthiopianDateConverter.convertToEthiopianDate(DateTime.now());
  double totalMoney = 0.0;
  @override
  void initState() {
    super.initState();
    setState(() {
      setState(() {
        try {
          if (widget.totalCapacity.isNotEmpty && widget.tariff.isNotEmpty) {
            totalMoney =
                int.parse(widget.totalCapacity) * double.parse(widget.tariff);
            totalMoney = double.parse(totalMoney.toStringAsFixed(3));
          } else {
            print("totalCapacity or tariff is empty");
          }
        } catch (e) {
          print("Error parsing totalCapacity or tariff: $e");
        }
      });
    });

    _bindingPrinter().then((bool? isBind) async {
      SunmiPrinter.paperSize().then((int size) {
        setState(() {
          paperSize = size;
        });
      });

      SunmiPrinter.printerVersion().then((String version) {
        setState(() {
          printerVersion = version;
        });
      });

      SunmiPrinter.serialNumber().then((String serial) {
        setState(() {
          serialNumber = serial;
        });
      });

      setState(() {
        printBinded = isBind!;
      });
    });
  }

  void _saveReport(String agent, String amount, String plate) async {
    print(agent);
    print(amount);
    print(plate);
    DateTime today = DateTime.now();
    ReportLocalDataSource dataSource = ReportLocalDataSource();

    // Parse amount as double
    double amountValue = double.parse(amount);
    // Convert double to int
    int amountInt = amountValue.toInt();
    // Calculate the totalServiceFee as 2% of the amount
    double serviceFee = amountValue * 0.02;
    print('report save func pressed');

    // Create a ReportModel instance
    ReportModel report = ReportModel(
      name: agent,
      amount: amountInt, // Use amountInt instead of amountValue
      totalServiceFee: serviceFee,
      date: today.toString(),
      plate: plate,
    );

    await dataSource.setReport(report); // Save the report to the database
  }

  // void _saveReport(String agent, String amount, String plate) async {
  //   print(agent);
  //   print(amount);
  //   print(plate);
  //   DateTime today = DateTime.now();
  //   ReportLocalDataSource dataSource = ReportLocalDataSource();
  //   int amountInt = int.parse(amount);
  //   // Calculate the totalServiceFee as 2% of the amount
  //   double amountValue = double.parse(amount);
  //   double serviceFee = amountValue * 0.02;
  //   print('report save func pressed');

  //   // Create a ReportModel instance
  //   ReportModel report = ReportModel(
  //     name: agent,
  //     amount: amountInt, // Convert amount to int
  //     totalServiceFee: serviceFee,
  //     date: today.toString(),
  //     plate: plate,
  //   );

  //   await dataSource.setReport(report); // Save the report to the database
  // }

  /// must binding ur printer at first init in app
  Future<bool?> _bindingPrinter() async {
    final bool? result = await SunmiPrinter.bindingPrinter();
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('መውጫ ቲኬት ማተሚያ'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
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
                          "Queue Information",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        const Text(
                          "Sa'aatii itti bahe:",
                          style: TextStyle(
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
                    Row(
                      children: [
                        const Text(
                          "Level: ",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.level,
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
                          "Plate No: ",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.plateNo,
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
                          "Buufata: ",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          widget.station,
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
                          "Magaalaa Gahumsaa: ",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          widget.destination,
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
                          "Fageenya: ",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "${widget.distance} km",
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
                          "Single Tariff: ",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "${widget.tariff} birr",
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
                          "Tessoo: ",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "${widget.totalCapacity} ",
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
                          "Total: ",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "${totalMoney} birr",
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
                  child: Bbar.BarcodeWidget(
                    barcode: Bbar.Barcode.code128(),
                    data: '12345765',
                    width: 200,
                    height: 100,
                  ),
                ),
              ),
              const Divider(),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                        onPressed: () async {
                          _saveReport(
                            widget.agent,
                            totalMoney.toString(),
                            widget.plateNo,
                          );
                          await printTickets();
                        },
                        child: const Text('Print Ticket')),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  Future<void> printTickets() async {
    print('መውጫ ታትሟል');
    final DateTime today = DateTime.now();
    String uniqueCounter =
        generateUniqueCounter(today, widget.plateNo[0].codeUnitAt(0));

    // Save the report to the database

    await SunmiPrinter.initPrinter();
    await SunmiPrinter.startTransactionPrint(true);
    Uint8List dalex = await _getImageFromAsset('assets/images/Untitled-2.jpg');

    await SunmiPrinter.startTransactionPrint(true);
    await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
    await SunmiPrinter.printImage(dalex);
    // await SunmiPrinter.lineWrap(1);
    await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
    await SunmiPrinter.bold();
    await SunmiPrinter.printText('Tikeetii Bahumsaa!');
    // await SunmiPrinter.line();
    await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);

    await SunmiPrinter.bold();
    await SunmiPrinter.printText(
        "Guyyaa ------------------${ethio_date.day.toString()}/${ethio_date.month.toString()}/${ethio_date.year.toString()}:-${ethio_date.hour.toString()}:${ethio_date.minute.toString()}",
        style: SunmiStyle(fontSize: SunmiFontSize.SM));

    await SunmiPrinter.bold();
    await SunmiPrinter.printText("Agent ------------------${widget.agent}",
        style: SunmiStyle(fontSize: SunmiFontSize.SM));

    await SunmiPrinter.bold();
    await SunmiPrinter.printText(
        "Lakkoofsa gabatee --------------${widget.plateNo}",
        style: SunmiStyle(fontSize: SunmiFontSize.SM));

    await SunmiPrinter.bold();
    await SunmiPrinter.printText("Sadarkaa ------------------${widget.level}",
        style: SunmiStyle(fontSize: SunmiFontSize.SM));

    await SunmiPrinter.bold();
    await SunmiPrinter.printText("Ka'umsaa ----------------${widget.station}",
        style: SunmiStyle(fontSize: SunmiFontSize.SM));

    await SunmiPrinter.bold();
    await SunmiPrinter.printText(
        "Gahunsaa ------------------${widget.destination}",
        style: SunmiStyle(fontSize: SunmiFontSize.SM));
    await SunmiPrinter.bold();
    await SunmiPrinter.printText(
        "Fageenya ------------------${widget.distance} km",
        style: SunmiStyle(fontSize: SunmiFontSize.SM));
    await SunmiPrinter.bold();
    await SunmiPrinter.printText(
        "Dhaabbata ------------------${widget.association}",
        style: SunmiStyle(fontSize: SunmiFontSize.SM));
    await SunmiPrinter.bold();
    await SunmiPrinter.printText(
        "Tessoo ------------------${widget.totalCapacity}",
        style: SunmiStyle(fontSize: SunmiFontSize.SM));
    await SunmiPrinter.bold();
    await SunmiPrinter.printText(
        "Total birr ------------------${totalMoney} birr",
        style: SunmiStyle(fontSize: SunmiFontSize.SM));

    await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
    await SunmiPrinter.printBarCode(uniqueCounter, height: 30);
    await SunmiPrinter.lineWrap(2);
    await SunmiPrinter.printText('Huubachiisa: Tikeetiin kun emala yeroo');
    await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
    await SunmiPrinter.printText('tokkoo qofaaf tajaajila!');
    await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
    await SunmiPrinter.printText('Inala gaarii!!');
    await SunmiPrinter.lineWrap(2);
    await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
    await SunmiPrinter.printText('Powered by: Dalex ',
        style: SunmiStyle(fontSize: SunmiFontSize.XS));

    await SunmiPrinter.exitTransactionPrint(true);
  }
}

Future<Uint8List> _getImageFromAsset(String iconPath) async {
  return await readFileBytes(iconPath);
}

Future<Uint8List> readFileBytes(String path) async {
  ByteData fileData = await rootBundle.load(path);
  Uint8List fileUnit8List = fileData.buffer
      .asUint8List(fileData.offsetInBytes, fileData.lengthInBytes);
  return fileUnit8List;
}
