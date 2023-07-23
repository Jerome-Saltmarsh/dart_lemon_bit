
import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/library.dart';
import 'package:lemon_byte/byte_reader.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../gamestream/isometric/components/functions/format_bytes.dart';
import 'connection_status.dart';

abstract class WebsocketClientBuilder extends StatelessWidget with ByteReader  {

  late WebSocketChannel webSocketChannel;
  late WebSocketSink sink;
  late final connectionStatus = Watch(ConnectionStatus.None);
  String connectionUri = '';
  DateTime? connectionEstablished;

  final serverResponseStack = Uint8List(1000);
  final serverResponseStackLength = Uint16List(1000);
  var serverResponseStackIndex = 0;

  var previousServerResponse = -1;
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

   // Future init(SharedPreferences sharedPreferences) async {
   //   print('gamestream.init()');
   //
   //   final visitDateTimeString = sharedPreferences.getString('visit-datetime');
   //   if (visitDateTimeString != null) {
   //     final visitDateTime = DateTime.parse(visitDateTimeString);
   //     final durationSinceLastVisit = DateTime.now().difference(visitDateTime);
   //     print('duration since last visit: ${durationSinceLastVisit.inSeconds} seconds');
   //     // games.website.saveVisitDateTime();
   //     // if (durationSinceLastVisit.inSeconds > 45){
   //     //   games.website.checkForLatestVersion();
   //     //   return;
   //     // }
   //   }
   //
   //   // io.detectInputMode();
   //
   //   // final visitCount = sharedPreferences.getInt('visit-count');
   //   // if (visitCount == null){
   //   //   sharedPreferences.putAny('visit-count', 1);
   //   //   games.website.visitCount.value = 1;
   //   // } else {
   //   //   sharedPreferences.putAny('visit-count', visitCount + 1);
   //   //   games.website.visitCount.value = visitCount + 1;
   //   //
   //   //   final cachedVersion = sharedPreferences.getString('version');
   //   //   if (cachedVersion != null){
   //   //     if (version != cachedVersion){
   //   //       print('New version detected (previous: $cachedVersion, latest: $version)');
   //   //     }
   //   //   }
   //   //
   //   //   // network.region.value = engine.isLocalHost ? ConnectionRegion.LocalHost : ConnectionRegion.Asia_South;
   //   // }
   //   await Future.delayed(const Duration(seconds: 4));
   // }

   void onError(Object error, StackTrace stack);

   void onChangedNetworkConnectionStatus(ConnectionStatus connection);

  void update();

  @override
  Widget build(BuildContext context);

  Duration? get connectionDuration {
    if (timeConnectionEstablished == null) return null;
    return DateTime.now().difference(timeConnectionEstablished!);
  }

  String get formattedConnectionDuration {
    final duration = connectionDuration;
    if (duration == null) return 'not connected';
    final seconds = duration.inSeconds % 60;
    final minutes = duration.inMinutes;
    return 'minutes: $minutes, seconds: $seconds';
  }

  String formatAverageBufferSize(int bytes){
    final duration = connectionDuration;
    if (duration == null) return 'not connected';
    final seconds = duration.inSeconds;
    final bytesPerSecond = (bytes / seconds).round();
    final bytesPerMinute = bytesPerSecond * 60;
    final bytesPerHour = bytesPerMinute * 60;
    return 'per second: $bytesPerSecond, per minute: $bytesPerMinute, per hour: $bytesPerHour';
  }

  String formatAverageBytePerSecond(int bytes){
    final duration = connectionDuration;
    if (duration == null) return 'not connected';
    if (duration.inSeconds <= 0) return '-';
    return formatBytes((bytes / duration.inSeconds).round());
  }

  String formatAverageBytePerMinute(int bytes){
    final duration = connectionDuration;
    if (duration == null) return 'not connected';
    if (duration.inSeconds <= 0) return '-';
    return formatBytes((bytes / duration.inSeconds).round() * 60);
  }

  String formatAverageBytePerHour(int bytes){
    final duration = connectionDuration;
    if (duration == null) return 'not connected';
    if (duration.inSeconds <= 0) return '-';
    return formatBytes((bytes / duration.inSeconds).round() * 3600);
  }

  void readServerResponse(Uint8List values) {
    assert (values.isNotEmpty);
    index = 0;
    this.values = values;
    bufferSize.value = values.length;
    bufferSizeTotal.value += values.length;

    var serverResponseStart = -1;
    var serverResponse = -1;
    serverResponseStackIndex = -1;
    final length = values.length - 1;

    while (index < length) {

      if (serverResponse != -1) {
        serverResponseStackIndex++;
        serverResponseStack[serverResponseStackIndex] = serverResponse;
        serverResponseStackLength[serverResponseStackIndex] = index - serverResponseStart;
      }

      serverResponseStart = index;
      serverResponse = readByte();
      readResponse(serverResponse);

      previousServerResponse = serverResponse;
    }

    serverResponseStackIndex++;
    serverResponseStack[serverResponseStackIndex] = serverResponse;
    serverResponseStackLength[serverResponseStackIndex] = index - serverResponseStart;
    bufferSize.value = index;
    index = 0;

    onReadRespondFinished();
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