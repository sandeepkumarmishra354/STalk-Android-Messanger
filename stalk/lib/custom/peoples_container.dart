import 'package:flutter/material.dart';
import '../network/stalk_network.dart';
import '../utils/enums.dart';

class PeoplesContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) => new PeoplesContainerState();
}

class PeoplesContainerState extends StatefulWidget {
  @override
  _PeoplesContainerState createState() => new _PeoplesContainerState();
}

class _PeoplesContainerState extends State<PeoplesContainerState>
    with AutomaticKeepAliveClientMixin<PeoplesContainerState> {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    StalkNetwork.instance.initiateCookie();
  }

  @override
  Widget build(BuildContext context) {
    return new FutureBuilder(
      future: StalkNetwork.instance.searchUser('sa'),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.none ||
            snapshot.connectionState == ConnectionState.waiting)
          return new Center(
            child: new Text("Loading..."),
          );
        if (snapshot.hasError)
          return new Center(
            child: new Text("Error: ${snapshot.error}"),
          );
        if (snapshot.hasData) return _createList(snapshot);
      },
    );
  }

  _createList(AsyncSnapshot snapshot) {
    Map data = snapshot.data;
    if (data['status'] == STATUS.InternalNetworkError)
      return new Center(
        child: new Text("Internal network error"),
      );
    if (data['status'] == STATUS.Success) {
      List mdata = data['data'];
      List<Widget> lt = new List<Widget>();
      mdata.forEach((d) {
        ListTile tlt = new ListTile(
          leading: new CircleAvatar(
            child: new Image(
              image: new NetworkImage(d['img_url']),
            ),
          ),
          title: new Text(d['fullname']),
          subtitle: new Text('@' + d['username']),
        );
        lt.add(tlt);
        lt.add(new Divider());
      });
      return new ListView(
        children: lt,
      );
    }
  }
}
