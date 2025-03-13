import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transport_app/bloc/upload/upload_bloc.dart';
import 'package:transport_app/bloc/upload/upload_event.dart';
import 'package:transport_app/bloc/upload/upload_state.dart';
import 'package:transport_app/core/my_colors.dart';
import 'package:transport_app/data/db_helper.dart';
import 'package:transport_app/data/ticket_data_source.dart';
import 'package:transport_app/models/report.dart';
import 'package:transport_app/models/ticket.dart';
import 'package:transport_app/services/report_upload.dart';

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
  List<Ticket> _unuploadedTickets = [];
  bool _isUploading = false;
  bool _uploadSuccessful = false;
  final TicketDataSource _ticketDataSource = TicketDataSource();
  final ReportService _reportService = ReportService();

  @override
  void initState() {
    super.initState();
    _initializeDatabase(); 
    _loadTotalCommission();
    _loadReportList();
    _loadUnuploadedTickets();
  }

  Future<void> _loadUnuploadedTickets() async {
    try {
      List<Ticket> tickets = await _ticketDataSource.getUnuploadedTickets();
      setState(() {
        _unuploadedTickets = tickets;
      });
    } catch (e) {
      print('Error loading unuploaded tickets: $e');
    }
  }

  Future<void> _uploadReports() async {
    // Check if there are either reports or unuploaded tickets
    bool hasDataToUpload = _reportList.isNotEmpty || _unuploadedTickets.isNotEmpty;
    
    if (!hasDataToUpload) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No data to upload'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
      _isLoading = true;
    });

    try {
      // If we have reports, use the regular upload method that handles both reports and tickets
      if (_reportList.isNotEmpty) {
        final Map<String, dynamic> result = await _reportService.upload(_reportList);
        print('Upload result: $result');
        
        // Determine overall success and show appropriate messages
        bool reportsSuccess = result['reportsSuccess'] ?? false;
        bool ticketsSuccess = result['ticketsSuccess'] ?? false;
        int reportsUploaded = result['reportsUploaded'] ?? 0;
        int ticketsUploaded = result['ticketsUploaded'] ?? 0;
        List<String> errors = (result['errors'] as List<dynamic>?)?.cast<String>() ?? [];
        
        // Update UI based on results
        setState(() {
          _isLoading = false;
          // Only consider upload successful if BOTH reports and tickets were successful
          _uploadSuccessful = reportsSuccess && ticketsSuccess;
        });
        
        // Show appropriate success/error messages
        if (_uploadSuccessful) {
          // All uploads succeeded
          String message = '';
          if (reportsUploaded > 0 && ticketsUploaded > 0) {
            message = '$reportsUploaded reports and $ticketsUploaded tickets uploaded successfully';
          } else if (reportsUploaded > 0) {
            message = '$reportsUploaded reports uploaded successfully';
          } else if (ticketsUploaded > 0) {
            message = '$ticketsUploaded tickets uploaded successfully';
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
              action: SnackBarAction(
                label: 'Clear',
                textColor: Colors.white,
                onPressed: () async {
                  await _clearReportList();
                  await _clearCommission();
                },
              ),
            ),
          );
          
          // Clear report list if reports were uploaded successfully
          if (reportsSuccess && reportsUploaded > 0) {
            await _clearReportList();
          }
        } else {
          // Some uploads failed
          String errorMessage = errors.join('\n');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Upload incomplete:\n$errorMessage'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
        
        // Refresh ticket list regardless of success/failure
        await _loadUnuploadedTickets();
      } else {
        // If there are only tickets but no reports, upload them directly
        try {
          final result = await _reportService.uploadUnuploadedTicketsOnly();
          bool ticketsSuccess = result['ticketsSuccess'] ?? false;
          int ticketsUploaded = result['ticketsUploaded'] ?? 0;
          
          // Update the UI after ticket upload attempt
          setState(() {
            _isLoading = false;
            _uploadSuccessful = ticketsSuccess;
          });
          
          // Refresh ticket list
          await _loadUnuploadedTickets();
          
          if (ticketsSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$ticketsUploaded tickets uploaded successfully'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
                action: SnackBarAction(
                  label: 'Clear',
                  textColor: Colors.white,
                  onPressed: () async {
                    await _clearCommission();
                  },
                ),
              ),
            );
          } else {
            List<String> errors = (result['errors'] as List<dynamic>?)?.cast<String>() ?? [];
            String errorMessage = errors.isEmpty ? 'Failed to upload tickets' : errors.join('\n');
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        } catch (e) {
          print('Error uploading tickets directly: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to upload tickets: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
          setState(() {
            _isLoading = false;
            _uploadSuccessful = false;
          });
        }
      }
    } catch (e) {
      print('Error dispatching upload event: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to start upload process: $e'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoading = false;
        _uploadSuccessful = false;
      });
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
      _uploadSuccessful = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UploadBloc, UploadState>(
      listener: (context, state) {
        if (state is UploadedReportState) {
          setState(() {
            _isLoading = false;
            _uploadSuccessful = true;
          });
          _clearReportList();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Report Uploaded"),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        } else if (state is UploadLoading) {
          setState(() {
            _isLoading = true;
          });
        } else if (state is UploadError) {
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
                  _buildInfoCard('Cars', totalCars.toString(), Icons.directions_car),
                  _buildInfoCard('Tickets', totalticket.toString(), Ionicons.ticket),
                  _buildInfoCard('Commission', totalCommission.toStringAsFixed(3), Ionicons.cash),
                  const SizedBox(width: 10),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_uploadSuccessful && _reportList.isEmpty)
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
                              content: const Text('Are you sure you want to clear the commission?'),
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

                          if (clearConfirmed == true) {
                            await _clearCommission();
                          }
                        },
                      ),
                    ),
                  const SizedBox(width: 40),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Report list section
                      if (_reportList.isNotEmpty) ...[  
                        const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Text(
                            'Report List: ',
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Poppins-Regular',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _reportList.length,
                          itemBuilder: (context, index) {
                            ReportModel report = _reportList[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              child: ListTile(
                                title: Text('Name: ${report.name}'),
                                subtitle: Text('Plate: ${report.plate}'),
                                trailing: Text('Total: ${report.total_amount}'),
                              ),
                            );
                          },
                        ),
                      ],
                      
                      // Ticket list section
                      if (_unuploadedTickets.isNotEmpty) ...[  
                        const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Text(
                            'Unuploaded Tickets: ',
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Poppins-Regular',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _unuploadedTickets.length,
                          itemBuilder: (context, index) {
                            Ticket ticket = _unuploadedTickets[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              child: ListTile(
                                title: Text('Plate: ${ticket.plate}'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Destination: ${ticket.destination}'),
                                    Text('Date: ${DateFormat('yyyy-MM-dd HH:mm').format(ticket.date)}'),
                                  ],
                                ),
                                trailing: Text('Tariff: ${ticket.tariff}'),
                                isThreeLine: true,
                              ),
                            );
                          },
                        ),
                      ],
                      
                      // No data indicator
                      if (_reportList.isEmpty && _unuploadedTickets.isEmpty)
                        Container(
                          alignment: Alignment.center,
                          height: 200,
                          child: Text(
                            'No tickets to upload',
                            style: TextStyle(fontSize: 16, color: Colors.orange),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _clearReportList() async {
    await ReportLocalDataSource().clearReports();
    await _loadReportList();
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Container(
      width: 100,
      height: 120,
      decoration: BoxDecoration(
        color: MyColors.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontSize: 10, color: Colors.white)),
          Text(value, style: const TextStyle(fontSize: 22, color: Colors.white)),
          Icon(icon, color: Colors.white, size: 40),
        ],
      ),
    );
  }

  // Initialize database and ensure tables exist
  Future<void> _initializeDatabase() async {
    try {
      final dbHelper = DatabaseHelper();
      await dbHelper.ensureTicketsTable();
      print('Database initialization completed');
    } catch (e) {
      print('Error initializing database: $e');
    }
  }
}
