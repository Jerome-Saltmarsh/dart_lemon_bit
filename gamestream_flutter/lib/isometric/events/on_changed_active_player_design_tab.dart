
import 'package:gamestream_flutter/game_audio.dart';
import 'package:gamestream_flutter/isometric/ui/enums/player_design_tab.dart';

void onChangedActivePlayerDesignTab(PlayerDesignTab value){
  GameAudio.click_sound_8.play();
}