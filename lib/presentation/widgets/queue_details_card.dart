// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:sunmi_printer_plus/column_maker.dart';
// import 'package:sunmi_printer_plus/enums.dart';
// import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';
// import 'package:transport_app/core/my_colors.dart';
// import 'package:transport_app/core/my_text.dart';
// import 'package:transport_app/models/queue_model.dart';
// import 'package:transport_app/presentation/result/sunmi_printer.dart';

// class BusDetailsPopup extends StatefulWidget {
//   final QueueModel busDetails;

//   const BusDetailsPopup({required this.busDetails});

//   @override
//   State<BusDetailsPopup> createState() => _BusDetailsPopupState();
// }

// TextEditingController distanceController = TextEditingController();
// TextEditingController destinationController = TextEditingController();

// class _BusDetailsPopupState extends State<BusDetailsPopup> {
//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: Text('Queue Details'.tr()),
//       content: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text('Plate No: ${widget.busDetails.plateNumber}'),
//             Text('Date: ${widget.busDetails.date}'),
//             Text('Time: ${widget.busDetails.time}'),
//             Text('Association: ${widget.busDetails.association}'),
//             Container(
//               height: 50,
//               width: MediaQuery.of(context).size.width * 0.55,
//               alignment: Alignment.topRight,
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               child: TextField(
//                 maxLines: 1,
//                 controller: destinationController,
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontFamily: 'Poppins-Light',
//                   fontWeight: FontWeight.bold,
//                 ),
//                 decoration: const InputDecoration(
//                   hintText: 'Enter Destination',
//                   contentPadding: EdgeInsets.all(-12),
//                 ),
//               ),
//             ),
//             Container(
//               height: 50,
//               width: MediaQuery.of(context).size.width * 0.55,
//               alignment: Alignment.topRight,
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               child: TextField(
//                 maxLines: 1,
//                 keyboardType: TextInputType.number,
//                 controller: distanceController,
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontFamily: 'Poppins-Light',
//                   fontWeight: FontWeight.bold,
//                 ),
//                 decoration: const InputDecoration(
//                   hintText: 'Enter Distance',
//                   contentPadding: EdgeInsets.all(-12),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//       actions: [
//         SizedBox(
//           width: double.infinity,
//           height: 45,
//           child: ElevatedButton(
//             style: ElevatedButton.styleFrom(
//                 backgroundColor: MyColors.primary, elevation: 0),
//             child: Text("Print".tr(),
//                 style: MyText.subhead(context)!.copyWith(color: Colors.white)),
//             onPressed: () {
//               Navigator.push(context, MaterialPageRoute(builder: (context) {
//                 return SunmiPrinterPage(
//                   date: widget.busDetails.date,
//                   time: widget.busDetails.time,
//                   station: widget.busDetails.station,
//                   plateNo: widget.busDetails.plateNumber,
//                   association: widget.busDetails.association,
//                   distance: distanceController.text,
//                   destination: destinationController.text,
//                 );
//               }));
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }
