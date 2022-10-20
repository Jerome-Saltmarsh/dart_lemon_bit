
import 'package:gamestream_flutter/game_audio.dart';

void onChangedNpcTalk(String? value){
  if (_talkVisible != isNullOrEmpty(value)){
     if (_talkVisible){
       GameAudio.click_sound_8(0.25);
     }
  }
  _talkVisible = isNullOrEmpty(value);
}

bool isNullOrEmpty(String? value){
  return value == null || value.isEmpty;
}

var _talkVisible = false;