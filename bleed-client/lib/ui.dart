import 'dart:math';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:bleed_client/common/GameState.dart';
import 'package:bleed_client/common/constants.dart';
import 'package:bleed_client/constants.dart';
import 'package:bleed_client/editor/editor.dart';
import 'package:bleed_client/common/GameType.dart';
import 'package:bleed_client/events.dart';
import 'package:bleed_client/functions/clearState.dart';
import 'package:bleed_client/functions/drawParticle.dart';
import 'package:bleed_client/functions/open_link.dart';
import 'package:bleed_client/game_engine/engine_state.dart';
import 'package:bleed_client/game_engine/game_widget.dart';
import 'package:bleed_client/game_engine/web_functions.dart';
import 'package:bleed_client/keys.dart';
import 'package:bleed_client/properties.dart';
import 'package:bleed_client/tutorials.dart';
import 'package:bleed_client/ui/dialogs.dart';
import 'package:bleed_client/ui/flutter_constants.dart';
import 'package:bleed_client/ui/styleguide.dart';
import 'package:bleed_client/ui/views.dart';
import 'package:flutter/material.dart';
import 'package:neuro/instance.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'classes/InventoryItem.dart';
import 'classes/Score.dart';
import 'common.dart';
import 'connection.dart';
import 'constants/servers.dart';
import 'enums/InventoryItemType.dart';
import 'enums/Mode.dart';
import 'common/Weapons.dart';
import 'images.dart';
import 'instances/inventory.dart';
import 'instances/settings.dart';
import 'maths.dart';
import 'send.dart';
import 'state.dart';
import 'ui/widgets.dart';
import 'utils.dart';
import 'utils/list_util.dart';

TextEditingController _playerNameController = TextEditingController();
Border _border =
    Border.all(color: Colors.black, width: 5.0, style: BorderStyle.solid);
SharedPreferences sharedPreferences;
bool _showScore = true;
bool _showServers = false;
double iconSize = 45;

bool observeMode = false;

Color _panelBackgroundColor = Colors.black38;

void initUI() {
  onConnectError.stream.listen((event) {
    showDialogConnectFailed();
  });

  respondTo((GameJoined gameStarted) async {
    closeMainMenuDialog();
  });

  on((LobbyJoined _) async {
    closeMainMenuDialog();
    redrawUI();
  });

  // TODO Refactor
  SharedPreferences.getInstance().then((instance) {
    //@ on sharedPreferences loaded
    sharedPreferences = instance;
    dispatch(instance);
    if (sharedPreferences.containsKey("tutorialIndex")) {
      tutorialIndex = sharedPreferences.getInt('tutorialIndex');
    }
    settings.audioMuted = sharedPreferences.containsKey('audioMuted') &&
        sharedPreferences.getBool('audioMuted');

    if (sharedPreferences.containsKey('server')) {
      Server server = servers[sharedPreferences.getInt('server')];
      connectServer(server);
    }
  });
}

void closeMainMenuDialog() {
  if (contextMainMenuDialog == null) return;
  Navigator.of(contextMainMenuDialog).pop();
}

Widget column(List<Widget> children) {
  return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children);
}

Widget row(List<Widget> children) {
  return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children);
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
                controller: _playerNameController,
              )
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('PLAY'),
            onPressed: _playerNameController.text.trim().length > 2
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

