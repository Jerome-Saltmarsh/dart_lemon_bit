
import 'package:bleed_common/node_type.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/classes/node.dart';
import 'package:gamestream_flutter/isometric/edit_state.dart';
import 'package:gamestream_flutter/isometric/ui/build_hud_map_editor.dart';
import 'package:gamestream_flutter/isometric/ui/constants/colors.dart';

Widget buildColumnSelectedNode(){
  return Container(
    padding: EdgeInsets.all(6),
    color: brownDark,
    child: Column(
      children: [
        watch(edit.selectedNode, (Node t) => text(NodeType.getName(t.type))),
        Container(
            height: 72,
            width: 72,
            alignment: Alignment.center,
            child: watch(edit.selectedNode, (Node t) => buildIconNodeType(t.type))),
        Row(
          children: [
            text("X:"),
            watch(edit.row, text),
          ],
        ),
        Row(
          children: [
            text("Y:"),
            watch(edit.row, text),
          ],

        ),
        Row(
          children: [
            text("-", onPressed: () => edit.z.value--),
            text("Z:"),
            watch(edit.z, text),
            text("+", onPressed: () => edit.z.value++),
          ],
        ),
      ],
    ),
  );
}