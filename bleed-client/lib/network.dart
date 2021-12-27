import 'dart:async';

import 'package:lemon_watch/watch.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

enum Connection {
  None,
  Connecting,
  Connected,
  Done,
  Error,
  Failed_To_Connect
}

final _WebSocket webSocket = _WebSocket();

class _WebSocket {
  late WebSocketChannel webSocketChannel;
  String connectionUri = "";
  final Watch<Connection> connection = Watch(Connection.None);
  final StreamController eventStream = StreamController.broadcast();
  bool get connected => connection.value == Connection.Connected;
  bool get connecting => connection.value == Connection.Connecting;

  // interface
  void connect({required String uri, required dynamic message}) {
    print("webSocket.connect($uri)");
    connection.value = Connection.Connecting;
    webSocketChannel = WebSocketChannel.connect(Uri.parse(uri));
    webSocketChannel.stream.listen(_onEvent, onError: _onError, onDone: _onDone);
    connectionUri = uri;
    sinkMessage(message);
  }

  void disconnect() {
    print('network.disconnect()');
    webSocketChannel.sink.close();
  }

  void dispose(){
    print("network.dispose()");
    webSocketChannel.sink.close();
  }

  void send(String message) {
    if (!connected) {
      print("warning cannot send because not connected");
      return;
    }
    sinkMessage(message);
  }

  void sinkMessage(String message) {
    webSocketChannel.sink.add(message);
  }

  void _onEvent(dynamic _response) {
    if (connecting) {
      connection.value = Connection.Connected;
    }
    eventStream.add(_response);
  }

  void _onError(dynamic value) {
    print("network.onError()");
  }

  void _onDone() {
    print("network.onDone()");
    connectionUri = "";
    if (connecting) {
      connection.value = Connection.Failed_To_Connect;
    } else {
      connection.value = Connection.Done;
    }
    dispose();
  }
}

