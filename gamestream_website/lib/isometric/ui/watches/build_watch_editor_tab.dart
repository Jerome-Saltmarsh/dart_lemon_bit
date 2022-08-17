
import 'package:bleed_common/grid_node_type.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/classes/node.dart';
import 'package:gamestream_flutter/isometric/edit_state.dart';
import 'package:gamestream_flutter/isometric/ui/constants/colors.dart';

import '../build_hud_map_editor.dart';
import '../widgets/build_container.dart';

Widget buildWatchEditorTab(){
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      watch(edit.selected, (Node type) => container(child: "${GridNodeType.getName(type.type)}", color: brownLight)),
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