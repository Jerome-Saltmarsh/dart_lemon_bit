
import 'package:gamestream_flutter/isometric/camera.dart';
import 'package:gamestream_flutter/isometric/edit_state.dart';

void editorActionRecenterCamera() =>
  cameraSetPositionGrid(
      edit.row.value,
      edit.column.value,
      edit.z.value,
  );