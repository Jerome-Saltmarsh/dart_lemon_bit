
import 'package:gamestream_flutter/isometric/camera.dart';
import 'package:gamestream_flutter/isometric/edit.dart';

void editorActionRecenterCamera() =>
  cameraSetPositionGrid(
      edit.row,
      edit.column,
      edit.z,
  );