
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/classes/vector3.dart';
import 'package:gamestream_flutter/isometric/watches/editor_selected_object.dart';

import '../widgets/build_container.dart';

Widget buildWatchEditorSelectedObject(){
   return watch(editorSelectedObject, (Vector3? selectedObject){
         if (selectedObject == null) return SizedBox();
         return container(child: selectedObject);
   });
}