import 'package:gamestream_flutter/isometric/update.dart';
import 'package:gamestream_flutter/isometric_web/read_player_input.dart';
import 'package:gamestream_flutter/network/send_client_request.dart';

class GameUpdate {
  void update() {
    updateIsometric();
    readPlayerInput();
    sendClientRequestUpdate();
  }
}
