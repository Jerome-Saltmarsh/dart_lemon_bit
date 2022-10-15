
import 'package:gamestream_flutter/audio_engine.dart';
import 'package:gamestream_flutter/utils/string_utils.dart';

void onChangedNpcTalk(String? value){
  if (_talkVisible != isNullOrEmpty(value)){
     if (_talkVisible){
       AudioEngine.audioSingleClickSound(0.25);
     }
  }
  _talkVisible = isNullOrEmpty(value);
}

var _talkVisible = false;