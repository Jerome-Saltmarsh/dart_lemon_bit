import 'dart:async';

import 'package:bleed_client/parse.dart';
import 'package:lemon_engine/engine.dart';
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
  final Watch<Connection> connection = Watch(Connection.None);
  final StreamController eventStream = StreamController.broadcast();
  bool get connected => connection.value == Connection.Connected;
  bool get connecting => connection.value == Connection.Connecting;
  String connectionUri = "";

  String event = "";

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
    connection.value = Connection.None;
  }

  void dispose(){
    print("network.dispose()");
    webSocketChannel.sink.close();
    eventStream.close();
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
    compiledGame = _response;
    parseState();
    engine.actions.redrawCanvas();
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

