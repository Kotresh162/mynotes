// ignore_for_file: use_build_context_synchronously

// import 'package:firebase_auth/firebase_auth.dart';
import 'package:mynotes/services/auth/auth_exception.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/utilities/error_dialog.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/constants/route.dart';
// import 'dart:developer' as devtools show log;

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewstate();
}

class _LoginViewstate extends State<LoginView> {
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
      appBar: AppBar(
        title: const Text('Login'),
      ),
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
                  await AuthService.firebase().logIn(
                    email: email,
                    password: password,
                  );
                  final user = AuthService.firebase().currentUser;
                  if(user?.isEmailVerified ?? false){
                    Navigator.of(context)
                      .pushNamedAndRemoveUntil(notesRoute, (route) => false);
                  }else{
                    Navigator.of(context)
                      .pushNamedAndRemoveUntil(verifyRoute, (route) => false);
                  }
                  // ignore: use_build_context_synchronousl
                } on InvaliCredentialAuthException {
                  await ShowErrorDialog(
                          context, 'invalid credential or user not found');
                } on GenericAuthException {
                  await ShowErrorDialog(context, 'something went wrong');
                }
                  
              },
              child: const Text('sign in')),
          TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(registerRoute, (route) => false);
              },
              child: const Text('not register yet? Register'))
        ],
      ),
    );
  }
}