import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simple_permissions/simple_permissions.dart';
import 'screens/registration_screen.dart';
import 'screens/login_screen.dart';
import 'screens/login_loading_screen.dart';
import 'screens/home_screen.dart';
import 'screens/about_screen.dart';
import 'screens/loggedin_screen.dart';
import 'utils/storage.dart';
import 'custom/custom_widget.dart';

void main() async {
  createFolders();
  await Storage.instance.init();
  bool regStatus = await Storage.instance.getRegistrationStatus();
  Widget home;
  if (regStatus != null && regStatus == true) {
    home = new LoginLoadingScreen();
  } else if (regStatus == false) {
    home = new RegistrationScreen();
  } else {
    home = STalk();
  }
  runApp(new MainApp(
    myHome: home,
  ));
}

class MainApp extends StatelessWidget {
  final Widget myHome;
  MainApp({this.myHome});
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: "STalk",
      home: myHome,
      routes: {
        '/RegScreen': (context) => new RegistrationScreen(),
        '/LoginScreen': (context) => new LoginScreen(),
        '/AboutScreen': (context) => new AboutPage(),
        '/HomeScreen': (context) => new STalk(),
        '/LoggedInScreen': (context) => new LoggedInScreen(),
      },
      theme: CustomWidget.theme,
    );
  }
}

void createFolders() async {
  Directory extDir = await getExternalStorageDirectory();
  Directory stalkDir = new Directory(extDir.path + "/STalk");
  Directory stalkDbDir = new Directory(extDir.path + "/STalk/Databases");
  Directory stalkMediaDir = new Directory(extDir.path + "/STalk/media");
  Directory stalkMediaImgDir =
      new Directory(extDir.path + "/STalk/media/image");
  Directory stalkMediaVideoDir =
      new Directory(extDir.path + "/STalk/media/video");
  Directory stalkMediaAudioDir =
      new Directory(extDir.path + "/STalk/media/audio");
  Directory stalkMediaGifDir = new Directory(extDir.path + "/STalk/media/gif");
  if (!await stalkDir.exists()) {
    await SimplePermissions.requestPermission(Permission.ReadExternalStorage);
    await SimplePermissions.requestPermission(Permission.WriteExternalStorage);
    await stalkDir.create(recursive: true);
    await stalkDbDir.create(recursive: true);
    await stalkMediaDir.create(recursive: true);
    await stalkMediaImgDir.create(recursive: true);
    await stalkMediaVideoDir.create(recursive: true);
    await stalkMediaAudioDir.create(recursive: true);
    await stalkMediaGifDir.create(recursive: true);
  }
}
