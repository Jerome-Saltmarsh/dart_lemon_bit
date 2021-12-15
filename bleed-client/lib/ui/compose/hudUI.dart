import 'dart:math';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:bleed_client/classes/Ability.dart';
import 'package:bleed_client/classes/Weapon.dart';
import 'package:bleed_client/common/AbilityType.dart';
import 'package:bleed_client/common/CharacterAction.dart';
import 'package:bleed_client/common/CharacterType.dart';
import 'package:bleed_client/common/ClientRequest.dart';
import 'package:bleed_client/common/WeaponType.dart';
import 'package:bleed_client/constants/colours.dart';
import 'package:bleed_client/constants/servers.dart';
import 'package:bleed_client/functions/clearState.dart';
import 'package:bleed_client/input.dart';
import 'package:bleed_client/mappers/mapWeaponToDecorationImage.dart';
import 'package:bleed_client/network/functions/disconnect.dart';
import 'package:bleed_client/send.dart';
import 'package:bleed_client/server/server.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/ui/compose/buildSkillTree.dart';
import 'package:bleed_client/ui/compose/widgets.dart';
import 'package:bleed_client/ui/logic/hudLogic.dart';
import 'package:bleed_client/ui/state/decorationImages.dart';
import 'package:bleed_client/ui/state/flutter_constants.dart';
import 'package:bleed_client/ui/state/hudState.dart';
import 'package:bleed_client/ui/state/styleguide.dart';
import 'package:bleed_client/utils/widget_utils.dart';
import 'package:bleed_client/watches/time.dart';
import 'package:flutter/material.dart';
import 'package:lemon_engine/functions/fullscreen_enter.dart';
import 'package:lemon_engine/functions/fullscreen_exit.dart';
import 'package:lemon_engine/game.dart';
import 'package:lemon_engine/properties/fullscreen_active.dart';
import 'package:lemon_engine/properties/mouse_world.dart';
import 'package:lemon_engine/state/build_context.dart';
import 'package:lemon_engine/state/canvas.dart';
import 'package:lemon_engine/state/paint.dart';
import 'package:lemon_engine/state/size.dart';
import 'package:lemon_math/golden_ratio.dart';
import 'package:lemon_watch/watch_builder.dart';

import 'buildTextBox.dart';

const double _padding = 8;
final emptyContainer = Container();

Widget buildLevelBar() {
  double width = 200;
  double height = width * goldenRatioInverse * goldenRatioInverse * goldenRatioInverse * goldenRatioInverse;

  return WatchBuilder(game.player.experiencePercentage, (double percentage) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 2),
          borderRadius: borderRadius4),
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.all(2),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Container(
            color: Colors.white,
            width: width,
            height: height,
          ),
          Container(
            color: colours.yellow,
            width: width * percentage,
            height: height,
          ),
          Container(
            color: Colors.transparent,
            width: width,
            height: height,
            alignment: Alignment.center,
            child: text('Level ${game.player.level.value}', color: Colors.black),
          ),
        ],
      ),
    );
  });
}


Widget buildHealthBar() {
  double width = 200;
  double height = width * goldenRatioInverse * goldenRatioInverse * goldenRatioInverse * goldenRatioInverse;

  return WatchBuilder(game.player.health, (double health) {
    double percentage = health / game.player.maxHealth;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 2),
          borderRadius: borderRadius4),
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.all(2),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Container(
            color: Colors.white,
            width: width,
            height: height,
          ),
          Container(
            color: colours.red,
            width: width * percentage,
            height: height,
          ),
          Container(
            color: Colors.transparent,
            width: width,
            height: height,
            alignment: Alignment.center,
            child: text('${health.toInt()} / ${game.player.maxHealth}', color: Colors.black),
          ),
        ],
      ),
    );
  });
}

Widget buildMagicBar() {
  double width = 200;
  double height = width * goldenRatioInverse * goldenRatioInverse * goldenRatioInverse * goldenRatioInverse;

  return WatchBuilder(game.player.magic, (double magic) {
    double percentage = magic / game.player.maxMagic.value;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 2),
          borderRadius: borderRadius4),
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.all(2),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Container(
            color: Colors.white,
            width: width,
            height: height,
          ),
          Container(
            color: colours.blue,
            width: width * percentage,
            height: height,
          ),
          Container(
            color: Colors.transparent,
            width: width,
            height: height,
            alignment: Alignment.center,
            child: text('${magic.toInt()} / ${game.player.maxMagic.value}', color: Colors.black),
          ),
        ],
      ),
    );
  });
}

