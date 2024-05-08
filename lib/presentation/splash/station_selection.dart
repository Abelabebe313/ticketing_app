import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transport_app/bloc/station%20bloc/station_state.dart';
import 'package:transport_app/presentation/auth/login_page.dart';

import '../../bloc/registration bloc/register_bloc.dart';
import '../../bloc/registration bloc/register_event.dart';
import '../../bloc/station bloc/station_bloc.dart';
import '../../bloc/station bloc/station_event.dart';
import '../../models/update_model.dart';
import '../../utils/save_station.dart';

class StationSelectionPage extends StatefulWidget {
  const StationSelectionPage({super.key});

  @override
  State<StationSelectionPage> createState() => _StationSelectionPageState();
}

class _StationSelectionPageState extends State<StationSelectionPage> {
  List<StationInfo>? station_Info;
  StationInfo? selectedStation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StationBloc, StationInfoState>(
      listener: (context, state) {
        if (state is StationInfoSuccess) {
          setState(() {
            _isLoading = false;
          });
          station_Info = state.stations;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Successfully Logged in'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        } else if (state is StationInfoError) {
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
            title: const Text('Select Station'),
          ),
          body: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : station_Info == null
                  ? const Center(
                      child: Text('No Stations Found'),
                    )
                  : ListView.builder(
                      itemCount: station_Info!.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(station_Info![index].name ?? ""),
                          onTap: () {
                            setState(() {
                              selectedStation = station_Info![index];
                            });
                          },
                        );
                      },
                    ),
        );
      },
    );
  }
}
