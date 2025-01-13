import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:parkmycar_client_shared/parkmycar_firebase_repo.dart';
import 'package:parkmycar_shared/parkmycar_shared.dart';

part 'active_parking_state.dart';
part 'active_parking_event.dart';

class ActiveParkingBloc extends Bloc<ActiveParkingEvent, ActiveParkingState> {
  ActiveParkingBloc() : super(ActiveParkingState.nonActive()) {
    on<ActiveParkingStart>(
        (event, emit) async => await _startParking(event, emit));
    on<ActiveParkingEnd>((event, emit) async => await _endParking(event, emit));
  }

  Future<void> _startParking(ActiveParkingStart event, emit) async {
    emit(ActiveParkingState.starting(event.parking));
    // TODO Ta bort delay
    // await Future.delayed(Duration(seconds: 2));
    try {
      // TODO Ersätt med bättre relationer mellan Parking och ParkingSpace
      // Do a little work-around for ParkingSpace since the returning
      // Parking object from create does not contain a ParkingSpace but
      // the provided parking param should contain a ParkingSpace object
      // (see ParkingStartDialog start parking button onPressed method).
      ParkingSpace parkingSpace = event.parking.parkingSpace!;

      Parking? newParking =
          await ParkingFirebaseRepository().create(event.parking);
      debugPrint(
          'Parking created: ${event.parking}, parkingSpace: ${event.parking.parkingSpace}');
      newParking!.parkingSpace = parkingSpace;
      emit(ActiveParkingState.active(newParking));
    } catch (e) {
      debugPrint('Error when creating Parking: ${event.parking}, Error: $e');
      emit(ActiveParkingState.errorStarting(e.toString()));
    }
  }

  Future<void> _endParking(ActiveParkingEnd event, emit) async {
    emit(ActiveParkingState.ending());
    // TODO Ta bort delay
    // await Future.delayed(Duration(seconds: 2));
    try {
      event.parking.endTime = DateTime.now();
      await ParkingFirebaseRepository().update(event.parking);
      debugPrint(
          'Parking stopped: ${event.parking}, parkingSpace: ${event.parking.parkingSpace}');
      emit(ActiveParkingState.nonActive());
    } catch (e) {
      debugPrint('Error when ending Parking: ${event.parking}, Error: $e');
      emit(ActiveParkingState.errorEnding(e.toString()));
    }
  }
}