Widget buildTopLeft() {
  return Positioned(
      top: _padding,
      left: _padding,
      child: Row(
        children: [
          Column(
            crossAxisAlignment: cross.center,
            children: [
              buildTime(),
              // height4,
              // buildPlayerLevel(),
            ],
          ),
          // width8,
          // buildPlayerNextLevelExperience(),
          // width8,
          // buildMouseWorldPosition(),
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
            child: text("Points $value", color: Colors.white, fontSize: 20)));
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

// Widget buildPlayerNextLevelExperience() {
//   return Tooltip(
//     message: "Experience",
//     child: WatchBuilder(game.player.experiencePercentage, (int value) {
//       double percentage = value / 100.0;
//       return Container(
//         width: 100,
//         height: 50,
//         alignment: Alignment.centerLeft,
//         padding: EdgeInsets.all(3),
//         decoration: BoxDecoration(
//             border: Border.all(color: Colors.white, width: 4),
//             borderRadius: borderRadius4),
//         child: Container(
//           color: Colors.white,
//           width: 100 * percentage,
//           height: 50,
//         ),
//       );
//     }),
//   );
// }

Widget buildBottomRight() {
  return WatchBuilder(game.player.characterType, (CharacterType type) {
    if (type == CharacterType.None) return emptyContainer;
    return Positioned(
        bottom: _padding,
        right: _padding,
        child: Row(
          children: [
            buildMessageBoxIcon(),
            width8,
            buildHealthBar(),
          ],
        ));
  });
}

Widget buildMessageBoxIcon() {
  return onPressed(
      hint: "Press Enter",
      callback: toggleMessageBox,
      child: border(
        child: text("Message"),
      ));
}

Widget buildTime() {
  return Tooltip(
    message: "Time",
    child: WatchBuilder(timeInSeconds, (int value) {
      return text("${padZero(timeInHours)} : ${padZero(timeInMinutes % 60)}");
    }),
  );
}

Widget buildMouseWorldPosition() {
  return WatchBuilder(timeInSeconds, (int value) {
    return text("Mouse X: ${mouseWorldX.toInt()}, Y: ${mouseWorldY.toInt()}");
  });
}

String padZero(num value) {
  String t = value.toInt().toString();
  if (t.length >= 2) return t;
  return '0$t';
}

Widget dialog({
  Widget child,
  double padding = 8,
  double width = 400,
  double height = 600,
  Color color = Colors.white24,
  Color borderColor = Colors.white,
  double borderWidth = 2,
  BorderRadius borderRadius = borderRadius4,
  Alignment alignment = Alignment.center,
  EdgeInsets margin = EdgeInsets.zero,
}) {
  return Container(
    width: screenWidth,
    height: screenHeight,
    alignment: alignment,
    child: Container(
      margin: margin,
      decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: borderWidth),
          borderRadius: borderRadius,
          color: color),
      padding: EdgeInsets.all(padding),
      width: width,
      height: height,
      child: child,
    ),
  );
}

Widget buildFullScreenDialog() {
  return WatchBuilder(hud.fullScreenDialogVisible, (bool visible) {
    if (!visible) return emptyContainer;
    return dialog(
        color: Colors.transparent,
        margin: EdgeInsets.only(top: 16),
        alignment: Alignment.topCenter,
        height: 60,
        borderColor: Colors.transparent,
        child: Row(
          mainAxisAlignment: main.center,
          children: [
            buildToggleFullscreen(),
            width16,
            onPressed(
              callback: () {
                hud.fullScreenDialogVisible.value = false;
              },
              child: text("No Thanks", decoration: TextDecoration.underline),
            ),
          ],
        ));
  });
}

Widget buildToggleFullscreen() {
  return border(
    child: onPressed(
      hint: "F11",
      callback: () {
        hud.fullScreenDialogVisible.value = false;
        if (fullScreenActive) {
          fullScreenExit();
        } else {
          fullScreenEnter();
        }
      },
      child: Row(
        children: [
          text(fullScreenActive ? "Exit Fullscreen" : "Fullscreen"),
          width4,
          buildDecorationImage(
              image: icons.fullscreen, width: 20, height: 20, borderWidth: 0),
        ],
      ),
    ),
  );
}

