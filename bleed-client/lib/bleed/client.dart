import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_game_engine/game_engine/game_input.dart';
import 'package:flutter_game_engine/game_engine/game_widget.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'common.dart';
import 'common_functions.dart';
import 'draw.dart';
import 'resources.dart';
import 'input.dart';
import 'ui.dart';

import 'keys.dart';
import 'settings.dart';
import 'state.dart';
import 'utils.dart';

class BleedClient extends GameWidget {
  WebSocketChannel webSocketChannel;
  bool initialized = false;
  int fps = 30;
  int milliSecondsPerSecond = 1000;
  Size size;
  int frameRate = 5;
  int frameRateValue = 0;
  int packagesSent = 0;
  int packagesReceived = 0;
  int errors = 0;
  int dones = 0;
  bool connected = false;
  bool debugMode = false;
  int requestDirection = directionDown;
  int requestCharacterState = characterStateIdle;
  double requestAim = 0;
  TextEditingController playerNameController = TextEditingController();
  DateTime previousEvent = DateTime.now();
  int framesSinceEvent = 0;
  Duration ping;
  String event = "";
  dynamic valueObject;
  DateTime lastRefresh = DateTime.now();
  Duration refreshDuration;
  bool smooth = true;

  BuildContext context;

  static const String localhost = "ws://localhost:8080";
  static const gpc = 'wss://bleed-12-osbmaezptq-ey.a.run.app/:8080';
  static const host = localhost;

  Uri get hostURI => Uri.parse(host);