Widget buildGameUI(BuildContext context) {
  if (globalSize == null) {
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
                  textStyle: TextStyle(color: Colors.white)),
            ]),
          ],
        ),
      ],
    );
  }

  if (connecting) {
    return buildViewLoading();
  } else if (!connected) {
    return buildViewConnect();
  }

  if (state.lobby != null) return center(buildViewJoinedLobby());

  if (compiledGame.gameId < 0) {
    return buildViewLoading();
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
  // dynamic player = getPlayerCharacter();
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

const DecorationImage grenades1Image = const DecorationImage(
  image: const AssetImage('images/weapon-grenade.png'),
);

Map<int, DecorationImage> grenadeImages = {
  0: grenades1Image,
  1: grenades1Image,
  2: grenades2Image,
  3: grenades3Image,
};

const DecorationImage grenades2Image = const DecorationImage(
  image: const AssetImage('images/weapon-grenades-02.png'),
);

const DecorationImage grenades3Image = const DecorationImage(
  image: const AssetImage('images/weapon-grenades-03.png'),
);

const DecorationImage healthImage = const DecorationImage(
  image: const AssetImage('images/health.png'),
);

const DecorationImage _handgunImage = const DecorationImage(
  image: const AssetImage('images/weapon-handgun.png'),
);

const DecorationImage _shotgunImage = const DecorationImage(
  image: const AssetImage('images/weapon-shotgun.png'),
);

const DecorationImage _sniperImage = const DecorationImage(
  image: const AssetImage('images/weapon-sniper-rifle.png'),
);

const DecorationImage _machineGunImage = const DecorationImage(
  image: const AssetImage('images/weapon-machine-gun.png'),
);

DecorationImage mapWeaponToImage(Weapon weapon) {
  switch (weapon) {
    case Weapon.HandGun:
      return _handgunImage;
    case Weapon.Shotgun:
      return _shotgunImage;
    case Weapon.SniperRifle:
      return _sniperImage;
    case Weapon.AssaultRifle:
      return _machineGunImage;
  }
  throw Exception("no image available for $weapon");
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
            color: Colors.black45, border: _border, image: image)),
  );
}

void toggleEditMap() {
  if (playMode) {
    mode = Mode.Edit;
  } else {
    mode = Mode.Play;
  }
}

double squareSize = 80;
double halfSquareSize = squareSize * 0.5;
double padding = 3;
double w = squareSize * inventory.columns + padding;
double h = squareSize * inventory.rows + padding;

Widget buildInventory() {
  return Container(
    color: Colors.grey,
    width: w,
    height: h,
    child: CustomPaint(
      size: Size(w, h),
      painter: CustomCustomPainter((Canvas canvas, Size size) {
        paint2.color = Colors.black12;
        for (int x = 0; x < inventory.columns; x++) {
          for (int y = 0; y < inventory.rows; y++) {
            canvas.drawRect(
                Rect.fromLTWH(
                    padding + squareSize * x,
                    padding + squareSize * y,
                    squareSize - padding,
                    squareSize - padding),
                paint2);
          }
        }

        for (int i = 0; i < inventory.items.length; i++) {
          InventoryItem item = inventory.items[i];

          Offset o = Offset(
              item.column * squareSize + halfSquareSize + (padding * 0.5),
              item.row * squareSize + halfSquareSize + padding);

          switch (item.type) {
            case InventoryItemType.HealthPack:
              paint2.color = Colors.red;
              canvas.drawCircle(o, 20, paint2);
              break;
            case InventoryItemType.HandgunClip:
              canvas.drawImage(
                  images.imageHandgunAmmo,
                  Offset(item.column * squareSize + (padding * 0.5),
                      item.row * squareSize + padding),
                  paint2);
              break;
            case InventoryItemType.ShotgunClip:
              canvas.drawImage(
                  images.imageShotgunAmmo,
                  Offset(item.column * squareSize + (padding * 0.5),
                      item.row * squareSize + padding),
                  paint2);
              break;
            case InventoryItemType.Handgun:
              paint2.color = Colors.white;
              canvas.drawImage(
                  images.imageHandgun,
                  Offset(item.column * squareSize + (padding * 0.5),
                      item.row * squareSize + padding),
                  paint2);
              break;
          }
        }
      }),
    ),
  );
}

void toggleShowScore() {
  _showScore = !_showScore;
  redrawUI();
}

