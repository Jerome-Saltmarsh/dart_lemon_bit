import 'package:flutter/material.dart';
import 'package:flutter_game_engine/game_engine/game_widget.dart';
import 'package:flutter_game_engine/game_engine/web_functions.dart';

import 'connection.dart';
import 'send.dart';
import 'settings.dart';
import 'state.dart';
import 'utils.dart';

TextEditingController playerNameController = TextEditingController();

void initUI(){
  onConnectError.stream.listen((event) {
    showConnectFailedDialog();
    forceRedraw();
  });
}

Widget text(String value, {fontSize = 18}) {
  return Text(value, style: TextStyle(color: Colors.white, fontSize: fontSize));
}

Widget button(String value, Function onPressed, {fontSize = 18}) {
  return OutlinedButton(
    child:
        Text(value, style: TextStyle(color: Colors.white, fontSize: fontSize)),
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
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start, children: children);
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
            onPressed: (){
              Navigator.of(context).pop();
            }
          ),
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
    width: size.width,
    height: size.height,
    alignment: Alignment.center,
    child: child,
  );
}

Widget buildDebugUI(BuildContext context) {
  if (connecting) {
    return center(text("Connecting"));
  } else if (!connected) {
    return center(
      column([
        row([
          text("BLEED", fontSize: 120),
        ]),
        Container(height: 50,),
        row([
          button('Localhost', connectLocalHost, fontSize: 21),
          Container(width: 10,),
          button('GCP', connectToGCP, fontSize: 21),
          Container(width: 10,),
          button('FULLSCREEN', requestFullScreen, fontSize: 21)
        ]),
      ]),
    );
  }

  if (framesSinceEvent > 30) {
    return Container(
      width: size.width,
      height: size.height,
      alignment: Alignment.center,
      child: Container(child: text("Reconnecting...", fontSize: 30)),
    );
  }
  dynamic player = getPlayerCharacter();
  if (player != null) {
    if (isDead(player)) {
      return Container(
        width: size.width,
        height: size.height,
        alignment: Alignment.center,
        child: button("Revive", sendRequestRevive, fontSize: 40),
      );
    }
  } else {
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
      button("FullScreen", requestFullScreen),
      if (playerAssigned) text("X: $playerX Y: $playerY"),
      if (debugMode)
        column([
          button("Respawn", sendRequestSpawn),
          button("Spawn NPC", sendRequestSpawnNpc),
          button("Clear NPCS", sendRequestClearNpcs),
          text("Ping: ${ping.inMilliseconds}"),
          text("Pass: $pass"),
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
          // button('First Pass: $firstPass', sendTogglePass1),
          // button('Second Pass: $secondPass', sendTogglePass2),
          // button('Third Pass: $thirdPass', sendTogglePass3),
          // button('Fourth Pass: $fourthPass', sendTogglePass4),
          button("smoothing $smooth", () => smooth = !smooth),
        ]),
    ],
  );
}

void showDebug() {
  debugMode = true;
}

void hideDebug() {
  debugMode = false;
}
