import 'package:gamestream_flutter/amulet/amulet.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_player.dart';
import 'package:gamestream_flutter/gamestream/sprites/kid_character_sprites.dart';
import 'package:lemon_math/src.dart';
import 'package:lemon_watch/src.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/ui.dart';
import 'package:gamestream_flutter/packages/common.dart';
import 'package:golden_ratio/constants.dart';
import 'package:lemon_engine/lemon_engine.dart';
import 'package:lemon_widgets/lemon_widgets.dart';

import 'render_sprite.dart';

Widget buildDialogCreateCharacterComputer(Amulet amulet, {double width = 600}) {
  var row = 0;

  final spinning = WatchBool(true);
  final engine = amulet.engine;
  final images = amulet.images;
  final player = amulet.player;
  final sprites = images.kidCharacterSprites;
  final nameController = TextEditingController(text: 'Anon${randomInt(99999, 999999)}');
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
        width: width,
        height: width * goldenRatio_1381,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  onPressed(
                    action: () {
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
                    action: () {
                      spinning.setFalse();
                      row = (row + 1) % 8;
                    },
                    child: buildText('->'),
                  ),
                ],
              ),
            ),
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
                      final helm = sprites.helm[player.helmType.value]
                          ?.fromCharacterState(characterState);
                      final head = sprites.head[gender]?.fromCharacterState(characterState);
                      final bodySprite = isMale ? sprites.bodyMale : sprites.bodyFemale;
                      final body = bodySprite[player.bodyType.value]
                          ?.fromCharacterState(characterState);
                      final torso = sprites.torso[gender]?.fromCharacterState(characterState);
                      final armsLeft = sprites.armLeft[ArmType.regular]
                          ?.fromCharacterState(characterState);
                      final armsRight = sprites.armRight[ArmType.regular]
                          ?.fromCharacterState(characterState);
                      final shoesLeft = sprites.shoesLeft[player.shoeType.value]
                          ?.fromCharacterState(characterState);
                      final shoesRight = sprites.shoesRight[player.shoeType.value]
                          ?.fromCharacterState(characterState);
                      final legs = sprites.legs[player.legsType.value]
                          ?.fromCharacterState(characterState);
                      final hair = sprites.hair[player.hairType.value]
                          ?.fromCharacterState(characterState);
                      final skinColor = player.skinColor.value;
                      final hairColor = player.colors.palette[player.hairColor.value].value;

                      renderSprite(
                          sprite: torso,
                          canvas: canvas,
                          row: row,
                          column: column,
                          color: skinColor);
                      renderSprite(sprite: legs, canvas: canvas, row: row, column: column);
                      renderSprite(
                          sprite: armsLeft,
                          canvas: canvas,
                          row: row,
                          column: column,
                          color: skinColor);
                      renderSprite(
                          sprite: armsRight,
                          canvas: canvas,
                          row: row,
                          column: column,
                          color: skinColor);
                      renderSprite(
                          sprite: shoesLeft, canvas: canvas, row: row, column: column);
                      renderSprite(
                          sprite: shoesRight, canvas: canvas, row: row, column: column);
                      renderSprite(sprite: body, canvas: canvas, row: row, column: column);
                      renderSprite(
                          sprite: head,
                          canvas: canvas,
                          row: row,
                          column: column,
                          color: skinColor);
                      renderSprite(
                          sprite: hair,
                          canvas: canvas,
                          row: row,
                          column: column,
                          color: hairColor);
                      renderSprite(sprite: helm, canvas: canvas, row: row, column: column);
                    }),
              ),
            ),
            Column(
              children: [
                buildControlName(nameController),
                height8,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnComplexion(player),
                    buildColumnHairStyle(player),
                    buildColumnHairColor(player),
                    buildColumnBodyShape(player),
                  ],
                ),
              ],
            ),
            Expanded(child: const SizedBox()),
            buildStartButton(amulet, nameController),
          ],
        )),
  );
}

Row buildStartButton(Amulet amulet, TextEditingController nameController) {
  return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(),
              onPressed(
                  action: () {
                    amulet.createPlayer(
                      name: nameController.text,
                    );
                  },
                  child: buildText('START',
                      size: 32, bold: true, color: Colors.green)
              ),
            ],
          );
}

Row buildControlName(TextEditingController nameController) {
  return Row(
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
              );
}

