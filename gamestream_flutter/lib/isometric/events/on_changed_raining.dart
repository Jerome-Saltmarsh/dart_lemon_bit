
import 'package:gamestream_flutter/game.dart';
import 'package:gamestream_flutter/isometric/grid.dart';

import '../grid/actions/rain_on.dart';

void onChangedRaining(bool raining){
  raining ? rainOn() : Game.rainOff();
  refreshLighting();
}