Widget buildHud() {
  String message = getMessage();

  return Stack(
    children: [
      buildTopRight(),
      if (player.alive && lag > 10)
        Positioned(
            top: 60,
            child: Container(
                width: screenWidth,
                alignment: Alignment.topCenter,
                child: Row(
                  mainAxisAlignment: main.center,
                  children: [
                    text("To reduce lag"),
                    width4,
                    border(
                        child: text("change server"),
                        padding: padding4,
                        radius: borderRadius4),
                  ],
                ))),

      if (player.alive) buildBottomLeft(),
      if (compiledGame.gameType == GameType.Fortress) buildViewFortress(),
      if (compiledGame.gameType == GameType.DeathMatch)
        buildGameInfoDeathMatch(),
      buildViewBottomRight(),
      if (state.gameState == GameState.Won) buildViewWin(),
      if (state.gameState == GameState.Lost) buildViewLose(),
      if (!observeMode &&
          player.dead &&
          compiledGame.gameType == GameType.Casual)
        buildViewRespawn(),
      // if (!playerDead && state.storeVisible) buildViewStore(),

      if (player.dead && observeMode)
        Positioned(
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
                            observeMode = false;
                          },
                          child: border(
                              child: text("Respawn", fontSize: 30),
                              padding: padding8,
                              radius: borderRadius4))
                    ]),
                    height32,
                    text("Hold E to pan camera")
                  ],
                ))),
      if (state.score.isNotEmpty && compiledGame.players.isNotEmpty)
        buildViewScore(),
      if (message != null) buildMessageBox(message),
    ],
  );
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

  Widget iconMenu = Tooltip(
    child: IconButton(
        icon: Icon(Icons.menu, size: iconSize, color: white),
        onPressed: showDialogMainMenu),
    message: "Menu",
  );

  Widget editMenu = Tooltip(
    child: IconButton(
        icon: Icon(Icons.edit, size: iconSize, color: white),
        onPressed: toggleEditMap),
    message: "Edit",
  );

  return Positioned(
      top: 0,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (settings.developMode) iconTogglePaths,
          if (settings.developMode) width4,
          if (settings.developMode) editMenu,
          // iconToggleScore,
          iconToggleAudio,
          width4,
          iconToggleFullscreen,
          if (settings.developMode) width4,
          // iconMenu
        ],
      ));
}

Widget buildTopLeft() {
  Widget iconToggleFullscreen = Tooltip(
    child: IconButton(
        icon: Icon(Icons.fullscreen, size: iconSize, color: white),
        onPressed: fullScreenEnter),
    message: "Fullscreen",
  );
  Widget iconToggleAudio = Tooltip(
      child: IconButton(
          icon: Icon(
              settings.audioMuted ? Icons.music_off : Icons.music_note_rounded,
              size: iconSize,
              color: white),
          onPressed: toggleAudioMuted),
      message: "Toggle Audio");

  Widget iconScore = Tooltip(
    child: IconButton(
        icon: Icon(_showScore ? Icons.score : Icons.score_outlined,
            size: iconSize, color: white),
        onPressed: toggleShowScore),
    message: _showScore ? "Hide Score" : "Show Score",
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
    message: _showScore ? "Hide Score" : "Show Score",
  );
}

Widget buildViewFortress() {
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
      borderRadius: borderRadius8,
    ),
  );
}

Widget buildEquipWeaponSlot({Weapon weapon, int index}) {
  return Stack(
    children: [
      buildTag(clipsRemaining(weapon)),
      onPressed(
          child: buildWeaponSlot(weapon: weapon),
          hint: "Press $index to equip",
          callback: sendRequestEquipShotgun),
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
      buildTag(price, color: player.credits >= price ? green : blood),
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
      border: Border.all(
          color: Colors.white,
          width: compiledGame.playerWeapon == weapon ? 6 : 1),
      borderRadius: borderRadius8,
    ),
  );
}

