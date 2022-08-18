


import 'package:gamestream_flutter/isometric/edit_state.dart';

/// node_type.dart
void onChangedCursorPosition(int type) {
  edit.refreshSelected();
  edit.deselectGameObject();
}