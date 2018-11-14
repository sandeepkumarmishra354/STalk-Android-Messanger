import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'custom_widget.dart';
import 'image-viewer.dart';
import '../utils/enums.dart';

class ChatMessage extends StatelessWidget {
  final String message;
  final Position position;
  final AnimationController animationController;
  final MessageType type;
  ChatMessage({
    @required this.message,
    @required this.position,
    @required this.animationController,
    this.type: MessageType.TEXT,
  });
  @override
  Widget build(BuildContext context) {
    return new ChatMessageState(
      message: this.message,
      position: this.position,
      type: this.type,
      animationController: this.animationController,
    );
  }
}

class ChatMessageState extends StatefulWidget {
  final String message;
  final Position position;
  final AnimationController animationController;
  final MessageType type;
  ChatMessageState(
      {@required this.message,
      @required this.position,
      @required this.type,
      @required this.animationController});

  @override
  _ChatMessageState createState() => new _ChatMessageState();
}

class _ChatMessageState extends State<ChatMessageState> {
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
  initState() {
    super.initState();
    widget.animationController.forward();
  }

  @override
  dispose() {
    super.dispose();
    //widget.animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new SizeTransition(
      sizeFactor: new CurvedAnimation(
          parent: widget.animationController, curve: Curves.easeOut),
      axisAlignment: 0.0,
      child: new Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: (widget.position == Position.LEFT)
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        children: <Widget>[
          new Flexible(
            child: new Container(
              margin: (widget.position == Position.LEFT)
                  ? _rightMargin
                  : _leftMargin,
              //padding: const EdgeInsets.all(10.0),
              child: (widget.type == MessageType.IMAGE)
                  ? _createImage(context)
                  : _createText(),
            ),
          ),
        ],
      ),
    );
  }

  _createText() {
    print(widget.message);
    return new Card(
      color: (widget.position == Position.LEFT)
          ? Colors.teal
          : (widget.type == MessageType.TEXT)
              ? Color(CustomWidget.hexToInt("ff0A3D62"))
              : null,
      shape: RoundedRectangleBorder(
        borderRadius: (widget.position == Position.LEFT)
            ? _leftMessageBorder
            : _rightMessageBorder,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: new Text(
          widget.message,
          softWrap: true,
          overflow: TextOverflow.clip,
          style:
              new TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
        ),
      ),
    );
  }

  _createImage(BuildContext context) {
    return new GestureDetector(
      child: new Card(
        elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: (widget.position == Position.LEFT)
            ? _leftMessageBorder
            : _rightMessageBorder,
      ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
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
              imageUrl: widget.message,
              width: 200.0,
              height: 200.0,
              fit: BoxFit.cover,
            ),
            borderRadius: new BorderRadius.all(Radius.circular(8.0)),
          ),
        ),
      ),
      onTap: () {
        Navigator.of(context).push(new MaterialPageRoute(
          builder: (context) => new PhotoViewer(
                imgUrl: widget.message,
              ),
        ));
      },
    );
  }
}
