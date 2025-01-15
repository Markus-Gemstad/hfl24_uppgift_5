import '../models/person.dart';
import 'firebase_repository.dart';

class PersonFirebaseRepository extends FirebaseRepository<Person> {
  PersonFirebaseRepository()
      : super(serializer: PersonSerializer(), collectionId: 'person');
}
