import 'package:parkmycar_shared/repositories/parking_space_firebase_repository.dart';

import '../models/parking.dart';
import 'firebase_repository.dart';

class ParkingFirebaseRepository extends FirebaseRepository<Parking> {
  ParkingFirebaseRepository()
      : super(serializer: ParkingSerializer(), collectionId: 'parking');

  Stream<List<Parking>> getOngoingParkingsStream() {
    var list = fireStore
        .collection(collectionId)
        .orderBy('startTime', descending: true)
        .snapshots()
        .asyncMap((snapshot) => Future.wait([
              for (var doc in snapshot.docs)
                _loadParkingSpace(serializer.fromJson(doc.data()))
            ]));
    return list
        .map((event) => event.where((element) => element.isOngoing).toList());
  }

  Future<Parking> _loadParkingSpace(Parking parking) async {
    var psRepo = ParkingSpaceFirebaseRepository();
    parking.parkingSpace = await psRepo.getById(parking.parkingSpaceId);
    return parking;
  }
}
