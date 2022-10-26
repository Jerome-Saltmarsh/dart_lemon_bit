
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/isometric/ui/build_hud_map_editor.dart';
import 'package:gamestream_flutter/isometric/ui/buttons/build_atlas_image.dart';
import 'package:gamestream_flutter/isometric/ui/constants/colors.dart';
import 'package:gamestream_flutter/library.dart';

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
              action: GameEditor.delete,
              child: Container(
                width: 16,
                height: 16,
                child: buildAtlasImageButton(
                  image: GameImages.icons,
                  srcX: 80,
                  srcY: 96,
                  srcWidth: 16,
                  srcHeight: 16,
                  action: GameEditor.delete,
                ),
              ),
            ),
          ],
        ),
        Container(
          height: 70,
            alignment: Alignment.center,
            child: watch(
                GameEditor.nodeSelectedType,
                    (int nodeType) =>
                        text(NodeType.getName(nodeType), align: TextAlign.center)
            )
        ),
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
                          image: GameImages.icons,
                          action: GameEditor.cursorZDecrease,
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
                    image: GameImages.icons,
                  action: GameEditor.cursorRowIncrease,
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
                    image: GameImages.icons,
                    action: GameEditor.cursorColumnIncrease,
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
                  child: watch(GameEditor.nodeSelectedType, buildIconNodeType)),
              Positioned(
                top: 50 + _shiftY,
                left: 50 + _shiftX,
                child: onMouseOver(builder: (BuildContext context, bool mouseOver) => buildAtlasImageButton(
                    image: GameImages.icons,
                  action: GameEditor.cursorRowDecrease,
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
                    image: GameImages.icons,
                  action: GameEditor.cursorZIncrease,
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
                    image: GameImages.icons,
                    action: GameEditor.cursorColumnDecrease,
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
      ],
    ),
  );