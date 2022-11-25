import 'package:bleed_server/gamestream.dart';
import 'package:bleed_server/src/network/websocket_server.dart';
import 'package:bleed_server/src/system.dart';


Future main() async {
  print('gamestream.online server starting');
  print('v${version}');
  if (isLocalMachine){
    print("Environment Detected: Jerome's Computer");
  }else{
    print("Environment Detected: Google Cloud Machine");
  }
  await engine.init();
  startWebsocketServer();
}

