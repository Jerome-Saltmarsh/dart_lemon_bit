import 'package:lemon_engine/engine.dart';
import 'package:lemon_math/angle_between.dart';
import 'package:lemon_math/distance_between.dart';
import 'state.dart';

class GameQueries {
  final GameState state;
  GameQueries(this.state);

  double getAngleBetweenMouseAndPlayer(){
    return angleBetween(state.player.x, state.player.y, mouseWorldX, mouseWorldY);
  }

  double getDistanceBetweenMouseAndPlayer(){
    return distanceBetween(mouseWorldX, mouseWorldY, state.player.x, state.player.y);
  }
}