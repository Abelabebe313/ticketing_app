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
        await uploadService.upload(event.reportList);
        emit(UploadedReportState(event.reportList));
      } catch (e) {
        print("=======> Error uploading reports" + e.toString());
        emit(const UploadError('Error uploading reports'));
      }
    });
  }
}
