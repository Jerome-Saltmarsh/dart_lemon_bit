import 'package:amulet_flutter/website/typedefs/create_character.dart';
import 'package:flutter/material.dart';
import 'package:amulet_flutter/amulet/ui/functions/build_color_wheel.dart';
import 'package:amulet_flutter/amulet/ui/functions/render_character_front.dart';
import 'package:amulet_flutter/gamestream/isometric/isometric_components.dart';
import 'package:amulet_flutter/gamestream/isometric/ui/widgets/isometric_builder.dart';
import 'package:amulet_flutter/gamestream/isometric/ui/widgets/isometric_icon.dart';
import 'package:amulet_flutter/gamestream/ui.dart';
import 'package:amulet_engine/packages/common.dart';
import 'package:amulet_engine/packages/lemon_math.dart';
import 'package:amulet_flutter/website/enums/website_page.dart';
import 'package:golden_ratio/constants.dart';
import 'package:lemon_engine/lemon_engine.dart';
import 'package:lemon_watch/src.dart';
import 'package:lemon_widgets/lemon_widgets.dart';



class DialogCreateCharacterComputer extends StatelessWidget {

  final CreateCharacter createCharacter;
  final Function onCreated;

  DialogCreateCharacterComputer({
    required this.createCharacter,
    required this.onCreated,
  });

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
    final width = 850.0;
    return IsometricBuilder(
      builder: (context, components) {
        final palette = components.colors.palette;
        complexion.value = palette.length - 1;
        return GSContainer(
            width: width,
            height: width * goldenRatio_0618,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildCharacterCanvas(components),
                height32,
                Column(
                  children: [
                    buildControls(palette),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        buildControlName(),
                        buildButtonStart(components),
                      ],
                    ),
                  ],
                ),
                // Expanded(child: const SizedBox()),

              ],
            ));
      }
    );
  }

  Widget buildButtonStart(
      IsometricComponents components,
  ) =>
      Row(
        children: [
          buildWatch(error, (error) => buildText(error, color: Colors.red)),
          width8,
          onPressed(
            action: () {
              createCharacter(
              name: nameController.text,
              complexion: complexion.value,
              hairType: hairType.value,
              hairColor: hairColor.value,
              gender: gender.value,
              headType: headType.value,
            );
             onCreated();
            },
            child: buildText('START', size: 25, color: Colors.green),
          ),
        ],
      );

  GSKeyEventHandler buildControlName() =>
      GSKeyEventHandler(
        child: Container(
            width: 200,
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

  Widget buildControls(List<Color> palette) => Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildColumnComplexion(palette),
              buildColumnHairStyle(),
              buildColumnHairColor(palette),
              buildColumnBodyShape(),
              buildColumnHeadType(),
            ],
          ),
        ],
      );

  Widget buildCharacterCanvas(IsometricComponents components) {
    final palette = components.colors.palette;
    return onPressed(
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
                          paint: (canvas, size) {

                            renderCharacterFront(
                              canvas: canvas,
                              sprites: components.images.kidCharacterSpritesFrontDiffuse,
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
                              // color: setAlpha(color: components.scene.ambientColor, alpha: 0) ,
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

