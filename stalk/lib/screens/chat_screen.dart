import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../custom/chat_message.dart';
import '../custom/custom_widget.dart';
import '../utils/auth_service.dart';

class ChatScreen extends StatelessWidget {
  final String friendName;
  final String friendUid;
  final String mainUid;
  final String photoUrl;
  final String mainUser;
  ChatScreen({
    this.friendName,
    this.friendUid,
    this.mainUid,
    this.photoUrl,
    this.mainUser,
  });
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Row(
          children: <Widget>[
            new Padding(
              padding: const EdgeInsets.only(top: 3.0, bottom: 3.0),
              child: CustomWidget.imageWidget(this.photoUrl),
            ),
            new Padding(
              padding: const EdgeInsets.only(left: 10.0),
            ),
            new Text(this.friendName),
          ],
        ),
      ),
      body: new ChatScreenState(
        friendUid: friendUid,
        friendName: friendName,
        mainUid: mainUid,
        mainUser: mainUser,
      ),
    );
  }
}

class ChatScreenState extends StatefulWidget {
  final String friendUid, mainUid, friendName, mainUser;
  ChatScreenState(
      {this.friendUid, this.mainUid, this.friendName, this.mainUser});
  @override
  _ChatScreenState createState() => new _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreenState>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = new TextEditingController();
  bool _isContainText = false;
  String _chatID;
  File _imageFile;
  var doc;

  @override
  void initState() {
    super.initState();
    _initChatId();
  }

  _initChatId() {
    if (widget.mainUid.hashCode <= widget.friendUid.hashCode)
      _chatID = "${widget.mainUid}-${widget.friendUid}";
    else
      _chatID = "${widget.friendUid}-${widget.mainUid}";
  }

  _showImageOption() async {
    showDialog(
      context: context,
      child: new SimpleDialog(
        children: <Widget>[
          CustomWidget.flatBtn("Open Camera",callback:(){_pickImage(ImageSource.camera);}),
          new Divider(),
          CustomWidget.flatBtn("Open Gallery",callback:(){_pickImage(ImageSource.gallery);}),
        ],
      ),
    );
  }

  _pickImage(ImageSource source) async {
    Navigator.pop(context);
    _imageFile = await ImagePicker.pickImage(source: source);
    if(_imageFile != null) {
      AuthService.sendMessage(
        from: widget.mainUser,
        to: widget.friendName,
        chatId: _chatID,
        img: _imageFile,
        type: 1,
      );
    }
  }

  _sendMessage() {
    String msg = _trimMessage(_messageController.text);
    if (msg.isNotEmpty) {
      _messageController.clear();
      setState(() {
        _isContainText = false;
      });
      AuthService.sendMessage(
        from: widget.mainUser,
        to: widget.friendName,
        content: msg,
        chatId: _chatID,
        type: 0,
      );
    }
  }

  _checkMessage(String val) {
    setState(() {
      val = _trimMessage(val);
      _isContainText = val.isNotEmpty;
    });
  }

  String _trimMessage(String val) {
    String tmp;
    do {
      tmp = val;
      val = val.trim();
    } while (tmp != val);

    return val;
  }

  _messageComposer() {
    return new Card(
      elevation: 6.0,
      child: new Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: new Row(
          children: <Widget>[
            new Container(
              margin: new EdgeInsets.symmetric(horizontal: 4.0),
              child: new IconButton(
                icon: new Icon(
                  Icons.photo_camera,
                  color: Theme.of(context).accentColor,
                ),
                onPressed: _showImageOption,
              ),
            ),
            new Flexible(
              child: new TextField(
                controller: _messageController,
                decoration:
                    new InputDecoration.collapsed(hintText: "Send a message"),
                onChanged: _checkMessage,
              ),
            ),
            new Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: new IconButton(
                color: Theme.of(context).accentColor,
                icon: new Icon(Icons.send),
                onPressed: _isContainText ? _sendMessage : null,
              ),
            )
          ],
        ),
      ),
    );
  }

  _messageList() {
    return new StreamBuilder(
      stream: Firestore.instance
          .collection('messages')
          .document(_chatID)
          .collection(_chatID)
          .orderBy('timestamp', descending: true)
          .limit(20)
          .snapshots(),
      builder: (context, ss) {
        if (!ss.hasData) {
          return new Center(
            child: new CircularProgressIndicator(),
          );
        } else {
          doc = ss.data.documents;
          return new Flexible(
            child: new ListView.builder(
              padding: new EdgeInsets.all(8.0), //new
              reverse: true,
              itemCount: ss.data.documents.length,
              itemBuilder: (context, i) => new ChatMessage(
                    message: doc[i]['content'],
                    type: doc[i]['type'],
                    position: (doc[i]['from'] == widget.mainUser)
                        ? Position.RIGHT
                        : Position.LEFT,
                  ),
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: new Column(
        children: <Widget>[
          _messageList(),
          new Divider(),
          _messageComposer(),
          new Padding(
            padding: const EdgeInsets.only(top: 2.0),
          )
        ],
      ),
    );
  }
}
