import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CustomWidget {
  static final ThemeData theme = new ThemeData(
    accentColor: new Color(hexToInt("ff30336B")),
    buttonColor: new Color(hexToInt("ff019031")),
    primaryColor: new Color(hexToInt("ff0A3D62")),
    errorColor: new Color(hexToInt("ffE71C23")),
    cursorColor: new Color(hexToInt("ff0A3D62")),
    scaffoldBackgroundColor: Colors.white,
  );

  static createButton(String txt, var callback) {
    return new Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: new Material(
        borderRadius: new BorderRadius.circular(10.0),
        shadowColor: Colors.blue,
        elevation: 5.0,
        child: new MaterialButton(
          minWidth: 202.0,
          height: 48.0,
          onPressed: callback,
          color: Colors.blueAccent,
          child: new Text(
            txt,
            style: new TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  static sTalkLogo() {
    return Center(
      child: new Image(
        width: 200.0,
        semanticLabel: "STalk",
        image: new AssetImage('images/logo.png'),
      ),
    );
  }

  static decorateWithBgImage(String img) {
    return new BoxDecoration(
      image: new DecorationImage(
        image: new AssetImage(img),
        fit: BoxFit.cover,
      ),
    );
  }

  static flatBtn(String txt, {Color color, var callback}) {
    return new FlatButton(
      child: new Text(
        txt,
        style: new TextStyle(color: color),
      ),
      onPressed: callback,
    );
  }

  static int hexToInt(String hex) {
    int val = 0;
    int len = hex.length;
    for (int i = 0; i < len; i++) {
      int hexDigit = hex.codeUnitAt(i);
      if (hexDigit >= 48 && hexDigit <= 57) {
        val += (hexDigit - 48) * (1 << (4 * (len - 1 - i)));
      } else if (hexDigit >= 65 && hexDigit <= 70) {
        // A..F
        val += (hexDigit - 55) * (1 << (4 * (len - 1 - i)));
      } else if (hexDigit >= 97 && hexDigit <= 102) {
        // a..f
        val += (hexDigit - 87) * (1 << (4 * (len - 1 - i)));
      } else {
        throw new FormatException("Invalid hexadecimal value");
      }
    }
    return val;
  }

  static loginButton({var callback}) {
    return new Container(
      margin: const EdgeInsets.only(right: 75.0, left: 75.0),
      child: new RaisedButton(
        textColor: Colors.white,
        padding: const EdgeInsets.only(
          top: 13.0,
          bottom: 13.0,
        ),
        child: new Text(
          "Sign In With Google",
          style: new TextStyle(fontSize: 18.0),
        ),
        color: new Color(hexToInt("ffAE1438")),
        onPressed: callback,
      ),
    );
  }

  static Widget imageWidget(String imgUrl) {
    return new Material(
      child: new CachedNetworkImage(
        placeholder: new Container(
          child: new CircularProgressIndicator(
            strokeWidth: 1.0,
          ),
          width: 50.0,
          height: 50.0,
          padding: const EdgeInsets.all(15.0),
        ),
        imageUrl: imgUrl,
        width: 50.0,
        height: 50.0,
        fit: BoxFit.cover,
      ),
      borderRadius: BorderRadius.all(Radius.circular(25.0)),
    );
  }

  static showSnackbarMessage({BuildContext context,String msg}) async {
    var snb = new SnackBar(
      content: new Text(msg),
    );
    Scaffold.of(context).showSnackBar(snb);
  }

}
