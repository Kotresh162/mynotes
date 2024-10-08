
import 'package:flutter/material.dart';
import 'package:mynotes/constants/route.dart';
import 'package:mynotes/enum/menu_actions.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/views/login_view.dart';
import 'package:mynotes/views/verify_email.dart';


class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: AuthService.firebase().initialize(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              final user = AuthService.firebase().currentUser;
              if (user != null) {
                if(user.isEmailVerified) {
                  return const NotesView();
                }
                else{
                  return const VerifyEmailView();
                }

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

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notes'),
      backgroundColor: Colors.blue,
      actions:  [
        PopupMenuButton<Menuaction>(
          onSelected: (value) async {
            switch (value){
              case Menuaction.logout:
                final shouldOut = await showlogOutDialog(context);
                if(shouldOut){
                await AuthService.firebase().logOut();
                // ignore: use_build_context_synchronously
                Navigator.of(context).pushNamedAndRemoveUntil(loginRoute, (_)=>false,);
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
Future<bool>showlogOutDialog(BuildContext context){
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

