
import 'package:bleed_common/library.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/classes/node.dart';
import 'package:gamestream_flutter/isometric/edit_state.dart';
import 'package:gamestream_flutter/isometric/ui/constants/colors.dart';
import 'package:gamestream_flutter/isometric/ui/constants/editor_grid_type_columns.dart';
import 'package:lemon_engine/screen.dart';

import '../build_hud_map_editor.dart';
import '../widgets/build_container.dart';

Widget buildWatchEditorTab(){
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      watch(edit.nodeSelected, (Node type) => container(child: "${NodeType.getName(type.type)}", color: brownLight)),
      buildColumnSelectNodeType()
    ],
  );
}

Widget buildColumnSelectNodeType(){
  return Container(
    height: screen.height - 70,
    child: SingleChildScrollView(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: editorGridTypesColumn1.map(buildButtonSelectNodeType).toList(),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: editorGridTypesColumn2.map(buildButtonSelectNodeType).toList(),
          ),
        ],
      ),
    ),
  );
}

Widget buildColumnSelectObjectType(){
  return Column();
}