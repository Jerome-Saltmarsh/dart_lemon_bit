
import 'package:gamestream_flutter/isometric/actions/editor_tab_set_objects.dart';
import 'package:gamestream_flutter/isometric/classes/vector3.dart';

void onChangedEditorSelectedObject(Vector3? value){
   if (value == null) return;
   editorTabSetObjects();
}