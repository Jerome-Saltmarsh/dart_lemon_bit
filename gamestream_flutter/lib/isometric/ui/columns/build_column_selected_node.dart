
import 'package:bleed_common/node_type.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/classes/node.dart';
import 'package:gamestream_flutter/isometric/edit_state.dart';
import 'package:gamestream_flutter/isometric/ui/build_hud_map_editor.dart';
import 'package:gamestream_flutter/isometric/ui/constants/colors.dart';

Widget buildColumnSelectedNode(){
  return Container(
    width: 130,
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            text("<", onPressed: () => edit.row.value--),
            watch(edit.row, (int row) => text("X: $row")),
            text(">", onPressed: () => edit.row.value++),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            text("<", onPressed: () => edit.column.value--),
            watch(edit.column, (int column) => text("Y: $column")),
            text(">", onPressed: () => edit.column.value++),
          ],

        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            text("<", onPressed: () => edit.z.value--),
            watch(edit.z, (int z) => text("Z: $z")),
            text(">", onPressed: () => edit.z.value++),
          ],
        ),
      ],
    ),
  );
}