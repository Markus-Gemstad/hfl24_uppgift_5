part of 'active_parking_bloc.dart';

sealed class ActiveParkingEvent {}

final class ActiveParkingStart extends ActiveParkingEvent {
  final Parking parking;
  ActiveParkingStart(this.parking);
}

final class ActiveParkingEnd extends ActiveParkingEvent {
  final Parking parking;
  ActiveParkingEnd(this.parking);
}
