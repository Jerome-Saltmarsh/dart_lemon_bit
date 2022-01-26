
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:bleed_client/classes/Weapon.dart';
import 'package:bleed_client/common/CharacterAction.dart';
import 'package:bleed_client/common/CharacterType.dart';
import 'package:bleed_client/common/GameType.dart';
import 'package:bleed_client/common/WeaponType.dart';
import 'package:bleed_client/constants/colours.dart';
import 'package:bleed_client/cube/camera3d.dart';
import 'package:bleed_client/debug.dart';
import 'package:bleed_client/flutterkit.dart';
import 'package:bleed_client/input.dart';
import 'package:bleed_client/mappers/mapWeaponToDecorationImage.dart';
import 'package:bleed_client/modules.dart';
import 'package:bleed_client/send.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/styles.dart';
import 'package:bleed_client/ui/state/decorationImages.dart';
import 'package:bleed_client/ui/state/hud.dart';
import 'package:bleed_client/ui/state/styleguide.dart';
import 'package:bleed_client/ui/ui.dart';
import 'package:bleed_client/utils/widget_utils.dart';
import 'package:flutter/material.dart';
import 'package:golden_ratio/constants.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_math/golden_ratio.dart';
import 'package:lemon_watch/watch_builder.dart';

import '../widgets.dart';

const double _padding = 8;
final emptyContainer = Container();

Widget buildTopLeft() {
  return Positioned(
      top: _padding,
      left: _padding,
      child: Column(
        crossAxisAlignment: axis.cross.start,
        children: [
          Row(
            children: [
              buildTime(),
              width8,
              WatchBuilder(game.type, (GameType value) {
                if (value == GameType.Moba) {
                  return Row(
                    children: [
                      WatchBuilder(game.teamLivesWest, (int lives) {
                        return text("West: $lives");
                      }),
                      width8,
                      WatchBuilder(game.teamLivesEast, (int lives) {
                        return text("East: $lives");
                      }),
                    ],
                  );
                }
                return emptyContainer;
              }),
              // buildMouseWorldPosition(),
            ],
          ),
          if (uiOptions.showTotalZombies)
            widgets.totalZombies,
        ],
      ));
}


Widget buildSkillsButton() {
  return WatchBuilder(game.player.skillPoints, (int value) {
    if (value == 0) return emptyContainer;
    return Container(
        height: 103,
        alignment: Alignment.topLeft,
        child: border(
            color: Colors.white,
            fillColor: Colors.black45,
            padding: padding4,
            child: text("Points $value", color: Colors.white, size: 20)));
  });
}

void toggleSkillTreeVisible() {
  hud.skillTreeVisible.value = !hud.skillTreeVisible.value;
}

Widget buildTotalZombies() {
  return WatchBuilder(game.totalZombies, (int value) {
    return text('Zombies: $value');
  });
}

Widget buildPlayerLevel() {
  return WatchBuilder(game.player.level, (int value) {
    return text('Level $value');
  });
}

Widget buildBottomRight() {
  return WatchBuilder(game.player.characterType, (CharacterType type) {
    return Positioned(
        bottom: _padding,
        right: _padding,
        child: Row(
          children: [
            buildMessageBoxIcon(),
          ],
        ));
  });
}

Widget buildMessageBoxIcon() {
  return onPressed(
      hint: "Press Enter",
      callback: toggleMessageBox,
      child: border(
        child: text("Say"),
      ));
}

Widget buildTime() {
  return Tooltip(
    message: "Time",
    child: WatchBuilder(modules.isometric.state.time, (int value) {
      return text("${padZero(modules.game.properties.timeInHours)} : ${padZero(modules.game.properties.timeInMinutes % 60)}");
    }),
  );
}

Widget buildMouseWorldPosition() {
  return WatchBuilder(modules.isometric.state.time, (int value) {
    return text("Mouse X: ${mouseWorldX.toInt()}, Y: ${mouseWorldY.toInt()}");
  });
}

String padZero(num value) {
  String t = value.toInt().toString();
  if (t.length >= 2) return t;
  return '0$t';
}

