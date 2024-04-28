import 'dart:typed_data';
import 'package:barcode_widget/barcode_widget.dart' as Bbar;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sunmi_printer_plus/column_maker.dart';
import 'package:sunmi_printer_plus/enums.dart';
import 'dart:async';

import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';

class SunmiPrinterPage extends StatefulWidget {
  final String time;
  final String date;
  final String station;
  final String plateNo;
  final String association;
  final String distance;
  final String destination;
  const SunmiPrinterPage(
      {Key? key,
      required this.time,
      required this.date,
      required this.station,
      required this.plateNo,
      required this.association,
      required this.distance,
      required this.destination})
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
  @override
  void initState() {
    super.initState();

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
                          "Sa'aatii itti seene: ",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${widget.date}-${widget.time}',
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
                          "Sa'aatii itti bahe",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${now.day.toString()}/${now.month.toString()}/${now.year.toString()}-${now.hour.toString()}:${now.minute.toString()}:${now.second.toString()}', // time goes here
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
                    const Row(
                      children: [
                        Text(
                          "Magaalaa Gahumsaa",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Addis Ababa',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Text(
                          "Fageenya",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          widget.distance,
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
                          print('print pressed');
                          await SunmiPrinter.initPrinter();
                          await SunmiPrinter.startTransactionPrint(true);
                          Uint8List dalex = await _getImageFromAsset(
                              'assets/images/Untitled-2.jpg');

                          await SunmiPrinter.startTransactionPrint(true);
                          await SunmiPrinter.setAlignment(
                              SunmiPrintAlign.CENTER);
                          await SunmiPrinter.printImage(dalex);
                          await SunmiPrinter.lineWrap(1);
                          await SunmiPrinter.setAlignment(
                              SunmiPrintAlign.CENTER);
                          await SunmiPrinter.bold();
                          await SunmiPrinter.printText('Tikeetii Bahumsaa!');
                          await SunmiPrinter.line();
                          await SunmiPrinter.setAlignment(
                              SunmiPrintAlign.CENTER);

                          await SunmiPrinter.printRow(cols: [
                            ColumnMaker(
                                text: "Sa'aatii itti seene",
                                width: 18,
                                align: SunmiPrintAlign.LEFT),
                            ColumnMaker(
                                text: '${widget.date}-${widget.time}',
                                width: 12,
                                align: SunmiPrintAlign.RIGHT),
                          ]);
                          await SunmiPrinter.printRow(cols: [
                            ColumnMaker(
                                text: "Sa'aatii itti bahe",
                                width: 18,
                                align: SunmiPrintAlign.LEFT),
                            ColumnMaker(
                                text:
                                    '${now.month.toString()}/${now.day.toString()}/${now.year.toString()}-${now.hour.toString()}:${now.minute.toString()}:${now.second.toString()}', // time goes here
                                width: 12,
                                align: SunmiPrintAlign.RIGHT),
                          ]);

                          await SunmiPrinter.printRow(cols: [
                            ColumnMaker(
                                text: "Lakkoofsa gabatee",
                                width: 18,
                                align: SunmiPrintAlign.LEFT),
                            ColumnMaker(
                                text: widget.plateNo,
                                width: 12,
                                align: SunmiPrintAlign.RIGHT),
                          ]);

                          await SunmiPrinter.printRow(cols: [
                            ColumnMaker(
                              text: "Buufata:",
                              width: 18,
                              align: SunmiPrintAlign.LEFT,
                            ),
                            ColumnMaker(
                                text: widget.station,
                                width: 12,
                                align: SunmiPrintAlign.RIGHT),
                          ]);

                          await SunmiPrinter.printRow(cols: [
                            ColumnMaker(
                              text: "Magaalaa Gahumsaa",
                              width: 18,
                              align: SunmiPrintAlign.LEFT,
                            ),
                            ColumnMaker(
                              text: widget.destination,
                              width: 12,
                              align: SunmiPrintAlign.RIGHT,
                            ),
                          ]);
                          await SunmiPrinter.printRow(cols: [
                            ColumnMaker(
                              text: "Fageenya",
                              width: 18,
                              align: SunmiPrintAlign.LEFT,
                            ),
                            ColumnMaker(
                              text: widget.distance,
                              width: 12,
                              align: SunmiPrintAlign.RIGHT,
                            ),
                          ]);
                          await SunmiPrinter.printRow(cols: [
                            ColumnMaker(
                              text: "dhaabbata",
                              width: 18,
                              align: SunmiPrintAlign.LEFT,
                            ),
                            ColumnMaker(
                              text: widget.association,
                              width: 12,
                              align: SunmiPrintAlign.RIGHT,
                            ),
                          ]);

                          await SunmiPrinter.setAlignment(
                              SunmiPrintAlign.CENTER);
                          await SunmiPrinter.lineWrap(2);
                          await SunmiPrinter.printText(
                              'Huubachiisa: Tikeetiin kun emala yeroo');
                          await SunmiPrinter.setAlignment(
                              SunmiPrintAlign.CENTER);
                          await SunmiPrinter.printText(
                              'tokkoo qofaaf tajaajila!');
                          await SunmiPrinter.setAlignment(
                              SunmiPrintAlign.CENTER);
                          await SunmiPrinter.printText('Inala gaarii!!');
                          await SunmiPrinter.lineWrap(2);

                          await SunmiPrinter.exitTransactionPrint(true);
                        },
                        child: const Text('Print Ticket')),
                  ],
                ),
              ),
            ],
          ),
        ));
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
