// // ignore_for_file: public_member_api_docs, sort_constructors_first
// import 'dart:convert';
// import 'dart:typed_data';

// import 'package:blue_print_pos/blue_print_pos.dart';
// import 'package:blue_print_pos/models/models.dart';
// import 'package:blue_print_pos/receipt/receipt.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:transport_app/models/report.dart';
// import 'package:transport_app/models/ticket.dart';

// class TicketPrintingPage extends StatefulWidget {
//   final int totalCapacity;
//   final int numberOfTickets;
//   final Ticket ticket;
//   TicketPrintingPage({
//     Key? key,
//     required this.totalCapacity,
//     required this.numberOfTickets,
//     required this.ticket,
//   }) : super(key: key);
//   @override
//   _TicketPrintingPageState createState() => _TicketPrintingPageState();
// }

// class _TicketPrintingPageState extends State<TicketPrintingPage> {
//   final BluePrintPos _bluePrintPos = BluePrintPos.instance;
//   List<BlueDevice> _blueDevices = <BlueDevice>[];
//   BlueDevice? _selectedDevice;
//   bool _isLoading = false;
//   int _loadingAtIndex = -1;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.blue,
//         foregroundColor: Colors.white,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           'የጉዞ ቲኬት ማተሚያ',
//           style: TextStyle(
//             color: Colors.white,
//           ),
//         ),
//       ),
//       body: SafeArea(
//         child: _isLoading && _blueDevices.isEmpty
//             ? const Center(
//                 child: CircularProgressIndicator(
//                   valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
//                 ),
//               )
//             : _blueDevices.isNotEmpty
//                 ? SingleChildScrollView(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: <Widget>[
//                         Column(
//                           children: List<Widget>.generate(_blueDevices.length,
//                               (int index) {
//                             return Row(
//                               children: <Widget>[
//                                 Expanded(
//                                   child: GestureDetector(
//                                     onTap: _blueDevices[index].address ==
//                                             (_selectedDevice?.address ?? '')
//                                         ? _onDisconnectDevice
//                                         : () => _onSelectDevice(index),
//                                     child: Padding(
//                                       padding: const EdgeInsets.all(8.0),
//                                       child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: <Widget>[
//                                           Text(
//                                             _blueDevices[index].name,
//                                             style: TextStyle(
//                                               color: _selectedDevice?.address ==
//                                                       _blueDevices[index]
//                                                           .address
//                                                   ? Colors.blue
//                                                   : Colors.black,
//                                               fontSize: 20,
//                                               fontWeight: FontWeight.w500,
//                                             ),
//                                           ),
//                                           Text(
//                                             _blueDevices[index].address,
//                                             style: TextStyle(
//                                               color: _selectedDevice?.address ==
//                                                       _blueDevices[index]
//                                                           .address
//                                                   ? Colors.blueGrey
//                                                   : Colors.grey,
//                                               fontSize: 14,
//                                               fontWeight: FontWeight.w500,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 if (_loadingAtIndex == index && _isLoading)
//                                   Container(
//                                     height: 24.0,
//                                     width: 24.0,
//                                     margin: const EdgeInsets.only(right: 8.0),
//                                     child: const CircularProgressIndicator(
//                                       valueColor: AlwaysStoppedAnimation<Color>(
//                                         Colors.blue,
//                                       ),
//                                     ),
//                                   ),
//                                 if (!_isLoading &&
//                                     _blueDevices[index].address ==
//                                         (_selectedDevice?.address ?? ''))
//                                   TextButton(
//                                     onPressed: _onPrintReceipt,
//                                     style: ButtonStyle(
//                                       backgroundColor: MaterialStateProperty
//                                           .resolveWith<Color>(
//                                         (Set<MaterialState> states) {
//                                           if (states.contains(
//                                               MaterialState.pressed)) {
//                                             return Theme.of(context)
//                                                 .colorScheme
//                                                 .primary
//                                                 .withOpacity(0.5);
//                                           }
//                                           return Theme.of(context).primaryColor;
//                                         },
//                                       ),
//                                     ),
//                                     child: Container(
//                                       color: _selectedDevice == null
//                                           ? Colors.grey
//                                           : Colors.blue,
//                                       padding: const EdgeInsets.all(8.0),
//                                       child: Text(
//                                         'Print'.tr(),
//                                         style: TextStyle(color: Colors.white),
//                                       ),
//                                     ),
//                                   ),
//                               ],
//                             );
//                           }),
//                         ),
//                       ],
//                     ),
//                   )
//                 : const Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: <Widget>[
//                         Text(
//                           'Scan bluetooth device',
//                           style: TextStyle(fontSize: 24, color: Colors.blue),
//                         ),
//                         Text(
//                           'Press button scan',
//                           style: TextStyle(fontSize: 14, color: Colors.grey),
//                         ),
//                       ],
//                     ),
//                   ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _isLoading ? null : _onScanPressed,
//         child: Icon(Icons.search),
//         backgroundColor: _isLoading ? Colors.grey : Colors.blue,
//       ),
//     );
//   }

//   Future<void> _onScanPressed() async {
//     setState(() => _isLoading = true);
//     _bluePrintPos.scan().then((List<BlueDevice> devices) {
//       if (devices.isNotEmpty) {
//         setState(() {
//           _blueDevices = devices;
//           _isLoading = false;
//         });
//       } else {
//         setState(() => _isLoading = false);
//       }
//     });
//   }

//   void _onDisconnectDevice() {
//     _bluePrintPos.disconnect().then((ConnectionStatus status) {
//       if (status == ConnectionStatus.disconnect) {
//         setState(() {
//           _selectedDevice = null;
//         });
//       }
//     });
//   }

