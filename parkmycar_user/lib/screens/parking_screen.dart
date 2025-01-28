import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parkmycar_shared/parkmycar_shared.dart';

import '../blocs/active_parking_bloc.dart';
import '../blocs/parking_spaces_bloc.dart';
import 'parking_ongoing_screen.dart';
import 'parking_start_dialog.dart';

class ParkingScreen extends StatelessWidget {
  const ParkingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // timeDilation = 2.0; // Make the animations go slower
    final ActiveParkingState activeParkingState =
        context.watch<ActiveParkingBloc>().state;

    return switch (activeParkingState.status) {
      ParkingStatus.active || ParkingStatus.starting => ParkingOngoingScreen(
          onEndParking: () {},
        ),
      _ => buildThisPage(context),
    };
  }

  Widget buildThisPage(BuildContext context) {
    return BlocListener(
      bloc: BlocProvider.of<ActiveParkingBloc>(context),
      listener: (context, ActiveParkingState state) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        switch (state.status) {
          case ParkingStatus.active:
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('En parkering har startats!')));
          case ParkingStatus.nonActive:
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('En parkering har avslutats!')));
          case ParkingStatus.errorStarting:
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Det gick inte att starta en parkering!')));
          case ParkingStatus.errorEnding:
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Det gick inte att avsluta en parkering!')));
          default: // Do nothing
        }
      },
      child: Column(
        children: [
          _SearchBar(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                context.read<ParkingSpacesBloc>().add(ReloadParkingSpaces());
                await context
                    .read<ParkingSpacesBloc>()
                    .stream
                    .firstWhere((state) => state is ParkingSpacesLoaded);
              },
              child: BlocBuilder<ParkingSpacesBloc, ParkingSpacesState>(
                builder: (context, parkingSpacesState) {
                  return switch (parkingSpacesState) {
                    ParkingSpacesInitial() =>
                      Center(child: CircularProgressIndicator()),
                    ParkingSpacesLoading() =>
                      Center(child: CircularProgressIndicator()),
                    ParkingSpacesError(message: final message) => Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text('Error: $message'),
                      ),
                    ParkingSpacesLoaded(
                      parkingSpaces: final parkingSpaces,
                    ) =>
                      (parkingSpaces.isEmpty)
                          ? SizedBox.expand(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text('Hittade inga parkeringsplatser.'),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(12.0),
                              itemCount: parkingSpaces.length,
                              itemBuilder: (context, index) {
                                var parkingSpace = parkingSpaces[index];
                                return ListTile(
                                  onTap: () async {
                                    // Use push instead of showDialog to only to
                                    // make hero animation work.
                                    Parking? parking =
                                        await Navigator.of(context)
                                            .push<Parking>(MaterialPageRoute(
                                                builder: (context) =>
                                                    ParkingStartDialog(
                                                        parkingSpace)));

                                    debugPrint(parking.toString());
                                    if (parking != null &&
                                        parking.isValid() &&
                                        context.mounted) {
                                      context
                                          .read<ActiveParkingBloc>()
                                          .add(ActiveParkingStart(parking));
                                    }
                                  },
                                  leading: Hero(
                                      tag: 'parkingicon${parkingSpace.id}',
                                      transitionOnUserGestures: true,
                                      child: Image.asset(
                                        'assets/parking_icon.png',
                                        width: 30.0,
                                      )),
                                  title: Text(parkingSpace.streetAddress),
                                  subtitle: Text(
                                      '${parkingSpace.postalCode} ${parkingSpace.city}\n'
                                      'Pris per timme: ${parkingSpace.pricePerHour} kr'),
                                );
                              },
                            ),
                  };
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatefulWidget {
  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  late TextEditingController _searchController;
  late ParkingSpacesBloc _parkingSpacesBloc;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_queryListener);
    _parkingSpacesBloc = context.read<ParkingSpacesBloc>();
    if (_parkingSpacesBloc.currentQuery != null) {
      _searchController.text = _parkingSpacesBloc.currentQuery!;
    }
  }

  void _queryListener() {
    _parkingSpacesBloc.add(SearchParkingSpaces(query: _searchController.text));
  }

  @override
  void dispose() {
    _searchController.removeListener(_queryListener);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: SearchBar(
        leading: const Icon(Icons.search),
        // trailing: <Widget>[ // Use for clearing search
        //   const Icon(Icons.close),
        //   SizedBox(
        //     width: 6.0,
        //   ),
        // ],
        hintText: 'Sök gata...',
        controller: _searchController,
      ),
    );
  }
}
