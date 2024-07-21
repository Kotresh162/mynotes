import 'package:flutter/material.dart';
import 'package:mynotes/constants/route.dart';
import 'package:mynotes/views/homepaga.dart';
import 'package:mynotes/views/login_view.dart';
import 'package:mynotes/views/register_view.dart';
import 'package:mynotes/views/verify_email.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    ),
    home: const Homepage(),
    routes: {
      loginRoute:(contex) => const LoginView(),
      registerRoute:(contex) => const RegisterView(),
      notesRoute:(context) => const notesView(),
      verifyRoute:(context) => const VerifyEmailView(),
    },
  ));
}
