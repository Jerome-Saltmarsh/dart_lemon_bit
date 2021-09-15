import 'package:bleed_client/common.dart';
import 'package:bleed_client/common/GameState.dart';
import 'package:bleed_client/editor/editor.dart';
import 'package:bleed_client/common/GameType.dart';
import 'package:bleed_client/common/StoreCosts.dart';
import 'package:bleed_client/events.dart';
import 'package:bleed_client/functions/clearState.dart';
import 'package:bleed_client/game_engine/engine_state.dart';
import 'package:bleed_client/game_engine/game_widget.dart';
import 'package:bleed_client/game_engine/web_functions.dart';
import 'package:bleed_client/keys.dart';
import 'package:bleed_client/properties.dart';
import 'package:bleed_client/tutorials.dart';
import 'package:bleed_client/ui/dialogs.dart';
import 'package:bleed_client/ui/views.dart';
import 'package:flutter/material.dart';
import 'package:neuro/instance.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'classes/InventoryItem.dart';
import 'classes/Score.dart';
import 'connection.dart';
import 'enums.dart';
import 'enums/InventoryItemType.dart';
import 'enums/Mode.dart';
import 'common/Weapons.dart';
import 'images.dart';
import 'instances/inventory.dart';
import 'instances/settings.dart';
import 'send.dart';
import 'state.dart';
import 'ui/widgets.dart';
import 'utils.dart';

TextEditingController _playerNameController = TextEditingController();
Border _border =
    Border.all(color: Colors.black, width: 5.0, style: BorderStyle.solid);
SharedPreferences sharedPreferences;
bool _showDebug = false;
bool _showScore = true;
double iconSize = 45;

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

  SharedPreferences.getInstance().then((value) {
    sharedPreferences = value;
    dispatch(value);
    if (sharedPreferences.containsKey("tutorialIndex")) {
      tutorialIndex = sharedPreferences.getInt('tutorialIndex');
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
          children: [text("LOADING BLEED")],
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

  if (compiledGame.gameId < 0) return center(MainMenu());

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
  }catch(error){
    print("error build hud");
    return text("an error occurred");
  }
}

const DecorationImage grenadeImage = const DecorationImage(
  image: const AssetImage('images/weapon-grenade.png'),
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

DecorationImage _getDecorationImage(Weapon weapon) {
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
        decoration: BoxDecoration(image: _getDecorationImage(weapon))),
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
                  imageHandgunAmmo,
                  Offset(item.column * squareSize + (padding * 0.5),
                      item.row * squareSize + padding),
                  paint2);
              break;
            case InventoryItemType.ShotgunClip:
              canvas.drawImage(
                  imageShotgunAmmo,
                  Offset(item.column * squareSize + (padding * 0.5),
                      item.row * squareSize + padding),
                  paint2);
              break;
            case InventoryItemType.Handgun:
              paint2.color = Colors.white;
              canvas.drawImage(
                  imageHandgun,
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
      // if (mouseAvailable && mouseX < 300 && mouseY < 300) buildTopLeft(),
      buildTopRight(),
      buildBottomLeft(),
      if (compiledGame.gameType == GameType.Fortress) buildViewFortress(),
      if (compiledGame.gameType == GameType.DeathMatch)
        buildGameInfoDeathMatch(),
      if (compiledGame.gameType == GameType.Casual) buildGameViewCasual(),
      if (state.gameState == GameState.Won) buildViewWin(),
      if (state.gameState == GameState.Lost) buildViewLose(),
      if (playerDead && compiledGame.gameType == GameType.Casual)
        buildViewRespawn(),
      // if (!tutorialsFinished) buildViewTutorial(),
      if (player.equippedClips == 0 && player.equippedRounds < 5)
        buildLowAmmo(),
      if (state.storeVisible) buildViewStore(),
      if (state.score.isNotEmpty && compiledGame.players.isNotEmpty)
        buildViewScore(),
      if (message != null) buildMessageBox(message),
    ],
  );
}

bool get playerDead {
  dynamic player = getPlayer;
  if (player == null) return false;
  return player[stateIndex] == characterStateDead;
}