Widget buildBottomCenter() {
  return Positioned(
      bottom: _padding,
      child: Container(
        width: engine.state.screen.width,
        child: Row(
          mainAxisAlignment: axis.main.center,
          crossAxisAlignment: axis.cross.end,
          children: [
            Column(
              mainAxisAlignment: axis.main.end,
              children: [
                widgets.healthBar,
                height2,
                widgets.magicBar,
                height2,
                widgets.experienceBar,
              ],
            ),
            width8,
            widgets.abilities,
            width8,
            Container(
              width: 200,
            )
          ],
        ),
      ));
}

Widget layout({
  bool expand = true,
  Widget? topLeft,
  Widget? topRight,
  Widget? bottomRight,
  Widget? bottomLeft,
  Widget? top,
  List<Widget>? children,
  Widget? child,
  double padding = 0,
  Color? color,
  Widget? foreground,
}){
  final stack = Stack(
    children: [
      if (children != null)
        ...children,
      if (child != null)
        child,
      if (topLeft != null)
        Positioned(top: padding, left: padding, child: topLeft,),
      if (topRight != null)
        Positioned(top: padding, right: padding, child: topRight,),
      if (bottomRight != null)
        Positioned(bottom: padding, right: padding, child: bottomRight,),
      if (bottomLeft != null)
        Positioned(bottom: padding, left: padding, child: bottomLeft,),
      if (top != null)
        Positioned(top: padding, child: top),
      if (foreground != null)
        foreground,
    ],
  );

  return expand ? fullScreen(child: stack, color: color): stack;
}

Widget buildUI3DCube() {
  return Column(
    children: [
      buttons.exit,
      Refresh(() {
        return text('camera3D.rotation: ${camera3D.rotation}');
      }),
      // Refresh((){
      //   return text('camera3D.viewportWidth: ${camera3D.viewportWidth.toInt()}');
      // }),
      // Refresh((){
      //   return text('camera3D.viewportHeight: ${camera3D.viewportHeight.toInt()}');
      // }),
      Refresh(() {
        return text('camera3D.fov: ${camera3D.fov.toInt()}');
      }),
      Refresh(() {
        return text(
            'camera.position: { x: ${engine.state.camera.x.toInt()}, y: ${engine.state.camera.y.toInt()}}');
      }),
      Refresh(() {
        return text('camera.zoom: ${engine.state.zoom}');
      }),
    ],
  );
}

Widget buildNumberOfPlayersRequiredDialog() {
  return WatchBuilder(game.numberOfPlayersNeeded, (int number) {
    if (number == 0) return emptyContainer;
    return dialog(
        height: 80,
        child: text("Waiting for $number more players to join the game"));
  });
}

Positioned buildCharacterAction() {
  return Positioned(
    left: 200,
    top: 300,
    child: WatchBuilder(characterController.action, (CharacterAction action) {
      return text(action);
    }),
  );
}

bool shotgunUnlocked() {
  for (Weapon weapon in game.player.weapons) {
    if (weapon.type == WeaponType.Shotgun) return true;
  }
  return false;
}

bool unlockedFirebolt() {
  for (Weapon weapon in game.player.weapons) {
    if (weapon.type == WeaponType.Shotgun) return true;
  }
  return false;
}

Widget buildTopRight() {
  return Positioned(
    top: _padding,
    right: _padding,
    child: buildMenu(),
  );
}

Widget buildIconEdit({
  double size = 19
}) {
  return buildDecorationImage(
      color: colours.none,
      image: decorationImages.edit, width: size, height: size, borderWidth: 0);
}

final playIcon = buildDecorationImage(
    color: colours.none,
    image: decorationImages.play, width: 60, height: 60, borderWidth: 0);


void toggleDebugMode() {
  game.settings.compilePaths = !game.settings.compilePaths;
  sendRequestSetCompilePaths(game.settings.compilePaths);
}

Widget buildMenu() {
  return mouseOver(builder: (BuildContext context, bool mouseOver){

    final menu = border(child: text("Menu"));

    if (!mouseOver){
      return menu;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (debug) buttons.debug,
        if (debug) width8,
        if (debug) buttons.edit,
        buttons.exit,
        buttons.changeCharacter,
        buttons.audio,
        width8,
        buildToggleFullscreen(),
        width8,
        menu,
      ],
    );
  });
}

