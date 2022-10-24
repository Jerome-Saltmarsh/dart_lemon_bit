
import 'package:gamestream_flutter/library.dart';


void onChangedRaining(bool raining){
  raining ? GameActions.rainStart() : GameActions.rainStop();
  GameState.refreshLighting();
}