//   void _saveReportLocally(ReportModel report) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     List<String> reportsJson = prefs.getStringList('reports') ?? [];
//     reportsJson.add(jsonEncode(report.toJson()));
//     prefs.setStringList('reports', reportsJson);
//   }
//   void _onSelectDevice(int index) {
//     setState(() {
//       _isLoading = true;
//       _loadingAtIndex = index;
//     });
//     final BlueDevice blueDevice = _blueDevices[index];
//     _bluePrintPos.connect(blueDevice).then((ConnectionStatus status) {
//       if (status == ConnectionStatus.connected) {
//         setState(() => _selectedDevice = blueDevice);
//       } else if (status == ConnectionStatus.timeout) {
//         _onDisconnectDevice();
//       } else {
//         print('$runtimeType - something wrong');
//       }
//       setState(() => _isLoading = false);
//     });
//   }

//   Future<void> _onPrintReceipt() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String tailorpref = prefs.getString('username') ?? '[]';
//     /// Example for Print Text
//     final ReceiptSectionText receiptText = ReceiptSectionText();

//     receiptText.addSpacer();
//     receiptText.addText(
//       'Tikeetii imaltootaa/የተጓዥ ቲኬት',
//       size: ReceiptTextSizeType.large,
//       style: ReceiptTextStyleType.bold,
//       // alignment: ReceiptAlignment.center,
//     );
//     receiptText.addSpacer(useDashed: true);
//     receiptText.addLeftRightText(
//       "የትኬት ቁጥር/Lakkoofsa tikkeettii:-",
//       "${widget.ticket.uniqueId}",
//       leftSize: ReceiptTextSizeType.medium,
//       rightSize: ReceiptTextSizeType.medium,
//     );
//     receiptText.addLeftRightText(
//       "ታርጋ/ gabatee:-",
//       "${widget.ticket.plate}",
//       leftSize: ReceiptTextSizeType.medium,
//       rightSize: ReceiptTextSizeType.medium,
//     );
//     receiptText.addLeftRightText(
//       "ትኬት ቆራጭ/Tikeetii kan fudhatu:-",
//       "${widget.ticket.tailure}",
//       leftSize: ReceiptTextSizeType.medium,
//       rightSize: ReceiptTextSizeType.medium,
//     );
//     receiptText.addLeftRightText(
//       "የጉዞ ቀን/Guyyaa imala:-",
//       "${widget.ticket.date}",
//       leftSize: ReceiptTextSizeType.medium,
//       rightSize: ReceiptTextSizeType.medium,
//     );
//     receiptText.addLeftRightText(
//       "መነሻ ከተማ/Magaalaa Kaa'umsa:-",
//       "${widget.ticket.departure}",
//       leftSize: ReceiptTextSizeType.medium,
//       rightSize: ReceiptTextSizeType.medium,
//     );
//     receiptText.addLeftRightText(
//       "መዳረሻ ከተማ/Magaalaa itti geessan:-",
//       "${widget.ticket.destination}",
//       leftSize: ReceiptTextSizeType.medium,
//       rightSize: ReceiptTextSizeType.medium,
//     );
//     receiptText.addLeftRightText(
//       "ደረጃ/Sadarkaa:-",
//       "${widget.ticket.level}",
//       leftSize: ReceiptTextSizeType.medium,
//       rightSize: ReceiptTextSizeType.medium,
//     );
//     receiptText.addLeftRightText(
//       "ታሪፍ/Taarifa:-",
//       "${widget.ticket.tariff}",
//       leftSize: ReceiptTextSizeType.medium,
//       rightSize: ReceiptTextSizeType.medium,
//     );
//     receiptText.addLeftRightText(
//       "የአገልግሎት ክፍያ/Kaffaltii Tajaajilaa:-",
//       "${widget.ticket.charge}",
//       leftSize: ReceiptTextSizeType.medium,
//       rightSize: ReceiptTextSizeType.medium,
//     );
//     receiptText.addSpacer(useDashed: true);
//     receiptText.addSpacer(useDashed: true);
//     receiptText.addLeftRightText(
//         "Huubachiisa:", "Tikeetiin kun emala yeroo tokkoo qofaaf tajaajila");
//     receiptText.addSpacer(useDashed: true);
//     receiptText.addSpacer(useDashed: true);
//     receiptText.addLeftRightText(
//         "ማሳሰቢያ:", "ይህ የመውጫ ትኬት ለአንድ ጉዞ ብቻ የሚያገለግል ነው!");
//     receiptText.addText('Powered by Dalex Import',
//         size: ReceiptTextSizeType.small);

//     for (int i = 0; i < widget.numberOfTickets; i++) {
//       String plateNumber = widget.ticket.plate;
//       int currentCount = prefs.getInt(plateNumber) ?? 0;
//       prefs.setInt(plateNumber, currentCount + 1);

//       int count = prefs.getInt(widget.ticket.plate) ?? 0;
//       if (widget.totalCapacity == count) {
//         String currentDate = DateTime.now().toLocal().toString().split(' ')[0];
//         // Create a ReportModel
//         ReportModel report = ReportModel(
//           name: tailorpref, // Add the actual name
//           amount: count, // Add the actual amount
//           date: currentDate, // Add the actual date
//           plate: plateNumber,
//         );
//         // Save the ReportModel locally using shared_preferences
//         _saveReportLocally(report);
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("የትኬት ቁጥሩ ስለሞላ አባኮትን መውጫ ይቁረጡለት"),
//             backgroundColor: Colors.blue,
//             duration: const Duration(seconds: 2),
//           ),
//         );
//       }
//       // final that print receipt
//       await _bluePrintPos.printReceiptText(receiptText);
//     }
//   }
// }
