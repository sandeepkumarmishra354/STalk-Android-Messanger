import 'package:flutter/material.dart';
import '../custom/custom_widget.dart';
import '../utils/toast.dart';
import '../utils/connection.dart';
import '../network/stalk_network.dart';
import '../utils/storage.dart';
import '../utils/enums.dart';
import '../data/constants.dart' as Constants;

class RegistrationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new RegistrationScreenState(),
    );
  }
}

class RegistrationScreenState extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreenState> {
  final _formkey = new GlobalKey<FormState>();
  final _fullnameController = new TextEditingController();
  final _usernameController = new TextEditingController();
  final _passwordController = new TextEditingController();
  final _repeatPasswordController = new TextEditingController();
  final Connection _connection = new Connection();
  final Storage _storage = new Storage();

  List<int> _ageList = new List<int>();
  List<DropdownMenuItem<int>> _listAgeItems = new List<DropdownMenuItem<int>>();

  int _userAge = 16;
  bool _isMale = true;
  bool _isFemale = false;
  bool _submitting = false;

  @override
  initState() {
    super.initState();
    _storage.init();
    _initAgeList();
    _initAgeListItem();
  }

  _initAgeList() {
    for (int i = 16; i <= 100; i++) _ageList.add(i);
  }

  _initAgeListItem() {
    for (int age in _ageList) {
      DropdownMenuItem<int> menuItem = new DropdownMenuItem<int>(
        child: new Text(
          "$age years",
          style: new TextStyle(color: Colors.blue),
        ),
        value: age,
      );
      _listAgeItems.add(menuItem);
    }
  }

  _topPadding(double v) {
    return new Padding(
      padding: EdgeInsets.only(top: v),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Stack(
      children: <Widget>[
        CustomWidget.createBluredBackground(Constants.penImage),
        new ListView(
          children: <Widget>[
            _topPadding(30.0),
            CustomWidget.sTalkLogo(),
            _topPadding(10.0),
            Center(
              child: new Text(
                "Complete your registration",
                style: new TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.blue),
              ),
            ),
            new Divider(),
            _topPadding(30.0),
            _formWidget(),
            _topPadding(30.0),
            _submitting ? CustomWidget.loading() : _submitButton(),
            _topPadding(20.0),
          ],
        ),
      ],
    );
  }

  _submitButton() {
    return new Container(
      margin: const EdgeInsets.only(left: 30.0, right: 30.0),
      child: new RaisedButton(
        color: Colors.blue,
        child: new Padding(
          padding: const EdgeInsets.all(12.0),
          child: new Text(
            "Submit",
            style: new TextStyle(color: Colors.white),
          ),
        ),
        onPressed: _submit,
      ),
    );
  }

  _formWidget() {
    return new Container(
      padding: const EdgeInsets.only(left: 15.0, right: 15.0),
      child: new Form(
        key: _formkey,
        child: new Column(
          children: <Widget>[
            CustomWidget.createInputField("Fullname",
                type: InputType.FORM,
                controller: _fullnameController, validator: (s) {
              if (s.isEmpty) return "enter your name";
            }),
            _topPadding(10.0),
            CustomWidget.createInputField(
              "Username",
              type: InputType.FORM,
              controller: _usernameController,
              validator: (s) {
                if (s.isEmpty) return "enter username";
              },
            ),
            _topPadding(10.0),
            new Text(
              "Choose gender",
              style: new TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.white),
            ),
            _topPadding(15.0),
            _genderOption(),
            _topPadding(10.0),
            new Text(
              "Choose age",
              style: new TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.white),
            ),
            _topPadding(10.0),
            _ageOption(),
            _topPadding(15.0),
            CustomWidget.createInputField("Choose password",
                type: InputType.FORM,
                controller: _passwordController, validator: (s) {
              if (s.isEmpty) return "choose a strong password";
              if (s.length < 6) return "password must be 6 character long";
            }),
            _topPadding(10.0),
            CustomWidget.createInputField("Repeat password",
                type: InputType.FORM,
                controller: _repeatPasswordController,
                secureText: true, validator: (s) {
              if (s.isEmpty) return "password doesn't match";
              if (_passwordController.text != s)
                return "password doesn't match";
            }),
          ],
        ),
      ),
    );
  }

  _genderOption() {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        new Text(
          "Male",
          style: new TextStyle(color: Colors.white),
        ),
        new Checkbox(
          value: _isMale,
          activeColor: Colors.blue,
          onChanged: (v) {
            if (v)
              setState(() {
                _isMale = true;
                _isFemale = false;
              });
          },
        ),
        new Padding(
          padding: const EdgeInsets.only(right: 10.0),
        ),
        new Text(
          "Female",
          style: new TextStyle(color: Colors.white),
        ),
        new Checkbox(
          value: _isFemale,
          activeColor: Colors.blue,
          onChanged: (v) {
            if (v)
              setState(() {
                _isMale = false;
                _isFemale = true;
              });
          },
        ),
      ],
    );
  }

  _ageOption() {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        new Text(
          "I'm",
          style:
              new TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        new Padding(
          padding: const EdgeInsets.only(left: 10.0),
        ),
        new DropdownButton(
          items: _listAgeItems,
          onChanged: _ageChanged,
          isDense: true,
          value: _userAge,
        ),
        new Text(
          "old",
          style:
              new TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ],
    );
  }

  _ageChanged(int newAge) {
    print("new age $newAge");
    setState(() {
      _userAge = newAge;
    });
  }

  _submit() async {
    if (await _connection.isOnline()) {
      if (_formkey.currentState.validate()) {
        setState(() {
          _submitting = true;
        });
        Map savedData = await _storage.getNumberAndUid();
        String uid = savedData['uid'];
        String phn = savedData['phone_no'];
        StalkNetwork network = new StalkNetwork();
        var result = await network.completeRegistration(
          username: _usernameController.text,
          fullname: _fullnameController.text,
          password: _passwordController.text,
          age: _userAge,
          gender: _isMale ? Gender.Male : Gender.Female,
          uid: uid,
          number: phn,
        );
        setState(() {
          _submitting = false;
        });
        if (result['status'] == STATUS.Success) {
          _storage.setRegistrationStatus(status: true);
          _storage.saveOtherDetails(
            fullname: _fullnameController.text,
            username: _usernameController.text,
            password: _passwordController.text,
            age: _userAge,
            gender: _isMale ? Gender.Male : Gender.Female,
          );
          var lr = await network.loginUser(
            username: _usernameController.text,
            password: _passwordController.text,
          );
          if (lr['status'] == STATUS.Success) {
            Navigator.of(context).pushReplacementNamed("/LoggedInScreen");
          }
        }
        if (result['status'] == STATUS.InternalNetworkError) {
          // fail
          Toast.showToast(msg: "internal network problem");
        }
        if (result['status'] == STATUS.Fail) {
          Toast.showToast(msg: "uid did not match..");
        }
        if (result['status'] == STATUS.UsernameAlreadyTaken) {
          Toast.showToast(msg: "username already taken");
        }
      }
    } else
      Toast.showToast(msg: "Network not available !!");
  }
}