Widget buildTopRight() {
  double iconSize = 45;

  Widget iconToggleFullscreen = Tooltip(
    child: IconButton(
        icon: Icon(Icons.fullscreen, size: iconSize, color: white),
        onPressed: requestFullScreen),
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

  // Widget iconToggleScore = Tooltip(
  //   child: IconButton(
  //       icon: Icon(Icons.format_list_numbered_rtl,
  //           size: iconSize, color: _showScore ? white : Colors.white60),
  //       onPressed: toggleShowScore),
  //   message: _showScore ? "Hide Score" : "Show Score",
  // );

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
          if (settings.developMode) editMenu,
          // iconToggleScore,
          iconToggleAudio,
          iconToggleFullscreen,
          iconMenu
        ],
      ));
}

Widget buildTopLeft() {
  Widget iconToggleFullscreen = Tooltip(
    child: IconButton(
        icon: Icon(Icons.fullscreen, size: iconSize, color: white),
        onPressed: requestFullScreen),
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
    top: 0,
    left: 0,
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

Widget buildBottomLeft() {
  return Positioned(
    bottom: 0,
    child: Container(
      color: Colors.black45,
      padding: EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          buildWeaponButton(compiledGame.playerWeapon),
          text(player.equippedClips, fontSize: 25),
          width16,
          Container(
              width: 50,
              height: 40,
              decoration: BoxDecoration(image: grenadeImage)),
          text(compiledGame.playerGrenades, fontSize: 25),
          width16,
          Container(
              width: 50,
              height: 40,
              decoration: BoxDecoration(image: healthImage)),
          text(compiledGame.playerMeds, fontSize: 25),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                padding: EdgeInsets.all(10),
                color: Colors.black54,
                child: text(tutorial.getText())),
          ],
        ),
      ));
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
    if (compiledGame.playerMeds > 0) {
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
      bottom: 80,
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

Widget buildViewStore() {
  return Positioned(
      top: 60,
      right: 0,
      child: Container(
        color: Colors.black45,
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            text('CREDITS ${state.player.points}'),
            button(
                "Handgun Ammo (10)",
                state.player.points >= storeCosts.ammoHandgun
                    ? purchaseAmmoHandgun
                    : null),
            button("Shotgun Ammo (10)", purchaseAmmoShotgun),
          ],
        ),
      ));
}

Widget buildGameViewCasual() {
  return Positioned(
      right: 10,
      bottom: 10,
      child: Container(
          color: Colors.black45,
          padding: EdgeInsets.all(8),
          child: text("CASUAL GAME")));
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
          button('Close', () => _showDebug = false),
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

Widget buildViewRespawn() {
  return Positioned(
      bottom: 200,
      child: Container(
        width: screenWidth,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                padding: EdgeInsets.all(16),
                width: 600,
                color: Colors.black45,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    text("You Died",
                        fontSize: 30, decoration: TextDecoration.underline),
                    height16,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        text("Tip: ${getTip()}"),
                        width16,
                        Container(
                            width: 60,
                            child: button("next", nextTip,
                                alignment: Alignment.center))
                      ],
                    ),
                    height32,
                    button("Respawn", sendRequestRevive,
                        fontSize: 40, alignment: Alignment.center),
                  ],
                )),
          ],
        ),
      ));
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

Widget buildViewScore() {
  try {
    Score highest = highScore;

    if (!_showScore) {
      return Positioned(
        top: 0,
        left: 0,
        child: buildToggleScoreIcon(),
      );
    }

    Widget iconClose = IconButton(
        icon: Icon(Icons.close, size: 30, color: Colors.white70),
        onPressed: toggleShowScore);

    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          child: Container(
            color: Colors.black45,
            width: 200,
            padding: EdgeInsets.all(4),
            height: 300,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  height16,
                  text("Highest", decoration: TextDecoration.underline),
                  Row(children: [
                    Container(width: 140, child: text(highest.playerName)),
                    Container(width: 50, child: text(highest.record)),
                  ]),
                  Divider(),
                  text("Leader", decoration: TextDecoration.underline),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: state.score.map((score) {
                      return Row(
                        children: [
                          Container(
                              width: 140,
                              child: text(score.playerName,
                                  color: score.playerName == playerName
                                      ? Colors.red
                                      : Colors.white)),
                          Container(width: 50, child: text(score.points)),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(top: 0, left: 160, child: iconClose,),
      ],
    );
  }catch(error){
    return text("error build score");
  }
}

void showDebug() {
  debugMode = true;
}

void hideDebug() {
  debugMode = false;
}