Widget buildBottomLeft() {
  return Positioned(
    bottom: 5,
    left: 5,
    child: Container(
      padding: padding8,
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: borderRadius4,
      ),
      child: Row(
        mainAxisAlignment: main.center,
        crossAxisAlignment: cross.end,
        children: [
          buildSlotWeapon(weapon: Weapon.HandGun, index: 1),
          width8,
          buildSlotWeapon(weapon: Weapon.Shotgun, index: 2),
          width8,
          buildSlotWeapon(weapon: Weapon.SniperRifle, index: 3),
          // width8,
          // buildSlotWeapon(weapon: Weapon.AssaultRifle, index: 4),
          // width8,
          // Stack(
          //   children: [
          //     if (player.meds > 0) buildTag(player.meds),
          //     onPressed(
          //         hint: "Press H to use med kit",
          //         callback: sendRequestUseMedKit,
          //         child: buildImageSlot(
          //             image: healthImage,
          //             width: 120 * goldenRatioInverse,
          //             height: 120 * goldenRatioInverse,
          //             color: player.meds > 0 ? null : Colors.white60)),
          //   ],
          // ),
          // width8,
          // Stack(
          //   children: [
          //     if (player.grenades > 0) buildTag(player.grenades),
          //     Tooltip(
          //         message: "Press G to throw grenade",
          //         child: buildImageSlot(
          //             image: grenades1Image,
          //             width: 120 * goldenRatioInverse,
          //             height: 120 * goldenRatioInverse,
          //             color: player.grenades > 0 ? null : Colors.white60)),
          //   ],
          // ),
          // width8,
          // buildSlot(title: "Credits: ${player.credits}"),
        ],
      ),
    ),
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

Widget buildTag(dynamic value, {Color color = Colors.white}) {
  return Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      child: text(value, fontWeight: FontWeight.bold, color: color));
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

String getMessage() {
  if (player.health == 0) return null;

  if (player.health < player.maxHealth * 0.25) {
    if (player.meds > 0) {
      return "Low Health: Press H to heal";
    }
  }
  if (player.equippedRounds == 0) {
    if (player.equippedClips == 0) {
      return 'Empty: Press 1, 2, 3 to change weapons';
    } else {
      return 'Press R to reload';
    }
  }

  if (player.equippedRounds <= 2) {
    return "Low Ammo";
  }

  return null;
}

Widget buildMessageBox(String message) {
  return Positioned(
      bottom: 120,
      child: Container(
        width: screenWidth,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                padding: EdgeInsets.all(10),
                color: Colors.black26,
                child: text(message, fontSize: 20)),
          ],
        ),
      ));
}

StoreTab storeTab = StoreTab.Buy;

enum StoreTab { Buy, Upgrade }

Widget buildViewStore() {
  return Positioned(
      top: 60,
      right: 0,
      child: Container(
        color: Colors.black45,
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            text('CREDITS ${state.player.points}'),
            Row(
              children: [
                Container(
                  width: 100,
                  child: button("Buy", () {
                    storeTab = StoreTab.Buy;
                    redrawUI();
                  }),
                ),
                Container(
                  width: 100,
                  child: button("Upgrade", () {
                    storeTab = StoreTab.Upgrade;
                    redrawUI();
                  }),
                ),
              ],
            ),
            if (storeTab == StoreTab.Buy) buildViewBuy(),
            if (storeTab == StoreTab.Upgrade) buildViewUpgrade(),
          ],
        ),
      ));
}

Widget buildViewBuy() {
  return Column(
    children: [
      height8,
      text("Weapons"),
      if (!player.acquiredHandgun)
        buildRow(prices.weapon.handgun, "Handgun", purchaseWeaponHandgun),
      if (player.acquiredHandgun)
        buildRow(prices.ammo.handgun, "Handgun Ammo", purchaseAmmoHandgun),
      if (!player.acquiredShotgun)
        buildRow(prices.weapon.shotgun, "Shotgun", purchaseWeaponShotgun),
      if (player.acquiredShotgun)
        buildRow(prices.weapon.shotgun, "Shotgun Ammo", purchaseAmmoShotgun),
      height8,
      text("items"),
      height8,
      text("Upgrades"),
    ],
  );
}

