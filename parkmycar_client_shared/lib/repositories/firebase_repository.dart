import 'dart:convert';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:parkmycar_shared/parkmycar_shared.dart';

abstract class FirebaseRepository<T> implements RepositoryInterface<T> {
  Serializer<T> serializer;

  FirebaseRepository({required this.serializer});

  @override
  Future<T?> create(T item) async {
    final response = await http.post(Uri(),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(serializer.toJson(item)));

    if (response.statusCode == 200) {
      try {
        final json = jsonDecode(response.body);
        return serializer.fromJson(json);
      } catch (e) {
        throw Exception('Gick inte att läsa returdata.');
      }
    } else if (response.statusCode == 400 &&
        response.body == objectNotCreated) {
      throw Exception('Kunde inte skapa objekt.');
    } else if (response.statusCode == 404) {
      throw Exception('Kunde inte hitta server.');
    } else {
      throw Exception('Okänt fel.');
    }
  }

  /// Send item serialized as json over http to server
  @override
  Future<T?> update(T item) async {
    final response = await http.put(Uri(),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(serializer.toJson(item)));

    if (response.statusCode == 200) {
      try {
        final json = jsonDecode(response.body);
        return serializer.fromJson(json);
      } catch (e) {
        throw Exception('Gick inte att läsa returdata.');
      }
    } else if (response.statusCode == 400 && response.body == objectNotFound) {
      throw Exception('Hittade inte objekt.');
    } else if (response.statusCode == 404) {
      throw Exception('Kunde inte hitta server.');
    } else {
      throw Exception('Okänt fel.');
    }
  }

  @override
  Future<T?> getById(String id) async {
    Response response = await http.get(
      Uri(),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      try {
        final json = jsonDecode(response.body);
        return serializer.fromJson(json);
      } catch (e) {
        throw Exception('Gick inte att läsa returdata.');
      }
    } else if (response.statusCode == 400 && response.body == objectNotFound) {
      throw Exception('Hittade inte objekt.');
    } else if (response.statusCode == 404) {
      throw Exception('Kunde inte hitta server.');
    } else {
      throw Exception('Okänt fel.');
    }
  }

  /// Use compare to sort the list
  @override
  Future<List<T>> getAll([int Function(T a, T b)? compare]) async {
    final response = await http.get(
      Uri(),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      try {
        final json = jsonDecode(response.body);
        List<T> list =
            (json as List).map((item) => serializer.fromJson(item)).toList();
        if (compare != null) {
          list.sort(compare);
        }
        return list;
      } catch (e) {
        throw Exception('Gick inte att läsa returdata.');
      }
    } else if (response.statusCode == 404) {
      throw Exception('Kunde inte hitta server.');
    } else {
      throw Exception('Gick inte att hämta objekt.');
    }
  }

  @override
  Future<bool> delete(String id) async {
    final response = await http.delete(
      Uri(),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return true;
    } else if (response.statusCode == 400 && response.body == objectNotFound) {
      throw Exception('Hittade inte objekt.');
    } else if (response.statusCode == 404) {
      throw Exception('Kunde inte hitta server.');
    } else {
      throw Exception('Gick inte att ta bort objekt.');
    }
  }
}
