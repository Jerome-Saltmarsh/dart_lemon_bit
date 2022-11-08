
import 'package:flutter/material.dart';
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
              buildPositionedIconArrow(
                top: 65 + _shiftY,
                left: 27 + _shiftX,
                action: GameEditor.cursorZDecrease,
                iconType: IconType.Arrows_Down_Yellow,
                iconTypeMouseOver: IconType.Arrows_Down_Orange,
                hint: "Shift + Arrow Down",
              ),
              buildPositionedIconArrow(
                top: 3 + _shiftY,
                left: 3 + _shiftY,
                action: GameEditor.cursorRowDecrease,
                iconType: IconType.Arrows_North_Yellow,
                iconTypeMouseOver: IconType.Arrows_North_Orange,
                hint: "Arrow Up",
              ),
              // Positioned(
              //   top: 3 + _shiftY,
              //   left: 3 + _shiftY,
              //   child: onMouseOver(builder: (BuildContext context, bool mouseOver) => Engine.buildAtlasImageButton(
              //       image: GameImages.atlasIcons,
              //     action: GameEditor.cursorRowDecrease,
              //     srcX: mouseOver ? AtlasIconsX.Arrows_Orange : AtlasIconsX.Arrows_Yellow,
              //     srcY: AtlasIconsY.Arrows_North,
              //     srcWidth: 21,
              //     srcHeight: 21,
              //     hint: "Arrow Up"
              //   ),
              // )),
              buildPositionedIconArrow(
                top: 5 + _shiftY,
                left: 50 + _shiftX,
                action: GameEditor.cursorColumnDecrease,
                iconType: IconType.Arrows_East_Yellow,
                iconTypeMouseOver: IconType.Arrows_East_Orange,
                hint: "Arrow Right",
              ),
              // Positioned(
              //   top: 5 + _shiftY,
              //   left: 50 + _shiftX,
              //   child: onMouseOver(builder: (BuildContext context, bool mouseOver) => Engine.buildAtlasImageButton(
              //       image: GameImages.atlasIcons,
              //       action: GameEditor.cursorColumnDecrease,
              //       srcX: mouseOver ? AtlasIconsX.Arrows_Orange : AtlasIconsX.Arrows_Yellow,
              //       srcY: AtlasIconsY.Arrows_East,
              //       srcWidth: 21,
              //       srcHeight: 21,
              //       hint: "Arrow Right"
              //   ),
              // )),
              Container(
                  height: 72,
                  width: 72,
                  alignment: Alignment.center,
                  child: watch(GameEditor.nodeSelectedType, EditorUI.buildIconNodeType)
              ),
              buildPositionedIconArrow(
                top: 50 + _shiftY,
                left: 50 + _shiftX,
                action: GameEditor.cursorRowIncrease,
                iconType: IconType.Arrows_South_Yellow,
                iconTypeMouseOver: IconType.Arrows_South_Orange,
                  hint: "Arrow Down"
              ),
              // Positioned(
              //   top: 50 + _shiftY,
              //   left: 50 + _shiftX,
              //   child: onMouseOver(builder: (BuildContext context, bool mouseOver) => Engine.buildAtlasImageButton(
              //       image: GameImages.atlasIcons,
              //     action: GameEditor.cursorRowIncrease,
              //     srcX: mouseOver ? AtlasIconsX.Arrows_Orange : AtlasIconsX.Arrows_Yellow,
              //     srcY: AtlasIconsY.Arrows_South,
              //     srcWidth: 21,
              //     srcHeight: 21,
              //     hint: "Arrow Down"
              //   )),
              // ),
              buildPositionedIconArrow(
                  top: -10 + _shiftY,
                  left: 27 + _shiftX,
                  action: GameEditor.cursorZIncrease,
                  iconType: IconType.Arrows_Up_Yellow,
                  iconTypeMouseOver: IconType.Arrows_Up_Orange,
                  hint: "Arrow Down"
              ),
              // Positioned(
              //   top: -10 + _shiftY,
              //   left: 27 + _shiftX,
              //   child: onPressed(
              //     action: GameEditor.cursorZIncrease,
              //     child: onMouseOver(builder: (BuildContext context, bool mouseOver) => GameUI.buildAtlasIcon(
              //       mouseOver ? IconType.Arrows_Orange : IconType.Arrows_Yellow
              //     )),
              //     hint: "Shift + Arrow Up",
              //   ),
              //   // child: onMouseOver(builder: (BuildContext context, bool mouseOver) => GameUI.buildAtlasIcon(
              //   //     image: GameImages.atlasIcons,
              //   //     action: GameEditor.cursorZIncrease,
              //   //     srcX: mouseOver ? AtlasIcons.getSrcX(IconType.Arrows_Orange).Arrows_Orange : AtlasIconsX.Arrows_Yellow,
              //   //     srcY: AtlasIconsY.Arrows_Up,
              //   //     srcWidth: 21,
              //   //     srcHeight: 21,
              //   //     hint: "Shift + Arrow Up"
              //   // )),
              // ),
              Positioned(
                top: 50 + _shiftY,
                left: 0 + _shiftX,
                child: onPressed(
                  action: GameEditor.cursorZIncrease,
                  child: onMouseOver(builder: (BuildContext context, bool mouseOver) => GameUI.buildAtlasIcon(
                      mouseOver ? IconType.Arrows_West_Orange : IconType.Arrows_West_Yellow
                  )),
                  hint: "Arrow Left",
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

Widget buildPositionedIconArrow({
  required double top,
  required double left,
  required Function action,
  required int iconType,
  required int iconTypeMouseOver,
  required String hint,
}) =>
  Positioned(
    top: top,
    left: left,
    child: onPressed(
      action: action,
      child: onMouseOver(builder: (BuildContext context, bool mouseOver) => GameUI.buildAtlasIcon(
          mouseOver ? iconTypeMouseOver : iconType
      )),
      hint: hint,
    ),
  );