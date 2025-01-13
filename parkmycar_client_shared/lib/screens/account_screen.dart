import 'package:flutter/material.dart';
import 'package:parkmycar_client_shared/parkmycar_client_stuff.dart';
import 'package:parkmycar_client_shared/parkmycar_firebase_repo.dart';
import 'package:parkmycar_shared/parkmycar_shared.dart';
import 'package:provider/provider.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen(
      {super.key,
      this.isEditMode = true,
      this.doPop = false,
      this.verticalAlign = MainAxisAlignment.center});

  final bool isEditMode;
  final bool doPop;
  final MainAxisAlignment verticalAlign;

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _name;
  String? _email;

  void savePerson(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      if (!mounted) return;

      _formKey.currentState!.save();

      try {
        if (widget.isEditMode) {
          // Update name of currently logged in person
          final authState = context.read<AuthBloc>().state;
          if (authState.status == AuthStateStatus.authenticated) {
            //Person currentPerson = authState.user; // Get user from state
            authState.user?.name = _name!; // Update name in state
            await PersonFirebaseRepository().update(authState.user!);
          }
        } else {
          // Save new person
          await PersonFirebaseRepository().create(Person(_name!, _email!));
        }

        String successMessage =
            (widget.isEditMode) ? 'Person uppdaterad!' : 'Person skapad!';
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(successMessage)));
      } catch (e) {
        // ignore: use_build_context_synchronously
        debugPrint(e.toString());
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text('Person kunde inte sparas!')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    Person? currentPerson = authState.user;
    String title = (widget.isEditMode) ? 'Redigera konto' : 'Skapa konto';

    return Scaffold(
      body: Align(
        alignment: Alignment.center,
        child: Container(
          padding: EdgeInsets.all(12.0),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: widget.verticalAlign,
              children: [
                Text(title, style: Theme.of(context).textTheme.headlineSmall),
                TextFormField(
                  initialValue: currentPerson?.name,
                  validator: (value) => Validators.isValidName(value)
                      ? null
                      : 'Ange ett giltigt namn.',
                  onFieldSubmitted: (_) => savePerson(context),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  autofocus: true,
                  onSaved: (newValue) => _name = newValue,
                  decoration: const InputDecoration(
                      border: UnderlineInputBorder(), labelText: 'Namn'),
                ),
                SizedBox(height: 20),
                TextFormField(
                  initialValue: currentPerson?.email,
                  autovalidateMode: AutovalidateMode.onUnfocus,
                  validator: (value) => Validators.isValidEmail(value)
                      ? null
                      : 'Ange en giltig e-postadress',
                  readOnly: widget.isEditMode,
                  onSaved: (newValue) => _email = newValue,
                  decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: (widget.isEditMode)
                          ? 'E-post (går inte att ändra)'
                          : 'E-post'),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Visibility(
                      visible: widget.doPop,
                      child: ElevatedButton(
                        child: const Text('Avbryt'),
                        onPressed: () {
                          if (widget.doPop) {
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                    ),
                    SizedBox(width: 20),
                    FilledButton(
                      child: const Text('Spara'),
                      onPressed: () async {
                        savePerson(context);
                        if (widget.doPop) {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  ],
                ),
                Visibility(
                  visible: widget.isEditMode,
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      Text('Byt tema',
                          style: Theme.of(context).textTheme.headlineSmall),
                      SizedBox(height: 10),
                      SegmentedButton<ThemeMode>(
                        segments: [
                          ButtonSegment<ThemeMode>(
                            value: ThemeMode.light,
                            icon: Icon(Icons.light_mode),
                            label: Text('Ljust'),
                          ),
                          ButtonSegment<ThemeMode>(
                            value: ThemeMode.dark,
                            icon: Icon(Icons.dark_mode),
                            label: Text('Mörkt'),
                          ),
                          ButtonSegment<ThemeMode>(
                            value: ThemeMode.system,
                            icon: Icon(Icons.auto_mode),
                            label: Text('Auto'),
                          ),
                        ],
                        selected: <ThemeMode>{
                          // context.read<ThemeCubit>().state
                          Provider.of<ThemeCubit>(context).state
                        },
                        onSelectionChanged: (p0) {
                          // context.read<ThemeCubit>().changeThemeMode(p0.first);
                          Provider.of<ThemeCubit>(context, listen: false)
                              .changeThemeMode(p0.first);
                        },
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
