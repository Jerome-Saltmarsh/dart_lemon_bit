
import 'package:flutter/services.dart';
import 'package:gamestream_flutter/isometric/audio.dart';
import 'package:gamestream_flutter/isometric_web/keys.dart';

import 'actions.dart';
import 'state.dart';

class GameMap {

  final GameState state;
  final GameActions actions;

  GameMap(this.state, this.actions){
  }
}

