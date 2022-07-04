
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/enums/editor_tab.dart';
import 'package:gamestream_flutter/isometric/ui/constants/colors.dart';
import 'package:gamestream_flutter/isometric/watches/editor_active_tab.dart';
import 'package:lemon_engine/screen.dart';

import '../build_hud_map_editor.dart';
import '../widgets/build_container.dart';

Widget buildWatchEditorTab(){
  return watch(editorActiveTab, (EditorTab activeEditorTab){
     return Column(
       crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: EditorTab.values.map(buildButtonSelectEditorTab).toList(),
          ),
          buildColumnSelectGridNodeType()
        ],
     );
  });
}

Widget buildButtonSelectEditorTab(EditorTab value){
  return container(
      child: value.name,
      action: ()=> editorActiveTab.value = value,
      color: value == editorActiveTab.value ? greyDark : grey,
  );
}

Widget buildColumnEditorTab(EditorTab editorTab){
  switch(editorTab){
    case EditorTab.Grid:
      return buildColumnSelectGridNodeType();
    case EditorTab.Objects:
      return buildColumnSelectObjectType();
  }
}

Widget buildColumnSelectGridNodeType(){
  return Container(
    height: screen.height - 160,
    child: SingleChildScrollView(
      child: Column(
        children: selectableTiles.map(buildButtonSelectGridNodeType).toList(),
      ),
    ),
  );
}

Widget buildColumnSelectObjectType(){
  return Column();
}