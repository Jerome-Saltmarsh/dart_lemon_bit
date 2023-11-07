
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/amulet/ui/functions/render_canvas_isometric_player.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_player.dart';
import 'package:gamestream_flutter/gamestream/isometric/ui/isometric_colors.dart';
import 'package:gamestream_flutter/gamestream/isometric/ui/widgets/isometric_icon.dart';
import 'package:gamestream_flutter/gamestream/ui/enums/icon_type.dart';
import 'package:gamestream_flutter/gamestream/ui/widgets/mouse_over.dart';
import 'package:gamestream_flutter/packages/common/src/isometric/character_state.dart';
import 'package:gamestream_flutter/website/widgets/dialog_create_character_computer.dart';
import 'package:lemon_engine/lemon_engine.dart';
import 'package:lemon_widgets/lemon_widgets.dart';

Widget buildContainerPlayerFront({
  required IsometricPlayer player,
  TextEditingController? nameController,
  double height = 150,
  Color borderColor = Colors.white,
  double borderWidth = 1,
}) {
  var row = 4;
  var column = 0;
  return onPressed(
    action: () => row = (row + 1) % 8,
    child: buildBorder(
      width: borderWidth,
      color: borderColor,
      child: Container(
        height: height,
        alignment: Alignment.center,
        color: Colors.black12,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 100,
              child: CustomCanvas(
                  paint: (canvas, size) {
                    renderCanvasIsometricPlayer(
                        player: player,
                        canvas: canvas,
                        row: row,
                        column: column,
                        sprites: player.images.kidCharacterSpritesFrontSouth,
                        characterState: CharacterState.Idle,
                        color: player.scene.colorSouth(player.nodeIndex)
                    );
                    renderCanvasIsometricPlayer(
                        player: player,
                        canvas: canvas,
                        row: row,
                        column: column,
                        sprites: player.images.kidCharacterSpritesFrontWest,
                        characterState: CharacterState.Idle,
                        color: player.scene.colorWest(player.nodeIndex)
                    );

                  }
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: MouseOver(builder: (mouseOver) => IsometricIcon(
                iconType: IconType.Turn_Right,
                scale: 0.2,
                color: mouseOver ? Colors.green.value : Colors.white38.value,
              ),),
            ),
            if (nameController != null)
              Positioned(
                top: 0,
                left: 8,
                child: buildControlName(nameController),
              )
          ],
        ),
      ),
    ),
  );
}
