import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parkmycar_shared/parkmycar_shared.dart';

import '../blocs/auth_bloc.dart';
import 'account_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final authStatus = context.watch<AuthBloc>().state.status;
    final authBloc = BlocProvider.of<AuthBloc>(context);
    final bool isLoading = (authStatus == AuthStateStatus.authenticating);

    final formKey = GlobalKey<FormState>();
    final usernameFocus = FocusNode();
    // final passwordFocus = FocusNode();

    String? email;

    return Scaffold(
        body: BlocListener(
      bloc: authBloc,
      listener: (context, AuthState state) {
        if (state.status == AuthStateStatus.unauthenticated) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
                SnackBar(content: Text('Inloggningen misslyckades!')));
        }
      },
      child: Center(
        child: Form(
          key: formKey,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 32),
                TextFormField(
                  focusNode: usernameFocus,
                  autofocus: true,
                  initialValue: 'markus@gemstad.se',
                  enabled: !isLoading,
                  decoration: const InputDecoration(
                    labelText: 'E-postadress',
                    prefixIcon: Icon(Icons.person),
                  ),
                  autovalidateMode: AutovalidateMode.onUnfocus,
                  validator: (value) => Validators.isValidEmail(value)
                      ? null
                      : 'Ange en giltig e-postadress',
                  onFieldSubmitted: (_) {
                    if (formKey.currentState!.validate()) {
                      formKey.currentState!.save();
                      context.read<AuthBloc>().add(AuthLoginRequested(email!));
                    }
                  },
                  onSaved: (newValue) => email = newValue,
                ),
                // const SizedBox(height: 16),
                // TextFormField(
                //   focusNode: passwordFocus,
                //   obscureText: true,
                //   enabled: authService.status != AuthStatus.authenticating,
                //   decoration: const InputDecoration(
                //     labelText: 'Lösenord',
                //     prefixIcon: Icon(Icons.lock),
                //   ),
                //   validator: (value) =>
                //       value?.isEmpty ?? true ? 'Ange ett lösenord' : null,
                //   onFieldSubmitted: (_) {
                //     if (formKey.currentState!.validate()) {
                //       context.read<AuthService>().login();
                //     }
                //   },
                // ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: isLoading
                      ? FilledButton(
                          onPressed: () {},
                          child: SizedBox(
                            height: 20.0,
                            width: 20.0,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        )
                      : FilledButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              formKey.currentState!.save();
                              context
                                  .read<AuthBloc>()
                                  .add(AuthLoginRequested(email!));
                            }
                          },
                          child: const Text('Logga in'),
                        ),
                ),
                const SizedBox(height: 32),
                Text('Eller saknar du konto?'),
                const SizedBox(height: 16),
                TextButton(
                    onPressed: () {
                      formKey.currentState!.reset();
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => AccountScreen(
                                isEditMode: false,
                                doPop: true,
                              )));
                    },
                    child: Text('Skapa nytt konto'))
              ],
            ),
          ),
        ),
      ),
    ));
  }
}
