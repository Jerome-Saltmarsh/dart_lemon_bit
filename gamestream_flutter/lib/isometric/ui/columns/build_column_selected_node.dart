
import 'package:bleed_common/node_type.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/classes/node.dart';
import 'package:gamestream_flutter/isometric/edit.dart';
import 'package:gamestream_flutter/isometric/ui/build_hud_map_editor.dart';
import 'package:gamestream_flutter/isometric/ui/buttons/build_atlas_image.dart';
import 'package:gamestream_flutter/isometric/ui/constants/colors.dart';
import 'package:gamestream_flutter/utils/widget_utils.dart';

const _shiftX = 23.0;
const _shiftY = 20.0;

Widget buildEditorSelectedNode() =>
  Container(
    width: 130,
    height: 220,
    padding: const EdgeInsets.all(6),
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
                child: buildAtlasImageButton(
                  srcX: 80,
                  srcY: 96,
                  srcWidth: 16,
                  srcHeight: 16,
                  action: edit.delete,
                ),
              ),
            ),
          ],
        ),
        Container(
          height: 70,
            alignment: Alignment.center,
            child: watch(edit.nodeSelected, (Node t) => text(NodeType.getName(t.type), align: TextAlign.center))),
        Container(
          width: 120,
          height: 120,
          alignment: Alignment.center,
          color: Colors.green,
          child: Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: [
              Positioned(
                top: 65 + _shiftY,
                left: 27 + _shiftX,
                child: onMouseOver(builder: (BuildContext context, bool mouseOver) =>
                      buildAtlasImageButton(
                          action: edit.cursorZDecrease,
                          srcX: mouseOver ? 9673 : 9650,
                          srcY: 27,
                          srcWidth: 19,
                          srcHeight: 27,
                          hint: "Shift + Arrow Down"
                      )
                ),
              ),
              Positioned(
                top: 3 + _shiftY,
                left: 3 + _shiftY,
                child: onMouseOver(builder: (BuildContext context, bool mouseOver) => buildAtlasImageButton(
                  action: edit.cursorRowDecrease,
                  srcX: mouseOver ? 9672 : 9649,
                  srcY: 110,
                  srcWidth: 21,
                  srcHeight: 21,
                  hint: "Arrow Up"
                ),
              )),
              Positioned(
                top: 5 + _shiftY,
                left: 50 + _shiftX,
                child: onMouseOver(builder: (BuildContext context, bool mouseOver) => buildAtlasImageButton(
                    action: edit.cursorColumnDecrease,
                    srcX: mouseOver ? 9672 : 9649,
                    srcY: 137,
                    srcWidth: 21,
                    srcHeight: 21,
                    hint: "Arrow Right"
                ),
              )),
              Container(
                  height: 72,
                  width: 72,
                  alignment: Alignment.center,
                  child: watch(edit.nodeSelected, (Node t) => buildIconNodeType(t.type))),
              Positioned(
                top: 50 + _shiftY,
                left: 50 + _shiftX,
                child: onMouseOver(builder: (BuildContext context, bool mouseOver) => buildAtlasImageButton(
                  action: edit.cursorRowIncrease,
                  srcX: mouseOver ? 9672 : 9649,
                  srcY: 56,
                  srcWidth: 21,
                  srcHeight: 21,
                  hint: "Arrow Down"
                )),
              ),
              Positioned(
                top: -10 + _shiftY,
                left: 27 + _shiftX,
                child: onMouseOver(builder: (BuildContext context, bool mouseOver) => buildAtlasImageButton(
                  action: edit.cursorZIncrease,
                  srcX: mouseOver ? 9673 : 9650,
                  srcY: 0,
                  srcWidth: 21,
                  srcHeight: 21,
                  hint: "Shift + Arrow Up"
                )),
              ),
              Positioned(
                top: 50 + _shiftY,
                left: 0 + _shiftX,
                child: onMouseOver(builder: (BuildContext context, bool mouseOver) => buildAtlasImageButton(
                    action: edit.cursorColumnIncrease,
                    srcX: mouseOver ? 9672 : 9649,
                    srcY: 83,
                    srcWidth: 21,
                    srcHeight: 21,
                    hint: "Arrow Left"
                )),
              ),
            ],
          ),
        ),
        // height4,
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //   children: [
        //     Tooltip(child: text("<", onPressed: () => edit.row.value--), message: "Arrow Up",),
        //     watch(edit.row, (int row) => text("X: $row")),
        //     Tooltip(child: text(">", onPressed: () => edit.row.value++), message: "Arrow Down",),
        //   ],
        // ),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //   children: [
        //     Tooltip(child: text("<", onPressed: () => edit.column.value--), message: "Arrow Right",),
        //     watch(edit.column, (int column) => text("Y: $column")),
        //     Tooltip(child: text(">", onPressed: () => edit.column.value++), message: "Arrow Left",),
        //   ],
        //
        // ),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //   children: [
        //     Tooltip(child: text("<", onPressed: () => edit.z.value--), message: "Shift + Arrow Down",),
        //     watch(edit.z, (int z) => text("Z: $z")),
        //     Tooltip(child: text(">", onPressed: () => edit.z.value++), message: "Shift + Arrow Up",),
        //   ],
        // ),
      ],
    ),
  );