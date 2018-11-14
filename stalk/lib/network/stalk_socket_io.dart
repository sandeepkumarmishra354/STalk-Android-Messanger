import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';
import 'dart:convert';

class STalkSocketIo {
  final String _defaultUrl = "http://192.168.225.103";
  final String _defaultNamespace = '/';
  SocketIO _socket;
  bool isInitiated = false;
  bool isConnected = false;

  String get id {
    if (_socket != null)
      return _socket.getId();
    else {
      return null;
    }
  }

  STalkSocketIo.createSocket({
    String url: "http://192.168.225.103",
    String namespace: '/',
    String query,
    void statusCallback(String),
  }) {
    _socket = new SocketIOManager().createSocketIO(
      url,
      namespace,
      query: query,
      socketStatusCallback: (data) async {
        if (data == 'connect')
          this.isConnected = true;
        else
          this.isConnected = false;
        (statusCallback != null) ? statusCallback(data) : print(data);
      },
    );

    if (_socket != null) {
      _socket.init();
      isInitiated = true;
    }
  }

  STalkSocketIo() {
    _socket = new SocketIOManager().createSocketIO(
      _defaultUrl,
      _defaultNamespace,
      socketStatusCallback: (data) async {
        if (data == 'connect')
          this.isConnected = true;
        else
          this.isConnected = false;
        print(data);
      },
    );
    if (_socket != null) {
      _socket.init();
      isInitiated = true;
    }
  }

  connect() async {
    if (_socket != null && isInitiated) {
      await _socket.connect();
    } else
      throw new Exception(
          "ERROR:: Socket not created or initialised but connect called");
  }

  disconnect() {
    if (_socket != null) {
      _socket.disconnect();
      isConnected = false;
    }
  }

  listen(String event, void callback(dynamic)) async {
    if (_socket != null) {
      await _socket.subscribe(event, (String data) async {
        if (data != null && data.isNotEmpty) {
          final jsonData = json.decode(data);
          callback(jsonData);
        } else
          callback(null);
      });
    } else
      throw new Exception(
          "ERROR:: Socket not created or initialised but listen called");
  }

  removeListener(String event, {Function callback}) async {
    await _socket.unSubscribe(event, callback);
  }

  emit(String event, String message, {Function callback}) {
    if (_socket != null) {
      _socket.sendMessage(event, message, callback);
    } else
      throw new Exception(
          "ERROR:: Socket not created or initialised but emit called");
  }

  distroyStalkSocket() {
    if (_socket != null) {
      SocketIOManager().destroySocket(_socket);
      _socket = null;
      isInitiated = false;
      isConnected = false;
    }
  }
}
