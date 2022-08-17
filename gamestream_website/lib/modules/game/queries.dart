import 'package:gamestream_flutter/isometric/player.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_math/library.dart';

import 'state.dart';

class GameQueries {
  final GameState state;
  GameQueries(this.state);

  double getAngleBetweenMouseAndPlayer(){
    return getAngleBetween(player.x, player.y, mouseWorldX, mouseWorldY);
  }

  double getDistanceBetweenMouseAndPlayer(){
    return distanceBetween(mouseWorldX, mouseWorldY, player.x, player.y);
  }
}