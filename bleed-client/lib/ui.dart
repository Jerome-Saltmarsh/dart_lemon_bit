import 'package:bleed_client/editor/editor.dart';
import 'package:bleed_client/enums/ClientRequest.dart';
import 'package:bleed_client/game_engine/engine_state.dart';
import 'package:bleed_client/game_engine/game_widget.dart';
import 'package:bleed_client/game_engine/web_functions.dart';
import 'package:bleed_client/properties.dart';
import 'package:flutter/material.dart';

import 'classes/InventoryItem.dart';
import 'connection.dart';
import 'enums/InventoryItemType.dart';
import 'enums/Mode.dart';
import 'enums/Weapons.dart';
import 'images.dart';
import 'instances/game.dart';
import 'instances/inventory.dart';
import 'instances/settings.dart';
import 'send.dart';
import 'settings.dart';
import 'state.dart';
import 'utils.dart';

TextEditingController _playerNameController = TextEditingController();
ButtonStyle _buttonStyle = buildButtonStyle(Colors.white, 2);

void initUI() {
  onConnectError.stream.listen((event) {
    showConnectFailedDialog();
  });
}

Widget text(String value, {fontSize = 18}) {
  return Text(value, style: TextStyle(color: Colors.white, fontSize: fontSize));
}

Widget button(String value, Function onPressed,
    {double fontSize = 18.0, ButtonStyle buttonStyle}) {
  return OutlinedButton(
    child:
        Text(value, style: TextStyle(color: Colors.white, fontSize: fontSize)),
    style: buttonStyle ?? _buttonStyle,
    onPressed: onPressed,
  );
}

ButtonStyle buildButtonStyle(Color borderColor, double borderWidth) {
  return OutlinedButton.styleFrom(
    side: BorderSide(color: borderColor, width: borderWidth),
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(5))),
  );
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

Future<void> showConnectFailedDialog() async {
  return showDialog<void>(
    context: globalContext,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Connection Failed'),
        actions: <Widget>[
          TextButton(
              child: const Text('Okay'),
              onPressed: () {
                Navigator.of(context).pop();
              }),
        ],
      );
    },
  );
}

void connectToGCP() {
  connect(gpc);
}

Widget center(Widget child) {
  return Container(
    width: globalSize.width,
    height: globalSize.height,
    alignment: Alignment.center,
    child: child,
  );
}

Widget buildGameUI(BuildContext context) {
  if (globalSize == null) {
    return text("loading");
  }
  if (connecting) {
    return center(text("Connecting"));
  } else if (!connected) {
    return center(
      column([
        row([
          text("BLEED", fontSize: 120),
        ]),
        Container(
          height: 50,
        ),
        row([
          button('Localhost', connectLocalHost, fontSize: 21),
          Container(
            width: 10,
          ),
          button('GCP', connectToGCP, fontSize: 21),
          Container(
            width: 10,
          ),
          button('FULLSCREEN', requestFullScreen, fontSize: 21)
        ]),
      ]),
    );
  }

  if (gameId < 0) {
    return column([
      // button('Open World', () {
      //   send(ClientRequest.Game_Join_Open_World.index.toString());
      // }),
      button('Death Match', () {
        requestJoinRandomGame();
      }),
      // button('Create Game', (){}),
      // button('Join Game', (){})
    ]);
  }

  if (editMode) return buildEditorUI();

  if (game.playerId == -1) {
    return text("player id not assigned");
  }

  if (framesSinceEvent > 30) {
    return Container(
      width: globalSize.width,
      height: globalSize.height,
      alignment: Alignment.center,
      child: Container(child: text("Reconnecting...", fontSize: 30)),
    );
  }
  dynamic player = getPlayerCharacter();
  if (player == null) {
    return Container(
      width: globalSize.width,
      height: globalSize.height,
      alignment: Alignment.center,
      child: button("Spawn", sendRequestSpawn, fontSize: 100),
    );
  }

  return buildHud();
}

void requestJoinRandomGame() {
  send(ClientRequest.Game_Join_Random.index.toString());
}

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
            border: playerWeapon == weapon
                ? Border.all(
                    color: Colors.white, width: 5.0, style: BorderStyle.solid)
                : null,
            image: _getDecorationImage(weapon))),
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
  Positioned topLeft = Positioned(
    top: 0,
    left: 0,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            button(playMode ? 'Edit' : "Play", toggleMode),
            // text('mouseScreenX: ${mouseX.toInt()}, mouseScreenY: ${mouseY.toInt()}'),
            text('mouseWorldX: ${mouseWorldX.toInt()}, mouseWorldY: ${mouseWorldY.toInt()}'),
            text('Stamina: $playerStamina / $playerMaxStamina'),
            text('x: ${game.playerX}, y: ${game.playerY}'),
            text("zombies: ${game.npcs.length}"),
            text("players: ${game.players.length}"),
            text("zoom: ${zoom.toStringAsFixed(2)}"),
            text("cameraX: ${cameraX.toInt()}, cameraY: ${cameraY.toInt()}")
          ],
        )
      ],
    ),
  );

  Positioned topRight = Positioned(
      top: 0,
      right: 0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          button("FullScreen", requestFullScreen),
          button(settings.audioMuted ? 'Unmute Audio' : 'Mute Audio',
              settings.toggleAudioMuted),
        ],
      ));

  Positioned bottomLeft = Positioned(
    left: 0,
    bottom: 0,
    child: Row(
      children: [
        buildWeaponButton(playerWeapon),
        Container(
            color: Colors.black87,
            alignment: Alignment.center,
            height: 50,
            width: 100,
            child: text(handgunRounds.toString(), fontSize: 28)),
      ],
    ),
  );

  Positioned bottomRight = Positioned(
    right: 0,
    bottom: 0,
    child: buildInventory(),
  );

  Positioned center = Positioned(
      child: Container(
    width: globalSize.width,
    height: globalSize.height,
    color: Colors.black45,
    child: button("respawn", sendRequestRevive, fontSize: 30),
  ));

  return Stack(
    children: [topLeft, topRight, bottomLeft, bottomRight,
      if(playerHealth <= 0)
      center],
  );
}

Widget buildDebugPanel() {

  return column([
    button("Respawn", sendRequestSpawn),
    button("Spawn NPC", sendRequestSpawnNpc),
    button("Clear NPCS", sendRequestClearNpcs),
    text("Ping: ${ping.inMilliseconds}"),
    text("Player Id: ${game.playerId}"),
    text("Player Health: $playerHealth / $playerMaxHealth"),
    text("Data Size: ${event.length}"),
    text("Frames since event: $framesSinceEvent"),
    text("Milliseconds Since Last Frame: $millisecondsSinceLastFrame"),
    if (millisecondsSinceLastFrame > 0)
      text("FPS: ${(1000 / millisecondsSinceLastFrame).round()}"),
    if (serverFramesMS > 0)
      text("Server FPS: ${(1000 / serverFramesMS).round()}"),
    text("Players: ${game.players.length}"),
    text("Bullets: ${game.bullets.length}"),
    text("Npcs: ${game.npcs.length}"),
    text("Player Assigned: $playerAssigned"),
  ]);
}

void showDebug() {
  debugMode = true;
}

void hideDebug() {
  debugMode = false;
}
