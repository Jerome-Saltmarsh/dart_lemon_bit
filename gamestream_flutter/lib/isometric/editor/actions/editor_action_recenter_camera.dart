
import 'package:gamestream_flutter/isometric/camera.dart';
import 'package:gamestream_flutter/game_editor.dart';

void editorActionRecenterCamera() =>
  cameraSetPositionGrid(
    GameEditor.row,
    GameEditor.column,
    GameEditor.z,
  );