import 'package:gamestream_flutter/amulet/amulet.dart';
import 'package:gamestream_flutter/amulet/ui/containers/build_container_player_front.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_player.dart';
import 'package:gamestream_flutter/gamestream/sprites/kid_character_sprites.dart';
import 'package:lemon_math/src.dart';

import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/ui.dart';
import 'package:gamestream_flutter/packages/common.dart';
import 'package:golden_ratio/constants.dart';
import 'package:lemon_engine/lemon_engine.dart';
import 'package:lemon_widgets/lemon_widgets.dart';

import '../functions/render_sprite.dart';

Widget buildDialogCreateCharacterComputer(Amulet amulet, {double width = 650}) {
  final engine = amulet.engine;
  final player = amulet.player;
  final randomName = 'Anon${randomInt(99999, 999999)}';
  final nameController = TextEditingController(text: randomName);
  final textSelection = TextSelection(baseOffset: 0, extentOffset: randomName.length);
  nameController.selection = textSelection;
  engine.disableKeyEventHandler();

  return OnDisposed(
    action: engine.enableKeyEventHandler,
    child: GSContainer(
        width: width,
        height: width * goldenRatio_1381,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildContainerPlayerFront(
                player: player,
                nameController: nameController,
                height: 180,
            ),
            height32,
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnComplexion(player),
                    buildColumnHairStyle(player),
                    buildColumnHairColor(player),
                    buildColumnBodyShape(player),
                    buildColumnHeadType(player),
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



Widget buildColumnHeadType(IsometricPlayer player) =>
  buildWatch(player.headType, (playerHeadTye) => buildColumn(
        title: 'HEAD SHAPE',
        children: HeadType.values.map((headShape) =>
            onPressed(
              action: () => player.setHeadType(headShape),
              child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 80,
                  height: 80 * goldenRatio_0618,
                  alignment: Alignment.center,
                  color: headShape == playerHeadTye ? Colors.white24 : Colors.transparent,
                  padding: const EdgeInsets.all(4),
                  child: buildText(HeadType.getName(headShape))),
            ))
    ));


Widget buildStartButton(Amulet amulet, TextEditingController nameController) => Row(
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
                      size: 48,
                      bold: true,
                      color: amulet.colors.teal_1,
                  ),
              ),
            ],
          );

Widget buildControlName(TextEditingController nameController) =>
    Container(
      width: 150,
      child: TextField(
        cursorColor: Colors.white,
        controller: nameController,
        autofocus: true,
        decoration: InputDecoration(
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent), // Set the desired color here
          ),
          enabledBorder: InputBorder.none,
        ),
        style: TextStyle(
          color: Colors.white,
          fontSize: 25
        ),
      ),
    );

Widget buildColumnBodyShape(IsometricPlayer player) => buildWatch(
    player.gender,
    (playerGender) =>
         buildColumn(
             title: 'BODY SHAPE',
             children: Gender.values.map((gender) =>
             onPressed(
               action: () => player.setGender(gender),
               child: AnimatedContainer(
                   duration: const Duration(milliseconds: 150),
                   width: 80,
                   height: 80 * goldenRatio_0618,
                   alignment: Alignment.center,
                   color: playerGender == gender ? Colors.white24 : Colors.transparent,
                   padding: const EdgeInsets.all(4),
                   child: buildText(gender == Gender.male ? 'Square' : 'Curved'))),
             )
         )
   );

Widget buildColumnHairColor(IsometricPlayer player) =>
    buildWatch(player.hairColor, (playerHairColor) => buildColumn(
        title: 'HAIR COLOR',
        children: [
          buildColorWheel(
            colors: player.colors.palette,
            onPickIndex: player.setHairColor,
            currentIndex: playerHairColor,
          )
        ])
    );

Widget buildColumnHairStyle(IsometricPlayer player) => buildWatch(player.hairType, (playerHairType) => buildColumn(
      title: 'HAIR STYLE',
      children: HairType.values.map((hairType) => onPressed(
        action: () => player.setHairType(hairType),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 80,
          height: 80 * goldenRatio_0618,
          alignment: Alignment.center,
          color: hairType == playerHairType ? Colors.white24 : Colors.transparent,
          padding: const EdgeInsets.all(4),
          child: buildText(HairType.getName(hairType)),
        ),
      ))));


Widget buildColumnComplexion(IsometricPlayer player) =>
    buildWatch(player.complexion, (playerComplexion) => buildColumn(
      title: 'COMPLEXION',
      children: [
        buildColorWheel(
            colors: player.colors.palette,
            onPickColor: player.setComplexion,
            currentIndex: playerComplexion,
        )
      ])
    );

Widget buildColumn({
  required String title,
  required Iterable<Widget> children,
}) => Container(
  child:   Column(
        children: [
          buildText(title, color: Colors.white.withOpacity(0.8)),
          height8,
          Container(
            height: 300,
            constraints: BoxConstraints(
              minWidth: 100,
            ),
            padding: const EdgeInsets.all(8),
            color: Colors.black12,
            child: SingleChildScrollView(
              child: Column(
                children: children.toList(growable: false),
              ),
            ),
          )
        ],
      ),
);

CustomCanvas buildCanvasPlayerCharacter(ValueNotifier<int> canvasFrame,
    IsometricPlayer player, KidCharacterSprites sprites, int row) => CustomCanvas(
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
        final hair = sprites.hairFront[player.hairType.value]
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

Widget buildColorWheel({
  required List<Color> colors,
  Function (Color color)? onPickColor,
  Function (int index)? onPickIndex,
  int? currentIndex,
  double width = 50.0,
}) => Column(
  children: colors.map((color) {
    final active = colors.indexOf(color) == currentIndex;
    final sizedWidth = active ? (width * goldenRatio_1381) : width;
    return onPressed(
      action: () {
        if (onPickColor != null){
          onPickColor(color);
        }
        if (onPickIndex != null){
          onPickIndex(colors.indexOf(color));
        }
      },
      child: AnimatedContainer(
        curve: Curves.easeInOutQuad,
        key: ValueKey(color.value),
        duration: const Duration(milliseconds: 120),
        color: color,
        width: sizedWidth,
        height: sizedWidth * goldenRatio_0618,
        alignment: Alignment.center,
      ),
    );
  }).toList(growable: false),
);
