import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:parkmycar_shared/parkmycar_shared.dart';

import '/screens/main_screen.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory((await getTemporaryDirectory()).path),
  );

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthBloc(
              authRepository: AuthRepository(),
              personRepository: PersonFirebaseRepository()),
        ),
        BlocProvider(
          create: (BuildContext context) => ThemeCubit(),
        ),
      ],
      child: ParkMyCarApp(),
    ),
  );
}

class ParkMyCarApp extends StatelessWidget {
  const ParkMyCarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ParkMyCar',
      debugShowCheckedModeBanner: false,
      themeMode: context.watch<ThemeCubit>().state,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: Color.fromRGBO(85, 234, 242, 1.0),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Color.fromRGBO(85, 234, 242, 1.0),
      ),
      home: const AuthViewSwitcher(),
    );
  }
}

class AuthViewSwitcher extends StatelessWidget {
  const AuthViewSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: switch (authState.status) {
        AuthStateStatus.authenticated => const MainScreen(), // When logged in
        _ => const LoginScreen(title: 'ParkMyCar'), // For all other cases
      },
    );
  }
}
