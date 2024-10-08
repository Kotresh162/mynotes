import 'package:flutter/material.dart';
import 'package:mynotes/constants/route.dart';
import 'package:mynotes/services/auth/auth_exception.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/utilities/error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {

  late final TextEditingController _email;
  late final TextEditingController _password;
  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register'),),
      body: Column(
              children: [
                TextField(
                  controller: _email,
                  enableSuggestions: false,
                  autocorrect: false,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'enter ur email',
                  ),
                ),
                TextField(
                  controller: _password,
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    hintText: 'enter a password',
                  ),
                ),
                TextButton(
                    onPressed: () async {
                      final email = _email.text;
                      final password = _password.text;
                      
                      try {
                        await AuthService.firebase().creatUser(
                        email: email,
                        password: password,
                      );
                      AuthService.firebase().sendEmailVerification();
                      Navigator.of(context).pushNamed(verifyRoute);
                      } on WeakPasswordAuthException {
                        await ShowErrorDialog(context, 'provide strong password');
                      } on EmailExistAuthException {
                        await ShowErrorDialog(context, 'email is already used');
                      }  on GenericAuthException catch(e) {
                        await ShowErrorDialog(context, e.toString());
                      }
                    },
                    child: const Text('Register')),
                    TextButton(onPressed: (){Navigator.of(context).pushNamedAndRemoveUntil(loginRoute, (route) => false);}, child: const Text('already registered ? login here'))
              ],
            ),
    );
  }
}