part of 'active_parking_bloc.dart';

enum ParkingStatus {
  nonActive,
  starting,
  active,
  ending,
  errorStarting,
  errorEnding
}

class ActiveParkingState {
  final ParkingStatus status;
  final Parking? parking;
  final String message;

  const ActiveParkingState._({
    this.status = ParkingStatus.nonActive,
    this.parking,
    this.message = '',
  });

  const ActiveParkingState.nonActive()
      : this._(status: ParkingStatus.nonActive, parking: null);

  const ActiveParkingState.starting(Parking parking)
      : this._(status: ParkingStatus.starting, parking: parking);

  const ActiveParkingState.active(Parking parking)
      : this._(status: ParkingStatus.active, parking: parking);

  const ActiveParkingState.ending() : this._(status: ParkingStatus.ending);

  const ActiveParkingState.errorStarting(String message)
      : this._(
            status: ParkingStatus.errorStarting,
            message: message,
            parking: null);

  const ActiveParkingState.errorEnding(String message)
      : this._(
            status: ParkingStatus.errorEnding, message: message, parking: null);
}
