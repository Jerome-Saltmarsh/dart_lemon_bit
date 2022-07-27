
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/isometric/ui/constants/colors.dart';

import '../build_hud_map_editor.dart';
import '../widgets/build_container.dart';

Widget buildWatchEditorTab(){
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      container(child: "Type", color: brownLight),
      buildColumnSelectGridNodeType()
    ],
  );
}

Widget buildColumnSelectGridNodeType(){
  return Container(
    height: 200,
    child: SingleChildScrollView(
      child: Column(
        children: editorSelectableGridTypes.map(buildButtonSelectGridNodeType).toList(),
      ),
    ),
  );
}

Widget buildColumnSelectObjectType(){
  return Column();
}