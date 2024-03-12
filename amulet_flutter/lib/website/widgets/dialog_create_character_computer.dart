import 'package:amulet_engine/common.dart';
import 'package:amulet_flutter/isometric/builders/build_watch.dart';
import 'package:amulet_flutter/isometric/consts/height.dart';
import 'package:amulet_flutter/isometric/consts/width.dart';
import 'package:amulet_flutter/isometric/enums/icon_type.dart';
import 'package:amulet_flutter/isometric/ui/widgets/gs_container.dart';
import 'package:amulet_flutter/isometric/ui/widgets/gs_key_event_handler.dart';
import 'package:amulet_flutter/isometric/ui/widgets/mouse_over.dart';
import 'package:amulet_flutter/website/typedefs/create_character.dart';
import 'package:flutter/material.dart';
import 'package:amulet_flutter/amulet/ui/functions/build_color_wheel.dart';
import 'package:amulet_flutter/amulet/ui/functions/render_character_sprites.dart';
import 'package:amulet_flutter/isometric/components/isometric_components.dart';
import 'package:amulet_flutter/isometric/ui/widgets/isometric_builder.dart';
import 'package:amulet_flutter/isometric/ui/widgets/isometric_icon.dart';
import 'package:amulet_flutter/website/enums/website_page.dart';
import 'package:golden_ratio/constants.dart';
import 'package:lemon_engine/lemon_engine.dart';
import 'package:lemon_lang/src.dart';
import 'package:lemon_math/src.dart';
import 'package:lemon_watch/src.dart';
import 'package:lemon_widgets/lemon_widgets.dart';

class DialogCreateCharacterComputer extends StatelessWidget {

  final CreateCharacter createCharacter;
  final Function onCreated;

  final buttonHeight = 64.0;
  final widthName = 310.0;
  final nameController = TextEditingController(
      text: 'Anon${randomInt(9999, 99999).toString()}'
  );
  final row = Watch(4);
  final complexion = Watch(0);
  final hairType = Watch(1);
  final hairColor = Watch(0);
  final gender = Watch(Gender.male);
  final headType = Watch(0);
  final error = Watch('');
  final difficulty = Watch(Difficulty.Normal);

  DialogCreateCharacterComputer({
    required this.createCharacter,
    required this.onCreated,
  });

  @override
  Widget build(BuildContext context) => IsometricBuilder(
      builder: (context, components) {
        final palette = components.colors.palette;
        complexion.value = palette.length - 1;
        const width = 700.0;
        return buildBorder(
          color: Colors.black12,
          width: 3,
          child: GSContainer(
              width: width,
              height: width * goldenRatio_0618,
              border: Border.all(color: Colors.black12, width: 3),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildCharacterCanvas(components),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildControls(palette),
                          height8,
                          buildControlName(),
                          height8,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              buildControlDifficulty(),
                              width32,
                              buildButtonStart(),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              )),
        );
      }
    );

  Widget buildControlDifficulty() => onPressed(
       action: toggleDifficulty,
       child: Container(
         alignment: Alignment.center,
         // padding: const EdgeInsets.all(8),
         color: Colors.black12,
         height: buttonHeight,
         width: 150,
         child: buildWatch(difficulty, (difficultyValue) =>
             Row(
               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
               crossAxisAlignment: CrossAxisAlignment.center,
               children: [
                 Container(
                     width: 60,
                     child: buildText(difficultyValue.name)
                 ),
                 width16,
                 Row(
                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                     children: Difficulty.values
                         .map((e) => Container(width: 15, height: 15, color: e == difficultyValue ? Colors.white : Colors.white54,))
                         .toList()
                 )
               ],
             )),
       ),
     );

  void toggleDifficulty(){
     difficulty.value = Difficulty.values.cycle(difficulty.value.index + 1);
  }

  Widget buildButtonStart() =>
      onPressed(
        action: () {
          createCharacter(
            name: nameController.text,
            complexion: complexion.value,
            hairType: hairType.value,
            hairColor: hairColor.value,
            gender: Gender.male,
            headType: headType.value,
            difficulty: difficulty.value,
        );
         onCreated();
        },
        child: Container(
            alignment: Alignment.center,
            width: 100,
            height: buttonHeight,
            color: Colors.green,
            child: buildText('START', size: 34, color: Colors.white),
        ),
      );

  GSKeyEventHandler buildControlName() =>
      GSKeyEventHandler(
        child: Container(
            width: widthName,
            padding: const EdgeInsets.all(8),
            color: Colors.black12,
            child: TextField(
              autofocus: true,
              controller: nameController,
              decoration: InputDecoration(border: InputBorder.none),
              style: TextStyle(
                color: Colors.orange,
                fontSize: 25,
              ),
            )),
      );

  Widget buildControls(List<Color> palette) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      buildColumnComplexion(palette),
      width4,
      buildColumnHairStyle(),
      width4,
      buildColumnHairColor(palette),
    ],
  );

  Widget buildCharacterCanvas(IsometricComponents components) {
    final palette = components.colors.palette;
    const width = 275.0;
    return onPressed(
                action: (){
                  row.value = (row.value + 1) % 8;
                },
                child: Container(
                  width: width,
                  height: width * goldenRatio_1381,
                  alignment: Alignment.center,
                  color: Colors.black12,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        top: 180,
                        child: CustomCanvas(
                          paint: (canvas, size) {

                            renderCharacterSprites(
                              canvas: canvas,
                              sprites: components.images.kidCharacterSpritesIsometricDiffuse,
                              row: row.value,
                              column: 0,
                              characterState: CharacterState.Idle,
                              gender: gender.value,
                              helmType: 0,
                              headType: headType.value,
                              armorType: ArmorType.Tunic,
                              shoeType: ShoeType.Leather_Boots,
                              hairType: hairType.value,
                              weaponType: 0,
                              skinColor: palette[complexion.value].value,
                              hairColor: palette[hairColor.value].value,
                              color: 0,
                            );
                          },
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
              );
  }

  Widget buildBackButton(IsometricComponents components) => onPressed(
        action: () => components.website.websitePage.value = WebsitePage.Select_Character,
        child: buildText('Back'),
      );

  Widget buildColumnHeadType() =>
      buildWatch(headType, (activeHeadType) => buildColumn(
          title: 'HEAD',
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


  Widget buildColumnBodyShape() =>
      buildWatch(gender, (activeGender) =>
          buildColumn(
              title: 'BODY',
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

  Widget buildColumnHairColor(List<Color> palette) =>
      buildWatch(hairColor, (activeHairColor) => buildColumn(
          title: 'HAIR-COLOR',
          children: [
            buildColorWheel(
              colors: palette,
              onPickIndex: hairColor.call,
              currentIndex: activeHairColor,
            )
          ])
      );

  Widget buildColumnHairStyle() =>
      buildWatch(hairType, (activeHairType) => buildColumn(
          title: 'HAIR-STYLE',
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


  Widget buildColumnComplexion(List<Color> palette) =>
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
}

