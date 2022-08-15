


import 'package:gamestream_flutter/isometric/edit_state.dart';

void onEditorColumnChanged(int value){
  edit.refreshSelected();
  edit.deselectGameObject();
}