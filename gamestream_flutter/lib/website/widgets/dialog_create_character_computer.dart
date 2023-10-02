import 'package:gamestream_flutter/amulet/ui/functions/render_canvas_character_sprites.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_player.dart';
import 'package:gamestream_flutter/gamestream/isometric/ui/widgets/isometric_builder.dart';
import 'package:gamestream_flutter/gamestream/isometric/ui/widgets/isometric_icon.dart';
import 'package:gamestream_flutter/gamestream/sprites/kid_character_sprites.dart';
import 'package:gamestream_flutter/website/enums/website_page.dart';
import 'package:lemon_math/src.dart';

import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/ui.dart';
import 'package:gamestream_flutter/packages/common.dart';
import 'package:golden_ratio/constants.dart';
import 'package:lemon_engine/lemon_engine.dart';
import 'package:lemon_widgets/lemon_widgets.dart';
import 'package:user_service_client/src.dart';

import '../../amulet/ui/functions/render_canvas_sprite.dart';
import 'package:lemon_watch/src.dart';


typedef OnStart = Function({required int complex});

class DialogCreateCharacterComputer extends StatelessWidget {

  final nameController = TextEditingController(
      text: 'Anon${randomInt(9999, 99999).toString()}'
  );
  final row = Watch(0);
  final complexion = Watch(0);
  final hairType = Watch(0);
  final hairColor = Watch(0);
  final gender = Watch(0);
  final headType = Watch(0);
  final error = Watch('');

  @override
  Widget build(BuildContext context) {
    final width = 550.0;
    final randomName = 'Anon${randomInt(99999, 999999)}';
    final nameController = TextEditingController(text: randomName);
    final textSelection = TextSelection(baseOffset: 0, extentOffset: randomName.length);
    nameController.selection = textSelection;
    return IsometricBuilder(
      builder: (context, components) {
        final palette = components.colors.palette;

        return GSContainer(
            width: width,
            height: width * goldenRatio_1381,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                onPressed(
                  action: () {
                    components.website.websitePage.value = WebsitePage.User;
                  },
                  child: buildText('Back'),
                ),
                Center(
                  child: onPressed(
                    action: (){
                      row.value = (row.value + 1) % 8;
                    },
                    child: Container(
                      width: 130,
                      height: 130 * goldenRatio_1381,
                      alignment: Alignment.center,
                      color: Colors.black12,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            top: 100,
                            child: CustomCanvas(
                              paint: (canvas, size) =>
                                renderCanvasCharacterSprites(
                                  canvas: canvas,
                                  sprites: components.images.kidCharacterSpritesFront,
                                  row: row.value,
                                  column: 0,
                                  characterState: CharacterState.Idle,
                                  gender: gender.value,
                                  helmType: 0,
                                  headType: headType.value,
                                  bodyType: BodyType.Leather_Armour,
                                  shoeType: ShoeType.Leather_Boots,
                                  legsType: LegType.Leather,
                                  hairType: hairType.value,
                                  weaponType: 0,
                                  skinColor: palette[complexion.value].value,
                                  hairColor: palette[hairColor.value].value,
                                ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: MouseOver(builder: (mouseOver) => IsometricIcon(
                              iconType: IconType.Turn_Right,
                              scale: 0.2,
                              color: mouseOver ? Colors.green.value : Colors.white38.value,
                            )),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                height32,
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnComplexion(complexion, palette),
                        buildColumnHairStyle(hairType),
                        buildColumnHairColor(hairColor, palette),
                        buildColumnBodyShape(gender),
                        buildColumnHeadType(headType),
                      ],
                    ),
                  ],
                ),
                Expanded(child: const SizedBox()),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GSKeyEventHandler(
                      child: Container(
                          width: 200,
                          padding: const EdgeInsets.all(8),
                          color: Colors.black12,
                          child: TextField(
                            autofocus: true,
                            controller: nameController,
                            decoration: InputDecoration(
                              border: InputBorder.none
                            ),
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 25,
                            ),
                          )
                      ),
                    ),
                    Row(
                      children: [
                        buildWatch(error, (error) => buildText(error, color: Colors.red)),
                        width8,
                        onPressed(
                          action: () {
                            UserServiceClient.createCharacter(
                              url: components.user.userServiceUrl.value,
                              userId: components.user.userId.value,
                              password: components.user.password.value,
                              name: nameController.text,
                              complexion: complexion.value,
                              hairType: hairType.value,
                              hairColor: hairColor.value,
                              gender: gender.value,
                              headType: headType.value,
                            ).then((response) {
                              if (response.statusCode == 200){
                                components.user.playCharacter(response.body);
                                return;
                              }
                              error.value = response.body;
                            });
                          },
                          child: buildText('START', size: 25, color: Colors.green),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ));
      }
    );
  }
}

Widget buildColumnHeadType(Watch<int> headType) =>
  buildWatch(headType, (activeHeadType) => buildColumn(
        title: 'HEAD SHAPE',
        children: HeadType.values.map((value) =>
            onPressed(
              action: () => headType.value = value,
              child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 80,
                  height: 80 * goldenRatio_0618,
                  alignment: Alignment.center,
                  color: value == activeHeadType ? Colors.white24 : Colors.transparent,
                  padding: const EdgeInsets.all(4),
                  child: buildText(HeadType.getName(value))),
            ))
    ));


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

Widget buildColumnBodyShape(Watch<int> gender) =>
    buildWatch(gender, (activeGender) =>
      buildColumn(
        title: 'BODY SHAPE',
        children: Gender.values.map(
          (value) => onPressed(
              action: () => gender.value = value,
              child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 80,
                  height: 80 * goldenRatio_0618,
                  alignment: Alignment.center,
                  color: activeGender == value
                      ? Colors.white24
                      : Colors.transparent,
                  padding: const EdgeInsets.all(4),
                  child:
                      buildText(value == Gender.male ? 'Square' : 'Curved'))),
        )));

