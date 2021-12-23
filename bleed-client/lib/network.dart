import 'dart:async';

import 'package:bleed_client/common/ClientRequest.dart';
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

// state
late WebSocketChannel webSocketChannel;
String connectionUri = "";
final Watch<Connection> connection = Watch(Connection.None);
final StreamController eventStream = StreamController.broadcast();
bool get connected => connection.value == Connection.Connected;
bool get connecting => connection.value == Connection.Connecting;

// interface
void connectWebSocket(String uri) {
  connection.value = Connection.Connecting;
  webSocketChannel = WebSocketChannel.connect(Uri.parse(uri));
  webSocketChannel.stream.listen(_onEvent, onError: _onError, onDone: _onDone);
  connectionUri = uri;
  ping();
}

void ping(){
  sinkMessage(ClientRequest.Ping.index.toString());
}

void disconnect() {
  print('network.disconnect()');
  // if (!connected) return;
  // connection.value = Connection.Done;
  if (webSocketChannel == null) return;
  webSocketChannel.sink.close();
}

void dispose(){
  print("network.dispose()");
  // eventStream.close();
  // eventStream.onResume();
  if (webSocketChannel == null) return;
  webSocketChannel.sink.close();
}

void send(String message) {
  if (!connected) {
    print("warning cannot send because not connected");
  }
  sinkMessage(message);
}

void sinkMessage(String message) {
  webSocketChannel.sink.add(message);
}

void _onEvent(dynamic _response) {
  if (connecting) {
    _onConnected();
  }
  eventStream.add(_response);
}

void _onConnected(){
  print("network.onConnected()");
  connection.value = Connection.Connected;
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