
import 'package:gamestream_flutter/game_audio.dart';

void onChangedPlayerDesigned(bool value){
   if (value){
      GameAudio.audioSingleItemUnlock();
   }
}