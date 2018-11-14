import 'package:flutter/material.dart';

class PostContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) => new PostContainerState();
}

class PostContainerState extends StatefulWidget {
  @override
  _PostContainerState createState() => new _PostContainerState();
}

class _PostContainerState extends State<PostContainerState>
    with AutomaticKeepAliveClientMixin<PostContainerState> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return new Container();
  }
}
