import 'package:bleed_client/network/events/onDone.dart';
import 'package:bleed_client/network/events/onError.dart';
import 'package:bleed_client/network/events/onEvent.dart';
import 'package:bleed_client/network/state/connecting.dart';
import 'package:bleed_client/network/state/connectionUri.dart';
import 'package:bleed_client/network/state/webSocketChannel.dart';
import 'package:bleed_client/network/streams/onConnect.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void connect(String uri) {
  connecting = true;
  webSocketChannel = WebSocketChannel.connect(Uri.parse(uri));
  webSocketChannel.stream.listen(handleOnEvent, onError: handleOnError, onDone: handleOnDone);
  connectionUri = uri;
  onConnectController.add(uri);
}