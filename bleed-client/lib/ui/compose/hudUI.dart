import 'dart:math';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:bleed_client/bleed.dart';
import 'package:bleed_client/common/GameType.dart';
import 'package:bleed_client/common/Weapons.dart';
import 'package:bleed_client/common/constants.dart';
import 'package:bleed_client/connection.dart';
import 'package:bleed_client/constants.dart';
import 'package:bleed_client/constants/servers.dart';
import 'package:bleed_client/editor/editor.dart';
import 'package:bleed_client/engine/functions/fullscreenEnter.dart';
import 'package:bleed_client/engine/functions/toggleFullScreen.dart';
import 'package:bleed_client/engine/properties/fullScreenActive.dart';
import 'package:bleed_client/engine/render/game_widget.dart';
import 'package:bleed_client/engine/state/buildContext.dart';
import 'package:bleed_client/engine/state/canvas.dart';
import 'package:bleed_client/engine/state/paint.dart';
import 'package:bleed_client/engine/state/size.dart';
import 'package:bleed_client/functions/clearState.dart';
import 'package:bleed_client/functions/open_link.dart';
import 'package:bleed_client/instances/settings.dart';
import 'package:bleed_client/mappers/mapWeaponToDecorationImage.dart';
import 'package:bleed_client/maths.dart';
import 'package:bleed_client/send.dart';
import 'package:bleed_client/server.dart';
import 'package:bleed_client/state.dart';
import 'package:bleed_client/state/colours.dart';
import 'package:bleed_client/ui/compose/views.dart';
import 'package:bleed_client/ui/state/flutter_constants.dart';
import 'package:bleed_client/ui/logic/hudLogic.dart';
import 'package:bleed_client/ui/state/decorationImages.dart';
import 'package:bleed_client/ui/state/hudState.dart';
import 'package:bleed_client/ui/state/styleguide.dart';
import 'package:bleed_client/ui/compose/widgets.dart';
import 'package:bleed_client/utils.dart';
import 'package:bleed_client/utils/list_util.dart';
import 'package:bleed_client/utils/widget_utils.dart';
import 'package:flutter/material.dart';

import '../../properties.dart';
import '../../tutorials.dart';
import 'buildTextBox.dart';
import 'dialogs.dart';

Widget buildHud() {
  print("buildHud()");

  return Stack(
    children: [
      buildTopRight(),
      buildTextBox(),
      if (hud.state.textBoxVisible)
      _buildServerText(),
      if (player.alive) buildViewBottomLeft(),
      if (compiledGame.gameType == GameType.Fortress) _buildViewFortress(),
      if (compiledGame.gameType == GameType.DeathMatch)
        buildGameInfoDeathMatch(),
      _buildViewBottomRight(),
      _buildServerText(),
      if (!hud.state.observeMode && player.dead) _buildViewRespawn(),
      if (player.dead && hud.state.observeMode) _buildRespawnLight(),
      if (compiledGame.gameType == GameType.Casual) buildViewScore(),
    ],
  );
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

Widget buildTop() {
  return Positioned(
      top: 0,
      child: Container(
        width: screenWidth,
        height: 100,
        child: Row(
          mainAxisAlignment: main.center,
          children: [
            buildMedSlot(),
            Container(
              height: 50,
              width: 100,
              // color: Colors.blue,
            ),
            Container(
              height: 50,
              width: 100,
              color: Colors.red,
            )
          ],
        ),
      ));
}


Widget buildTopRight() {
  double iconSize = 45;

  Widget iconToggleFullscreen = Tooltip(
    child: IconButton(
        icon: Icon(fullScreenActive ? Icons.fullscreen_exit : Icons.fullscreen,
            size: iconSize, color: white),
        onPressed: toggleFullScreen),
    message: fullScreenActive ? "Exit Fullscreen" : "Enter Fullscreen",
  );
  Widget iconToggleAudio = Tooltip(
      child: IconButton(
          icon: Icon(
              settings.audioMuted ? Icons.music_off : Icons.music_note_rounded,
              size: iconSize,
              color: white),
          onPressed: toggleAudioMuted),
      message: settings.audioMuted ? "Resume Audio" : "Mute Audio");

  Widget iconTogglePaths = Tooltip(
    child: IconButton(
        icon: Icon(Icons.map, size: iconSize, color: white),
        onPressed: () {
          settings.compilePaths = !settings.compilePaths;
          sendRequestSetCompilePaths(settings.compilePaths);
        }),
    message: "Toggle Paths",
  );

  Widget buttonJoinGameOpenWorld = button('Open World', joinGameOpenWorld);
  Widget buttonJoinGameCasual = button('Casual', joinGameCasual);

  Widget iconToggleEditMode = Tooltip(
    child: IconButton(
        icon: Icon(Icons.edit, size: iconSize, color: white),
        onPressed: toggleEditMode),
    message: "Edit",
  );

  return Positioned(
      top: 0,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (compiledGame.gameType == GameType.Casual) buttonJoinGameOpenWorld,
          if (compiledGame.gameType == GameType.Open_World)
            buttonJoinGameCasual,
          if (settings.developMode) iconTogglePaths,
          if (settings.developMode) width8,
          if (settings.developMode) iconToggleEditMode,
          iconToggleAudio,
          width8,
          iconToggleFullscreen,
          if (settings.developMode) width8,
          // iconMenu
        ],
      ));
}


