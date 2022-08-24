
import 'package:bleed_common/library.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/classes/node.dart';
import 'package:gamestream_flutter/isometric/edit_state.dart';
import 'package:gamestream_flutter/isometric/ui/constants/colors.dart';
import 'package:lemon_engine/screen.dart';

import '../build_hud_map_editor.dart';
import '../widgets/build_container.dart';

Widget buildWatchEditorTab(){
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      watch(edit.selectedNode, (Node type) => container(child: "${NodeType.getName(type.type)}", color: brownLight)),
      buildColumnSelectNodeType()
    ],
  );
}

Widget buildColumnSelectNodeType(){
  return Container(
    height: screen.height - 70,
    child: SingleChildScrollView(
      child: Row(
        children: [
          Column(
            children: editorGridTypesColumn1.map(buildButtonSelectNodeType).toList(),
          ),
          Column(
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