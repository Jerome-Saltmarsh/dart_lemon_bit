
import 'package:bleed_client/network/state/connected.dart';
import 'package:bleed_client/network/state/connecting.dart';
import 'package:bleed_client/network/state/connectionUri.dart';
import 'package:bleed_client/network/streams/onDone.dart';

void handleOnDone() {
  print("connection done");
  connectionUri = "";
  connected = false;
  connecting = false;
  onDoneStream.add(true);
}