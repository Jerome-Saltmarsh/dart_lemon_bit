
import 'package:bleed_client/network/state/connected.dart';
import 'package:bleed_client/network/state/connecting.dart';
import 'package:bleed_client/network/streams/onConnectError.dart';
import 'package:bleed_client/network/streams/onError.dart';

void handleOnError(dynamic value) {
  if (connecting) {
    print("connection connect error");
    onConnectError.add(value);
  } else {
    print("connection error");
    onError.add(value);
  }
  connected = false;
  connecting = false;
}