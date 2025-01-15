import 'package:flutter/material.dart';
import 'package:parkmycar_shared/parkmycar_shared.dart';

import '../globals.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  late Future<List<Parking>> _ongoingParkings;
  final ValueNotifier<int> _ongoingParkingCount = ValueNotifier<int>(0);
  late Future<double> _totalParkingIncome;
  late Future<List<PopularParkingSpace>> _popularParkingSpaceList;

  Future<List<Parking>> getOngoingParkings() async {
    // Get all sorted by latest first
    var items = await ParkingFirebaseRepository().getAll('startTime');

    // Filtrera på nu pågående parkeringar
    // TODO Kunna hämta lista fördigfilrerad från databasen
    items = items.where((element) => element.isOngoing).toList();

    // Setting the _ongoingCount activates the ChangeNotifier
    // (do this because the count is placed outside of the FutureBuilder)
    _ongoingParkingCount.value = items.length;

    for (var item in items) {
      // TODO Ersätt med bättre relationer mellan Parking och ParkingSpace
      try {
        item.parkingSpace =
            await ParkingSpaceFirebaseRepository().getById(item.parkingSpaceId);
      } catch (e) {
        debugPrint('Error getting ParkingSpace:${item.parkingSpaceId}');
      }
    }

    // Added delay to demonstrate loading animation
    return Future.delayed(Duration(milliseconds: 250), () => items);
  }

  Future<List<PopularParkingSpace>> getPopularParkingSpaces() async {
    var parkingSpaces = await ParkingSpaceFirebaseRepository().getAll();
    var parkings = await ParkingFirebaseRepository().getAll();

    // TODO Ersätta med bättre relationer mellan Parking och ParkingSpace
    List<PopularParkingSpace> list = List.empty(growable: true);
    for (int i = 0; i < parkingSpaces.length; i++) {
      var parkingSpace = parkingSpaces[i];
      try {
        int parkingCount = parkings
            .where((element) => element.parkingSpaceId == parkingSpace.id)
            .length;
        if (parkingCount > 0) {
          list.add(PopularParkingSpace(parkingSpace, parkingCount));
        }
      } catch (e) {
        //debugPrint('Error getting Parking:${parkingSpace.id}');
      }
    }

    // Sort by number of parkings and get top 10
    // TODO Be able to get top 10 ParkingSpaces directly from the db instead
    list.sort((a, b) => b.parkingCount.compareTo(a.parkingCount));
    list = list.take(10).toList();

    // Added delay to demonstrate loading animation
    return Future.delayed(Duration(milliseconds: 250), () => list);
  }

  Future<double> getTotalParkingIncome() async {
    var items = await ParkingFirebaseRepository().getAll();
    items = items.where((element) => !element.isOngoing).toList();
    return items.fold<double>(0, (sum, item) => sum + item.totalCost);
  }

  @override
  void initState() {
    super.initState();
    _ongoingParkings = getOngoingParkings();
    _totalParkingIncome = getTotalParkingIncome();
    _popularParkingSpaceList = getPopularParkingSpaces();
  }

  @override
  Widget build(BuildContext context) {
    // debugPaintSizeEnabled = true;
    return Padding(
      padding: const EdgeInsets.only(top: 20, right: 12, bottom: 12, left: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  children: [
                    Text('Aktiva parkeringar',
                        style: Theme.of(context).textTheme.titleLarge),
                    SizedBox(width: 10),
                    OngoingCountWidget(
                        counterValueNotifier: _ongoingParkingCount),
                    IconButton(
                        onPressed: () {
                          setState(() {
                            _ongoingParkings = getOngoingParkings();
                          });
                        },
                        icon: Icon(Icons.refresh))
                  ],
                ),
                SizedBox(height: 20),
                FutureBuilder<List<Parking>>(
                    future: _ongoingParkings,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data!.isEmpty) {
                          return Expanded(
                            child: Text('Finns inga pågående parkeringar.'),
                          );
                        }

                        return Expanded(
                          child: ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              var item = snapshot.data![index];
                              return ListTile(
                                  contentPadding: EdgeInsets.all(0),
                                  title: Text(item.parkingSpace!.streetAddress),
                                  subtitle: Text(
                                      '${item.parkingSpace!.postalCode} ${item.parkingSpace!.city}\n'
                                      'Tid: ${dateTimeFormatShort.format(item.startTime)} - '
                                      '${dateTimeFormatShort.format(item.endTime)}'));
                            },
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        return Expanded(
                          child: Text('Error: ${snapshot.error}'),
                        );
                      }

                      return Center(child: CircularProgressIndicator());
                    }),
              ],
            ),
          ),
          VerticalDivider(
            width: 40,
          ),
          //SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder(
                    future: _totalParkingIncome,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Text(
                            'Summa inkomst: ${double.parse(snapshot.data!.toStringAsFixed(2))} kr',
                            style: Theme.of(context).textTheme.titleLarge);
                      }
                      return CircularProgressIndicator();
                    }),
                SizedBox(height: 30),
                Text('10 populäraste adresser',
                    style: Theme.of(context).textTheme.titleLarge),
                FutureBuilder(
                    future: _popularParkingSpaceList,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Expanded(
                          child: RefreshIndicator(
                            onRefresh: () async {
                              setState(() {
                                _popularParkingSpaceList =
                                    getPopularParkingSpaces();
                              });
                            },
                            child: ListView.builder(
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                var item = snapshot.data![index];
                                return ListTile(
                                  contentPadding: EdgeInsets.all(0),
                                  title: Text(
                                      '${index + 1}. ${item.parkingSpace.streetAddress}'),
                                  subtitle: Text(
                                      '${item.parkingSpace.postalCode} ${item.parkingSpace.city}\n'
                                      'Antal parkeringar: ${item.parkingCount} st'),
                                );
                              },
                            ),
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return Expanded(
                          child: Text('Error: ${snapshot.error}'),
                        );
                      }

                      return CircularProgressIndicator();
                    }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OngoingCountWidget extends StatelessWidget {
  const OngoingCountWidget({super.key, required this.counterValueNotifier});

  final ValueNotifier<int> counterValueNotifier;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: counterValueNotifier,
      builder: (BuildContext context, Widget? child) {
        if (counterValueNotifier.value == 0) {
          return Text('(-)', style: Theme.of(context).textTheme.titleLarge);
        }
        return Text('(${counterValueNotifier.value})',
            style: Theme.of(context).textTheme.titleLarge);
      },
    );
  }
}

class PopularParkingSpace {
  ParkingSpace parkingSpace;
  int parkingCount;

  PopularParkingSpace(this.parkingSpace, this.parkingCount);
}
