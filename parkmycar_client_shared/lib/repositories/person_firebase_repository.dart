import 'package:parkmycar_shared/parkmycar_shared.dart';
import 'firebase_repository.dart';

class PersonFirebaseRepository extends FirebaseRepository<Person> {
  PersonFirebaseRepository() : super(serializer: PersonSerializer());
}
