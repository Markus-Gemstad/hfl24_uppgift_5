import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parkmycar_shared/parkmycar_shared.dart';

import '../blocs/active_parking_bloc.dart';
import '../globals.dart';

class ParkingOngoingScreen extends StatefulWidget {
  const ParkingOngoingScreen({super.key, required this.onEndParking});

  final Function onEndParking;

  @override
  State<ParkingOngoingScreen> createState() => _ParkingOngoingScreenState();
}

class _ParkingOngoingScreenState extends State<ParkingOngoingScreen> {
  Timer? _timer;
  String overdueWarning = '';

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        setState(() {});
      },
    );
  }

  @override
  void initState() {
    startTimer();
    super.initState();
  }

  @override
  void dispose() {
    if (_timer?.isActive ?? false) {
      _timer?.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeParkingState = context.watch<ActiveParkingBloc>().state;
    Parking? ongoingParking = activeParkingState.parking;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pågående parkering'),
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              ListTile(
                leading: Hero(
                  tag: 'parkingicon${ongoingParking!.parkingSpace!.id}',
                  child: Image.asset(
                    'assets/parking_icon.png',
                    width: 60.0,
                  ),
                ),
                title: Text(ongoingParking.parkingSpace!.streetAddress),
                subtitle: Text(
                    '${ongoingParking.parkingSpace!.postalCode} ${ongoingParking.parkingSpace!.city}\n'
                    'Pris per timme: ${ongoingParking.parkingSpace!.pricePerHour} kr'),
              ),
              SizedBox(height: 20),
              Text(
                  'Starttid: ${dateTimeFormat.format(ongoingParking.startTime)}'),
              Text('Sluttid: ${dateTimeFormat.format(ongoingParking.endTime)}'),
              SizedBox(height: 20.0),
              BlocBuilder<ActiveParkingBloc, ActiveParkingState>(
                builder: (context, state) {
                  if (state.status == ParkingStatus.starting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (state.status == ParkingStatus.active) {
                    return buildOngoingBody(ongoingParking, context);
                  } else {
                    return Text('error...');
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  Column buildOngoingBody(Parking ongoingParking, BuildContext context) {
    return Column(
      children: [
        Text('Förfluten tid: ${ongoingParking.elapsedTimeToString()}',
            style: TextStyle(fontSize: 20)),
        Text('Kostnad: ${ongoingParking.elapsedCostToString()}',
            style: TextStyle(fontSize: 20)),
        Text(
          overdueWarning,
          style: TextStyle(fontSize: 16, color: Colors.red),
        ),
        SizedBox(height: 20.0),
        ElevatedButton(
          onPressed: () {
            context
                .read<ActiveParkingBloc>()
                .add(ActiveParkingEnd(ongoingParking));
            // context.widget.onEndParking();
          },
          child: Text('Avsluta parkering'),
        ),
      ],
    );
  }
}
