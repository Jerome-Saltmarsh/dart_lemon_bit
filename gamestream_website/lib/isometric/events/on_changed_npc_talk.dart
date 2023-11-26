
import 'package:gamestream_flutter/isometric/audio/audio_singles.dart';
import 'package:gamestream_flutter/utils/string_utils.dart';

void onChangedNpcTalk(String? value){
  if (_talkVisible != isNullOrEmpty(value)){
     if (_talkVisible){
       audioSingleClickSound(0.25);
     }
  }
  _talkVisible = isNullOrEmpty(value);
}

var _talkVisible = false;