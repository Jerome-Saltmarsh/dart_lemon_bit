import 'dart:math';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:bleed_client/classes/Weapon.dart';
import 'package:bleed_client/common/HeroType.dart';
import 'package:bleed_client/common/WeaponType.dart';
import 'package:bleed_client/constants/colours.dart';
import 'package:bleed_client/constants/servers.dart';
import 'package:bleed_client/functions/clearState.dart';
import 'package:bleed_client/mappers/mapWeaponToDecorationImage.dart';
import 'package:bleed_client/network/functions/disconnect.dart';
import 'package:bleed_client/send.dart';
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
import 'package:lemon_engine/functions/toggle_fullscreen.dart';
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
import 'dialogs.dart';

const double _padding = 8;
const _iconSize = 45.0;
final emptyContainer = Container();

Widget buildHealthBar() {
  return WatchBuilder(game.player.health, (double health) {
    double percentage = health / game.player.maxHealth;
    double width = 120;
    double height = width * goldenRatioInverse;

    return Tooltip(
      message: 'Health ${health.toInt()} / ${game.player.maxHealth}',
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 4),
            borderRadius: borderRadius4),
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.all(3),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            // borderRadius: borderRadius4
          ),
          width: width * percentage,
          height: height,
        ),
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
              height4,
              buildPlayerLevel(),
            ],
          ),
          width8,
          buildPlayerNextLevelExperience(),
          width8,
          buildSkillsButton(),
        ],
      ));
}

Widget buildSkillsButton() {
  return WatchBuilder(game.player.skillPoints, (int value) {
    return onPressed(
      callback: toggleSkillTreeVisible,
      child: Row(children: [
        Tooltip(message: "Press T", child: text("Skills")),
        if (value > 0) width4,
        if (value > 0) text(value)
      ]),
    );
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

Widget buildPlayerNextLevelExperience() {
  return Tooltip(
    message: "Experience",
    child: WatchBuilder(game.player.experiencePercentage, (int value) {
      double percentage = value / 100.0;
      return Container(
        width: 100,
        height: 50,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.all(3),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 4),
            borderRadius: borderRadius4),
        child: Container(
          color: Colors.white,
          width: 100 * percentage,
          height: 50,
        ),
      );
    }),
  );
}

Widget buildBottomRight() {
  return Positioned(bottom: _padding, right: _padding, child: buildHealthBar());
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
}) {
  return Container(
    width: screenWidth,
    height: screenHeight,
    alignment: Alignment.center,
    child: Container(
      padding: EdgeInsets.all(padding),
      color: color,
      width: width,
      height: height,
      child: child,
    ),
  );
}

Widget buildSelectHero() {
  final fontSize = 20;
  return WatchBuilder(game.player.heroType, (HeroType value) {
    if (value == HeroType.None) {
      return dialog(
          child: Column(
        children: [
          height16,
          text("Select Hero", fontSize: 30),
          height16,
          ...heroTypesExceptNone.map((heroType) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: text(heroTypeToString(heroType), fontSize: fontSize,
                  onPressed: () {
                game.player.heroType.value = heroType;
              }),
            );
          }).toList(),
        ],
      ));
    }
    return emptyContainer;
  });
}

Widget buildHud() {
  print("buildHud()");

  return WatchBuilder(game.player.alive, (bool alive) {
    return Stack(
      children: [
        buildTextBox(),
        if (alive) buildBottomLeft(),
        if (alive) buildBottomRight(),
        buildTopLeft(),
        if (!hud.state.observeMode && !alive) _buildViewRespawn(),
        if (!alive && hud.state.observeMode) _buildRespawnLight(),
        _buildServerText(),
        buildTopRight(),
        buildSkillTree(),
        buildSelectHero(),
      ],
    );
  });
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

Widget buildMenu() {
  return WatchBuilder(hud.state.menuVisible, (bool value) {
    print("Build menu visible $value");
    if (!value)
      return Container(
        child: const Icon(Icons.menu, size: _iconSize, color: Colors.white),
      );

    Widget iconToggleFullscreen = Tooltip(
      child: IconButton(
          icon: Icon(
              fullScreenActive ? Icons.fullscreen_exit : Icons.fullscreen,
              size: _iconSize,
              color: Colors.white),
          onPressed: toggleFullScreen),
      message: fullScreenActive ? "Exit Fullscreen" : "Enter Fullscreen",
    );
    Widget iconToggleAudio = Tooltip(
        child: IconButton(
            icon: WatchBuilder(game.settings.audioMuted, (bool value) {
              return Icon(value ? Icons.music_off : Icons.music_note_rounded,
                  size: _iconSize, color: Colors.white);
            }),
            onPressed: toggleAudioMuted),
        message: "Toggle Audio");

    Widget iconTogglePaths = Tooltip(
      child: IconButton(
          icon: Icon(Icons.map, size: _iconSize, color: Colors.white),
          onPressed: () {
            game.settings.compilePaths = !game.settings.compilePaths;
            sendRequestSetCompilePaths(game.settings.compilePaths);
          }),
      message: "Toggle Paths",
    );

    Widget iconToggleEditMode = Tooltip(
      child: IconButton(
          icon: Icon(Icons.edit, size: _iconSize, color: Colors.white),
          onPressed: toggleEditMode),
      message: "Edit",
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (game.settings.developMode) iconTogglePaths,
        if (game.settings.developMode) width8,
        if (game.settings.developMode) iconToggleEditMode,
        iconToggleAudio,
        width8,
        iconToggleFullscreen,
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

Widget buildImageSlot(
    {DecorationImage image,
    double width,
    double height,
    double borderWidth = 1,
    Color color}) {
  return Container(
    width: width,
    height: height,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      image: image,
      color: color,
      border: Border.all(color: Colors.white, width: borderWidth),
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

Widget buildBottomLeft() {
  return Positioned(bottom: _padding, left: _padding, child: buildWeaponMenu());
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

Stack buildGrenadeSlot() {
  return Stack(
    children: [
      Tooltip(
          message: "Press G to throw grenade",
          child: buildImageSlot(
              image: grenades1Image,
              width: 120 * goldenRatioInverse,
              height: 120 * goldenRatioInverse,
              color: Colors.black38)),
      buildTag(game.player.grenades)
    ],
  );
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

Widget buildViewWin() {
  return Positioned(
      bottom: 200,
      child: Container(
        width: screenWidth,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                color: Colors.black45,
                child: button("YOU WIN", showDialogMainMenu,
                    fontSize: 40, alignment: Alignment.center)),
          ],
        ),
      ));
}

Widget buildViewLose() {
  return Positioned(
      bottom: 200,
      child: Container(
        width: screenWidth,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                color: Colors.black45,
                child: button("YOU LOSE", showDialogMainMenu,
                    fontSize: 40, alignment: Alignment.center)),
          ],
        ),
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