Widget buildViewUpgrade() {
  return Column(
    children: [
      height8,
      text("Weapons"),
      if (player.acquiredHandgun)
        buildRow(
            prices.weapon.handgun, "Handgun Damage", purchaseWeaponHandgun),
      if (player.acquiredHandgun)
        buildRow(
            prices.weapon.handgun, "Handgun Capacity", purchaseWeaponHandgun),
    ],
  );
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

Widget buildViewBottomRight() {
  return Positioned(
    right: 5,
    bottom: 5,
    child: MouseRegion(
      onEnter: (_) {
        _showServers = true;
        redrawUI();
      },
      onExit: (_) {
        _showServers = false;
        redrawUI();
      },
      child: Container(
          padding: padding8,
          width: 120,
          decoration: BoxDecoration(
            borderRadius: borderRadius4,
            color: Colors.black45,
          ),
          child: Column(
            crossAxisAlignment: cross.center,
            children: [
              if ((player.dead && !observeMode) | _showServers)
                onPressed(
                    callback: disconnect,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: text("Disconnect"), padding: padding4,)),
              if ((player.dead && !observeMode) | _showServers)
                buildServerList(),
              if (player.alive) onPressed(
                  callback: () {
                    _showServers = !_showServers;
                    redrawUI();
                  },
                  child: Container(
                      padding: padding4,
                      child: text(getServerName(currentServer)))),
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
              _showServers = false;
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

int get enemiesLeft {
  int count = 0;

  if (state.player.squad == -1) {
    for (dynamic player in compiledGame.players) {
      if (player[stateIndex] == characterStateDead) continue;
      count++;
    }
    return count - 1;
  }

  for (dynamic player in compiledGame.players) {
    if (player[stateIndex] == characterStateDead) continue;
    if (player[squad] == state.player.squad) continue;
    count++;
  }
  return count;
}

Widget buildDebugColumn() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          text(
              'mouseWorldX: ${mouseWorldX.toInt()}, mouseWorldY: ${mouseWorldY.toInt()}'),
          text('x: ${compiledGame.playerX}, y: ${compiledGame.playerY}'),
          text("zombies: ${compiledGame.npcs.length}"),
          text("players: ${compiledGame.players.length}"),
          text("zoom: ${zoom.toStringAsFixed(2)}"),
          text("cameraX: ${cameraX.toInt()}, cameraY: ${cameraY.toInt()}"),
          text(
              "centerX: ${screenCenterWorldX.toInt()} ${screenCenterWorldY.toInt()}"),
          text(
              'screen width: ${screenWidth / zoom}, screen height: ${screenHeight / zoom}'),
        ],
      )
    ],
  );
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

Widget buildViewRespawn() {
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
            decoration:
                BoxDecoration(borderRadius: borderRadius4, color: _panelBackgroundColor),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: cross.center,
                children: [
                  Container(
                      decoration: BoxDecoration(
                        borderRadius: borderRadius8,
                        color: blood,
                      ),
                      padding: padding8,
                      child: text("BLEED beta v1.0.0")),
                  height16,
                  text("YOU DIED", fontSize: 30, decoration: underline),
                  height16,
                  Container(
                    padding: padding16,
                    decoration: BoxDecoration(
                      borderRadius: borderRadius8,
                      color: black54,
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
                      borderRadius: borderRadius8,
                      color: black54,
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
                      borderRadius: borderRadius8,
                      color: black54,
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
                                child: text(getTip())),
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
                  // height8,
                  // Container(
                  //   decoration: BoxDecoration(
                  //     borderRadius: borderRadius8,
                  //     color: black54,
                  //   ),
                  //   padding: padding16,
                  //   child: Column(
                  //     children: [
                  //       text("Server"),
                  //       height8,
                  //       // Row(mainAxisAlignment: main.even, children: [
                  //       //   onPressed(
                  //       //       child: isUriConnected(servers.germany)
                  //       //           ? border(
                  //       //               child: text("Germany"),
                  //       //               padding: padding4,
                  //       //               borderRadius: borderRadius4)
                  //       //           : text("Germany"),
                  //       //       callback: connectServerGermany),
                  //       //   onPressed(
                  //       //       child: isUriConnected(servers.usaEast)
                  //       //           ? border(
                  //       //               child: text("USA East"),
                  //       //               padding: padding4,
                  //       //               borderRadius: borderRadius4)
                  //       //           : text("USA East"),
                  //       //       callback: () {
                  //       //         connect(servers.usaEast);
                  //       //       }),
                  //       //   onPressed(
                  //       //       child: isUriConnected(servers.usaWest)
                  //       //           ? border(
                  //       //               child: text("USA West"),
                  //       //               padding: padding4,
                  //       //               borderRadius: borderRadius4)
                  //       //           : text("USA West"),
                  //       //       callback: () {
                  //       //         connect(servers.usaWest);
                  //       //       }),
                  //       // ]),
                  //     ],
                  //   ),
                  // ),
                  height32,
                  Row(
                    mainAxisAlignment: main.between,
                    children: [
                      onPressed(
                          child: Container(
                              padding: padding16, child: text("Close")),
                          callback: () {
                            observeMode = true;
                            redrawUI();
                          }),
                      width16,
                      onPressed(
                        child: border(
                            child: text("RESPAWN", fontSize: 30),
                            padding: padding16,
                            radius: borderRadius8,
                            color: Colors.black38,
                            fillColor: black54),
                        callback: sendRequestRevive,
                        hint: "Click to respawn",
                      ),
                    ],
                  ),
                ],
              ),
            )),
      ],
    ),
  );
}

