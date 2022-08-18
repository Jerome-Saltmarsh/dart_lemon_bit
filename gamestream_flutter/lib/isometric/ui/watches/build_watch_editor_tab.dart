
import 'package:bleed_common/library.dart';
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
      watch(edit.selectedNode, (Node type) => container(child: "${NodeType.getName(type.type)}", color: brownLight)),
      buildColumnSelectNodeType()
    ],
  );
}

Widget buildColumnSelectNodeType(){
  return Container(
    height: 200,
    child: SingleChildScrollView(
      child: Column(
        children: editorSelectableGridTypes.map(buildButtonSelectNodeType).toList(),
      ),
    ),
  );
}

Widget buildColumnSelectObjectType(){
  return Column();
}