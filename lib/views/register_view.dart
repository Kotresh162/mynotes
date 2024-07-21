// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mynotes/constants/route.dart';
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
                        await FirebaseAuth.instance
                          .createUserWithEmailAndPassword(
                        email: email,
                        password: password,
                      );
                      final user = FirebaseAuth.instance.currentUser;
                      user?.sendEmailVerification();
                      Navigator.of(context).pushNamed(verifyRoute);
                      } on FirebaseAuthException catch (e) {
                        if(e.code == 'weak-password'){
                          await ShowErrorDialog(context, 'provide strong password');
                        }
                        else if(e.code == 'email-already-in-use'){
                          await ShowErrorDialog(context, 'email is already used');
                        }
                        else if(e.code == 'invalid-email'){
                          await ShowErrorDialog(context, 'invalid email');
                        }
                        else{
                          await ShowErrorDialog(context, 'error:${e.code}');
                        }
                      } catch(e){
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