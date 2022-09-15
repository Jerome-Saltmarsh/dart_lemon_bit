
import 'package:bleed_common/node_type.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/classes/node.dart';
import 'package:gamestream_flutter/isometric/edit_state.dart';
import 'package:gamestream_flutter/isometric/editor/actions/editor_action_recenter_camera.dart';
import 'package:gamestream_flutter/isometric/ui/build_hud_map_editor.dart';
import 'package:gamestream_flutter/isometric/ui/buttons/build_atlas_image.dart';
import 'package:gamestream_flutter/isometric/ui/constants/colors.dart';
import 'package:gamestream_flutter/isometric/ui/widgets/build_container.dart';

Widget buildColumnSelectedNode(){
  return Container(
    width: 130,
    padding: EdgeInsets.all(6),
    color: brownDark,
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            onPressed(
              hint: "Delete",
              action: edit.delete,
              child: Container(
                width: 16,
                height: 16,
                child: buildCanvasImageButton(
                  srcX: 80,
                  srcY: 96,
                  srcWidth: 16,
                  srcHeight: 16,
                  action: edit.delete,
                ),
              ),
            ),
            // onPressed(
            //   hint: "Center Camera (G)",
            //   action: editorActionRecenterCamera,
            //   child: Container(
            //     width: 16,
            //     height: 16,
            //     child: buildCanvasImageButton(
            //         srcX: 96,
            //         srcY: 96,
            //         srcWidth: 16,
            //         srcHeight: 16,
            //         action: editorActionRecenterCamera,
            //     ),
            //   ),
            // ),
            // onPressed(
            //   hint: 'Recenter Camera (G)',
            //   action: editorActionRecenterCamera,
            //   child: buildCanvasImage(
            //     srcX: 96,
            //     srcY: 96,
            //     srcWidth: 16,
            //     srcHeight: 16,
            //   ),
            // ),
          ],
        ),
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