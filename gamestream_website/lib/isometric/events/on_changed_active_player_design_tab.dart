
import 'package:gamestream_flutter/isometric/audio/audio_singles.dart';
import 'package:gamestream_flutter/isometric/ui/enums/player_design_tab.dart';

void onChangedActivePlayerDesignTab(PlayerDesignTab value){
  audioSingleClickSound.play();
}