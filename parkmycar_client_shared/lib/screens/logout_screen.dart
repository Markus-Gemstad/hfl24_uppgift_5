import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:parkmycar_client_shared/blocs/auth_bloc.dart';
import 'package:provider/provider.dart';
import 'package:parkmycar_client_shared/parkmycar_firebase_repo.dart';
import 'package:parkmycar_shared/parkmycar_shared.dart';

class LogoutScreen extends StatelessWidget {
  const LogoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Är du säker på att du vill logga ut?'),
          ),
          FilledButton(
            onPressed: () async =>
                context.read<AuthBloc>().add(AuthLogoutRequested()),
            child: const Text('Logga ut'),
          ),
          Visibility(
            visible: kDebugMode,
            child: Column(
              children: [
                SizedBox(height: 20),
                TextButton(
                    onPressed: () async => createBaseData,
                    child: Text('DEBUG: Fyll på med basdata')),
                TextButton(
                    onPressed: () async => createParkingSpaces,
                    child: Text('DEBUG: Fyll på med parkeringsplatser')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void createBaseData() async {
  Person? person = await PersonFirebaseRepository()
      .create(Person("Markus Gemstad", "1122334455"));

  final vehicleRepo = VehicleFirebaseRepository();
  await vehicleRepo.create(Vehicle("ABC123", person!.id!, VehicleType.car));
  await vehicleRepo
      .create(Vehicle("BCD234", person.id!, VehicleType.motorcycle));

  // DateTime endTime = DateTime.now().add(const Duration(hours: 1));
  // await ParkingHttpRepository.instance
  //     .create(Parking(1, 1, DateTime.now(), endTime));
}

void createParkingSpaces() async {
  var parkingSpaceRepo = ParkingSpaceFirebaseRepository();
  await parkingSpaceRepo
      .create(ParkingSpace('Nya Stadens Torg 1', '531 31', 'Lidköping', 40));
  await parkingSpaceRepo
      .create(ParkingSpace('Gamla Stadens Torg 4', '531 32', 'Lidköping', 15));
  await parkingSpaceRepo
      .create(ParkingSpace('Esplanaden 6', '531 33', 'Lidköping', 35));
  await parkingSpaceRepo
      .create(ParkingSpace('Rådagatan 10', '531 35', 'Lidköping', 50));
  await parkingSpaceRepo
      .create(ParkingSpace('Östbygatan 18', '531 37', 'Lidköping', 25));
  await parkingSpaceRepo
      .create(ParkingSpace('Stenportsgatan 9', '531 40', 'Lidköping', 40));
  await parkingSpaceRepo
      .create(ParkingSpace('Kållandsgatan 22', '531 44', 'Lidköping', 20));
  await parkingSpaceRepo
      .create(ParkingSpace('Skaragatan 5', '531 30', 'Lidköping', 50));
  await parkingSpaceRepo
      .create(ParkingSpace('Sockerbruksgatan 15', '531 40', 'Lidköping', 20));
  await parkingSpaceRepo
      .create(ParkingSpace('Mariestadsvägen 2', '531 60', 'Lidköping', 40));
  await parkingSpaceRepo
      .create(ParkingSpace('Torggatan 3', '531 31', 'Lidköping', 10));
  await parkingSpaceRepo
      .create(ParkingSpace('Hamngatan 12', '531 32', 'Lidköping', 20));
  await parkingSpaceRepo
      .create(ParkingSpace('Västra Hamngatan 5', '531 33', 'Lidköping', 20));
  await parkingSpaceRepo
      .create(ParkingSpace('Framnäsvägen 1', '531 36', 'Lidköping', 40));
  await parkingSpaceRepo
      .create(ParkingSpace('Götgatan 7', '531 31', 'Lidköping', 40));
  await parkingSpaceRepo
      .create(ParkingSpace('Östra Hamnen 10', '531 32', 'Lidköping', 10));
  await parkingSpaceRepo
      .create(ParkingSpace('Viktoriagatan 14', '531 30', 'Lidköping', 30));
  await parkingSpaceRepo
      .create(ParkingSpace('Majorsallén 3', '531 40', 'Lidköping', 40));
  await parkingSpaceRepo
      .create(ParkingSpace('Hovbygatan 20', '531 41', 'Lidköping', 15));
  await parkingSpaceRepo
      .create(ParkingSpace('Kvarngatan 9', '531 42', 'Lidköping', 45));
}