int tipIndex = 0;

void nextTip() {
  tipIndex = (tipIndex + 1) % tips.length;
  redrawUI();
}

List<String> tips = [
  "Use the W,A,S,D keys to move",
  "Press 1, 2, 3, etc to change weapons",
  "Press G to throw grenade",
  "Press H to use med kit",
  "Hold left shift to sprint",
  "Press R to Reload",
  "Press Space bar to fire weapon",
  "Scroll with the mouse to zoom in and out",
  "Hold E to pan camera",
  'Change server using the option menu at the bottom right side of the screen',
  "Activate fullscreen using the option at the top right side of the screen"
];

String getTip() {
  return tips[tipIndex];
}

Widget buildDebugPanel() {
  return column([
    button("Spawn NPC", sendRequestSpawnNpc),
    text("Ping: ${ping.inMilliseconds}"),
    text("Player Id: ${compiledGame.playerId}"),
    text("Data Size: ${event.length}"),
    text("Frames since event: $framesSinceEvent"),
    text("Milliseconds Since Last Frame: $millisecondsSinceLastFrame"),
    if (millisecondsSinceLastFrame > 0)
      text("FPS: ${(1000 / millisecondsSinceLastFrame).round()}"),
    if (serverFramesMS > 0)
      text("Server FPS: ${(1000 / serverFramesMS).round()}"),
    text("Players: ${compiledGame.players.length}"),
    text("Bullets: ${compiledGame.bullets.length}"),
    text("Npcs: ${compiledGame.totalNpcs}"),
    text("Player Assigned: $playerAssigned"),
  ]);
}

int getScoreRecord(Score score) {
  return score.record;
}

bool _expandScore = false;

Widget buildViewScore() {
  if (!_showScore) {
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
        onHover: (_){
          _expandScore = true;
          redrawUI();
        },
        onExit: (_){
          _expandScore = false;
          redrawUI();
        },
        child: Container(
          decoration: BoxDecoration(
            color: black45,
            borderRadius: borderRadius4,
          ),
          width: width,
          padding: padding8,
          height: width * (_expandScore ? goldenRatio : goldenRatioInverse),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: cross.start,
              children: [
                Container(
                  width: width,
                  child: Row(
                    mainAxisAlignment: main.spread,
                    children: [
                      text("Leaderboard"),
                      iconClose
                    ],
                  ),
                ),
                height8,
                Column(
                  crossAxisAlignment: cross.start,
                  children: state.score.map((score) {
                    int index = state.score.indexOf(score);
                    return Row(
                      children: [
                        Container(
                            width: 140,
                            child: text('$index ${score.playerName}',
                                color: score.playerName == playerName
                                    ? blood
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
}

void showDebug() {
  debugMode = true;
}

void hideDebug() {
  debugMode = false;
}
