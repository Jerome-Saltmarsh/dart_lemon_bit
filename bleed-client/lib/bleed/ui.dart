import 'package:flutter/material.dart';
import 'package:flutter_game_engine/bleed/parse.dart';
import 'package:flutter_game_engine/game_engine/engine_state.dart';
import 'package:flutter_game_engine/game_engine/game_widget.dart';

import 'connection.dart';
import 'resources.dart';
import 'send.dart';
import 'settings.dart';
import 'state.dart';
import 'utils.dart';

TextEditingController playerNameController = TextEditingController();

Widget text(String value, { fontSize = 18}) {
  return Text(value, style: TextStyle(color: Colors.white, fontSize: fontSize));
}

Widget button(String value, Function onPressed, { fontSize = 18 }) {
  return OutlinedButton(
    child: Text(value, style: TextStyle(color: Colors.white, fontSize: fontSize)),
    style: OutlinedButton.styleFrom(
      side: BorderSide(color: Colors.white, width: 2),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))),
    ),
    onPressed: onPressed,
  );
}

Widget column(List<Widget> children) {
  return Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: children);
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
                controller: playerNameController,
              )
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('PLAY'),
            onPressed: playerNameController.text.trim().length > 2
                ? () {
              loadAudioFiles();
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

Widget buildDebugUI(BuildContext context){
  if (!connected) return text("Connecting");

  if (framesSinceEvent > 30){
    return Container(
      width: size.width,
      height: size.height,
      alignment: Alignment.center,
      child: Container(child: text("Reconnecting...", fontSize: 30)),
    );
  }
  dynamic player = getPlayerCharacter();
  if (player != null){
    if(isDead(player)) {
      return Container(
        width: size.width,
        height: size.height,
        alignment: Alignment.center,
        child: button("Revive", sendRequestRevive, fontSize: 40),
      );
    }
  }else{
    return Container(
      width: size.width,
      height: size.height,
      alignment: Alignment.center,
      child: button("Spawn", sendRequestSpawn, fontSize: 40),
    );
  }

  return column(
    [
      if (!connected) button("Connect", connect),
      if (!debugMode) button("Show Debug", showDebug),
      if (debugMode) button("Hide Debug", hideDebug),
      button("Respawn", sendRequestSpawn),
      button("Spawn NPC", sendRequestSpawnNpc),
      button("Clear NPCS", sendRequestClearNpcs),
      text("Ping: ${ping.inMilliseconds}"),
      text("Pass: $pass"),
      text("Player Id: $playerId"),
      text("Player Health: $playerHealth / $playerMaxHealth"),
      text("Date Size: ${event.length}"),
      text("Frames since event: $framesSinceEvent"),
      text("Milliseconds Since Last Frame: $millisecondsSinceLastFrame"),
      if(millisecondsSinceLastFrame > 0)
        text("FPS: ${ (1000 / millisecondsSinceLastFrame).round() }"),
      if (serverFramesMS > 0)
        text("Server FPS: ${ (1000 / serverFramesMS).round() }"),
      text("Players: ${players.length}"),
      text("Bullets: ${bullets.length}"),
      text("Npcs: ${npcs.length}"),
      text("Player Assigned: $playerAssigned"),
      text('Request Direction $requestDirection'),
      text('Request State $requestCharacterState'),
      text('Cache Size $cacheSize'),
      button('First Pass: $firstPass', sendTogglePass1),
      button('Second Pass: $secondPass', sendTogglePass2),
      button('Third Pass: $thirdPass', sendTogglePass3),
      button('Fourth Pass: $fourthPass', sendTogglePass4),
      // text('First Pass $firstPassMS'),
      // text('Second Pass $firstPassMS'),
      button("smoothing $smooth", () => smooth = !smooth),
      if (debugMode)
        column([
          text("Server Host: $host"),
          text("Connected. Id: $playerId"),
          if (ping != null) text("Ping: ${ping.inMilliseconds}"),
          if (refreshDuration != null)
            text("Refresh: ${refreshDuration.inMilliseconds}"),
          text("Date Size: ${event.length}"),
          text("Packages Sent: $packagesSent"),
          text("Packages Received: $packagesReceived"),
          if (mousePosX != null) text("mousePosX: ${mousePosX.round()}"),
          if (mousePosY != null) text("mousePosY: ${mousePosY.round()}"),
          if (playerAssigned && mousePosX != null)
            text('mouseRotation: ${getMouseRotation().toStringAsFixed(2)}'),
          text("cameraX: ${cameraX.round()}"),
          text("cameraY: ${cameraY.round()}"),
          // if (playerAssigned)
          //   text("playerScreenPositionX: ${playerScreenPositionX().round()}"),
          // if (playerAssigned)
          //   text("playerScreenPositionY: ${playerScreenPositionY().round()}"),
          text("Errors: $errors"),
          text("Dones: $dones"),
        ])
    ],
  );
}

void showDebug() {
  debugMode = true;
}

void hideDebug() {
  debugMode = false;
}