Widget buildTopLeft() {
  Widget iconToggleFullscreen = Tooltip(
    child: IconButton(
        icon: Icon(Icons.fullscreen, size: hud.properties.iconSize, color: white),
        onPressed: fullScreenEnter),
    message: "Fullscreen",
  );
  Widget iconToggleAudio = Tooltip(
      child: IconButton(
          icon: Icon(
              settings.audioMuted ? Icons.music_off : Icons.music_note_rounded,
              size: hud.properties.iconSize,
              color: white),
          onPressed: toggleAudioMuted),
      message: "Toggle Audio");

  Widget iconScore = Tooltip(
    child: IconButton(
        icon: Icon(hud.state.showScore ? Icons.score : Icons.score_outlined,
            size: hud.properties.iconSize, color: white),
        onPressed: toggleShowScore),
    message: hud.state.showScore ? "Hide Score" : "Show Score",
  );

  return Positioned(
    top: 5,
    left: 5,
    child: Row(
      children: [iconToggleFullscreen, iconToggleAudio, iconScore],
    ),
  );
}

Widget buildToggleScoreIcon() {
  return Tooltip(
    child: IconButton(
        icon: Icon(Icons.format_list_numbered_rtl_outlined,
            size: 35, color: Colors.white60),
        onPressed: toggleShowScore),
    message: hud.state.showScore ? "Hide Score" : "Show Score",
  );
}

Widget _buildServerText() {
  return StatefulBuilder(
      builder: (BuildContext context, StateSetter stateSetter) {
        hud.stateSetters.npcMessage = stateSetter;

        if (player.message.isEmpty) return blank;

        return Positioned(
            child: Container(
              width: screenWidth,
              alignment: Alignment.center,
              child: Container(
                width: 300,
                // height: 300 * goldenRatioInverse,
                color: Colors.black45,
                padding: padding16,
                child: Column(
                  children: [
                    text(player.message),
                    height16,
                    button("Next", () {
                      player.message = "";
                      rebuildNpcMessage();
                    }),
                  ],
                ),
              ),
            ),
            bottom: 100);
      });
}

Widget _buildViewFortress() {
  return Positioned(
      right: 0,
      bottom: 0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          text("Lives: ${compiledGame.lives}"),
          text("Wave: ${compiledGame.wave}"),
          text("Next Wave: ${compiledGame.nextWave}"),
        ],
      ));
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



Widget buildEquipWeaponSlot({Weapon weapon, int index}) {
  return Stack(
    children: [
      onPressed(
          child: buildWeaponSlot(weapon: weapon),
          hint: "Press $index to equip",
          callback: sendRequestEquipShotgun),
      buildTag(clipsRemaining(weapon)),
    ],
  );
}

