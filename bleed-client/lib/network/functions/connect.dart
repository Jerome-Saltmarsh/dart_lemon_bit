// TODO Illegal Import
import 'package:bleed_client/common/ClientRequest.dart';
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
  onConnectController.add(uri);
  webSocketChannel = WebSocketChannel.connect(Uri.parse(uri));
  webSocketChannel.stream.listen(handleOnEvent, onError: handleOnError, onDone: handleOnDone);
  webSocketChannel.sink.add(ClientRequest.Ping.index);
  connectionUri = uri;
}