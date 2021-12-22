
import 'package:bleed_client/network/state/connected.dart';
import 'package:bleed_client/network/state/connectionUri.dart';
import 'package:bleed_client/network/streams/onDone.dart';

void handleOnDone() {
  connectionUri = "";
  connection.value = Connection.Done;
  onDoneStream.add(true);
}