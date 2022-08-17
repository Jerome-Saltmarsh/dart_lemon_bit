

import 'package:flutter/material.dart';
import 'package:gamestream_flutter/isometric/enums/editor_dialog.dart';
import 'package:gamestream_flutter/isometric/ui/build_hud_audio_mixer.dart';
import 'package:gamestream_flutter/isometric/ui/build_hud_debug.dart';
import 'package:gamestream_flutter/isometric/ui/dialogs/build_dialog_canvas_size.dart';
import 'package:gamestream_flutter/isometric/ui/dialogs/build_game_dialog_scene_load.dart';
import 'package:gamestream_flutter/isometric/ui/dialogs/build_game_dialog_scene_save.dart';

Widget buildEditorDialog(EditorDialog value){
  switch (value) {
    case EditorDialog.Scene_Load:
      return buildGameDialogSceneLoad();
    case EditorDialog.Scene_Save:
      return buildGameDialogSceneSave();
    case EditorDialog.Debug:
      return buildHudDebug();
    case EditorDialog.Audio_Mixer:
      return buildHudAudioMix();
    case EditorDialog.Canvas_Size:
      return buildDialogCanvasSize();
  }
}