Widget buildSelectHero() {
  final fontSize = 20;
  return dialog(
      color: Colors.white24,
      child: Column(
        children: [
          height16,
          text("Select Hero", fontSize: 30),
          height16,
          ...playableCharacterTypes.map((characterType) {
            return mouseOver(
              builder: (BuildContext context, bool mouseOver) {
                return onPressed(
                  callback: () {
                    server.send.selectCharacterType(characterType);
                  },
                  child: border(
                    margin: EdgeInsets.only(bottom: 16),
                    fillColor: mouseOver ? Colors.black87 : Colors.black26,
                    child: Container(
                      width: 200,
                      child: text(characterTypeToString(characterType),
                          fontSize: fontSize),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ],
      ));
}

Widget buildBottomCenter() {
  return Positioned(
      bottom: _padding,
      child: Container(
        width: screenWidth,
        child: Row(
          mainAxisAlignment: main.center,
          crossAxisAlignment: cross.end,
          children: [
            Column(
              mainAxisAlignment: main.end,
              children: [
                buildHealthBar(),
                height2,
                buildMagicBar(),
                height2,
                buildLevelBar(),
              ],
            ),
            width8,
            buildAbilities(),
            width8,
            Container(
              width: 200,
            )
          ],
        ),
      ));
}

Widget buildHud() {
  return WatchBuilder(game.player.characterType, (CharacterType value) {
    if (value == CharacterType.None) {
      return buildSelectHero();
    }

    return WatchBuilder(game.player.alive, (bool alive) {
      return Stack(
        children: [
          buildTextBox(),
          // if (alive) buildBottomLeft(),
          // if (alive) buildBottomRight(),
          buildTopLeft(),
          if (alive) buildBottomCenter(),
          if (!hud.state.observeMode && !alive) _buildViewRespawn(),
          if (!alive && hud.state.observeMode) _buildRespawnLight(),
          _buildServerText(),
          buildTopRight(),
          buildSkillTree(),
          buildFullScreenDialog(),
        ],
      );
    });
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

Positioned _buildRespawnLight() {
  return Positioned(
      top: 30,
      child: Container(
          width: screenWidth,
          child: Column(
            crossAxisAlignment: cross.center,
            children: [
              Row(mainAxisAlignment: main.center, children: [
                onPressed(
                    callback: () {
                      sendRequestRevive();
                      hud.state.observeMode = false;
                    },
                    child: border(
                        child: text("Respawn", fontSize: 30),
                        padding: padding8,
                        radius: borderRadius4))
              ]),
              height32,
              text("Hold E to pan camera")
            ],
          )));
}

Widget buildTopRight() {
  return Positioned(
    top: _padding,
    right: _padding,
    child: buildMenu(),
  );
}

Widget buildToggleAudio() {
  return WatchBuilder(game.settings.audioMuted, (bool audio) {
    return onPressed(
        callback: toggleAudio,
        child: border(child: text(audio ? "Audio On" : "Audio Off")));
  });
}

Widget _buildSettingsIcon() {
  return buildDecorationImage(
      image: icons.settings, width: 40, height: 40, borderWidth: 0);
}

Widget _buildToggleEdit() {
  return button("Editor", toggleEditMode);
}

Widget buildToggleDebug() {
  return button("Debug", toggleDebugMode);
}

void toggleDebugMode() {
  game.settings.compilePaths = !game.settings.compilePaths;
  sendRequestSetCompilePaths(game.settings.compilePaths);
}

Widget buildMenu() {
  return WatchBuilder(hud.state.menuVisible, (bool value) {
    if (!value) return _buildSettingsIcon();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (game.settings.developMode) buildToggleDebug(),
        if (game.settings.developMode) width8,
        if (game.settings.developMode) _buildToggleEdit(),
        button("Change Hero", () {
          sendClientRequest(ClientRequest.Reset_Character_Type);
        }),
        buildToggleAudio(),
        width8,
        buildToggleFullscreen(),
        if (game.settings.developMode) width8,
      ],
    );
  });
}

Widget _buildServerText() {
  return WatchBuilder(game.player.message, (String value) {
    if (value.isEmpty) return blank;

    return Positioned(
        child: Container(
          width: screenWidth,
          alignment: Alignment.center,
          child: Container(
            width: 300,
            color: Colors.black45,
            padding: padding16,
            child: Column(
              children: [
                text(game.player.message.value),
                height16,
                button("Next", clearPlayerMessage),
              ],
            ),
          ),
        ),
        bottom: 100);
  });
}

void clearPlayerMessage() {
  game.player.message.value = "";
}

Widget buildSlot({String title}) {
  return Container(
    child: Column(
      mainAxisAlignment: main.center,
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
  DecorationImage image,
  double width,
  double height,
  double borderWidth = 1,
  Color color,
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
      mainAxisAlignment: main.start,
      children: [
        buildAmmoBar(p),
        Stack(
          children: [
            onPressed(
                child: buildWeaponSlot(weapon.type),
                callback: () {
                  sendRequestEquip(index);
                  rebuildUI();
                }),
            if (weapon.type != WeaponType.Unarmed) buildTag(weapon.rounds),
          ],
        ),
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
      crossAxisAlignment: cross.start,
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

Widget buildEquippedWeaponSlot(WeaponType weapon) {
  return Row(
    children: [
      WatchBuilder(game.player.equippedRounds, (int rounds) {
        if (game.player.equippedCapacity.value == 0) {
          return buildAmmoBar(1);
        }
        return buildAmmoBar(rounds / game.player.equippedCapacity.value);
      }),
      Stack(
        children: [
          buildWeaponSlot(weapon),
          if (weapon != WeaponType.Unarmed)
            WatchBuilder(game.player.equippedRounds, buildTag),
        ],
      ),
    ],
  );
}

Widget buildAmmoBar(double percentage) {
  return Container(
    width: 40,
    height: 75,
    color: Colors.white24,
    alignment: Alignment.bottomCenter,
    child: Container(
      width: 40,
      height: 75 * percentage,
      color: Colors.white,
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

Widget buildAbilities() {
  return WatchBuilder(game.player.ability, (AbilityType ability) {
    print("buildAbilities($ability)");
    return Container(
      child: Row(
        crossAxisAlignment: cross.end,
        children: [
          buildAbility(game.player.ability1, 1, ability),
          width4,
          buildAbility(game.player.ability2, 2, ability),
          width4,
          buildAbility(game.player.ability3, 3, ability),
          width4,
          buildAbility(game.player.ability4, 4, ability),
        ],
      ),
    );
  });
}

Widget buildAbility(
    Ability ability, int index, AbilityType selectedAbilityType) {
  return WatchBuilder(ability.type, (AbilityType type) {
    if (type == AbilityType.None) return emptyContainer;

    bool selected = type == selectedAbilityType;

    if (selected) {
      print('$selectedAbilityType selected');
    }

    return Column(
      mainAxisAlignment: main.end,
      children: [
        WatchBuilder(game.player.skillPoints, (int points) {
          if (points == 0) return emptyContainer;

          return onPressed(
            callback: () {
              sendRequest.upgradeAbility(index);
            },
            child: mouseOver(builder: (BuildContext context, bool mouseOver) {
              return border(
                child: text("+", fontSize: 25),
                color: selected ? Colors.white : Colors.white54,
                fillColor: mouseOver ? Colors.white54 : Colors.white12,
                padding: EdgeInsets.symmetric(horizontal: 5),
              );
            }),
          );
        }),
        height20,
        WatchBuilder(ability.level, (int level) {
          return WatchBuilder(ability.cooldown, (int cooldown) {
            return WatchBuilder(ability.cooldownRemaining,
                (int cooldownRemaining) {
              return onPressed(
                hint: abilityTypeToString(ability.type.value),
                callback: level == 0 || cooldownRemaining > 0
                    ? null
                    : () {
                        sendRequestSelectAbility(index);
                      },
                child: Stack(
                  children: [
                    mouseOver(builder: (BuildContext context, bool mouseOver) {
                      return buildDecorationImage(
                          image: mapAbilityTypeToDecorationImage[type],
                          width: 50,
                          height: 50,
                          borderColor: mouseOver || selected
                              ? Colors.white
                              : Colors.black54,
                          borderWidth: 3);
                    }),
                    if (level > 0)
                      Container(
                          color: Colors.black54,
                          padding: padding4,
                          child: text(level)),
                    if (cooldownRemaining > 0)
                      Container(
                          width: 50,
                          height: 50,
                          alignment: Alignment.center,
                          color: Colors.black54,
                          child: text("${cooldownRemaining}s")),
                    if (level < 1)
                      Container(
                        width: 50,
                        height: 50,
                        alignment: Alignment.center,
                        color: Colors.black54,
                      ),
                    // if (cooldownRemaining > 0)
                    //   buildPercentageBox(0.66, 50),
                  ],
                ),
              );
            });
          });
        }),
      ],
    );
  });
}

Widget buildExpandedWeapons() {
  int index = -1;
  return Column(
    crossAxisAlignment: cross.start,
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
      mainAxisAlignment: main.end,
      crossAxisAlignment: cross.start,
      children: [
        if (mouseOver) buildExpandedWeapons(),
        WatchBuilder(game.player.weapon, buildEquippedWeaponSlot)
      ],
    );
  });
}

Widget _buildViewRespawn() {
  print("buildViewRespawn()");
  return Container(
    width: screenWidth,
    height: screenHeight,
    child: Row(
      mainAxisAlignment: main.center,
      crossAxisAlignment: cross.center,
      children: [
        Container(
            padding: padding16,
            width: max(screenWidth * goldenRatioInverseB, 480),
            decoration: BoxDecoration(
                borderRadius: borderRadius4, color: Colors.black38),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: cross.center,
                children: [
                  Container(
                      decoration: BoxDecoration(
                        borderRadius: borderRadius4,
                        color: colours.blood,
                      ),
                      padding: padding8,
                      child: text("BLEED beta v1.0.0")),
                  height16,
                  text("YOU DIED", fontSize: 30, decoration: underline),
                  height16,
                  Container(
                    padding: padding16,
                    decoration: BoxDecoration(
                      borderRadius: borderRadius4,
                      color: black26,
                    ),
                    child: Column(
                      crossAxisAlignment: cross.center,
                      children: [
                        text("Please Support Me"),
                        height16,
                        Row(
                          mainAxisAlignment: main.even,
                          children: [
                            onPressed(
                              child: border(
                                  child: Container(
                                      width: 70,
                                      alignment: Alignment.center,
                                      child: text(
                                        "Paypal",
                                      )),
                                  radius: borderRadius4,
                                  padding: padding8),
                              callback: () {
                                // openLink(links.paypal);
                              },
                              // hint: links.paypal
                            ),
                            onPressed(
                              child: border(
                                  child: Container(
                                      width: 70,
                                      alignment: Alignment.center,
                                      child: text("Patreon")),
                                  radius: borderRadius4,
                                  padding: padding8),
                              callback: () {
                                // openLink(links.patreon);
                              },
                              // hint: links.patreon
                            )
                          ],
                        ),
                        height8,
                      ],
                    ),
                  ),
                  height8,
                  Container(
                    padding: padding16,
                    decoration: BoxDecoration(
                      borderRadius: borderRadius4,
                      color: black26,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        text("Community"),
                        height8,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            comingSoon(
                              child: Row(
                                children: [
                                  text("Youtube"),
                                  IconButton(
                                      // onPressed: () {},
                                      icon: Icon(
                                    Icons.link,
                                    color: Colors.white,
                                  ))
                                ],
                              ),
                            ),
                            onPressed(
                              hint: "Come and Hang!",
                              callback: () {
                                // openLink(links.discord);
                              },
                              child: Row(
                                children: [
                                  text("Discord"),
                                  IconButton(
                                      onPressed: () {},
                                      icon: Icon(
                                        Icons.link,
                                        color: Colors.white,
                                      ))
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  height8,
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: borderRadius4,
                      color: black26,
                    ),
                    padding: padding16,
                    child: Column(
                      children: [
                        text("Hints"),
                        Row(
                          mainAxisAlignment: main.center,
                          crossAxisAlignment: cross.center,
                          children: [
                            Container(
                                width: 350,
                                alignment: Alignment.center,
                                child: text(currentTip)),
                            width16,
                            Tooltip(
                              message: "Next Hint",
                              child: IconButton(
                                  onPressed: nextTip,
                                  icon: Icon(
                                    Icons.arrow_forward,
                                    color: Colors.white,
                                    size: 30,
                                  )),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  height32,
                  Row(
                    mainAxisAlignment: main.between,
                    children: [
                      onPressed(
                          child: Container(
                              padding: padding16, child: text("Close")),
                          callback: () {
                            hud.state.observeMode = true;
                            rebuildUI();
                          }),
                      width16,
                      mouseOver(
                          builder: (BuildContext context, bool mouseOver) {
                        return onPressed(
                          child: border(
                              child: text("RESPAWN",
                                  fontWeight: bold,
                                  decoration: mouseOver ? underline : null),
                              padding: padding16,
                              radius: borderRadius4,
                              color: Colors.white,
                              width: 1,
                              fillColor: mouseOver ? black54 : black26),
                          callback: sendRequestRevive,
                          hint: "Click to respawn",
                        );
                      })
                    ],
                  ),
                ],
              ),
            )),
      ],
    ),
  );
}

Widget buildImageButton(DecorationImage image, Function onTap,
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

Future<void> showChangeNameDialog() async {
  return showDialog<void>(
    context: globalContext,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Welcome to Bleed'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('WASD keys to move'),
              Text('Hold SPACE to aim'),
              Text('Left click to shoot'),
              Text('Please enter a name'),
              TextField(
                autofocus: true,
                focusNode: FocusNode(),
                controller: hud.textEditingControllers.playerName,
              )
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('PLAY'),
            onPressed:
                hud.textEditingControllers.playerName.text.trim().length > 2
                    ? () {
                        // sendRequestSpawn(playerNameController.text.trim());
                        Navigator.of(context).pop();
                      }
                    : null,
          ),
        ],
      );
    },
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
        width: screenWidth,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                padding: EdgeInsets.all(10),
                color: Colors.black26,
                child: text(
                    game.player.equippedRounds == 0 ? "Empty" : "Low Ammo",
                    fontSize: 20)),
          ],
        ),
      ));
}

Widget buildTag(dynamic value, {Color color = Colors.white}) {
  return Container(
      width: 40,
      height: 30,
      alignment: Alignment.center,
      child: text(value, fontWeight: FontWeight.bold, color: color));
}

Widget buildMessageBox(String message) {
  return Positioned(
      bottom: 120,
      child: Container(
        width: screenWidth,
        child: Row(
          mainAxisAlignment: main.center,
          children: [
            Container(
                padding: padding8,
                color: Colors.black26,
                child: text(message, fontSize: 20)),
          ],
        ),
      ));
}

Widget buildServer() {
  return MouseRegion(
    onEnter: (_) {
      hud.state.showServers = true;
      rebuildUI();
    },
    onExit: (_) {
      hud.state.showServers = false;
      rebuildUI();
    },
    child: Container(
        padding: padding8,
        width: 140,
        decoration: BoxDecoration(
          borderRadius: borderRadius4,
          color: Colors.black45,
        ),
        child: Column(
          crossAxisAlignment: cross.center,
          children: [
            if ((game.player.dead && !hud.state.observeMode) |
                hud.state.showServers)
              onPressed(
                  callback: disconnect,
                  child: Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: text("Disconnect"),
                    padding: padding4,
                  )),
            if ((game.player.dead && !hud.state.observeMode) ||
                hud.state.showServers)
              buildServerList(),
            Container(
                padding: padding4, child: text(getServerName(currentServer))),
          ],
        )),
  );
}

Widget buildServerList() {
  return Column(
      crossAxisAlignment: cross.end,
      children: servers.map((server) {
        bool active = isServerConnected(server);
        return onPressed(
            hint: "Connect to ${getServerName(server)} server",
            callback: () {
              connectServer(server);
              hud.state.showServers = false;
            },
            child: Container(
              padding: padding4,
              decoration: active
                  ? BoxDecoration(
                      border: Border.all(width: 2, color: Colors.white),
                      borderRadius: borderRadius4)
                  : null,
              margin: const EdgeInsets.only(bottom: 16),
              child: text(getServerName(server)),
            ));
      }).toList());
}

Widget buildGameOver() {
  return Positioned(
      child: Container(
    width: globalSize.width,
    height: globalSize.height,
    color: Colors.black45,
    child: button("Game Over", clearState, fontSize: 30),
  ));
}

Widget buildDialog(Widget child) {
  return Positioned(
      top: 30, child: Container(width: screenWidth, child: child));
}

void drawRing(Ring ring,
    {double percentage,
    Color color,
    Offset position,
    Color backgroundColor = Colors.white}) {
  setStrokeWidth(6);
  setColor(backgroundColor);
  for (int i = 0; i < ring.points.length - 1; i++) {
    globalCanvas.drawLine(
        ring.points[i] + position, ring.points[i + 1] + position, paint);
  }

  setStrokeWidth(3);
  setColor(color);
  int fillSides = (ring.sides * percentage).toInt();
  for (int i = 0; i < fillSides; i++) {
    globalCanvas.drawLine(
        ring.points[i] + position, ring.points[i + 1] + position, paint);
  }
}
