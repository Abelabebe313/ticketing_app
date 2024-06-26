// import 'package:flutter/material.dart';
// import 'package:transport_app/models/queue_model.dart';
// import 'package:transport_app/presentation/widgets/queue_details_card.dart';
// import 'package:ionicons/ionicons.dart';

// class BusQueueCardWidget extends StatelessWidget {
//   String station;
//   String plateNo;
//   String? association;
//   String? date;
//   String time;
//   final VoidCallback onRemove;
//   BusQueueCardWidget({
//     Key? key,
//     required this.station,
//     required this.plateNo,
//     required this.association,
//     this.date,
//     required this.time,
//     required this.onRemove,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         showDialog(
//           context: context,
//           builder: (BuildContext context) {
//             return BusDetailsPopup(
//               busDetails: QueueModel(
//                 station: station,
//                 plateNumber: plateNo,
//                 date: date!,
//                 time: time,
//                 association: association!,
//               ),
//             );
//           },
//         );
//       },
//       child: Container(
//         margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//         width: MediaQuery.of(context).size.width * 0.9,
//         height: MediaQuery.of(context).size.height * 0.1,
//         decoration: BoxDecoration(
//           color: Colors.grey.shade100,
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 30,
//               height: 30,
//               margin: const EdgeInsets.only(left: 10),
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade400,
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: const Center(
//                 child: Icon(Ionicons.bus),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.only(left: 10),
//               child: Text(
//                 plateNo, // plate number goes here
//                 style: const TextStyle(
//                   color: Colors.black,
//                   fontSize: 14,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             // const Spacer(),
//             // const Icon(Icons.access_time),
//             const SizedBox(width: 10),
//             Padding(
//               padding: const EdgeInsets.only(right: 5),
//               child: Text(
//                 date!, // date goes here
//                 style: const TextStyle(
//                   color: Colors.black,
//                   fontSize: 14,
//                 ),
//               ),
//             ),
//             // Column(
//             //   mainAxisAlignment: MainAxisAlignment.center,
//             //   children: [
//             //     Padding(
//             //       padding: const EdgeInsets.only(right: 20),
//             //       child: Text(
//             //         date!, // date goes here
//             //         style: const TextStyle(
//             //           color: Colors.black,
//             //           fontSize: 14,
//             //         ),
//             //       ),
//             //     ),
//             //     Padding(
//             //       padding: const EdgeInsets.only(right: 20),
//             //       child: Text(
//             //         time,
//             //         style: const TextStyle(
//             //           color: Colors.black,
//             //           fontSize: 14,
//             //         ),
//             //       ),
//             //     ),
//             //   ],
//             // ),
//             IconButton(
//               onPressed: onRemove,
//               icon: const Icon(
//                 Icons.delete,
//                 color: Colors.red,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
