import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transport_app/presentation/auth/login_page.dart';
import 'package:transport_app/presentation/widgets/station_dropdowns.dart';

import '../../bloc/station bloc/station_bloc.dart';
import '../../bloc/station bloc/station_event.dart';
import '../../bloc/station bloc/station_state.dart';
import '../../models/update_model.dart';
import '../../utils/save_station.dart';

class Starter extends StatefulWidget {
  const Starter({super.key});

  @override
  State<Starter> createState() => _StarterState();
}

class _StarterState extends State<Starter> {
  List<StationInfo>? station_Info;
  StationInfo? l_SelectedStation;

  bool _isloading = false;
  @override
  void initState() {
    super.initState();
    checkFirstVisit();
    context.read<StationBloc>().add(FetchStationInfoEvent());
  }

  Future<void> checkFirstVisit() async {
    final prefs = await SharedPreferences.getInstance();
    final stationSelectedBefore = prefs.getBool('station_selected') ?? false;

    Future.delayed(
      const Duration(seconds: 2),
      () {
        if (stationSelectedBefore) {
          // If visited before, navigate to Home()
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        } else {
          // Set visited_before flag to true for future visits
          prefs.setBool('station_selected', true);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StationBloc, StationInfoState>(
        listener: (context, state) {
      if (state is StationInfoLoading) {
        setState(() {
          _isloading = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Loading...'),
          ),
        );
      } else if (state is StationInfoSuccess) {
        setState(() {
          station_Info = state.stations;
          _isloading = false;
        });
      } else if (state is StationInfoError) {
        setState(() {
          _isloading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.errorMessage),
          ),
        );
      }
    }, builder: (context, snapshot) {
      return Builder(builder: (context) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Center(
                child: Text(
                  'Select your station',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _isloading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : Container(
                      padding: const EdgeInsets.fromLTRB(40, 5, 40, 5),
                      margin: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                      child: (station_Info != null)
                          ? SizedBox(
                              height: 60,
                              child: DropdownButtonFormField<StationInfo>(
                                hint: const Text(
                                  'Select Station',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontFamily: 'Poppins-Light',
                                    fontSize: 14,
                                  ),
                                ),
                                value: l_SelectedStation,
                                onChanged: (value) {
                                  setState(() {
                                    l_SelectedStation = value;
                                  });
                                },
                                items: station_Info!
                                    .map<DropdownMenuItem<StationInfo>>(
                                        (station) {
                                  return DropdownMenuItem<StationInfo>(
                                    value: station,
                                    child: Text(
                                      station.name!,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontFamily: 'Poppins-Light',
                                        fontSize: 14,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 16, horizontal: 12),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.grey, width: 1),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.blue,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  ),
                                ),
                                isExpanded: true,
                                isDense: true,
                                style: const TextStyle(color: Colors.grey),
                              ),
                            )
                          : Container(),
                    ),
              const SizedBox(
                height: 50,
              ),
              ElevatedButton(
                onPressed: () {
                  // if station selected move to login page
                  if (l_SelectedStation != null) {
                    // Save selected station to Hive
                    saveStationToHive(l_SelectedStation!);
                    
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginPage(),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select a station'),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.fromLTRB(40, 10, 40, 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Next'),
              ),
            ],
          ),
        );
      });
    });
  }
}
