
import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/game_library.dart';

class GameActions {
  static void setAmbientShadeToHour(){
    GameState.ambientShade.value = Shade.fromHour(GameState.hours.value);
  }
}