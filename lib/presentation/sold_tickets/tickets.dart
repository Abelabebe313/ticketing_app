import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transport_app/bloc/upload/upload_bloc.dart';
import 'package:transport_app/bloc/upload/upload_event.dart';
import 'package:transport_app/bloc/upload/upload_state.dart';
import 'package:transport_app/core/my_colors.dart';
import 'package:transport_app/models/report.dart';

class SoldTickets extends StatefulWidget {
  const SoldTickets({Key? key});

  @override
  SoldTicketsState createState() => SoldTicketsState();
}

class SoldTicketsState extends State<SoldTickets> {
  double totalCommission = 0.0;
  @override
  void initState() {
    super.initState();
    _loadTotalCommission();
  }

  Future<void> _loadTotalCommission() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      totalCommission = prefs.getDouble('dailyReport') ?? 0.0;
    });
  }

  Future<void> _clearCommission() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('dailyReport');
    setState(() {
      totalCommission = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sold tickets'.tr(),
          style: const TextStyle(
            fontSize: 18,
            fontFamily: 'Poppins-Regular',
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              child: Text(
                'Waliigala tikkeettii gurgurame: ',
                style: const TextStyle(
                  fontSize: 18,
                  fontFamily: 'Poppins-Regular',
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              child: Text(
                '${double.parse(totalCommission.toStringAsFixed(3))} birr',
                style: const TextStyle(
                  fontSize: 24,
                  fontFamily: 'Poppins-Regular',
                ),
              ),
            ),
          ),
          Center(
            child: SizedBox(
              width: 200,
              height: 40,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: MyColors.primary, elevation: 0),
                child: const Text(
                  "Ifaa",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'Poppins-Regular',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () async {
                  // Show confirmation dialog
                  bool clearConfirmed = await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Clear Commission'),
                      content: const Text(
                          'Kaffaltii tajaajilaa qulqulleessuu akka barbaaddu mirkaneeffatteettaa?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: Text('Clear'),
                        ),
                      ],
                    ),
                  );

                  // Clear commission if user confirmed
                  if (clearConfirmed == true) {
                    await _clearCommission();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
