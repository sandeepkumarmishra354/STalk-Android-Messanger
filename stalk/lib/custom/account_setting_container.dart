import 'package:flutter/material.dart';

class AccountSettingContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) => new AccountSettingContainerState();
}

class AccountSettingContainerState extends StatefulWidget {
  @override
  _AccountSettingContainerState createState() => new _AccountSettingContainerState();
}

class _AccountSettingContainerState extends State<AccountSettingContainerState> {
  @override
  Widget build(BuildContext context) {
    return new Container(
      child: new Center(
        child: new Text("Account Setting"),
      ),
    );
  }
}