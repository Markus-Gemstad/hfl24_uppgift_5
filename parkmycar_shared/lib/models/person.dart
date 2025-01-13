import '../util/validators.dart';
import 'identifiable.dart';
import 'serializer.dart';

class Person extends Identifiable {
  String name;
  String email;

  /// Default constructor. Exclude id if this is a new object
  Person(this.name, this.email, [String? id]) : super(id);

  @override
  bool isValid() {
    return Validators.isValidName(name) && Validators.isValidEmail(email);
  }

  @override
  String toString() {
    return "Id: $id, Namn: $name, E-post: $email";
  }
}

class PersonSerializer extends Serializer<Person> {
  @override
  Map<String, dynamic> toJson(Person item) {
    return {
      'id': item.id,
      'email': item.email,
      'name': item.name,
    };
  }

  @override
  Person fromJson(Map<String, dynamic> json) {
    return Person(
      json['name'] as String,
      json['email'] as String,
      json['id'] as String,
    );
  }
}
