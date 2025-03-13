import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:dio/dio.dart';
import 'package:transport_app/data/ticket_data_source.dart';
import 'package:transport_app/models/report.dart';
import 'package:transport_app/models/ticket.dart';
import 'package:transport_app/models/update_model.dart';

class ReportService {
  static const String reportBaseUrl =
      "https://api.noraticket.com/v1/public/api/tickets";
  // Updated to use the same endpoint as reports since individual-tickets endpoint returns 404
  static const String ticketBaseUrl =
      "https://api.noraticket.com/v1/public/api/tickets";
  static const String tokenHive = "token";

  final Dio _dio = Dio();
  final TicketDataSource _ticketDataSource = TicketDataSource();

  // Main upload method that handles both reports and tickets
  Future<Map<String, dynamic>> upload(List<ReportModel> reportList) async {
    Box<String>? tokenBox;
    Box<StationInfo>? stationBox;
    List<Future<dynamic>> uploadTasks = [];
    Map<String, dynamic> result = {
      'reportsSuccess': false,
      'ticketsSuccess': false,
      'reportsUploaded': 0,
      'ticketsUploaded': 0,
      'errors': <String>[],
    };

    try {
      if (Hive.isBoxOpen(tokenHive)) {
        tokenBox = Hive.box<String>(tokenHive);
      } else {
        tokenBox = await Hive.openBox<String>(tokenHive);
      }

      if (Hive.isBoxOpen('station')) {
        stationBox = Hive.box<StationInfo>('station');
      } else {
        stationBox = await Hive.openBox<StationInfo>('station');
      }

      final String? token = tokenBox.get('token');
      if (token == null) {
        result['errors'].add('Token is missing. Please log in again.');
        return result;
      }

      StationInfo? savedStation = stationBox.get('station');
      if (savedStation == null) {
        result['errors'].add('Station info not found in the local storage');
        return result;
      }
      final String? stationId = savedStation.id;

      print("=======> Uploading reports");
      print("==========> Number of Available Reports: ${reportList.length}");
      print("==========> All Available Reports: ${reportList[0]}");
      print("Token: $token");
      print("Station ID: $stationId");

      int successfulReports = 0;

      // Process reports first
      for (ReportModel reportModel in reportList) {
        final data = {
          "station_id": stationId,
          "uploaded_by": reportModel.name ?? 'Anonymous',
          "total_price": reportModel.total_amount,
          "service_fee": reportModel.totalServiceFee, 
          "no_of_ticket": reportModel.no_of_ticket,
          "vehicle_plate_no": reportModel.plate,
          "vehicle_level": reportModel.level,
          "destination": reportModel.destination,
          "uploaded_date": DateTime.now().toIso8601String(),
          "validate": "ok",  
        };

        uploadTasks.add(
            _uploadReport(data, token).then((_) {
              successfulReports++;
            }).catchError((e) {
              result['errors'].add('Failed to upload report ${reportModel.plate}: $e');
              return null; // Must return a value compatible with the Future's type
            })
        );
      }

      // Wait for all reports to finish uploading
      await Future.wait(uploadTasks);
      
      if (successfulReports == reportList.length) {
        result['reportsSuccess'] = true;
        result['reportsUploaded'] = successfulReports;
        print("=======> All reports uploaded successfully");
      } else {
        print("=======> Some reports failed to upload");
        result['reportsUploaded'] = successfulReports;
      }

      // Now process tickets (if any unuploaded tickets exist)
      try {
        print("Looking for unuploaded tickets in database...");
        List<Ticket> unuploadedTickets = await _ticketDataSource.getUnuploadedTickets();
        
        if (unuploadedTickets.isNotEmpty) {
          print("Found ${unuploadedTickets.length} unuploaded tickets in database");
          
          // Print the first ticket for debugging
          if (unuploadedTickets.isNotEmpty) {
            print("Ticket data: ${unuploadedTickets[0].toJson()}");
          }
          
          print("=======> Uploading ${unuploadedTickets.length} unuploaded tickets");
          
          List<String> successfullyUploadedTicketIds = [];
          List<Future<void>> uploadTicketTasks = [];
          
          for (var ticket in unuploadedTickets) {
            uploadTicketTasks.add(_uploadSingleTicket(
              ticket, 
              token, 
              stationId,
              onSuccess: () {
                successfullyUploadedTicketIds.add(ticket.uniqueId);
              }
            ).catchError((e) {
              // Make sure to return null to satisfy the Future type
              return null;
            }));
          }
          
          // Use allSettled-like approach to continue even if some tickets fail
          await Future.wait(
            uploadTicketTasks.map((task) => task.then((_) => null).catchError((e) => null)),
          );
          
          // Mark successfully uploaded tickets
          if (successfullyUploadedTicketIds.isNotEmpty) {
            await _ticketDataSource.markTicketsAsUploaded(successfullyUploadedTicketIds);
            result['ticketsUploaded'] = successfullyUploadedTicketIds.length;
            
            // Only consider ticket upload successful if all tickets were uploaded
            if (successfullyUploadedTicketIds.length == unuploadedTickets.length) {
              result['ticketsSuccess'] = true;
            }
          }
          
          if (successfullyUploadedTicketIds.length < unuploadedTickets.length) {
            int failedCount = unuploadedTickets.length - successfullyUploadedTicketIds.length;
            result['errors'].add("Failed to upload $failedCount tickets");
          }
        } else {
          print("No unuploaded tickets found");
          result['ticketsSuccess'] = true; // No tickets to upload = success
        }
      } catch (e) {
        print("Error uploading tickets: $e");
        result['errors'].add("Failed to upload tickets: $e");
      }
      
      return result;
      
    } catch (e) {
      print("=======> Error uploading reports$e");
      result['errors'].add("An unknown error occurred: $e");
      return result;
    }
  }

