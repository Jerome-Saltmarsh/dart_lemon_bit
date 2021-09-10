import 'package:bleed_client/editor/editor.dart';
import 'package:bleed_client/enums/GameType.dart';
import 'package:bleed_client/events.dart';
import 'package:bleed_client/functions/clearState.dart';
import 'package:bleed_client/game_engine/engine_state.dart';
import 'package:bleed_client/game_engine/game_widget.dart';
import 'package:bleed_client/game_engine/web_functions.dart';
import 'package:bleed_client/properties.dart';
import 'package:bleed_client/ui/dialogs.dart';
import 'package:bleed_client/ui/views.dart';
import 'package:flutter/material.dart';
import 'package:neuro/instance.dart';

import 'classes/InventoryItem.dart';
import 'connection.dart';
import 'enums/InventoryItemType.dart';
import 'enums/Mode.dart';
import 'enums/Weapons.dart';
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

bool _showDebug = false;

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
            text("LOADING BLEED")
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

  if (state.lobby != null) return center(buildJoinedLobby());

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

  return buildHud();
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
    case Weapon.MachineGun:
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
        decoration: BoxDecoration(
            // color: Colors.white70,
            // border: compiledGame.playerWeapon == weapon ? _border : null,
            image: _getDecorationImage(weapon))),
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

void toggleMode() {
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

Widget buildHud() {
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


  Widget iconMenu = Tooltip(
    child: IconButton(
        icon: Icon(Icons.menu, size: iconSize, color: white),
        onPressed: showDialogMainMenu),
    message: "Menu",
  );

  Positioned topLeft = Positioned(
    top: 0,
    left: 0,
    child: Row(
      children: [
        iconToggleFullscreen,
        iconToggleAudio,
      ],
    ),
  );

  Positioned topRight = Positioned(
      top: 0,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (settings.developMode && !_showDebug)
            button('Debug', () => _showDebug = !_showDebug),
          if (settings.developMode) button('Editor', toggleMode),
          iconMenu
        ],
      ));

  List<Widget> clips = [];

  for (int i = 0; i < player.equippedClips; i++) {
    clips.add(Container(
      color: white,
      width: 25,
      height: 50,
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.only(right: 5),
    ));
  }

  List<Widget> grenades = [];

  for (int i = 0; i < compiledGame.playerGrenades; i++) {
    grenades.add(Container(
        width: 60, height: 50, decoration: BoxDecoration(image: grenadeImage)));
  }

  List<Widget> healthPacks = [];

  for (int i = 0; i < compiledGame.playerMeds; i++) {
    healthPacks.add(Container(
        width: 60, height: 50, decoration: BoxDecoration(image: healthImage)));
  }

  Positioned bottomLeft = Positioned(
    left: 0,
    bottom: 5,
    child: Row(
      // crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            buildWeaponButton(compiledGame.playerWeapon),
            Row(
              children: clips,
            ),
          ],
        ),
        Row(
          children: grenades,
        ),
        // Container(
        //     color: Colors.black87,
        //     alignment: Alignment.center,
        //     height: 50,
        //     width: 100,
        //     child: text(compiledGame.playerGrenades.toString(), fontSize: 28)),
        Row(
          children: healthPacks,
        ),
        // Container(
        //     width: 120,
        //     height: 50,
        //     decoration: BoxDecoration(border: _border, image: healthImage)),
        // Container(
        //     color: Colors.black87,
        //     alignment: Alignment.center,
        //     height: 50,
        //     width: 100,
        //     child: text(compiledGame.playerMeds.toString(), fontSize: 28)),
      ],
    ),
  );

  Positioned bottomRight = Positioned(
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

  return Stack(
    children: [
      if (mouseAvailable && mouseX < 300 && mouseY < 300) topLeft,
      topRight,
      bottomLeft,
      if (compiledGame.gameType == GameType.Fortress) bottomRight,
      if (gameOver) buildGameOver(),
      if (playerHealth <= 0 && compiledGame.gameType == GameType.Casual) buildRespawn()
    ],
  );
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

Widget buildRespawn() {
  return Positioned(
      child: Container(
    width: globalSize.width,
    height: globalSize.height,
    color: Colors.black45,
    child: button("respawn", sendRequestRevive, fontSize: 30),
  ));
}

Widget buildDebugPanel() {
  return column([
    button("Respawn", sendRequestSpawn),
    button("Spawn NPC", sendRequestSpawnNpc),
    text("Ping: ${ping.inMilliseconds}"),
    text("Player Id: ${compiledGame.playerId}"),
    text("Player Health: $playerHealth / $playerMaxHealth"),
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

void showDebug() {
  debugMode = true;
}

void hideDebug() {
  debugMode = false;
}
