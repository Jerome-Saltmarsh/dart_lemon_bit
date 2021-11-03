import 'package:bleed_client/network/streams/onConnect.dart';
import 'package:bleed_client/network/streams/onConnectError.dart';
import 'package:bleed_client/network/streams/onConnected.dart';
import 'package:bleed_client/network/streams/onDisconnected.dart';
import 'package:bleed_client/network/streams/onDone.dart';
import 'package:bleed_client/network/streams/onError.dart';
import 'package:bleed_client/network/streams/eventStream.dart';

void dispose(){
  onConnectController.close();
  onConnectedController.close();
  onConnectError.close();
  onDisconnected.close();
  onDoneStream.close();
  onError.close();
  eventStream.close();
}