import 'package:flutter/material.dart';

class ProfileContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) => new ProfileContainerState();
}

class ProfileContainerState extends StatefulWidget {
  @override
  _ProfileContainerState createState() => new _ProfileContainerState();
}

class _ProfileContainerState extends State<ProfileContainerState> {
  @override
  Widget build(BuildContext context) {
    return new Container(
      child: new Center(
        child: new Text("Profile"),
      ),
    );
  }
}