Widget buildSlotWeapon({Weapon weapon, int index}) {
  bool acquired = weaponAcquired(weapon);
  return Column(
    children: [
      if (!acquired && player.canPurchase)
        buildPurchaseWeaponSlot(weapon: weapon),
      if (player.canPurchase) height8,
      if (!acquired) buildSlot(title: "Slot $index"),
      if (acquired) buildEquipWeaponSlot(weapon: weapon, index: index),
    ],
  );
}

Widget buildPurchaseWeaponSlot({Weapon weapon}) {
  int price = mapWeaponPrice(weapon);
  return Stack(
    children: [
      onPressed(
          hint: '${mapWeaponName(weapon)} $price',
          child: buildWeaponSlot(weapon: weapon),
          callback: () {
            sendRequestPurchaseWeapon(weapon);
          }),
      buildTag(price, color: player.credits >= price ? colours.green : colours.blood),
    ],
  );
}

Widget buildWeaponSlot({Weapon weapon}) {
  return Container(
    width: 120,
    height: 120 * goldenRatioInverse,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      image: mapWeaponToImage(weapon),
      color: Colors.black26,
      border: Border.all(
          color: Colors.white,
          width: compiledGame.playerWeapon == weapon ? 6 : 1),
      borderRadius: borderRadius4,
    ),
  );
}

Widget buildMedSlot() {
  return Stack(children: [
    onPressed(
        hint: "Press H to use med kit",
        callback: sendRequestUseMedKit,
        child: buildImageSlot(
            image: healthImage,
            width: 120 * goldenRatioInverse,
            height: 120 * goldenRatioInverse,
            color: Colors.black38)),
    buildTag(player.meds)
  ]);
}


Widget buildViewBottomLeft() {
  return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
    hud.stateSetters.bottomLeft = setState;
    return Positioned(
      bottom: 0,
      left: 0,
      child: Container(
        padding: padding8,
        decoration: BoxDecoration(
          borderRadius: borderRadius4,
        ),
        child: Row(
          mainAxisAlignment: main.center,
          crossAxisAlignment: cross.end,
          children: [
            buildSlotWeapon(weapon: Weapon.HandGun, index: 1),
            width4,
            buildSlotWeapon(weapon: Weapon.Shotgun, index: 2),
            width4,
            buildSlotWeapon(weapon: Weapon.SniperRifle, index: 3),
            width4,
            buildSlotWeapon(weapon: Weapon.AssaultRifle, index: 4),
            // width4,
            // buildMedSlot(),
            width4,
            buildGrenadeSlot(),
            // width4,
            // buildSlot(title: "Credits: ${player.credits}"),
          ],
        ),
      ),
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
      buildTag(player.grenades)
    ],
  );
}

Widget buildViewTutorial() {
  return Positioned(
      bottom: 100,
      child: Container(
        width: screenWidth,
        child: Row(
          mainAxisAlignment: main.center,
          children: [
            Container(
                padding: EdgeInsets.all(10),
                color: Colors.black54,
                child: text(tutorial.getText())),
          ],
        ),
      ));
}

