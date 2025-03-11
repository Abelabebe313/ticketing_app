import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transport_app/bloc/upload/upload_event.dart';
import 'package:transport_app/bloc/upload/upload_state.dart';
import 'package:transport_app/services/report_upload.dart';

class UploadBloc extends Bloc<UploadEvent, UploadState> {
  UploadBloc(UploadState initialState) : super(UploadInitial()) {
    final uploadService = ReportService();

    on<UploadReportEvent>((event, emit) async {
      emit(UploadLoading());
      try {
        print("=======> Uploading reports");
        final Map<String, dynamic> result = await uploadService.upload(event.reportList);
        
        // Extract success status and error messages from the result
        bool reportsSuccess = result['reportsSuccess'] ?? false;
        bool ticketsSuccess = result['ticketsSuccess'] ?? false;
        List<String> errors = (result['errors'] as List<dynamic>?)?.cast<String>() ?? [];
        int reportsUploaded = result['reportsUploaded'] ?? 0;
        int ticketsUploaded = result['ticketsUploaded'] ?? 0;
        
        if (reportsSuccess && ticketsSuccess) {
          // Both reports and tickets uploaded successfully
          emit(UploadedReportState(event.reportList));
        } else if (errors.isNotEmpty) {
          // At least one error occurred
          String errorMessage = errors.join('\n');
          emit(UploadError(errorMessage));
        } else if (reportsSuccess) {
          // Only reports were successful (no tickets or ticket upload failed)
          emit(UploadedReportState(event.reportList));
        } else {
          // Default error case
          emit(const UploadError('Error uploading reports or tickets'));
        }
      } catch (e) {
        print("=======> Error uploading reports: ${e.toString()}");
        emit(UploadError('Error uploading reports: ${e.toString()}'));
      }
    });
  }
}
