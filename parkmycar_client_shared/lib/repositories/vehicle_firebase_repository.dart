import 'package:parkmycar_shared/parkmycar_shared.dart';
import 'firebase_repository.dart';

class VehicleFirebaseRepository extends FirebaseRepository<Vehicle> {
  VehicleFirebaseRepository() : super(serializer: VehicleSerializer());
}
