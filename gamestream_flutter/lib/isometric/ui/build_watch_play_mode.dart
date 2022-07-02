
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/play_mode.dart';
import 'package:gamestream_flutter/isometric/ui/build_hud_audio_mixer.dart';
import 'package:gamestream_flutter/isometric/ui/build_hud_debug.dart';
import 'package:gamestream_flutter/isometric/ui/build_hud_map_editor.dart';
import 'package:gamestream_flutter/isometric/ui/build_hud_play_mode.dart';
import 'package:gamestream_flutter/isometric/ui/build_play_mode_file.dart';
import 'package:gamestream_flutter/isometric/ui/build_stack_save.dart';

Widget buildWatchPlayMode(){
   return watch(playMode, (PlayMode playMode){
      switch (playMode){
        case PlayMode.Play:
          return buildHudPlayMode();
        case PlayMode.Edit:
          return buildHudMapEditor();
        case PlayMode.Debug:
          return buildHudDebug();
        case PlayMode.Audio:
          return buildHudAudioMix();
        case PlayMode.File:
          return buildPlayModeFile();
        case PlayMode.Save:
          return buildStackSave();
      }
   });
}