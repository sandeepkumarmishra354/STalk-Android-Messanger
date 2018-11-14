import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:test_flutter/utils/enums.dart';
import 'registration_screen.dart';
import 'login_screen.dart';
//import 'loggedin_screen.dart';
import '../custom/custom_widget.dart';
import '../utils/auth_service.dart';
import '../utils/storage.dart';
import '../utils/connection.dart';
import '../utils/toast.dart';
import '../network/stalk_network.dart';
import '../data/constants.dart' as Constants;

class STalk extends StatefulWidget {
  @override
  _STalkState createState() => new _STalkState();
}

class _STalkState extends State<STalk> {
  bool _sendingCode = false;
  bool _isVarified = false;
  bool _isCodeSent = false;
  bool _showVerWidget = false;
  bool _enableRBtn = false;
  bool _enableVBtn = false;
  bool _isVerifying = false;
  String _verificationId;
  String _phoneNumber;
  String _countryCode = "+91";
  String _smsCode;
  final AuthService _authService = new AuthService();
  final Storage _storage = new Storage();
  final Connection _connection = new Connection();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _txtController = new TextEditingController();
  final TextEditingController _codeController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    _storage.init();
    _connection.init();
    StalkNetwork.instance.initiateCookie();
  }

  Future<void> _verifyPhone(String phoneNo) async {
    final PhoneCodeAutoRetrievalTimeout autoRetrieve = (String verId) {
      this._verificationId = verId;
    };
    final PhoneCodeSent smsCodeSent = (String verId, [int forceCodeResend]) {
      this._verificationId = verId;
      setState(() {
        _sendingCode = false;
        _isCodeSent = true;
        _showVerWidget = true;
      });
      _signIn();
    };
    final PhoneVerificationCompleted verifiedSuccess = (FirebaseUser user) {
      _userVerified(user);
    };
    final PhoneVerificationFailed veriFailed = (AuthException e) {
      print(e.message);
      setState(() {
        _sendingCode = false;
        _isCodeSent = false;
        _isVarified = false;
        _showVerWidget = false;
        _isVarified = false;
        _isVerifying = false;
      });
    };
    if (await _connection.isOnline()) {
      setState(() {
        _sendingCode = true;
      });
      try {
        await FirebaseAuth.instance.verifyPhoneNumber(
            phoneNumber: phoneNo,
            codeAutoRetrievalTimeout: autoRetrieve,
            codeSent: smsCodeSent,
            timeout: const Duration(seconds: 5),
            verificationCompleted: verifiedSuccess,
            verificationFailed: veriFailed);
      } catch (e) {
        print(e.message);
        Toast.showToast(msg: "oops !! something went wrong");
        setState(() {
          _sendingCode = false;
          _isCodeSent = false;
          _isVarified = false;
          _showVerWidget = false;
          _isVarified = false;
          _isVerifying = false;
        });
      }
    } else
      Toast.showToast(msg: "Network unavailable !!");
  }

  _enterCodeWidget(BuildContext context) {
    return new ListView(
      children: <Widget>[
        new Padding(
          padding: const EdgeInsets.only(top: 30.0),
        ),
        CustomWidget.sTalkLogo(),
        new Padding(
          padding: const EdgeInsets.only(top: 10.0),
        ),
        new Container(
          padding: const EdgeInsets.all(8.0),
          child: new Text(
            Constants.smsWaitingText(_phoneNumber),
            style:
                new TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
        new Padding(
          padding: const EdgeInsets.only(top: 20.0),
        ),
        new Container(
          margin: const EdgeInsets.only(left: 20.0, right: 20.0),
          child: CustomWidget.createInputField(
            "Enter verification code",
            controller: _codeController,
            keyboardType: TextInputType.number,
            onChanged: (String val) {
              _smsCode = val;
              if (val.length <= 5)
                setState(() {
                  _enableVBtn = false;
                });
              else
                setState(() {
                  _enableVBtn = true;
                });
            },
          ),
          decoration: new BoxDecoration(
            color: new Color(CustomWidget.hexToInt("80FFFFFF")),
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        new Padding(
          padding: const EdgeInsets.only(bottom: 15.0),
        ),
        _isVerifying
            ? CustomWidget.loading()
            : CustomWidget.loginButton(
                txt: "VERIFY",
                callback: _enableVBtn ? _signIn : null,
              ),
        new Padding(
          padding: const EdgeInsets.only(top: 12.0),
        ),
        CustomWidget.flatBtn(
          "EDIT NUMBER",
          color: Colors.blue,
          callback: _isVerifying
              ? null
              : () {
                  setState(() {
                    _showVerWidget = false;
                  });
                },
        ),
      ],
    );
  }

  _signIn() async {
    var user = await FirebaseAuth.instance.currentUser();
    if (user == null) {
      if (_smsCode != null) {
        setState(() {
          if (_phoneNumber != '+918052525337') _isVerifying = true;
        });
      }
      try {
        var u1 = await FirebaseAuth.instance.signInWithPhoneNumber(
            verificationId: this._verificationId, smsCode: this._smsCode);
        _userVerified(u1);
      } catch (e) {
        print(e.message);
        Toast.showToast(msg: "Something went wrong");
        setState(() {
          _isVerifying = false;
        });
      }
    } else {
      _registerUserToServer(user);
    }
  }

  _userVerified(FirebaseUser user) async {
    print("AAAAAAAAAAVVVVVVVVVVVVVVVVV");
    _registerUserToServer(user);
  }

  _registerUserToServer(var user) async {
    print("RRRRRRRRRTTTTTTTTTSSSSSSSSSS");
    Map result = await StalkNetwork.instance
        .registerPhone(phone: user.phoneNumber, uid: user.uid);
    print(result);
    setState(() {
      _isVerifying = false;
    });
    if (result['status'] == STATUS.Fail) {
      Toast.showToast(msg: "Error:: try again");
    }
    if (result['status'] == STATUS.AccountExists) {
      Toast.showToast(
          msg:
              "An account already exists with same number ${user.phoneNumber}");
    }
    if (result['status'] == STATUS.Success) {
      _storage.saveNumberAndUid(user.phoneNumber, user.uid);
      _storage.setRegistrationStatus(status: false);
      Navigator.of(context).pushReplacement(new MaterialPageRoute(
          builder: (BuildContext context) => new RegistrationScreen()));
    }
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
        new Container(
          margin: const EdgeInsets.only(left: 20.0, right: 20.0),
          child: new TextField(
            controller: _txtController,
            keyboardType: TextInputType.phone,
            decoration: new InputDecoration(
              hintText: "Mobile Number",
              border: InputBorder.none,
              prefixIcon: new Container(
                child: new CountryCodePicker(
                  initialSelection: 'IN',
                  favorite: ['+91', 'IN'],
                  onChanged: (CElement ce) {
                    _countryCode = ce.dialCode;
                  },
                ),
              ),
            ),
            onChanged: (val) {
              if (val.length <= 9)
                setState(() {
                  _enableRBtn = false;
                });
              else
                setState(() {
                  _enableRBtn = true;
                });
            },
          ),
          decoration: new BoxDecoration(
            color: new Color(CustomWidget.hexToInt("80FFFFFF")),
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        new Padding(
          padding: const EdgeInsets.only(bottom: 15.0),
        ),
        _sendingCode
            ? CustomWidget.loading()
            : CustomWidget.loginButton(
                txt: "REGISTER",
                callback: _enableRBtn
                    ? () async {
                        _phoneNumber = _countryCode + _txtController.text;
                        if (await _connection.isOnline()) {
                          FirebaseUser user =
                              await _authService.checkExistance(_phoneNumber);
                          if (user == null)
                            _verifyPhone(_phoneNumber);
                          else
                            _registerUserToServer(user);
                        } else
                          Toast.showToast(msg: "Network unavailable !!");
                      }
                    : null),
        CustomWidget.flatBtn(
          "Login",
          color: Colors.deepPurple,
          callback: _showLoginScreen,
        ),
      ],
    );
  }

  _showLoginScreen() async {
    Navigator.of(context).pushReplacement(
        new MaterialPageRoute(builder: (context) => new LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      body: new Container(
          decoration: CustomWidget.decorateWithBgImage(Constants.penImage),
          child: _showVerWidget
              ? _enterCodeWidget(context)
              : _createLoginBtn() //_createLoginBtn(),
          ),
    );
  }
}
