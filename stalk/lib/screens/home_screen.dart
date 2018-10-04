import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../custom/custom_widget.dart';
import '../utils/auth_service.dart';
import '../screens/loggedin_screen.dart';
import '../utils/storage.dart';
import '../utils/connection.dart';

class STalk extends StatefulWidget {
  @override
  _STalkState createState() => new _STalkState();
}

class _STalkState extends State<STalk> {
  bool _loggingIn = false;
  final AuthService _authService = new AuthService();
  final Storage _storage = new Storage();
  final Connection _connection = new Connection();

  @override
  void initState() {
    super.initState();
    _storage.init();
    _connection.init();
  }

  _startLogin() async {
    await _connection.refresh();
    if (_connection.isNetworkAvailable()) {
      setState(() {
        _loggingIn = true;
      });
      _authService.signInWithGoogle().then(_handleLoginData);
    }
    else {
      CustomWidget.showSnackbarMessage(
        context: context,
        msg: "Network not available",
      );
    }
  }

  _handleLoginData(FirebaseUser user) {
    setState(() {
      _loggingIn = false;
    });
    if (user != null) {
      _storage.saveUserDetails(user);
      _authService.saveDetailsToFirebase(user);
      Navigator.of(context).pushReplacement(new MaterialPageRoute(
          builder: (BuildContext context) => new LoggedInScreen(user)));
    }
  }

  _loading() {
    return new FlatButton(
      child: new Column(
        children: <Widget>[
          new CircularProgressIndicator(),
          new Padding(
            padding: const EdgeInsets.only(top: 7.0),
          ),
          new Text(
            "Logging in...",
            style: new TextStyle(color: Colors.white),
          ),
        ],
      ),
      onPressed: null,
    );
  }

  _createLoginBtn() {
    return new ListView(
      children: <Widget>[
        new Padding(
          padding: const EdgeInsets.only(top: 30.0),
        ),
        CustomWidget.sTalkLogo(),
        new Padding(
          padding: const EdgeInsets.only(top: 55.0),
        ),
        _loggingIn
            ? _loading()
            : CustomWidget.loginButton(callback: _startLogin),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Container(
        decoration: CustomWidget.decorateWithBgImage("images/pen.jpg"),
        child: _createLoginBtn(),
      ),
    );
  }
}
