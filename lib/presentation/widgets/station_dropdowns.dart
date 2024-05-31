import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:transport_app/bloc/station%20bloc/station_bloc.dart';

import '../../bloc/station bloc/station_event.dart';
import '../../bloc/station bloc/station_state.dart';
import '../../models/update_model.dart';

class StationDropdown extends StatefulWidget {
  const StationDropdown({super.key});

  @override
  State<StationDropdown> createState() => _StationDropdownState();
}

class _StationDropdownState extends State<StationDropdown> {
  StationInfo? selectedStation;
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    BlocProvider.of<StationBloc>(context).add(FetchStationInfoEvent());
  }

  Future<void> saveStationToHive(StationInfo stationinf) async {
    StationInfo station = StationInfo(
      id: stationinf.id,
      name: stationinf.name,
      location: stationinf.location,
      departure: stationinf.departure,
    );
    try {
      // Open Hive box for station
      final box = await Hive.openBox<StationInfo>('station');

      // Clear existing data
      await box.clear();

      // Put the station into the box
      await box.put('station', station);

      print('Station saved to Hive successfully');
    } catch (e) {
      print('Error saving station to Hive: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StationBloc, StationInfoState>(
      listener: (context, state) {
        if (state is StationInfoLoading) {
          setState(() {
            _isLoading = true;
          });
        } else if (state is StationInfoSuccess) {
          setState(() {
            _isLoading = false;
          });
        } else if (state is StationInfoError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage)),
          );
          setState(() {
            _isLoading = false;
          });
        }
      },
      builder: (context, state) {
        if (_isLoading) {
          return const CircularProgressIndicator(
            color: Colors.blue,
          );
        }

        if (state is StationInfoSuccess) {
          return DropdownButton<StationInfo>(
            hint: const Text("Select a station"),
            value: selectedStation,
            items: state.stations.map((station) {
              return DropdownMenuItem<StationInfo>(
                value: station,
                child: Text(station.name ?? ''),
              );
            }).toList(),
            onChanged: (StationInfo? value) {
              setState(()  {
                selectedStation = value;
                 saveStationToHive(selectedStation!);
              });
            },
          );
        } else {
          return const Text('Failed to load stations');
        }
      },
    );
  }
}
