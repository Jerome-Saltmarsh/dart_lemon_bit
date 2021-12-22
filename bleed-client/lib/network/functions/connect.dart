import 'package:bleed_client/common/ClientRequest.dart';
import 'package:bleed_client/network/state/connectionUri.dart';
import 'package:bleed_client/network/state/webSocketChannel.dart';
import 'package:bleed_client/network/streams/eventStream.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:lemon_watch/watch.dart';

enum Connection {
  None,
  Connecting,
  Connected,
  Done,
  Error,
  Failed_To_Connect
}

// state
final Watch<Connection> connection = Watch(Connection.None);
bool get connected => connection.value == Connection.Connected;
bool get connecting => connection.value == Connection.Connecting;


// interface
void connect(String uri) {
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
  print('disconnect()');
  if (!connected) return;
  connection.value = Connection.Done;
  if (webSocketChannel == null) return;
  webSocketChannel.sink.close();
}

void dispose(){
  eventStream.close();
}

void send(String message) {
  if (!connected) return;
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
  connectionUri = "";
  if (connecting) {
    connection.value = Connection.Failed_To_Connect;
  } else {
    connection.value = Connection.Error;
  }
}

void _onDone() {
  connectionUri = "";
  connection.value = Connection.Done;
}