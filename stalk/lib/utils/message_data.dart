import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'enums.dart';

class MessageData {
  String _content;
  String _sender;
  String _receiver;
  MessageType _messageType;
  String _time;
  String _type;
  final String _imageType = "IMAGE";
  final String _textType = "TEXT";
  final String _videoType = "VIDEO";
  final String _audioType = "AUDIO";
  final String _gifType = "GIF";

  String get time => _time;
  String get messageType => _type;
  String get content => _content;
  String get sender => _sender;
  String get receiver => _receiver;
  MessageType get type => _messageType;

  MessageData({
    @required String content,
    @required String sender,
    @required String receiver,
    MessageType type: MessageType.TEXT,
  }) {
    this._content = content;
    this._sender = sender;
    this._receiver = receiver;
    this._messageType = type;
    var dt = new DateTime.now();
    int hour = dt.hour + 1;
    int minute = dt.minute;
    String am_pm = "";
    if (hour >= 12) {
      am_pm = "PM";
      hour = hour - 12;
    } else
      am_pm = "AM";

    _time = "$hour:$minute $am_pm";

    switch (this._messageType) {
      case MessageType.AUDIO:
        _type = _audioType;
        break;
      case MessageType.VIDEO:
        _type = _videoType;
        break;
      case MessageType.IMAGE:
        _type = _imageType;
        break;
      case MessageType.GIF:
        _type = _gifType;
        break;
      case MessageType.TEXT:
        _type = _textType;
        break;
    }
  }

  Map<String, String> getDataAsMap() {
    Map<String, String> data = new Map<String, String>();
    data['content'] = this._content;
    data['sender'] = this._sender;
    data['receiver'] = this._receiver;
    data['time'] = this._time;
    data['type'] = this._type;
    return data;
  }

  String getDataAsJsonString() {
    Map data = getDataAsMap();
    String jsonData = json.encode(data);
    return jsonData;
  }
}
