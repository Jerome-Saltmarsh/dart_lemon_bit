import 'dart:typed_data';
import 'package:lemon_watch/src.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../enums/connection_status.dart';


class WebsocketClient {
  DateTime? connectionEstablished;

  Function(String values) readString;
  Function(Uint8List values) readBytes;

  late WebSocketChannel webSocketChannel;
  late Sink sink;

  final Function(Object error, StackTrace stack) onError;
  final Function()? onDone;
  final connectionStatus = Watch(ConnectionStatus.None);

  WebsocketClient({
    required this.readString,
    required this.readBytes,
    required this.onError,
    this.onDone,
    Function(ConnectionStatus connectionStatus)? onConnectionStatusChanged
  }) {
    if (onConnectionStatusChanged != null){
      connectionStatus.onChanged(onConnectionStatusChanged);
    }
  }

  bool get connected => connectionStatus.value == ConnectionStatus.Connected;

  bool get connecting => connectionStatus.value == ConnectionStatus.Connecting;

  Duration? get connectionDuration {
    if (connectionEstablished == null) return null;
    return DateTime.now().difference(connectionEstablished!);
  }

  void connect({required String uri, required dynamic message}) {
    print('websocket_client.connect($uri)');
    connectionStatus.value = ConnectionStatus.Connecting;
    try {
      webSocketChannel = WebSocketChannel.connect(
          Uri.parse(uri), protocols: ['gamestream.online']);

      webSocketChannel.stream.listen(_onEvent,
          onError: internalOnError,
          onDone: _onDone,
      );
      sink = webSocketChannel.sink;
      sink.add(message);
    } catch(e) {
      connectionStatus.value = ConnectionStatus.Failed_To_Connect;
    }
  }

  void internalOnError(Object error, StackTrace stack){
     onError(error, stack);
  }

  void disconnect() {
    if (connected){
      print('websocketClient.disconnect()');
      sink.close();
    }
  }

  void _onEvent(dynamic response) {
    if (!connected) {
      connectionEstablished = DateTime.now();
      connectionStatus.value = ConnectionStatus.Connected;
    }
    if (response is Uint8List) {
      readBytes(response);
      return;
    }
    if (response is String) {
      readString(response);
      return;
    }
    throw Exception('cannot parse response: $response');
  }

  void _onDone() {

    if (connectionEstablished != null){
      final duration = DateTime.now().difference(connectionEstablished!);
      connectionEstablished = null;
      print('websocket-connection-duration: ${duration.inSeconds} seconds');
    }

    if (connecting) {
      connectionStatus.value = ConnectionStatus.Failed_To_Connect;
    } else {
      connectionStatus.value = ConnectionStatus.Done;
    }

    sink.close();
    onDone?.call();
  }

  void send(dynamic message) {
    if (!connected) {
      print('warning cannot send because not connected');
      return;
    }
    sink.add(message);
  }
}