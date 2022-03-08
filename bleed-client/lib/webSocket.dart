import 'package:bleed_client/bytestream_parser.dart';
import 'package:bleed_client/parse.dart';
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

final webSocket = _WebSocket();

class _WebSocket {
  late WebSocketChannel webSocketChannel;
  final Watch<Connection> connection = Watch(Connection.None);
  bool get connected => connection.value == Connection.Connected;
  bool get connecting => connection.value == Connection.Connecting;
  String connectionUri = "";
  late WebSocketSink sink;

  // interface
  void connect({required String uri, required dynamic message}) {
    print("webSocket.connect($uri)");
    connection.value = Connection.Connecting;
    webSocketChannel = WebSocketChannel.connect(Uri.parse(uri));
    webSocketChannel.stream.listen(_onEvent, onError: _onError, onDone: _onDone);
    sink = webSocketChannel.sink;
    connectionUri = uri;
    sinkMessage(message);
  }

  void disconnect() {
    print('network.disconnect()');
    sink.close();
    connection.value = Connection.None;
  }

  void send(String message) {
    if (!connected) {
      print("warning cannot send because not connected");
      return;
    }
    sinkMessage(message);
  }

  void sinkMessage(String message) {
    sink.add(message);
  }

  void _onEvent(dynamic _response) {
    if (connecting) {
      connection.value = Connection.Connected;
    }
    if (_response is String){
      event = _response;
      parseState();
      return;
    }

    if (_response is List<int>){
       byteStreamParser.parse(_response);
    }
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
    sink.close();
  }
}

