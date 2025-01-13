import 'firebase_repository.dart';
import 'package:parkmycar_shared/parkmycar_shared.dart';

class ParkingFirebaseRepository extends FirebaseRepository<Parking> {
  ParkingFirebaseRepository() : super(serializer: ParkingSerializer());
}
