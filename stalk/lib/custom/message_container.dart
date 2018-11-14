import 'package:flutter/material.dart';
import '../custom/chat_message.dart';
import '../event-handler/event.dart';
import '../utils/enums.dart';

class MessageContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) => new MessageContainerState();
}

class MessageContainerState extends StatefulWidget {
  @override
  _MessageContainerState createState() => new _MessageContainerState();
}

class _MessageContainerState extends State<MessageContainerState>
    with
        SingleTickerProviderStateMixin,
        AutomaticKeepAliveClientMixin<MessageContainerState> {
  List<ChatMessage> _messageList = new List<ChatMessage>();
  final ScrollController _scrollController = new ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    Event.instance.registerForNewMessage(_addMsgList);
  }

  @override
  void dispose() {
    super.dispose();
    _messageList.forEach((ChatMessage cm) {
      cm.animationController.dispose();
    });
  }

  _addMsgList(NewMessageEvent nm) async {
    ChatMessage cm = new ChatMessage(
      message: nm.messageData.content,
      position: Position.LEFT,
      type: nm.messageData.type,
      animationController: new AnimationController(
        vsync: this,
        duration: new Duration(
          milliseconds: 400,
        ),
      ),
    );
    setState(() {
      _messageList.add(cm);
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[
        new Expanded(
          child: new Container(
            child: new ListView.builder(
              //reverse: true,
              //shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              controller: _scrollController,
              padding: new EdgeInsets.all(8.0),
              itemCount: _messageList.length,
              itemBuilder: (context, i) {
                return _messageList[i];
              },
            ),
          ),
        )
      ],
    );
    ;
  }
}
