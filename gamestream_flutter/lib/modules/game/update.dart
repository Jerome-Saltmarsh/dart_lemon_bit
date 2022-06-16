import 'package:bleed_common/library.dart';
import 'package:flutter/services.dart';
import 'package:gamestream_flutter/isometric/character_controller.dart';
import 'package:gamestream_flutter/isometric/server_response_reader.dart';
import 'package:gamestream_flutter/isometric/update.dart';
import 'package:gamestream_flutter/isometric_web/read_player_input.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/client_request_sender.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_watch/watch.dart';

import 'state.dart';

final _gameActions = modules.game.actions;
final totalUpdates = Watch(0);

class GameUpdate {

  final GameState state;

  GameUpdate(this.state);

  void update() {
    totalUpdates.value++;
    framesSinceUpdateReceived.value++;
    updateIsometric();
    readPlayerInput();
    sendRequestUpdatePlayer();
  }

}
