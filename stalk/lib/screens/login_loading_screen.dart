import 'dart:async';
import 'package:flutter/material.dart';
import 'package:after_layout/after_layout.dart';
import '../custom/custom_widget.dart';
import '../network/stalk_network.dart';
import '../utils/storage.dart';
import '../utils/toast.dart';
import '../utils/connection.dart';
import '../utils/enums.dart';

class LoginLoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.indigo,
      body: new LoginLoadingScreenState(),
    );
  }
}

class LoginLoadingScreenState extends StatefulWidget {
  @override
  _LoginLoadingScreenState createState() => _LoginLoadingScreenState();
}

class _LoginLoadingScreenState extends State<LoginLoadingScreenState>
    with AfterLayoutMixin<LoginLoadingScreenState> {
  Timer _timer;
  final Connection _connection = new Connection();
  bool _isLoggingIn = false;
  final List _loadingDots = ['.', '.', '.', '.'];
  String _dispText = "Logging in";
  int _maxLen;
  int _index = 0;

  @override
  afterFirstLayout(BuildContext context) {
    _tryToLogin();
  }

  @override
  void initState() {
    super.initState();
    StalkNetwork.instance.initiateCookie();
    _maxLen = _loadingDots.length;
    //_startAnimating();
  }

  @override
  dispose() {
    super.dispose();
    _timer.cancel();
  }

  _startAnimating() async {
    if (_timer == null) {
      _timer = Timer.periodic(new Duration(milliseconds: 500), (_) {
        _dispText += _loadingDots[_index];
        _index++;
        if (_index >= _maxLen) {
          _dispText = "Logging in";
          _index = 0;
        }
        setState(() {});
      });
    }
  }

  _stopAnimation() async {
    if (_timer != null && _timer.isActive) {
      _timer.cancel();
      _timer = null;
    }
  }

  _setLoginState(bool state) {
    setState(() {
      _isLoggingIn = state;
    });
  }

  _tryToLogin() async {
    //try here to login the user
    await _startAnimating();
    _setLoginState(true);
    await Storage.instance.init();
    Map det = await Storage.instance.getOtherDetails();
    if (det['username'] == "") {
      _registrationNotCompleted();
    } else {
      if (await _connection.isOnline()) {
        _doLoginProcess(det);
      } else {
        _setLoginState(false);
        Toast.showToast(msg: "Network unavailable");
        _stopAnimation();
      }
    }
  }

  _retry() async {
    // retry login
    _tryToLogin();
  }

  _registrationNotCompleted() async {
    _setLoginState(false);
    await _stopAnimation();
    bool status = await Storage.instance.getRegistrationStatus();
    if (status == null) {
      Toast.showToast(
        msg: "null: no account exists\ncreate new or login to an real account",
      );
      Navigator.of(context).pushReplacementNamed('/HomeScreen');
    } else if (status == false) {
      Toast.showToast(msg: "Complete your registration first");
      Navigator.of(context).pushReplacementNamed('/RegScreen');
    } else
      Toast.showToast(msg: "Bad exception !!!");
  }

  _doLoginProcess(Map det) async {
    Map res = await StalkNetwork.instance.isLoggedIn();
    _setLoginState(false);
    _stopAnimation();
    if (res['status'] == STATUS.Success && res['user'] == det['username']) {
      Navigator.of(context).pushReplacementNamed('/LoggedInScreen');
    }
    if (res['status'] == STATUS.NotLoggedIn) {
      Toast.showToast(
        msg: "You are currently not logged in.\nTry to login again",
      );
      Navigator.of(context).pushReplacementNamed('/LoginScreen');
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        CustomWidget.sTalkLogo(),
        new Padding(
          padding: const EdgeInsets.only(top: 30.0),
        ),
        _isLoggingIn
            ? CustomWidget.loading(color: Colors.white)
            : new Container(),
        new Padding(
          padding: const EdgeInsets.only(top: 10.0),
        ),
        _isLoggingIn
            ? new Text(
                _dispText,
                style: new TextStyle(color: Colors.lime),
              )
            : new Container(),
        new Padding(
          padding: const EdgeInsets.only(top: 30.0),
        ),
        _isLoggingIn
            ? new Container()
            : new Column(
                children: <Widget>[
                  new IconButton(
                    icon: new Icon(Icons.refresh),
                    color: Colors.white,
                    iconSize: 60.0,
                    onPressed: _retry,
                  ),
                  new Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                  ),
                  new Text("Tap to retry"),
                ],
              ),
      ],
    );
  }
}