Widget buildColumnBodyShape(IsometricPlayer player) => buildWatch(
    player.gender,
    (gender) =>
         buildColumn(
             title: 'BODY TYPE',
             children: Gender.values.map((gender) =>
             buildText(gender == Gender.male ? 'SQUARE' : 'CURVED'))
         )
   );

Widget buildColumnHairColor(IsometricPlayer player) => buildColumn(
      title: 'HAIR COLOR',
      children: player.colors.palette.map((color) => Container(
            color: color,
            width: 50,
            height: 50 * goldenRatio_0618,
          )),
    );

Widget buildColumnHairStyle(IsometricPlayer player) => buildWatch(player.hairType, (playerHairType) => buildColumn(
      title: 'HAIR STYLE',
      children: HairType.values.map((hairType) => onPressed(
        action: () => player.setHairType(hairType),
        child: Container(
          color: hairType == playerHairType ? Colors.green : Colors.transparent,
          padding: const EdgeInsets.all(4),
          child: buildText(HairType.getName(hairType)),
        ),
      ))));

Widget buildColumnComplexion(IsometricPlayer player) =>
    buildWatch(player.complexion, (playerComplexion) => buildColumn(
      title: 'COMPLEXION',
      children: player.colors.palette.map((color) => onPressed(
        action: () => player.setComplexion(color),
        child: buildBorder(
          color: playerComplexion == player.colors.palette.indexOf(color) ? Colors.black : color,
          width: 2,
          radius: BorderRadius.zero,
          child: Container(
            color: color,
            width: 50,
            height: 50 * goldenRatio_0618,
          ),
        ),
      )))
    );

Column buildColumn({
  required String title,
  required Iterable<Widget> children,
}) => Column(
      children: [
        buildText(title),
        height8,
        Container(
          height: 300,
          child: SingleChildScrollView(
            child: Column(
              children: children.toList(growable: false),
            ),
          ),
        )
      ],
    );

CustomCanvas buildCanvasPlayerCharacter(ValueNotifier<int> canvasFrame,
    IsometricPlayer player, KidCharacterSprites sprites, int row) {
  return CustomCanvas(
      frame: canvasFrame,
      paint: (canvas, size) {
        final column = 0;
        final gender = player.gender.value;
        final isMale = gender == Gender.male;
        final characterState = CharacterState.Idle;
        final helm = sprites.helm[player.helmType.value]
            ?.fromCharacterState(characterState);
        final head = sprites.head[gender]?.fromCharacterState(characterState);
        final bodySprite = isMale ? sprites.bodyMale : sprites.bodyFemale;
        final body = bodySprite[player.bodyType.value]
            ?.fromCharacterState(characterState);
        final torso = sprites.torso[gender]?.fromCharacterState(characterState);
        final armsLeft = sprites.armLeft[ArmType.regular]
            ?.fromCharacterState(characterState);
        final armsRight = sprites.armRight[ArmType.regular]
            ?.fromCharacterState(characterState);
        final shoesLeft = sprites.shoesLeft[player.shoeType.value]
            ?.fromCharacterState(characterState);
        final shoesRight = sprites.shoesRight[player.shoeType.value]
            ?.fromCharacterState(characterState);
        final legs = sprites.legs[player.legsType.value]
            ?.fromCharacterState(characterState);
        final hair = sprites.hair[player.hairType.value]
            ?.fromCharacterState(characterState);
        final skinColor = player.skinColor.value;
        final hairColor = player.colors.palette[player.hairColor.value].value;

        renderSprite(
            sprite: torso,
            canvas: canvas,
            row: row,
            column: column,
            color: skinColor);
        renderSprite(sprite: legs, canvas: canvas, row: row, column: column);
        renderSprite(
            sprite: armsLeft,
            canvas: canvas,
            row: row,
            column: column,
            color: skinColor);
        renderSprite(
            sprite: armsRight,
            canvas: canvas,
            row: row,
            column: column,
            color: skinColor);
        renderSprite(
            sprite: shoesLeft, canvas: canvas, row: row, column: column);
        renderSprite(
            sprite: shoesRight, canvas: canvas, row: row, column: column);
        renderSprite(sprite: body, canvas: canvas, row: row, column: column);
        renderSprite(
            sprite: head,
            canvas: canvas,
            row: row,
            column: column,
            color: skinColor);
        renderSprite(
            sprite: hair,
            canvas: canvas,
            row: row,
            column: column,
            color: hairColor);
        renderSprite(sprite: helm, canvas: canvas, row: row, column: column);
      });
}
