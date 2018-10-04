import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'custom_widget.dart';

enum Position { LEFT, RIGHT }

class ChatMessage extends StatelessWidget {
  final String message;
  final Position position;
  final int type;
  ChatMessage(
      {@required this.message, @required this.position, @required this.type});
  final _rightMargin = EdgeInsets.only(
    top: 5.0,
    right: 20.0,
  );
  final _leftMargin = EdgeInsets.only(
    top: 5.0,
    left: 20.0,
  );

  final _leftMessageBorder = BorderRadius.only(
    topRight: Radius.circular(15.0),
    bottomLeft: Radius.circular(15.0),
    bottomRight: Radius.circular(15.0),
  );
  final _rightMessageBorder = BorderRadius.only(
    topLeft: Radius.circular(15.0),
    topRight: Radius.circular(15.0),
    bottomLeft: Radius.circular(15.0),
  );

  @override
  Widget build(BuildContext context) {
    return new Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: (position == Position.LEFT)
          ? MainAxisAlignment.start
          : MainAxisAlignment.end,
      children: <Widget>[
        new Flexible(
          child: new Container(
            margin: (position == Position.LEFT) ? _rightMargin : _leftMargin,
            padding: const EdgeInsets.all(10.0),
            decoration: new BoxDecoration(
              borderRadius: (position == Position.LEFT)
                  ? _leftMessageBorder
                  : _rightMessageBorder,
              border: (position == Position.LEFT)
                  ? (type == 0) ? new Border.all(color: Colors.grey) : null
                  : null,
              color: (position == Position.LEFT)
                  ? null
                  : (type == 0)
                      ? new Color(CustomWidget.hexToInt("ff0A79DF"))
                      : null,
            ),
            child: (type == 0) ? _createText() : _createImage(),
          ),
        ),
      ],
    );
  }

  _createText() {
    return new Text(
      this.message,
      softWrap: true,
      overflow: TextOverflow.clip,
      style: new TextStyle(
          fontWeight: FontWeight.w500,
          color: (position == Position.LEFT) ? null : Colors.white),
    );
  }

  _createImage() {
    return new Container(
      child: new Material(
        child: new CachedNetworkImage(
          placeholder: new Container(
            child: new CircularProgressIndicator(),
            width: 200.0,
            height: 200.0,
            padding: const EdgeInsets.all(70.0),
            decoration: new BoxDecoration(
              color: Colors.grey,
              borderRadius: new BorderRadius.all(Radius.circular(8.0)),
            ),
          ),
          errorWidget: new Container(
            child: new Text("error"),
          ),
          imageUrl: this.message,
          width: 200.0,
          height: 200.0,
          fit: BoxFit.cover,
        ),
        borderRadius: new BorderRadius.all(Radius.circular(8.0)),
      ),
    );
  }
}
