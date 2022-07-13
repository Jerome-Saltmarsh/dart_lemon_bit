

import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/enums/game_dialog.dart';
import 'package:gamestream_flutter/isometric/ui/build_hud_audio_mixer.dart';
import 'package:gamestream_flutter/isometric/ui/build_hud_debug.dart';
import 'package:gamestream_flutter/isometric/ui/dialogs/build_dialog_canvas_size.dart';
import 'package:gamestream_flutter/isometric/ui/dialogs/build_game_dialog_scene_load.dart';
import 'package:gamestream_flutter/isometric/ui/dialogs/build_game_dialog_scene_save.dart';

import 'build_game_dialog_quests.dart';

Widget buildGameDialog(GameDialog gameDialog){
  switch(gameDialog){
    case GameDialog.Scene_Load:
      return buildGameDialogSceneLoad();
    case GameDialog.Scene_Save:
      return buildGameDialogSceneSave();
    case GameDialog.Debug:
      return buildHudDebug();
    case GameDialog.Audio_Mixer:
      return buildHudAudioMix();
    case GameDialog.Canvas_Size:
      return buildDialogCanvasSize();
    case GameDialog.Quests:
      return buildGameDialogQuests();
  }
}