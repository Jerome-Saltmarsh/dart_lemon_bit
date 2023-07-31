
import 'package:gamestream_flutter/gamestream/isometric/isometric.dart';
import 'package:gamestream_flutter/lemon_websocket_client/websocket_client.dart';

class IsometricNetwork {

  late final WebsocketClient websocket;

  IsometricNetwork(Isometric isometric) {
    websocket = WebsocketClient(
        readString: isometric.readServerResponseString,
        readBytes: isometric.readNetworkBytes,
        onError: isometric.onError,
        onConnectionStatusChanged: isometric.onChangedNetworkConnectionStatus,
    );
  }

  void sendClientRequest(int value, [dynamic message]) =>
      message != null
          ? websocket.send('${value} $message')
          : websocket.send(value);

}