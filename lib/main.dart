import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/firebase_options.dart';
import 'package:mynotes/views/login_view.dart';
import 'package:mynotes/views/register_view.dart';
import 'package:mynotes/views/verify_Email.dart';
import 'dart:developer' as devtools show log;

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
      '/login/':(contex) => const LoginView(),
      '/register/':(contex) => const RegisterView()
    },
  ));
}

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                if(user.emailVerified) {
                  return const notesView();
                }
                else{
                  return const VerifyEmailView();
                }
              // print(user);
              // if (user?.emailVerified ?? false) {
              //   // Add your logic here for verified users
              // return const Text('Done');
              // } else {
              //   return const VerifyEmailView();
              // }
          }
              else{
                return const LoginView();
              }
            default :
              return const CircularProgressIndicator();
          }
        },
      );
  }
}
enum Menuaction {logout}
class notesView extends StatefulWidget {
  const notesView({super.key});

  @override
  State<notesView> createState() => _notesViewState();
}

class _notesViewState extends State<notesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notes'),
      actions:  [
        PopupMenuButton<Menuaction>(
          onSelected: (value) async {
            switch (value){
              case Menuaction.logout:
                final ShouldOut = await ShowlogOutDialog(context);
                if(ShouldOut){
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushNamedAndRemoveUntil('/login/', (_)=>false,);
                }
              default:
              break;
            }
          
            },
          itemBuilder: (context) {
            return const [
              PopupMenuItem<Menuaction>(value: Menuaction.logout,child:  Text('Logout')),
            ];
          }
        )
      ],),
      body: const Text('notes VIew'),
    );
  }
}
Future<bool>ShowlogOutDialog(BuildContext context){
  return showDialog<bool>(context: context, builder: (context){
    return AlertDialog(
      title: const Text('SignOut'),
      content: const Text('are u sure to sign out'),
      actions: [
        TextButton(onPressed: (){
          Navigator.of(context).pop(false);
        }, child: const Text('cancel')),
        TextButton(onPressed: (){
          Navigator.of(context).pop(true);
        }, child: const Text('log out')),

      ],
    );
  }
  ).then((value)=> value ?? false);
}