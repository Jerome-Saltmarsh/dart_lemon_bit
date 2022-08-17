


import 'package:gamestream_flutter/isometric/edit_state.dart';

void onEditorZChanged(int z){
  edit.refreshSelected();
  edit.deselectGameObject();
}