
import 'package:gamestream_flutter/game_audio.dart';
import 'package:gamestream_flutter/utils/string_utils.dart';

void onChangedNpcTalk(String? value){
  if (_talkVisible != isNullOrEmpty(value)){
     if (_talkVisible){
       GameAudio.click_sound_8(0.25);
     }
  }
  _talkVisible = isNullOrEmpty(value);
}

var _talkVisible = false;