Widget buildColumnHairColor(Watch<int> hairColor, List<Color> palette) =>
    buildWatch(hairColor, (activeHairColor) => buildColumn(
        title: 'HAIR COLOR',
        children: [
          buildColorWheel(
            colors: palette,
            onPickIndex: hairColor.call,
            currentIndex: activeHairColor,
          )
        ])
    );

Widget buildColumnHairStyle(Watch<int> hairType) =>
    buildWatch(hairType, (activeHairType) => buildColumn(
      title: 'HAIR STYLE',
      children: HairType.values.map((type) => onPressed(
        action: () => hairType.value = type,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 80,
          height: 80 * goldenRatio_0618,
          alignment: Alignment.center,
          color: type == activeHairType ? Colors.white24 : Colors.transparent,
          padding: const EdgeInsets.all(4),
          child: buildText(HairType.getName(type)),
        ),
      ))));


Widget buildColumnComplexion(Watch<int> complexion, List<Color> palette) =>
    buildWatch(complexion, (activeComplexion) => buildColumn(
      title: 'COMPLEXION',
      children: [
        buildColorWheel(
            colors: palette,
            onPickIndex: complexion.call,
            currentIndex: activeComplexion,
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
            height: 200,
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

        renderCanvasSprite(
            sprite: torso,
            canvas: canvas,
            row: row,
            column: column,
            color: skinColor);
        renderCanvasSprite(sprite: legs, canvas: canvas, row: row, column: column);
        renderCanvasSprite(
            sprite: armsLeft,
            canvas: canvas,
            row: row,
            column: column,
            color: skinColor);
        renderCanvasSprite(
            sprite: armsRight,
            canvas: canvas,
            row: row,
            column: column,
            color: skinColor);
        renderCanvasSprite(
            sprite: shoesLeft, canvas: canvas, row: row, column: column);
        renderCanvasSprite(
            sprite: shoesRight, canvas: canvas, row: row, column: column);
        renderCanvasSprite(sprite: body, canvas: canvas, row: row, column: column);
        renderCanvasSprite(
            sprite: head,
            canvas: canvas,
            row: row,
            column: column,
            color: skinColor);
        renderCanvasSprite(
            sprite: hair,
            canvas: canvas,
            row: row,
            column: column,
            color: hairColor);
        renderCanvasSprite(sprite: helm, canvas: canvas, row: row, column: column);
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
