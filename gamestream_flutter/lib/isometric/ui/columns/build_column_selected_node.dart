
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/games/isometric/game_isometric_ui.dart';
import 'package:gamestream_flutter/gamestream/ui/widgets/mouse_over.dart';
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            watch(gamestream.isometricEngine.editor.nodeSelectedIndex, text),
            onPressed(
              hint: "Delete",
              action: gamestream.isometricEngine.editor.delete,
              child: Container(
                width: 16,
                height: 16,
                child: engine.buildAtlasImageButton(
                  image: GameImages.atlas_icons,
                  srcX: 80,
                  srcY: 96,
                  srcWidth: 16,
                  srcHeight: 16,
                  action: gamestream.isometricEngine.editor.delete,
                ),
              ),
            ),
          ],
        ),
        Container(
          height: 70,
            alignment: Alignment.center,
            child: watch(
                gamestream.isometricEngine.editor.nodeSelectedType,
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
                action: gamestream.isometricEngine.editor.cursorZDecrease,
                iconType: IconType.Arrows_Down,
                hint: "Shift + Arrow Down",
              ),
              buildPositionedIconButton(
                top: 3 + _shiftY,
                left: 3 + _shiftY,
                action: gamestream.isometricEngine.editor.cursorRowDecrease,
                iconType: IconType.Arrows_North,
                hint: "Arrow Up",
              ),
              buildPositionedIconButton(
                top: 5 + _shiftY,
                left: 50 + _shiftX,
                action: gamestream.isometricEngine.editor.cursorColumnDecrease,
                iconType: IconType.Arrows_East,
                hint: "Arrow Right",
              ),
              Container(
                  height: 72,
                  width: 72,
                  alignment: Alignment.center,
                  child: watch(gamestream.isometricEngine.editor.nodeSelectedType, GameIsometricUI.buildAtlasNodeType)
              ),
              buildPositionedIconButton(
                top: 50 + _shiftY,
                left: 50 + _shiftX,
                action: gamestream.isometricEngine.editor.cursorRowIncrease,
                iconType: IconType.Arrows_South,
                  hint: "Arrow Down"
              ),
              buildPositionedIconButton(
                  top: -10 + _shiftY,
                  left: 27 + _shiftX,
                  action: gamestream.isometricEngine.editor.cursorZIncrease,
                  iconType: IconType.Arrows_Up,
                  hint: "Shift + Arrow Up"
              ),
              buildPositionedIconButton(
                  top: 50 + _shiftY,
                  left: 0 + _shiftX,
                  action: gamestream.isometricEngine.editor.cursorColumnIncrease,
                  iconType: IconType.Arrows_West,
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
      child: MouseOver(builder: (bool mouseOver) =>
          GameIsometricUI.buildAtlasIconType(
            iconType,
            color: mouseOver ? Colors.black38.value : Colors.white.value,
          )
      ),
      hint: hint,
    ),
  );