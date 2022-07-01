import 'package:bleed_server/system.dart';

import 'common/library.dart';
import 'engine.dart';
import 'network/websocket_server.dart';

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

