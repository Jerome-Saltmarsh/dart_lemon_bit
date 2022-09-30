


import 'package:gamestream_flutter/isometric/edit.dart';

/// node_type.dart
void onChangedCursorPosition(int type) {
  edit.refreshNodeSelectedIndex();
  edit.deselectGameObject();
}