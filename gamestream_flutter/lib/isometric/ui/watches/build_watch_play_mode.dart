
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/play_mode.dart';
import 'package:gamestream_flutter/isometric/ui/build_hud_map_editor.dart';
import 'package:gamestream_flutter/isometric/ui/stacks/build_stacks_play_mode.dart';

Widget buildWatchPlayMode(){
   return watch(playMode, (PlayMode playMode){
      switch (playMode){
        case PlayMode.Play:
          return buildStackPlayMode();
        case PlayMode.Edit:
          return buildHudMapEditor();
      }
   });
}