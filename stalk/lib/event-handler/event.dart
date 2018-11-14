import 'dart:async';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/foundation.dart';
import '../utils/message_data.dart';

class Event {
  EventBus _eventBus;
  StreamSubscription _forAllStreamSubs, _newMessageStreamSubs;
  bool _registeredForAll = false;
  bool _registeredForNewMessage = false;
  EventBus get eventBus => _eventBus;
  bool get registeredForAll => _registeredForAll;
  bool get registeredForNewMessage => _registeredForNewMessage;
  static Event instance = new Event._internal();
  factory Event() => instance;
  Event._internal() {
    _eventBus = new EventBus();
  }

  registerForAll(Function callback) {
    if (!_registeredForAll) {
      _forAllStreamSubs = _eventBus.on().listen(callback);
      _registeredForAll = true;
    }
  }

  unregisterForAll() {
    if(_registeredForAll) {
      _forAllStreamSubs.cancel();
      _registeredForAll = false;
    }
  }

  registerForNewMessage(Function callback) {
    if (!_registeredForNewMessage) {
      _newMessageStreamSubs = _eventBus.on<NewMessageEvent>().listen(callback);
      _registeredForNewMessage = true;
    }
  }

  unregisterForNewMessage() {
    if(_registeredForNewMessage) {
      _newMessageStreamSubs.cancel();
      _registeredForNewMessage = false;
    }
  }

  fireNewMessageEvent(MessageData newData) async {
    if (_registeredForNewMessage) {
      _eventBus.fire(new NewMessageEvent(
        messageData: newData,
      ));
    }
    else
    print("NOT REGISTERED...");
  }
}

class NewMessageEvent {
  final MessageData messageData;
  NewMessageEvent({@required this.messageData});
}
