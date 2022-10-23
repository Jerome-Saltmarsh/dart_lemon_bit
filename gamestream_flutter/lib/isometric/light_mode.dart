import 'package:gamestream_flutter/game_state.dart';
import 'package:lemon_watch/watch.dart';

final lightModeRadial = Watch(true, onChanged: (bool value){
  GameState.refreshLighting();
});

void toggleLightMode(){
   lightModeRadial.value = !lightModeRadial.value;
}