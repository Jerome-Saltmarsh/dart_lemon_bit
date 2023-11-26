import 'dart:typed_data';

import 'package:gamestream_flutter/isometric/server_response_reader.dart';
import 'package:gamestream_flutter/modules/modules.dart';
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

  DateTime? connectionEstablished;

  // interface
  void connect({required String uri, required dynamic message}) {
    print("webSocket.connect($uri)");
    connection.value = Connection.Connecting;
    webSocketChannel = WebSocketChannel.connect(Uri.parse(uri), protocols: ['gamestream.online']);
    webSocketChannel.stream.listen(_onEvent, onError: _onError, onDone: _onDone);
    sink = webSocketChannel.sink;
    connectionEstablished = DateTime.now();

    sink.done.then((value){
      print("Connection Finished");
      print("webSocketChannel.closeCode: ${webSocketChannel.closeCode}");
      print("webSocketChannel.closeReason: ${webSocketChannel.closeReason}");

      if (connectionEstablished != null){
        final duration = DateTime.now().difference(connectionEstablished!);
        print("Connection Duration ${duration.inSeconds} seconds");
      }

    });
    connectionUri = uri;
    sinkMessage(message);
  }

  void disconnect() {
    print('network.disconnect()');
    sink.close();
    connection.value = Connection.None;
  }

  void send(dynamic message) {
    if (!connected) {
      print("warning cannot send because not connected");
      return;
    }
    sinkMessage(message);
  }

  void sinkMessage(dynamic message) {
    sink.add(message);
  }

  void _onEvent(dynamic _response) {
    if (connecting) {
      connection.value = Connection.Connected;
    }
    
    if (_response is Uint8List) {
       return serverResponseReader.readBytes(_response);
    }
    if (_response is String){
      core.state.error.value = _response;
      return;
    }
    throw Exception("cannot parse response: $_response");
  }

  void _onError(Object error, StackTrace stackTrace) {
    print("network.onError()");
    // core.actions.setError(error.toString());
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

