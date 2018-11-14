import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:test_flutter/utils/toast.dart';
import 'package:url_launcher/url_launcher.dart';
import '../custom/custom_widget.dart';
import '../data/constants.dart' as Constants;

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("About"),
      ),
      body: new AboutPageState(),
    );
  }
}

class AboutPageState extends StatefulWidget {
  @override
  _AboutPageState createState() => new _AboutPageState();
}

class _AboutPageState extends State<AboutPageState> {
  String _appVersion = "";

  @override
  initState() {
    super.initState();
    PackageInfo.fromPlatform().then((PackageInfo pi) {
      setState(() {
        _appVersion = pi.version;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Stack(
      children: <Widget>[
        CustomWidget.createBluredBackground(Constants.penImage),
        Center(
          child: new Container(
            child: new ListView(
              physics: const BouncingScrollPhysics(),
              children: <Widget>[
                new Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                ),
                CustomWidget.sTalkLogo(),
                Center(
                  child: new Text(
                    _appVersion,
                    style: new TextStyle(color: Colors.white),
                  ),
                ),
                new Divider(),
                new Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                ),
                new Container(
                  padding: const EdgeInsets.all(10.0),
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new Text(
                        Constants.aboutStalk,
                        style: new TextStyle(
                          color: Colors.grey,
                          fontSize: 17.0,
                        ),
                      ),
                      new Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                      ),
                      new Center(
                        child: CustomWidget.flatBtn(
                          "visit flutter's official website",
                          color: Colors.blue,
                          callback: () {_launchUrl(Constants.flutterLink);},
                        ),
                      ),
                      new Divider(
                        color: Colors.grey,
                        height: 5.0,
                      ),
                      new Center(
                        child: CustomWidget.flatBtn(
                          "visit dart's official website",
                          color: Colors.blue,
                          callback: () {_launchUrl(Constants.dartLink);},
                        ),
                      ),
                      new Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                      ),
                      new Text(
                        Constants.stalkRules,
                        style: new TextStyle(
                          color: Colors.grey,
                          fontSize: 17.0,
                        ),
                      ),
                      new Center(
                        child: CustomWidget.flatBtn(
                          "view source code on github",
                          color: Colors.blue,
                          callback: () {_launchUrl(Constants.githubLink);},
                        ),
                      ),
                      new Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                      ),
                      new Text(
                        "For any query or bug report drop a mail here:-",
                        style: new TextStyle(
                          color: Colors.grey,
                          fontSize: 17.0,
                        ),
                      ),
                      new Text(
                        Constants.email,
                        style: new TextStyle(
                          color: Colors.blue,
                          fontSize: 17.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  _launchUrl(String url) async {
    if(await canLaunch(url)) {
      await launch(url);
    }
    else
      Toast.showToast(msg: "url launcher not supported on this device");
  }

}
