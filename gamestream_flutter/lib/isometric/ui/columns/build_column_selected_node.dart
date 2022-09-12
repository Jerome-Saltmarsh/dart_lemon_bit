
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
        Container(
          height: 70,
            alignment: Alignment.center,
            child: watch(edit.nodeSelected, (Node t) => text(NodeType.getName(t.type), align: TextAlign.center))),
        Container(
            height: 72,
            width: 72,
            alignment: Alignment.center,
            child: watch(edit.nodeSelected, (Node t) => buildIconNodeType(t.type))),
        height4,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Tooltip(child: text("<", onPressed: () => edit.row.value--), message: "Arrow Up",),
            watch(edit.row, (int row) => text("X: $row")),
            Tooltip(child: text(">", onPressed: () => edit.row.value++), message: "Arrow Down",),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Tooltip(child: text("<", onPressed: () => edit.column.value--), message: "Arrow Right",),
            watch(edit.column, (int column) => text("Y: $column")),
            Tooltip(child: text(">", onPressed: () => edit.column.value++), message: "Arrow Left",),
          ],

        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Tooltip(child: text("<", onPressed: () => edit.z.value--), message: "Shift + Arrow Down",),
            watch(edit.z, (int z) => text("Z: $z")),
            Tooltip(child: text(">", onPressed: () => edit.z.value++), message: "Shift + Arrow Up",),
          ],
        ),
      ],
    ),
  );
}