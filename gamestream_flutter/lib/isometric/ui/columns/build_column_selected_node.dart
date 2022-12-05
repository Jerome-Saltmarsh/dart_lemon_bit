
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/isometric/ui/constants/colors.dart';
import 'package:gamestream_flutter/library.dart';

const _shiftX = 17.0;
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
                child: Engine.buildAtlasImageButton(
                  image: GameImages.atlasIcons,
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
              buildPositionedIconButton(
                top: 65 + _shiftY,
                left: 27 + _shiftX,
                action: GameEditor.cursorZDecrease,
                iconType: IconType.Arrows_Down_Yellow,
                hint: "Shift + Arrow Down",
              ),
              buildPositionedIconButton(
                top: 3 + _shiftY,
                left: 3 + _shiftY,
                action: GameEditor.cursorRowDecrease,
                iconType: IconType.Arrows_North_Yellow,
                hint: "Arrow Up",
              ),
              buildPositionedIconButton(
                top: 5 + _shiftY,
                left: 50 + _shiftX,
                action: GameEditor.cursorColumnDecrease,
                iconType: IconType.Arrows_East_Yellow,
                hint: "Arrow Right",
              ),
              Container(
                  height: 72,
                  width: 72,
                  alignment: Alignment.center,
                  child: watch(GameEditor.nodeSelectedType, GameUI.buildAtlasNodeType)
              ),
              buildPositionedIconButton(
                top: 50 + _shiftY,
                left: 50 + _shiftX,
                action: GameEditor.cursorRowIncrease,
                iconType: IconType.Arrows_South_Yellow,
                  hint: "Arrow Down"
              ),
              buildPositionedIconButton(
                  top: -10 + _shiftY,
                  left: 27 + _shiftX,
                  action: GameEditor.cursorZIncrease,
                  iconType: IconType.Arrows_Up_Yellow,
                  hint: "Shift + Arrow Up"
              ),
              buildPositionedIconButton(
                  top: 50 + _shiftY,
                  left: 0 + _shiftX,
                  action: GameEditor.cursorColumnIncrease,
                  iconType: IconType.Arrows_West_Yellow,
                  hint: "Arrow Left"
              ),
            ],
          ),
        ),
      ],
    ),
  );

Widget buildPositionedIconButton({
  required double top,
  required double left,
  required Function action,
  required int iconType,
  required String hint,
}) =>
  Positioned(
    top: top,
    left: left,
    child: onPressed(
      action: action,
      child: onMouseOver(builder: (BuildContext context, bool mouseOver) =>
          GameUI.buildAtlasIconType(
            iconType,
            color: mouseOver ? Colors.black38.value : Colors.white.value,
          )
      ),
      hint: hint,
    ),
  );