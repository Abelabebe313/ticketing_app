import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:transport_app/bloc/upload/upload_bloc.dart';
import 'package:transport_app/bloc/upload/upload_event.dart';
import 'package:transport_app/bloc/upload/upload_state.dart';
import 'package:transport_app/core/my_colors.dart';
import 'package:transport_app/models/report.dart';

import '../../data/report.dart';

class SoldTickets extends StatefulWidget {
  const SoldTickets({Key? key}) : super(key: key);

  @override
  SoldTicketsState createState() => SoldTicketsState();
}

class SoldTicketsState extends State<SoldTickets> {
  double totalCommission = 0.0;
  int totalticket = 0;
  int totalCars = 0;
  bool _isLoading = false;
  List<ReportModel> _reportList = [];
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadTotalCommission();
    _loadReportList();
  }

 
  Future<void> _uploadReports() async {
    setState(() {
      _isUploading = true;
    });

    try {
      for (ReportModel report in _reportList) {
        BlocProvider.of<UploadBloc>(context)
            .add(UploadReportEvent(report: report));
      }

      await ReportLocalDataSource().clearReports();
      _loadReportList(); // Reload the list after clearing
    } catch (e) {
      // Handle any errors here
      print('Error uploading reports: $e');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _loadReportList() async {
    try {
      List<ReportModel> reports = await ReportLocalDataSource().getAllReport();
      setState(() {
        _reportList = reports;
      });
    } catch (e) {
      print('Error loading report list: $e');
      // Handle error accordingly
    }
  }

  Future<void> _loadTotalCommission() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      totalCommission = prefs.getDouble('dailyReport') ?? 0.0;
      totalticket = prefs.getInt('totalTicket') ?? 0;
      totalCars = prefs.getInt('totalCars') ?? 0;
    });
  }

  Future<void> _clearCommission() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('dailyReport');
    await prefs.remove('totalTicket');
    await prefs.remove('totalCars');
    setState(() {
      totalCommission = 0.0;
      totalticket = 0;
      totalCars = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UploadBloc, UploadState>(
      listener: (context, state) {
        if (state is UploadedReportState) {
          setState(() {
            _isLoading = false;
          });
        } else if (state is UploadLoading) {
          setState(() {
            _isLoading = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Report Uploaded"),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        } else if (state is UploadError) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
          setState(() {
            _isLoading = false;
          });
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Sold tickets'.tr(),
              style: const TextStyle(
                fontSize: 18,
                fontFamily: 'Poppins-Regular',
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              SizedBox(
                width: 110,
                height: 40,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: MyColors.primary, elevation: 0),
                  onPressed: _isUploading ? null : _uploadReports,
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : Text(
                          "Upload".tr(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontFamily: 'Poppins-Regular',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
            ],
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const SizedBox(width: 10),
                  Container(
                    width: 100,
                    height: 120,
                    decoration: BoxDecoration(
                      color: MyColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 10),
                        Text(
                          'Cars',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontFamily: 'Poppins-Regular',
                          ),
                        ),
                        Text(
                          totalCars.toString(),
                          style: const TextStyle(
                            fontSize: 22,
                            color: Colors.white,
                            fontFamily: 'Poppins-Regular',
                          ),
                        ),
                        Icon(
                          Icons.directions_car,
                          color: Colors.white,
                          size: 40,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 100,
                    height: 120,
                    decoration: BoxDecoration(
                      color: MyColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        Text(
                          'Tickets',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontFamily: 'Poppins-Regular',
                          ),
                        ),
                        Text(
                          totalticket.toString(),
                          style: const TextStyle(
                            fontSize: 22,
                            color: Colors.white,
                            fontFamily: 'Poppins-Regular',
                          ),
                        ),
                        Icon(
                          Ionicons.ticket,
                          color: Colors.white,
                          size: 40,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 100,
                    height: 120,
                    decoration: BoxDecoration(
                      color: MyColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        Text(
                          'Commission',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontFamily: 'Poppins-Regular',
                          ),
                        ),
                        Text(
                          totalCommission.toStringAsFixed(3),
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontFamily: 'Poppins-Regular',
                          ),
                        ),
                        Icon(
                          Ionicons.cash,
                          color: Colors.white,
                          size: 40,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 85,
                    height: 40,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: MyColors.primary, elevation: 0),
                      child: const Text(
                        "Clear",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontFamily: 'Poppins-Regular',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      onPressed: () async {
                        bool clearConfirmed = await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Clear Commission'),
                            content: const Text(
                                'Are you sure you want to clear the commission?'),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: Text('Clear'),
                              ),
                            ],
                          ),
                        );

                        if (clearConfirmed == true) {
                          await _clearCommission();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  child: const Text(
                    'Report List: ',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Poppins-Regular',
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _reportList.length,
                  itemBuilder: (context, index) {
                    ReportModel report = _reportList[index];
                    return ListTile(
                      title: Text('Name: ${report.name}'),
                      subtitle: Text('Plate: ${report.plate}'),
                      trailing: Text('Date: ${report.date}'),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
