
import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/library.dart';
import 'package:lemon_byte/byte_reader.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'connection_status.dart';

abstract class WebsocketClientBuilder extends StatelessWidget with ByteReader  {

  late WebSocketChannel webSocketChannel;
  late WebSocketSink sink;
  late final connectionStatus = Watch(ConnectionStatus.None);
  String connectionUri = '';
  DateTime? connectionEstablished;

  var renderResponse = false;

  DateTime? timeConnectionEstablished;

  final bufferSize = Watch(0);
  final bufferSizeTotal = Watch(0);
  final decoder = ZLibDecoder();


  WebsocketClientBuilder() {
    print('WebsocketClientBuilder()');
    connectionStatus.onChanged(onChangedNetworkConnectionStatus);
  }

  bool get connected => connectionStatus.value == ConnectionStatus.Connected;

  bool get connecting => connectionStatus.value == ConnectionStatus.Connecting;

  void onError(Object error, StackTrace stack);

  void onChangedNetworkConnectionStatus(ConnectionStatus connection);

  Widget build(BuildContext context);

  Duration? get connectionDuration {
    if (timeConnectionEstablished == null) return null;
    return DateTime.now().difference(timeConnectionEstablished!);
  }

  void readServerResponse(Uint8List values) {
    assert (values.isNotEmpty);
    index = 0;
    this.values = values;
    bufferSize.value = values.length;
    bufferSizeTotal.value += values.length;

    final length = values.length - 1;

    while (index < length) {
      readResponse(readByte());
    }

    bufferSize.value = index;
    onReadRespondFinished();
    index = 0;
  }

  void onReadRespondFinished();

  void readResponse(int serverResponse);

  void onConnectionLost();


  void connect({required String uri, required dynamic message}) {
    print('webSocket.connect($uri)');
    connectionStatus.value = ConnectionStatus.Connecting;
    try {
      webSocketChannel = WebSocketChannel.connect(
          Uri.parse(uri), protocols: ['gamestream.online']);

      webSocketChannel.stream.listen(_onEvent, onError: _onError, onDone: _onDone);
      sink = webSocketChannel.sink;
      connectionEstablished = DateTime.now();
      sink.done.then((value){
        print('Connection Finished');
        print('webSocketChannel.closeCode: ${webSocketChannel.closeCode}');
        print('webSocketChannel.closeReason: ${webSocketChannel.closeReason}');
        if (connectionEstablished != null){
          final duration = DateTime.now().difference(connectionEstablished!);
          print('Connection Duration ${duration.inSeconds} seconds');
        }

        if (webSocketChannel.closeCode != null){
          gamestream.onConnectionLost();


        }
      });
      connectionUri = uri;
      sink.add(message);
    } catch(e) {
      connectionStatus.value = ConnectionStatus.Failed_To_Connect;
    }
  }


  void disconnect() {
    print('websocketClientBuilder.disconnect()');
    if (connected){
      sink.close();
    }
    connectionStatus.value = ConnectionStatus.None;
  }

  void _onEvent(dynamic response) {
    if (connecting) {
      connectionStatus.value = ConnectionStatus.Connected;
    }

    if (response is Uint8List) {
      return gamestream.readServerResponse(response);
    }
    if (response is String) {
      if (response.toLowerCase() == 'ping'){
        print('ping request received');
        sink.add('pong');
        return;
      }
      return;
    }
    throw Exception('cannot parse response: $response');
  }
  void _onError(Object error, StackTrace stackTrace) {
    print('network.onError()');
    // core.actions.setError(error.toString());
  }


  void _onDone() {
    print('network.onDone()');

    connectionUri = '';
    if (connecting) {
      connectionStatus.value = ConnectionStatus.Failed_To_Connect;
    } else {
      connectionStatus.value = ConnectionStatus.Done;
    }
    sink.close();
  }


  void send(dynamic message) {
    if (!connected) {
      print('warning cannot send because not connected');
      return;
    }
    sink.add(message);
  }
}