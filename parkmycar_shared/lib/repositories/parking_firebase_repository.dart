import '../models/parking.dart';
import 'firebase_repository.dart';

class ParkingFirebaseRepository extends FirebaseRepository<Parking> {
  ParkingFirebaseRepository()
      : super(serializer: ParkingSerializer(), collectionId: 'parking');
}
