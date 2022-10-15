
import 'package:gamestream_flutter/audio_engine.dart';
import 'package:gamestream_flutter/isometric/ui/enums/player_design_tab.dart';

void onChangedActivePlayerDesignTab(PlayerDesignTab value){
  AudioEngine.audioSingleClickSound.play();
}