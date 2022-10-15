import 'package:bleed_common/wind.dart';
import 'package:gamestream_flutter/game_state.dart';
import 'package:gamestream_flutter/isometric/events/on_changed_wind.dart';
import 'package:lemon_watch/watch.dart';

final windAmbient = Watch(Wind.Calm, onChanged: onChangedWind);

void gridWindResetToAmbient(){
  final ambientWindIndex = windAmbient.value.index;
  for (var i = 0; i < GameState.nodesTotal; i++){
    GameState.nodesWind[i] = ambientWindIndex;
  }
}

