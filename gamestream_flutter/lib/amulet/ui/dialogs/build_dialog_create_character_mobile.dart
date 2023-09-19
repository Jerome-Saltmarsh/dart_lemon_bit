import 'package:gamestream_flutter/amulet/amulet.dart';
import 'package:lemon_watch/src.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/ui.dart';
import 'package:gamestream_flutter/packages/common.dart';
import 'package:golden_ratio/constants.dart';
import 'package:lemon_engine/lemon_engine.dart';
import 'package:lemon_widgets/lemon_widgets.dart';

import '../functions/render_canvas_sprite.dart';


Widget buildDialogCreateCharacterMobile(Amulet amulet){
  var row = 0;

  final spinning = WatchBool(true);
  final engine = amulet.engine;
  final images = amulet.images;
  final player = amulet.player;
  final sprites = images.kidCharacterSpritesIsometric;
  final nameController = TextEditingController();
  final canvasFrame = ValueNotifier(0);
  final canvasTimer = Timer.periodic(Duration(milliseconds: 50), (timer) {
    if (!spinning.value) {
      return;
    }
    if (canvasFrame.value++ % 3 == 0) {
      row = (row + 1) % 8;
    }
    ;
  });

  engine.disableKeyEventHandler();

  return OnDisposed(
    action: () {
      engine.enableKeyEventHandler();
      canvasTimer.cancel();
    },
    child: GSContainer(
        width: 300,
        height: 300 * goldenRatio_1381,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildBorder(
              width: 2,
              color: Colors.black26,
              child: Container(
                height: 150,
                alignment: Alignment.center,
                color: Colors.black12,
                child: CustomCanvas(
                    frame: canvasFrame,
                    paint: (canvas, size) {
                      final column = 0;
                      final gender = player.gender.value;
                      final isMale = gender == Gender.male;
                      final characterState = CharacterState.Idle;
                      final helm = sprites.helm[player.helmType.value]?.fromCharacterState(characterState);
                      final head = sprites.head[gender]?.fromCharacterState(characterState);
                      final bodySprite = isMale ? sprites.bodyMale : sprites.bodyFemale;
                      final body = bodySprite[player.bodyType.value]?.fromCharacterState(characterState);
                      final torso = sprites.torso[gender]?.fromCharacterState(characterState);
                      final armsLeft = sprites.armLeft[ArmType.regular]?.fromCharacterState(characterState);
                      final armsRight = sprites.armRight[ArmType.regular]?.fromCharacterState(characterState);
                      final shoesLeft = sprites.shoesLeft[player.shoeType.value]?.fromCharacterState(characterState);
                      final shoesRight = sprites.shoesRight[player.shoeType.value]?.fromCharacterState(characterState);
                      final legs = sprites.legs[player.legsType.value]?.fromCharacterState(characterState);
                      final hair = sprites.hairFront[player.hairType.value]?.fromCharacterState(characterState);
                      final skinColor = player.skinColor.value;
                      final hairColor = player.colors.palette[player.hairColor.value].value;

                      renderCanvasSprite(sprite: torso, canvas: canvas, row: row, column: column, color: skinColor);
                      renderCanvasSprite(sprite: legs, canvas: canvas, row: row, column: column);
                      renderCanvasSprite(sprite: armsLeft, canvas: canvas, row: row, column: column, color: skinColor);
                      renderCanvasSprite(sprite: armsRight, canvas: canvas, row: row, column: column, color: skinColor);
                      renderCanvasSprite(sprite: shoesLeft, canvas: canvas, row: row, column: column);
                      renderCanvasSprite(sprite: shoesRight, canvas: canvas, row: row, column: column);
                      renderCanvasSprite(sprite: body, canvas: canvas, row: row, column: column);
                      renderCanvasSprite(sprite: head, canvas: canvas, row: row, column: column, color: skinColor);
                      renderCanvasSprite(sprite: hair, canvas: canvas, row: row, column: column, color: hairColor);
                      renderCanvasSprite(sprite: helm, canvas: canvas, row: row, column: column);
                    }
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  onPressed(
                    action: (){
                      spinning.setFalse();
                      row = (row - 1) % 8;
                    },
                    child: buildText('<-'),
                  ),
                  Container(
                    width: 80,
                    alignment: Alignment.center,
                    child: onPressed(
                      action: spinning.toggle,
                      child: buildWatch(
                        spinning,
                            (t) => buildText(t ? 'PAUSE' : 'RESUME'),
                      ),
                    ),
                  ),
                  onPressed(
                    action: (){
                      spinning.setFalse();
                      row = (row + 1) % 8;
                    },
                    child: buildText('->'),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildText('NAME'),
                    Container(
                      width: 150,
                      child: TextField(
                        controller: nameController,
                        autofocus: true,
                      ),
                    ),
                  ],
                ),
                height4,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildText('COMPLEXION'),
                    onPressed(
                      action: player.showDialogChangeComplexion,
                      child: buildWatch(player.complexion, (complexion) => Container(
                        width: 50,
                        height: 50,
                        color: player.colors.palette[complexion],
                      )),
                    )
                  ],
                ),
                height4,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildText('HAIR STYLE'),
                    onPressed(
                      action: player.showDialogChangeHairType,
                      child: buildWatch(
                        player.hairType,
                            (hairType) => buildText(HairType.getName(hairType)),
                      ),
                    ),
                  ],
                ),
                height4,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildText('HAIR COLOR'),
                    onPressed(
                      action: player.showDialogChangeHairColor,
                      child: buildWatch(player.hairColor, (hairColor) => Container(
                        width: 50,
                        height: 50,
                        color: player.colors.palette[hairColor],
                      )),
                    )
                  ],
                ),
                height4,
                buildWatch(player.gender, (gender) => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      buildText('BODY'),
                      Row(children: [
                        onPressed(
                          action: player.toggleGender,
                          child: buildBorder(
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              color: gender == Gender.male ? Colors.white38 : null,
                              child: buildText('Square'),
                            ),
                          ),
                        ),
                        onPressed(
                          action: player.toggleGender,
                          child: buildBorder(
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              color: gender == Gender.female ? Colors.white38 : null,
                              child: buildText('Curvy'),
                            ),
                          ),
                        ),
                      ]),
                    ])),
              ],
            ),
            Expanded(child: const SizedBox()),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(),
                onPressed(
                    action: () {
                      amulet.createPlayer(
                        name: nameController.text,
                      );
                    },
                    child: buildText('START', size: 24, bold: true, color: Colors.green)
                ),
              ],
            ),
          ],
        )),
  );
}

