import 'package:parkmycar_shared/parkmycar_shared.dart';
import 'firebase_repository.dart';

class ParkingSpaceFirebaseRepository extends FirebaseRepository<ParkingSpace> {
  ParkingSpaceFirebaseRepository()
      : super(serializer: ParkingSpaceSerializer());
}