void clearPlayerMessage() {
  game.player.message.value = "";
}

Widget buildSlot({required String title}) {
  return Container(
    child: Column(
      mainAxisAlignment: axis.main.center,
      children: [
        text(title),
      ],
    ),
    width: 120,
    height: 120 * goldenRatioInverse,
    alignment: Alignment.center,
    decoration: styleGuide.slot.boxDecoration,
  );
}

Widget buildDecorationImage({
  required DecorationImage image,
  double width = 150,
  double height = 50,
  double borderWidth = 1,
  Color color = Colors.white,
  Color borderColor = Colors.white,
}) {
  return Container(
    width: width,
    height: height,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      image: image,
      color: color,
      border: borderWidth > 0
          ? Border.all(color: borderColor, width: borderWidth)
          : null,
      borderRadius: borderRadius4,
    ),
  );
}

Widget buildEquipWeaponSlot(Weapon weapon, int index) {
  return mouseOver(builder: (BuildContext context, bool mouseOver) {
    double p = weapon.capacity > 0 ? weapon.rounds / weapon.capacity : 1.0;
    return Row(
      mainAxisAlignment: axis.main.start,
      children: [
        Stack(
          children: [
            onPressed(
                child: buildWeaponSlot(weapon.type),
                callback: () {
                  sendRequestEquip(index);
                }),
            if (weapon.type != WeaponType.Unarmed) buildTag(weapon.rounds),
          ],
        ),
        buildAmmoBar(capacity: weapon.capacity, rounds:weapon.rounds, weaponType: weapon.type),
        if (mouseOver) buildWeaponStats(weapon)
      ],
    );
  });
}

Widget buildWeaponStats(Weapon weapon) {
  return Container(
    color: Colors.black38,
    padding: padding8,
    child: Column(
      crossAxisAlignment: axis.cross.start,
      children: [
        text(mapWeaponTypeToString(weapon.type)),
        text("Damage: ${weapon.damage}"),
        text("Capacity: ${weapon.capacity}"),
      ],
    ),
  );
}

String mapWeaponTypeToString(WeaponType weaponType) {
  return weaponType.toString().replaceAll("WeaponType.", "");
}

Widget buildEquippedWeaponSlot() {

  return WatchBuilder(game.player.weaponType, (WeaponType weaponType){
      return WatchBuilder(game.player.weaponCapacity, (int weaponCapacity){
          return WatchBuilder(game.player.weaponRounds, (int weaponRounds){
            return Column(
              children: [
                Stack(
                  children: [
                    buildWeaponSlot(weaponType),
                    // if (weaponType != WeaponType.Unarmed)
                    //   buildTag(weaponRounds),
                  ],
                ),
                if (weaponCapacity == 0)
                  buildAmmoBar(rounds: 1, capacity: 1, weaponType: weaponType),
                if (weaponCapacity > 0)
                  buildAmmoBar(rounds: weaponRounds,
                      capacity: weaponCapacity,
                      weaponType: weaponType),
              ],
            );
          });
      });
  });
}

Widget buildAmmoBar({
  required int rounds,
  required int capacity,
  required WeaponType weaponType,
}) {
  final percentage = rounds / capacity;
  final width = 180.0;
  final height = width * goldenRatio_0381;
  return Container(
    width: width,
    height: height,
    color: Colors.white24,
    alignment: Alignment.bottomCenter,
    child: Stack(
      children: [
        Container(
          width: width,
          height: height,
          color: colours.white382,
        ),
        Container(
          width: width * percentage,
          height: height,
          color: colours.white618,
        ),
        Container(
          width: width,
          height: height,
          alignment: Alignment.center,
          color: none,
          child: text('${weaponType.name} ${weaponType != WeaponType.Unarmed ? "$rounds/$capacity" : ""}', color: colours.black, bold: true)
        ),
      ],
    ),
  );
}

