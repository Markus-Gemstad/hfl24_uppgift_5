import 'package:uuid/uuid.dart';

abstract class Identifiable {
  String? id;

  Identifiable([String? id]) : id = id ?? Uuid().v4();

  bool isValid();
}
