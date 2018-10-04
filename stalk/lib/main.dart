import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/loggedin_screen.dart';
import 'custom/custom_widget.dart';
import 'utils/storage.dart';
import 'screens/chat_screen.dart';

void main() async {
  Storage storage = new Storage();
  await storage.init();
  var user = storage.isAlreadyLoggedIn();
  runApp(new MainApp(user: user,));
}

class MainApp extends StatelessWidget {
  final user;
  MainApp({this.user});
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: "STalk",
      //new ChatScreen(friendName:"",friendUid:"",mainUid:"",mainUser:"",photoUrl:"",)
			home: (user == null)?new STalk():new LoggedInScreen(user),
      routes: {
        '/Home': (context) => new STalk(),
      },
      theme: CustomWidget.theme,
    );
  }
}
