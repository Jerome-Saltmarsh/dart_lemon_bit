


import 'package:gamestream_flutter/isometric/edit_state.dart';

void onEditorRowChanged(int row){
  edit.refreshSelected();
  edit.deselectGameObject();
}