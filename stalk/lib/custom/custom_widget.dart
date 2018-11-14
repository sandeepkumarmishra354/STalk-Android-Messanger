import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/enums.dart';
import '../data/constants.dart' as Constants;

class CustomWidget {
  static final ThemeData theme = new ThemeData(
    accentColor: new Color(hexToInt("ff30336B")),
    buttonColor: new Color(hexToInt("ff019031")),
    primaryColor: new Color(hexToInt("ff0A3D62")),
    errorColor: new Color(hexToInt("ffE71C23")),
    cursorColor: new Color(hexToInt("ff0A3D62")),
    scaffoldBackgroundColor: Colors.white,
    indicatorColor: Colors.white,
    pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.android: OpenUpwardsPageTransitionsBuilder(),
        }),
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

  static sTalkLogo({double width: 200.0, double height}) {
    return Center(
      child: new Image(
        width: width,
        height: height,
        semanticLabel: "STalk",
        image: new AssetImage(Constants.logoImage),
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
      disabledTextColor: Colors.grey,
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

  static loginButton({var callback, String txt}) {
    return new Container(
      margin: const EdgeInsets.only(right: 75.0, left: 75.0),
      child: new RaisedButton(
        textColor: Colors.white,
        padding: const EdgeInsets.only(
          top: 13.0,
          bottom: 13.0,
        ),
        child: new Text(
          txt,
          style: new TextStyle(fontSize: 18.0),
        ),
        color: Colors.blueAccent,
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

  static Widget imageWidgetAsync(String phoneNo, {var onTap}) {
    return new Material(
      child: new StreamBuilder(
          stream: Firestore.instance
              .collection('users')
              .document(phoneNo)
              .snapshots(),
          builder: (context, ss) {
            if (ss.hasData) {
              return new Material(
                shape: CircleBorder(),
                color: Colors.transparent,
                child: new Ink.image(
                  fit: BoxFit.cover,
                  width: 45.0,
                  height: 45.0,
                  image: CachedNetworkImageProvider(ss.data['photoUrl']),
                  child: new InkWell(
                    onTap: onTap,
                    child: null,
                  ),
                ),
              );
            } else
              return new CircularProgressIndicator();
          }),
      borderRadius: BorderRadius.all(Radius.circular(25.0)),
    );
  }

  static createBluredBackground(String imgUrl, {int mode: 0}) {
    return new Container(
      decoration: new BoxDecoration(
        image: new DecorationImage(
          image: (mode == 0)
              ? new AssetImage(imgUrl)
              : new CachedNetworkImageProvider(imgUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: new BackdropFilter(
        filter: new ui.ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
        child: new Container(
          decoration: new BoxDecoration(
            color: Colors.black.withOpacity(0.5),
          ),
        ),
      ),
    );
  }

  static loading({Color color}) {
    return new FlatButton(
      child: new CircularProgressIndicator(
        valueColor: new AlwaysStoppedAnimation<Color>(color),
      ),
      onPressed: null,
    );
  }

  static createInputField(
    String labelText, {
    TextEditingController controller,
    TextInputType keyboardType,
    bool secureText: false,
    void onComplete(),
    void onSubmitted(String s),
    void onSaved(String s),
    void onChanged(String s),
    String validator(String s),
    InputType type: InputType.NORMAL,
  }) {
    Widget inputField = (type == InputType.FORM)
        ? new TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: secureText,
            validator: validator,
            decoration: new InputDecoration(
              hintText: labelText,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(12.0),
            ),
            onEditingComplete: onComplete,
            onFieldSubmitted: onSubmitted,
            onSaved: onSaved,
          )
        : new TextField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: secureText,
            decoration: new InputDecoration(
              hintText: labelText,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(12.0),
            ),
            onEditingComplete: onComplete,
            onSubmitted: onSubmitted,
            onChanged: onChanged,
          );

    return new Container(
      child: inputField,
      decoration: new BoxDecoration(
        color: new Color(hexToInt("80FFFFFF")),
        borderRadius: BorderRadius.circular(12.0),
      ),
    );
  }
}