  Future<void> _uploadReport(Map<String, dynamic> data, String token) async {
    try {
      final response = await _dio.post(
        reportBaseUrl,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
        data: data,
      );

      print("Processing ... Uploading Report");

      if (response.data['status'] == true) {
        print('Successfully uploaded report: ${response.data}');
      } else {
        print('Failed to upload report: ${response.data}');
        throw Exception('API returned failure: ${response.data['message']}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        print('Error Response: ${e.response?.data}');
      } else {
        print('Error: $e');
      }
      throw Exception('Failed to upload the report: ${e.message}');
    }
  }

  // New method to upload tickets that haven't been uploaded yet
  Future<void> uploadUnuploadedTickets(String token, String? stationId) async {
    try {
      // Get all unuploaded tickets
      List<Ticket> unuploadedTickets = await _ticketDataSource.getUnuploadedTickets();
      
      if (unuploadedTickets.isEmpty) {
        print('No unuploaded tickets found');
        return;
      }
      
      print("=======> Uploading ${unuploadedTickets.length} unuploaded tickets");
      
      List<String> successfullyUploadedTicketIds = [];
      List<Future<void>> uploadTicketTasks = [];
      
      for (var ticket in unuploadedTickets) {
        uploadTicketTasks.add(_uploadSingleTicket(
          ticket, 
          token, 
          stationId,
          onSuccess: () {
            successfullyUploadedTicketIds.add(ticket.uniqueId);
          }
        ));
      }
      
      await Future.wait(uploadTicketTasks);
      
      // Mark successfully uploaded tickets
      if (successfullyUploadedTicketIds.isNotEmpty) {
        await _ticketDataSource.markTicketsAsUploaded(successfullyUploadedTicketIds);
        print("=======> Marked ${successfullyUploadedTicketIds.length} tickets as uploaded");
      }
    } catch (e) {
      print('Error uploading tickets: $e');
      throw Exception('Failed to upload tickets: $e');
    }
  }
  
  Future<void> _uploadSingleTicket(
      Ticket ticket, 
      String token, 
      String? stationId,
      {required Function onSuccess}) async {
    Map<String, dynamic> data = {
      "station_id": stationId,
      "uploaded_by": ticket.tailure,
      "total_price": ticket.tariff,          // Fixed typo in field name
      "service_fee": ticket.charge,
      "no_of_ticket": 1,
      "vehicle_plate_no": ticket.plate,
      "vehicle_level": ticket.level,
      "destination": ticket.destination,
      "departure": ticket.departure,         // Added departure
      "association": ticket.association,     // Added association
      "distance": ticket.distance,           // Added distance
      "uploaded_date": ticket.date.toIso8601String(), // Fixed typo in field name
      "validate": "ok",
    };

    try {
      print("Uploading ticket with data: $data");
      
      final response = await _dio.post(
        ticketBaseUrl,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          validateStatus: (status) => true, // Accept any status code to handle errors better
        ),
        data: data,
      );

      print("Response status code: ${response.statusCode}");
      print("Response data: ${response.data}");

      // Check HTTP status code first
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw DioException(
          requestOptions: RequestOptions(path: ticketBaseUrl),
          response: response,
          type: DioExceptionType.badResponse,
          message: 'HTTP error ${response.statusCode}: ${response.statusMessage}',
        );
      }

      // Then check API response
      if (response.data['status'] == true) {
        print('Successfully uploaded ticket: ${ticket.uniqueId}');
        onSuccess();
      } else {
        print('API returned failure: ${response.data}');
        throw Exception('API returned failure for ticket ${ticket.uniqueId}: ${response.data['message'] ?? "Unknown error"}');
      }
    } on DioException catch (e) {
      print('DioException for ticket ${ticket.uniqueId}:');
      if (e.response != null) {
        print('  Status code: ${e.response?.statusCode}');
        print('  Response data: ${e.response?.data}');
        
        // Provide specific error based on status code
        String errorMessage;
        switch (e.response?.statusCode) {
          case 400:
            errorMessage = 'Bad request - check your ticket data format';
            break;
          case 401:
            errorMessage = 'Authentication failed - please log in again';
            break;
          case 403:
            errorMessage = 'Permission denied - your account cannot upload tickets';
            break;
          case 404:
            errorMessage = 'API endpoint not found - please contact support';
            break;
          case 500:
            errorMessage = 'Server error - please try again later';
            break;
          default:
            errorMessage = 'Network error ${e.response?.statusCode}: ${e.message}';
        }
        throw Exception('Failed to upload ticket ${ticket.uniqueId}: $errorMessage');
      } else {
        print('  Error message: ${e.message}');
        throw Exception('Network error uploading ticket ${ticket.uniqueId}: ${e.message}');
      }
    } catch (e) {
      print('General error uploading ticket ${ticket.uniqueId}: $e');
      throw Exception('Failed to upload ticket ${ticket.uniqueId}: $e');
    }
  }

  // New method to upload tickets directly (without reports)
  Future<Map<String, dynamic>> uploadUnuploadedTicketsOnly() async {
    Box<String>? tokenBox;
    Box<StationInfo>? stationBox;
    Map<String, dynamic> result = {
      'ticketsSuccess': false,
      'ticketsUploaded': 0,
      'errors': [],
    };
    
    try {
      // Check if the boxes are already open before opening them
      if (Hive.isBoxOpen(tokenHive)) {
        tokenBox = Hive.box<String>(tokenHive);
      } else {
        tokenBox = await Hive.openBox<String>(tokenHive);
      }
      
      if (Hive.isBoxOpen('station')) {
        stationBox = Hive.box<StationInfo>('station');
      } else {
        stationBox = await Hive.openBox<StationInfo>('station');
      }

      final String? token = tokenBox.get('token');
      if (token == null) {
        result['errors'].add('Token is missing. Please log in again.');
        return result;
      }

      StationInfo? savedStation = stationBox.get('station');
      if (savedStation == null) {
        result['errors'].add('Station info not found in the local storage');
        return result;
      }
      final String? stationId = savedStation.id;

      // Get all unuploaded tickets
      List<Ticket> unuploadedTickets = await _ticketDataSource.getUnuploadedTickets();
      
      if (unuploadedTickets.isEmpty) {
        print('No unuploaded tickets found');
        result['ticketsSuccess'] = true;
        return result;
      }
      
      print("=======> Uploading ${unuploadedTickets.length} unuploaded tickets");
      
      List<String> successfullyUploadedTicketIds = [];
      List<Future<void>> uploadTicketTasks = [];
      
      for (var ticket in unuploadedTickets) {
        uploadTicketTasks.add(_uploadSingleTicket(
          ticket, 
          token, 
          stationId,
          onSuccess: () {
            successfullyUploadedTicketIds.add(ticket.uniqueId);
          }
        ));
      }
      
      // Use allSettled-like approach to continue even if some tickets fail
      List<dynamic> uploadResults = await Future.wait(
        uploadTicketTasks.map((task) => task.then((_) => true).catchError((e) => e)),
      );
      
      int failedUploads = uploadResults.where((r) => r != true).length;
      
      // Mark successfully uploaded tickets
      if (successfullyUploadedTicketIds.isNotEmpty) {
        await _ticketDataSource.markTicketsAsUploaded(successfullyUploadedTicketIds);
        print("=======> Marked ${successfullyUploadedTicketIds.length} tickets as uploaded");
        result['ticketsUploaded'] = successfullyUploadedTicketIds.length;
      }
      
      // Only consider ticket upload successful if all tickets were uploaded
      if (failedUploads == 0) {
        result['ticketsSuccess'] = true;
      } else {
        result['errors'].add("Failed to upload $failedUploads tickets");
      }
      
      return result;
      
    } catch (e) {
      print('Error uploading tickets: $e');
      result['errors'].add("Failed to upload tickets: $e");
      return result;
    }
  }
}
