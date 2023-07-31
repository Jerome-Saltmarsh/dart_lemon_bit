
import 'package:gamestream_flutter/lemon_websocket_client/websocket_client.dart';

class IsometricNetwork extends WebsocketClient {

  // late final WebsocketClient websocket;

  IsometricNetwork({
    required super.readString,
    required super.readBytes,
    required super.onError,
    super.onConnectionStatusChanged,
  }) {
    // websocket = WebsocketClient(
    //     readString: readString,
    //     readBytes: readBytes,
    //     onError: onError,
    // );
  }

  void sendClientRequest(int value, [dynamic message]) =>
      message != null ? send('${value} $message') : send(value);

}