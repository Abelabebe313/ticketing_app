import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  bool _isLoading = false;
  List<ReportModel> _reportList = [];

  @override
  void initState() {
    super.initState();
    _loadTotalCommission();
    _loadReportList();
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
    });
  }

  Future<void> _clearCommission() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('dailyReport');
    await prefs.remove('totalTicket');
    setState(() {
      totalCommission = 0.0;
      totalticket = 0;
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
              ),
            ),
            actions: [
              SizedBox(
                width: 110,
                height: 40,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: MyColors.primary, elevation: 0),
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
                  onPressed: () async {
                    for (ReportModel report in _reportList) {
                      BlocProvider.of<UploadBloc>(context)
                          .add(UploadReportEvent(report: report));
                    }
                    await ReportLocalDataSource().clearReports();
                    _loadReportList(); // Removed await here
                  },
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
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  child: Text(
                    'Total Commission and Ticket: ',
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'Poppins-Regular',
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  const SizedBox(width: 5),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      child: Text(
                        '${totalticket} ticket :- ',
                        style: const TextStyle(
                          fontSize: 20,
                          fontFamily: 'Poppins-Regular',
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: Container(
                      child: Text(
                        '${totalCommission.toStringAsFixed(3)} birr',
                        style: const TextStyle(
                          fontSize: 20,
                          fontFamily: 'Poppins-Regular',
                        ),
                      ),
                    ),
                  ),
                  Spacer(),
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
                  const SizedBox(width: 10),
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
