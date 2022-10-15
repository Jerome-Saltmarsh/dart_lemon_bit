
import 'package:gamestream_flutter/audio_engine.dart';

void onChangedPlayerDesigned(bool value){
   if (value){
      AudioEngine.audioSingleItemUnlock();
   }
}