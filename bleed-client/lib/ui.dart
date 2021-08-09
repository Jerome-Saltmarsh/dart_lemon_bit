import 'package:flutter/material.dart';
import 'package:bleed_client/game_engine/engine_state.dart';
import 'package:bleed_client/game_engine/game_widget.dart';
import 'package:bleed_client/game_engine/web_functions.dart';

import 'connection.dart';
import 'enums/Weapons.dart';
import 'send.dart';
import 'settings.dart';
import 'state.dart';
import 'utils.dart';

TextEditingController _playerNameController = TextEditingController();
ButtonStyle _buttonStyle = buildButtonStyle(Colors.white, 2);

void initUI() {
  onConnectError.stream.listen((event) {
    showConnectFailedDialog();
    forceRedraw();
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
        borderRadius: BorderRadius.all(Radius.circular(10))),
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
    context: context,
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
    context: context,
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

  if (framesSinceEvent > 30) {
    return Container(
      width: globalSize.width,
      height: globalSize.height,
      alignment: Alignment.center,
      child: Container(child: text("Reconnecting...", fontSize: 30)),
    );
  }
  dynamic player = getPlayerCharacter();
  if (player != null) {
    if (isDead(player)) {
      return Container(
        width: globalSize.width,
        height: globalSize.height,
        alignment: Alignment.center,
        child: button("Revive", sendRequestRevive, fontSize: 40),
      );
    }
  } else {
    if (playerUUID.isNotEmpty) {
      return Text("Loading Players");
    }

    return Container(
      width: globalSize.width,
      height: globalSize.height,
      alignment: Alignment.center,
      child: button("Spawn", sendRequestSpawn, fontSize: 40),
    );
  }

  return buildHud();
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

Widget buildHud() {
  return column(
    [
      button("FullScreen", requestFullScreen),
      text('x: $playerX, y: $playerY'),
      text('Stamina: $playerStamina / $playerMaxStamina'),
      if (debugMode) buildDebugPanel(),
      buildWeaponButton(Weapon.HandGun),
      text('$handgunRounds / $handgunClipSize - $handgunClips'),
      buildWeaponButton(Weapon.Shotgun),
      buildWeaponButton(Weapon.SniperRifle),
      buildWeaponButton(Weapon.MachineGun),
    ],
  );
}

Widget buildDebugPanel() {
  return column([
    button("Respawn", sendRequestSpawn),
    button("Spawn NPC", sendRequestSpawnNpc),
    button("Clear NPCS", sendRequestClearNpcs),
    text("Ping: ${ping.inMilliseconds}"),
    text("Player Id: $playerId"),
    text("Player Health: $playerHealth / $playerMaxHealth"),
    text("Data Size: ${event.length}"),
    text("Frames since event: $framesSinceEvent"),
    text("Milliseconds Since Last Frame: $millisecondsSinceLastFrame"),
    if (millisecondsSinceLastFrame > 0)
      text("FPS: ${(1000 / millisecondsSinceLastFrame).round()}"),
    if (serverFramesMS > 0)
      text("Server FPS: ${(1000 / serverFramesMS).round()}"),
    text("Players: ${players.length}"),
    text("Bullets: ${bullets.length}"),
    text("Npcs: ${npcs.length}"),
    text("Player Assigned: $playerAssigned"),
  ]);
}

void showDebug() {
  debugMode = true;
}

void hideDebug() {
  debugMode = false;
}