Widget buildWeaponSlot(WeaponType weaponType) {
  return mouseOver(builder: (BuildContext context, bool mouseOver) {
    return Container(
      width: 120,
      height: 120 * goldenRatioInverse,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        image: mapWeaponTypeToImage[weaponType],
        color: mouseOver ? Colors.black45 : Colors.black26,
        border: Border.all(color: Colors.white, width: 1),
        borderRadius: borderRadius4,
      ),
    );
  });
}

// Widget buildBottomLeft() {
//   return Positioned(
//       bottom: _padding,
//       left: _padding,
//       child: Row(
//         crossAxisAlignment: cross.end,
//         children: [
//           buildMagicBar(),
//           width8,
//           buildAbilities(),
//           buildSkillsButton(),
//         ],
//       ));
// }

Widget buildPercentageBox(double percentage, double size) {
  return ClipPath(
    clipper: MyCustomClipper(percentage),
    child: Container(
      width: size,
      height: size,
      color: Colors.white,
    ),
  );
}

const oneEighth = 1.0 / 8.0;
const oneQuarter = 1.0 / 4.0;
const half = 1.0 / 2.0;

class MyCustomClipper extends CustomClipper<Path> {
  final double percentage;

  MyCustomClipper(this.percentage);

  @override
  Path getClip(Size size) {
    final width = size.width;
    final height = size.height;
    final halfWidth = width * 0.5;
    final halfHeight = height * 0.5;

    Path path = Path()..moveTo(halfWidth, 0);

    if (percentage > oneEighth) path.lineTo(0, 0); // top left

    if (percentage > oneQuarter) path.lineTo(0, halfHeight); // center left

    if (percentage > oneQuarter + oneEighth)
      path.lineTo(0, height); // bottom left

    if (percentage > half) path.lineTo(halfWidth, height); // center bottom

    if (percentage > half + oneEighth)
      path.lineTo(width, height); // bottom right

    if (percentage > half + oneQuarter)
      path.lineTo(width, halfHeight); // center right

    if (percentage > half + oneQuarter + oneEighth)
      path.lineTo(width, 0); // top right

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

Widget buildExpandedWeapons() {
  int index = -1;
  return Column(
    crossAxisAlignment: axis.cross.start,
    children: game.player.weapons.map((weapon) {
      index++;
      return Container(
        child: buildEquipWeaponSlot(weapon, index),
        margin: const EdgeInsets.only(bottom: 4),
      );
    }).toList(),
  );
}

Widget buildWeaponMenu() {
  return mouseOver(builder: (BuildContext context, bool mouseOver) {
    return Column(
      mainAxisAlignment: axis.main.end,
      crossAxisAlignment: axis.cross.start,
      children: [
        if (mouseOver) buildExpandedWeapons(),
        buildEquippedWeaponSlot(),
      ],
    );
  });
}

Widget buildImageButton(DecorationImage image, GestureTapCallback onTap,
    {double width = 120}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
        width: width,
        height: 50,
        decoration: BoxDecoration(
            color: Colors.black45,
            border: hud.properties.border,
            image: image)),
  );
}

Widget buildLoadingScreen() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AnimatedTextKit(repeatForever: true, animatedTexts: [
            RotateAnimatedText('Loading Bleed',
                textStyle: TextStyle(color: Colors.white, fontSize: 30)),
          ]),
        ],
      ),
    ],
  );
}

Widget buildLowAmmo() {
  return Positioned(
      bottom: 80,
      child: Container(
        width: engine.state.screen.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                padding: EdgeInsets.all(10),
                color: Colors.black26,
                child: text(
                    game.player.weaponRounds.value == 0
                        ? "Empty"
                        : "Low Ammo",
                    size: 20)),
          ],
        ),
      ));
}

Widget buildTag(dynamic value, {Color color = Colors.white}) {
  return Container(
      width: 40,
      height: 30,
      alignment: Alignment.center,
      child: text(value, weight: FontWeight.bold, color: color));
}

Widget buildMessageBox(String message) {
  return Positioned(
      bottom: 120,
      child: Container(
        width: engine.state.screen.width,
        child: Row(
          mainAxisAlignment: axis.main.center,
          children: [
            Container(
                padding: padding8,
                color: Colors.black26,
                child: text(message, size: 20)),
          ],
        ),
      ));
}
