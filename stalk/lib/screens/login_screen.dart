import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../custom/custom_widget.dart';
import '../network/stalk_network.dart';
import '../utils/enums.dart';
import '../utils/connection.dart';
import '../utils/toast.dart';
import '../data/constants.dart' as Constants;

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new LoginScreenState(),
    );
  }
}

class LoginScreenState extends StatefulWidget {
  @override
  _LoginScreenState createState() => new _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreenState> {
  final _usernameController = new TextEditingController();
  final _passworldController = new TextEditingController();
  final Connection _connection = new Connection();
  bool _enableLoginBtn = false;
  bool _loggingIn = false;

  @override
  void initState() {
      super.initState();
      StalkNetwork.instance.initiateCookie();
    }

  @override
  Widget build(BuildContext context) {
    return new Stack(
      children: <Widget>[
        CustomWidget.createBluredBackground(Constants.penImage),
        new ListView(
          children: <Widget>[
            new Padding(
              padding: const EdgeInsets.only(top: 30.0),
            ),
            CustomWidget.sTalkLogo(),
            new Padding(
              padding: const EdgeInsets.only(top: 20.0),
            ),
            Center(
              child: new Text(
                "LOGIN",
                style: new TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 40.0,
                  color: Colors.blue,
                ),
              ),
            ),
            new Padding(
              padding: const EdgeInsets.only(top: 15.0),
            ),
            _loginForm(),
            new Padding(
              padding: const EdgeInsets.only(top: 12.0),
            ),
            _loggingIn ? CustomWidget.loading(color: Colors.blue) : _loginButton(),
            CustomWidget.flatBtn(
              "Create an account",
              callback: _showCreateAccountScreen,
              color: Colors.white,
            ),
          ],
        ),
      ],
    );
  }

  _showCreateAccountScreen() async {
    Navigator.of(context).pushReplacement(new MaterialPageRoute(
      builder: (context)=> new STalk()
    ));
  }

  _loginForm() {
    return new Column(
      children: <Widget>[
        new Container(
          margin: const EdgeInsets.only(left: 30.0, right: 30.0),
          child: CustomWidget.createInputField(
            "Username",
            controller: _usernameController,
            onChanged: _onValueChanged,
          ),
        ),
        new Padding(
          padding: const EdgeInsets.only(top: 8.0),
        ),
        new Container(
          margin: const EdgeInsets.only(left: 30.0, right: 30.0),
          child: CustomWidget.createInputField(
            "Password",
            secureText: true,
            controller: _passworldController,
            onChanged: _onValueChanged,
          ),
        ),
      ],
    );
  }

  _onValueChanged(String val) async {
    if (_usernameController.text.isNotEmpty &&
        _passworldController.text.length > 5)
      setState(() {
        _enableLoginBtn = true;
      });
    else
      setState(() {
        _enableLoginBtn = false;
      });
  }

  _loginButton() {
    return new Container(
      margin: const EdgeInsets.only(left: 30.0, right: 40.0),
      child: new RaisedButton(
        child: new Text(
          "LOGIN",
          style: new TextStyle(
            color: Colors.white,
          ),
        ),
        color: Colors.deepPurple,
        onPressed: _enableLoginBtn ? _handleLogin : null,
      ),
    );
  }

  _handleLogin() async {
    if (await _connection.isOnline()) {
      if (_usernameController.text.isNotEmpty &&
          _passworldController.text.length > 5) {
        setState(() {
          _loggingIn = true;
        });
        var result = await StalkNetwork.instance.loginUser(
          username: _usernameController.text,
          password: _passworldController.text,
        );
        setState(() {
          _loggingIn = false;
        });
        print(result);
        if (result['status'] == STATUS.Success) {
          Toast.showToast(msg: "Now you are logged in");
          Navigator.of(context).pushReplacement(new MaterialPageRoute(
            builder: (context)=> new Scaffold(
              body: Center(
                child: new Text("Logged in as ${result['user']}"),
              ),
            )
          ));
        }
        if (result['status'] == STATUS.Fail) {
          print("ouch..!! wrong username or password");
          Toast.showToast(msg: "Oh.. fail");
        }
        if (result['status'] == STATUS.InternalNetworkError) {
          print("Internal network error");
          Toast.showToast(msg: "Something went wrong.. try letter");
        }
      }
    } else
      Toast.showToast(msg: "Network not available !!");
  }
}
