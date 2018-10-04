import 'package:flutter/material.dart';
import '../custom/custom_widget.dart';
import '../screens/chat_screen.dart';
import '../utils/storage.dart';
import '../utils/auth_service.dart';
import '../utils/connection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// LoggedInScreen Class
class LoggedInScreen extends StatelessWidget {
  final user;
  LoggedInScreen(this.user);
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: new MainLoggedInScreen(user),
    );
  }
}

// MainLoggedInScreen Class
class MainLoggedInScreen extends StatefulWidget {
  final user;
  MainLoggedInScreen(this.user);
  @override
  _MainLoggedInScreenState createState() => new _MainLoggedInScreenState();
}

// _MainLoggedInScreenState Class
class _MainLoggedInScreenState extends State<MainLoggedInScreen> {
  final Storage _storage = new Storage();
  final AuthService _authService = new AuthService();
  final Connection _connection = new Connection();
  bool _isDetailPressed = false;
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    _storage.init();
    _connection.init();
  }

  List<Widget> _drawerOption1() {
    return <Widget>[
      new ListTile(
        title: new Text("Settings"),
        onTap: () {},
      ),
      new Divider(
        color: Colors.pink,
      ),
      CustomWidget.flatBtn("logout", color: Colors.blue, callback: () async {
        await _connection.refresh();
        if (_connection.isNetworkAvailable()) {
          setState(() {
            _isLoggingOut = true;
          });
          await _storage.logOutUser();
          await _authService.signOutWithGoogle();
          setState(() {
            _isLoggingOut = false;
          });
          Navigator.of(context).pushReplacementNamed("/Home");
        } else {
          CustomWidget.showSnackbarMessage(
            context: context,
            msg: "Network not available",
          );
        }
      }),
    ];
  }

  List<Widget> _drawerOption2() {
    return <Widget>[
      new ListTile(
        title: new Text("Profile"),
        onTap: () {},
      ),
      new Divider(
        color: Colors.pink,
      ),
      CustomWidget.flatBtn("help", color: Colors.blue, callback: () {}),
    ];
  }

  _loggingOutIndicator() {
    return new Center(
      child: new CircularProgressIndicator(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        drawer: _isLoggingOut ? null : _sideDrawer(),
        appBar: new AppBar(
          centerTitle: true,
          title: new Text(widget.user.displayName),
        ),
        body: _isLoggingOut ? _loggingOutIndicator() : _createChatList());
  }

  _sideDrawer() {
    return new Drawer(
      child: new Column(
        children: <Widget>[
          new UserAccountsDrawerHeader(
            accountName: new Text(widget.user.displayName),
            accountEmail: new Text(widget.user.email),
            onDetailsPressed: () {
              setState(() {
                _isDetailPressed = !_isDetailPressed;
              });
            },
            currentAccountPicture:
                CustomWidget.imageWidget(widget.user.photoUrl),
          ),
          new Expanded(
            child: _drawerList(),
          ),
        ],
      ),
    );
    //);
  }

  _drawerList() {
    return new Container(
      child: new ListView(
        children: _isDetailPressed ? _drawerOption2() : _drawerOption1(),
      ),
    );
  }

  _createChatList() {
    return new Container(
      child: new StreamBuilder(
        stream: Firestore.instance.collection("users").snapshots(),
        builder: (context, ss) {
          if (!ss.hasData) {
            return new Center(
              child: new CircularProgressIndicator(),
            );
          } else {
            return new ListView.builder(
              padding: const EdgeInsets.only(top: 10.0),
              itemCount: ss.data.documents.length,
              itemBuilder: (context, i) => _buildUserList(
                  context, ss.data.documents[i], ss.data.documents.length),
            );
          }
        },
      ),
    );
  }

  Widget _buildUserList(
      BuildContext context, DocumentSnapshot document, int len) {
    if (document['uid'] == widget.user.uid) {
      if (len == 1)
        return new Center(
            child: new Text("No User Available !!"),
          );
      else
        return new Container();
    } else {
      return new Card(
        child: new ListTile(
          contentPadding: const EdgeInsets.all(8.0),
          title: new Text(document['displayName']),
          leading: CustomWidget.imageWidget(document['photoUrl']),
          onTap: () {
            Navigator.of(context).push(new MaterialPageRoute(
                builder: (BuildContext context) => new ChatScreen(
                      friendName: document['displayName'],
                      friendUid: document['uid'],
                      mainUid: widget.user.uid,
                      photoUrl: document['photoUrl'],
                      mainUser: widget.user.displayName,
                    )));
          },
        ),
      );
    }
  }
}
