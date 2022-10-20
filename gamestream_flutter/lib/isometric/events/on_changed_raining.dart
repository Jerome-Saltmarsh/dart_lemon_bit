
import 'package:gamestream_flutter/game_state.dart';
import 'package:gamestream_flutter/isometric/grid.dart';

import '../grid/actions/rain_on.dart';

void onChangedRaining(bool raining){
  raining ? rainOn() : GameState.rainOff();
  refreshLighting();
}