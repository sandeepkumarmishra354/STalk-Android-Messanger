import 'package:flutter/material.dart';
import 'package:badge/badge.dart';
import '../custom/custom_widget.dart';
import '../custom/post_container.dart';
import '../custom/message_container.dart';
import '../custom/peoples_container.dart';
import '../custom/profile_container.dart';
import '../custom/account_setting_container.dart';

// LoggedInScreen Class
class LoggedInScreen extends StatelessWidget {
  LoggedInScreen();
  @override
  Widget build(BuildContext context) {
    return new DefaultTabController(
      length: 5,
      child: new MainLoggedInScreen(),
    );
  }
}

// MainLoggedInScreen Class
class MainLoggedInScreen extends StatefulWidget {
  MainLoggedInScreen();
  @override
  _MainLoggedInScreenState createState() => new _MainLoggedInScreenState();
}

// _MainLoggedInScreenState Class
class _MainLoggedInScreenState extends State<MainLoggedInScreen>
    with
        TickerProviderStateMixin,
        AutomaticKeepAliveClientMixin<MainLoggedInScreen> {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  int _publicCount = 0;
  int _messageCount = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("STalk"),
      ),
      key: _scaffoldKey,
      body: new TabBarView(
        children: <Widget>[
          new PostContainer(),
          new MessageContainer(),
          new PeoplesContainer(),
          new ProfileContainer(),
          new AccountSettingContainer(),
        ],
      ),
      bottomNavigationBar: new TabBar(
        isScrollable: true,
        indicator: new BoxDecoration(
          color: Color(CustomWidget.hexToInt("ff0A3D62")),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.blueGrey,
        tabs: <Widget>[
          new Tab(
            icon: (_publicCount == 0)
                ? new Icon(Icons.public)
                : new Badge.after(
                    value: _publicCount.toString(),
                    borderColor: Colors.red,
                    child: new Icon(Icons.public),
                  ),
            text: "Post",
          ),
          new Tab(
            icon: (_messageCount == 0)
                ? new Icon(Icons.message)
                : new Badge.after(
                    value: _messageCount.toString(),
                    borderColor: Colors.red,
                    child: new Icon(
                      Icons.message,
                    )),
            text: "Message",
          ),
          new Tab(icon: new Icon(Icons.people_outline), text: "Peoples"),
          new Tab(icon: new Icon(Icons.person_outline), text: "Profile"),
          new Tab(icon: new Icon(Icons.settings), text: "Setting"),
        ],
      ),
    );
  }
}