Widget buildViewScore() {
  return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
    hud.stateSetters.score = setState;
    if (!hud.state.showScore) {
      return Positioned(
        top: 5,
        left: 5,
        child: buildToggleScoreIcon(),
      );
    }

    try {
      sort(state.score, getScoreRecord);
      Widget iconClose = Tooltip(
        message: "Hide Score board",
        child: IconButton(
            icon: Icon(Icons.close, size: 30, color: Colors.white),
            onPressed: toggleShowScore),
      );

      double width = 260;

      return Positioned(
        top: 5,
        left: 5,
        child: MouseRegion(
          onHover: (_) {
            hud.state.expandScore = true;
            rebuildUI();
          },
          onExit: (_) {
            hud.state.expandScore = false;
            rebuildUI();
          },
          child: Container(
            decoration: BoxDecoration(
              color: black45,
              borderRadius: borderRadius4,
            ),
            width: width,
            padding: padding8,
            height: width * (hud.state.expandScore ? goldenRatio : goldenRatioInverse),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: cross.start,
                children: [
                  Container(
                    width: width,
                    child: Row(
                      mainAxisAlignment: main.spread,
                      children: [text("Leaderboard"), iconClose],
                    ),
                  ),
                  height8,
                  if (state.score.isNotEmpty)
                    Column(
                      crossAxisAlignment: cross.start,
                      children: state.score.map((score) {
                        int index = state.score.indexOf(score);
                        return Row(
                          children: [
                            Container(
                                width: 140,
                                child: text('${index + 1}. ${score.playerName}',
                                    color: score.playerName == playerName
                                        ? colours.blood
                                        : Colors.white)),
                            Container(width: 50, child: text(score.points)),
                            Container(width: 50, child: text(score.record)),
                          ],
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    } catch (error) {
      return text("error build score");
    }
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
                                  openLink(links.paypal);
                                },
                                hint: links.paypal),
                            onPressed(
                                child: border(
                                    child: Container(
                                        width: 70,
                                        alignment: Alignment.center,
                                        child: text("Patreon")),
                                    radius: borderRadius4,
                                    padding: padding8),
                                callback: () {
                                  openLink(links.patreon);
                                },
                                hint: links.patreon)
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
                                        color: white,
                                      ))
                                ],
                              ),
                            ),
                            onPressed(
                              hint: "Come and Hang!",
                              callback: () {
                                openLink(links.discord);
                              },
                              child: Row(
                                children: [
                                  text("Discord"),
                                  IconButton(
                                      onPressed: () {},
                                      icon: Icon(
                                        Icons.link,
                                        color: white,
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


Widget buildWeaponButton(Weapon weapon) {
  return GestureDetector(
    onTap: () => sendRequestEquip(weapon),
    child: Container(
        width: 120,
        height: 50,
        decoration: BoxDecoration(image: mapWeaponToImage(weapon))),
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
            color: Colors.black45, border: hud.properties.border, image: image)),
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
            onPressed: hud.textEditingControllers.playerName.text.trim().length > 2
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


Widget buildGameUI(BuildContext context) {
  if (globalSize == null) {
    return buildLoadingScreen();
  }

  if (connecting) {
    return buildViewConnecting();
  } else if (!connected) {
    return buildViewConnect();
  }

  if (state.lobby != null) return center(buildViewJoinedLobby());

  if (compiledGame.gameId < 0) {
    // TODO consider case
    return buildViewConnecting();
  }
  if (editMode) return buildEditorUI();

  if (compiledGame.playerId < 0) {
    return text(
        "player id is not assigned. player id: ${compiledGame.playerId}, game id: ${compiledGame.gameId}");
  }

  if (compiledGame.tiles.isEmpty) {
    return text('tiles have not been loaded');
  }

  if (framesSinceEvent > 30) {
    return Container(
      width: globalSize.width,
      height: globalSize.height,
      alignment: Alignment.center,
      child: Container(child: text("Reconnecting...", fontSize: 30)),
    );
  }
  if (!playerAssigned) {
    return Container(
      width: globalSize.width,
      height: globalSize.height,
      alignment: Alignment.center,
      child: text("Error: No Player Assigned"),
    );
  }

  try {
    return buildHud();
  } catch (error) {
    print("error build hud");
    return text("an error occurred");
  }
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
                child: text(player.equippedRounds == 0 ? "Empty" : "Low Ammo",
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

Widget buildRow(int amount, String name, Function onPressed) {
  return Row(
    children: [
      Container(width: 40, child: text(amount)),
      width8,
      button(name, state.player.points >= amount ? onPressed : null),
    ],
  );
}


Widget _buildViewBottomRight() {
  return Positioned(
    right: 5,
    bottom: 5,
    child: MouseRegion(
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
              if ((player.dead && !hud.state.observeMode) | hud.state.showServers)
                onPressed(
                    callback: disconnect,
                    child: Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: text("Disconnect"),
                      padding: padding4,
                    )),
              if ((player.dead && !hud.state.observeMode) || hud.state.showServers)
                buildServerList(),
              Container(
                  padding: padding4, child: text(getServerName(currentServer))),
            ],
          )),
    ),
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


Widget buildGameInfoDeathMatch() {
  return Positioned(
      right: 10,
      bottom: 10,
      child: Container(
          color: Colors.black45,
          padding: EdgeInsets.all(8),
          child: text("Enemies Left: $enemiesLeft", fontSize: 30)));
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