  @override
  bool uiVisible() => true;

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
                      requestSpawn(playerNameController.text.trim());
                      Navigator.of(context).pop();
                    }
                  : null,
            ),
          ],
        );
      },
    );
  }

  @override
  Widget buildUI(BuildContext context) {
    this.context = context;
    if (!connected) return text("Connecting");

    return column(
      [
        if (connected) button("Disconnect", disconnect),
        if (!connected) button("Connect", connect),
        if (!debugMode) button("Show Debug", showDebug),
        if (debugMode) button("Hide Debug", hideDebug),
        text("Date Size: ${event.length}"),
        text("Frames since event: $framesSinceEvent"),
        text("Players: ${players.length}"),
        text("Npcs: ${npcs.length}"),
        text("Player Assigned: $playerAssigned"),
        button("smoothing $smooth", () => smooth = !smooth),
        if (debugMode)
          column([
            text("Server Host: $host"),
            text("Connected. Id: $id"),
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
            if (playerAssigned)
              text("playerScreenPositionX: ${playerScreenPositionX().round()}"),
            if (playerAssigned)
              text("playerScreenPositionY: ${playerScreenPositionY().round()}"),
            text("Errors: $errors"),
            text("Dones: $dones"),
          ])
      ],
    );
  }

  void disconnect() {
    connected = false;
    webSocketChannel.sink.close();
  }

  void showDebug() {
    debugMode = true;
  }

  void hideDebug() {
    debugMode = false;
  }

  void requestSpawn(String playerName) {
    print("request spawn");
    Map<String, dynamic> request = Map();
    request[keyCommand] = commandSpawn;
    request[keyPlayerName] = playerName;
    sendToServer(request);
  }

  void sendCommandAttack() {
    if (!playerAssigned) return;
    Map<String, dynamic> request = Map();
    request[keyCommand] = commandAttack;
    request[keyId] = id;
    request[keyRotation] = getMouseRotation();
    sendToServer(request);
  }

  void sendCommand(int value) {
    if (!connected) return;
    Map<String, dynamic> request = Map();
    request[keyCommand] = value;
    sendToServer(request);
  }

  void smoothings() {
    if (framesSinceEvent > 10) return;

    for (dynamic character in players) {
      double speed = 2;
      if (character[0] != characterStateWalking) {
        continue;
      }
      switch (getDirection(character)) {
        case directionUp:
          character[3] -= speed;
          break;
        case directionUpRight:
          character[2] += speed * 0.5;
          character[3] -= speed * 0.5;
          break;
        case directionRight:
          character[2] += speed;
          break;
        case directionDownRight:
          character[2] += speed * 0.5;
          character[3] += speed * 0.5;
          break;
        case directionDown:
          character[3] += speed;
          break;
        case directionDownLeft:
          character[2] -= speed * 0.5;
          character[3] += speed * 0.5;
          break;
        case directionLeft:
          character[2] -= speed;
          break;
        case directionUpLeft:
          character[2] -= speed * 0.5;
          character[3] -= speed * 0.5;
          break;
      }
      break;
    }
  }

  @override
  void fixedUpdate() {
    DateTime now = DateTime.now();
    refreshDuration = now.difference(lastRefresh);
    lastRefresh = DateTime.now();
    framesSinceEvent++;

    if (smooth) {
      smoothings();
    }

    controlCamera();

    if (!initialized) {
      initialized = true;
      return;
    }

    if (!playerAssigned) return;

    dynamic playerCharacter = getPlayerCharacter();
    double playerScreenX = playerCharacter[posX] - cameraX;
    double playerScreenY = playerCharacter[posY] - cameraY;
    double halfScreenWidth = size.width * 0.5;
    double halfScreenHeight = size.height * 0.5;
    double xOffset = halfScreenWidth - playerScreenX;
    double yOffset = halfScreenHeight - playerScreenY;
    cameraX -= (xOffset * cameraFollow);
    cameraY -= (yOffset * cameraFollow);

    if (keyPressedSpawnZombie) {
      sendCommand(commandSpawnZombie);
      return;
    }

    requestCharacterState = characterStateWalking;

    if (keyPressedSpace) {
      requestCharacterState = characterStateAiming;
    }

    if (keyEquipHandGun) {
      sendCommandEquipHandGun();
    }

    if (keyEquipShotgun) {
      sendCommandEquipShotgun();
    }

    if (keyPressedW) {
      if (keyPressedD) {
        requestDirection = directionUpRight;
      } else if (keyPressedA) {
        requestDirection = directionUpLeft;
      } else {
        requestDirection = directionUp;
      }
    } else if (keyPressedS) {
      if (keyPressedD) {
        requestDirection = directionDownRight;
      } else if (keyPressedA) {
        requestDirection = directionDownLeft;
      } else {
        requestDirection = directionDown;
      }
    } else if (keyPressedA) {
      requestDirection = directionLeft;
    } else if (keyPressedD) {
      requestDirection = directionRight;
    } else {
      if (!keyPressedSpace) {
        requestCharacterState = characterStateIdle;
      }
    }
    sendCommandUpdate();
  }

  void controlCamera() {
    if (keyPressedRightArrow) {
      cameraX += cameraSpeed;
    }
    if (keyPressedLeftArrow) {
      cameraX -= cameraSpeed;
    }
    if (keyPressedDownArrow) {
      cameraY += cameraSpeed;
    }
    if (keyPressedUpArrow) {
      cameraY -= cameraSpeed;
    }
  }

  @override
  void onMouseClick() {
    sendCommandAttack();
  }

  @override
  Future init() async {
    loadResources();
    connect();
    // Timer(Duration(milliseconds: 100), showChangeNameDialog);
    Timer(Duration(seconds: 2), () {
      requestSpawn('hello');
    });
  }

  void connect() {
    try {
      webSocketChannel = WebSocketChannel.connect(hostURI);
      webSocketChannel.stream.listen(onEvent, onError: onError, onDone: onDone);
      connected = true;
    } catch (error) {
      errors++;
    }
  }

  void sendCommandEquipHandGun() {
    sendCommandEquip(weaponHandgun);
  }

  void sendCommandEquipShotgun() {
    sendCommandEquip(weaponShotgun);
  }

  void sendCommandEquip(int weapon) {
    Map<String, dynamic> request = Map();
    request[keyCommand] = commandEquip;
    request[keyEquipValue] = weapon;
    request[keyId] = id;
    sendToServer(request);
  }

  void sendCommandUpdate() {
    Map<String, dynamic> request = Map();
    request[keyCommand] = commandUpdate;
    if (playerAssigned) {
      request['s'] = requestCharacterState;
      request[keyId] = id;
      if (requestCharacterState == characterStateAiming && mouseAvailable) {
        request[keyAimAngle] = getMouseRotation();
      }else{
        request['d'] = requestDirection;
      }
    }
    sendToServer(request);
  }

  void onEvent(dynamic valueString) {
    framesSinceEvent = 0;
    DateTime now = DateTime.now();
    ping = now.difference(previousEvent);
    previousEvent = DateTime.now();
    packagesReceived++;
    event = valueString;
    valueObject = decode(valueString);
    if (valueObject[keyNpcs] != null) {
      npcs = unparseNpcs(valueObject[keyNpcs]);
    }
    if (valueObject[keyPlayers] != null) {
      players = unparsePlayers(valueObject[keyPlayers]);
    }
    if (id < 0 && valueObject[keyId] != null) {
      id = valueObject[keyId];
      cameraX = playerCharacter[posX] - (size.width * 0.5);
      cameraY = playerCharacter[posY] - (size.height * 0.5);
    }

    // Play bullet audio
    if (valueObject[keyBullets] != null) {
      if ((valueObject[keyBullets] as List).length > bullets.length) {
        playPistolAudio();
      }
      bullets.clear();
      bullets = valueObject[keyBullets];
    }
    forceRedraw();
  }

  void onError(dynamic value) {
    errors++;
  }

  void onDone() {
    dones++;
    connected = false;
  }

  void sendToServer(dynamic event) {
    if (!connected) return;
    webSocketChannel.sink.add(encode(event));
    packagesSent++;
  }

  @override
  void draw(Canvas canvass, Size size) {
    this.size = size;
    canvas = canvass;
    if (!connected) return;

    frameRateValue++;
    if (frameRateValue % frameRate == 0) {
      drawFrame++;
    }

    if (mousePosX != null) {
      drawCircleOutline(
          radius: 5,
          x: mousePosX + cameraX,
          y: mousePosY + cameraY,
          color: white);
    }

    drawTiles();
    drawBullets();
    try{
      drawCharacters();
    }catch(e){
      print(e);
    }


    dynamic player = getPlayerCharacter();
    if (player != null && getState(player) == characterStateAiming) {
      double accuracy = player[keyAccuracy];
      double l = player[keyAimAngle] - (accuracy * 0.5);
      double r = player[keyAimAngle] + (accuracy * 0.5);
      drawLineRotation(player, l, bulletRange);
      drawLineRotation(player, r, bulletRange);
    }
  }

  void drawBulletRange() {
    if (!playerAssigned) return;
    dynamic player = getPlayerCharacter();
    drawCircleOutline(
        radius: bulletRange, x: player[posX], y: player[posY], color: white);
  }
}
