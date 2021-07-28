import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_game_engine/game_engine/game_input.dart';
import 'package:flutter_game_engine/game_engine/game_widget.dart';
import 'package:flutter_game_engine/multiplayer/common_functions.dart';
import 'package:flutter_game_engine/multiplayer/settings.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'common.dart';
import 'multiplayer_resources.dart';
import 'multiplayer_input.dart';
import 'mutliplayer_ui.dart';

import 'state.dart';
import 'utils.dart';

class MultiplayerClient extends GameWidget {
  WebSocketChannel webSocketChannel;
  bool initialized = false;
  int fps = 30;
  int milliSecondsPerSecond = 1000;
  Canvas canvas;
  Size size;
  int drawFrame = 0;
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
  TextEditingController playerNameController = TextEditingController();
  DateTime previousEvent = DateTime.now();
  int framesSinceEvent = 0;
  Duration ping;
  String event = "";
  dynamic valueObject;
  DateTime lastRefresh = DateTime.now();
  Duration refreshDuration;

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
        text("Direction: $requestDirection"),
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

  @override
  void fixedUpdate() {
    DateTime now = DateTime.now();
    refreshDuration = now.difference(lastRefresh);
    lastRefresh = DateTime.now();
    framesSinceEvent++;

    // if(framesSinceEvent < 10){
    //   for(dynamic character in characters){
    //     double speed = 2;
    //     switch (getDirection(character)) {
    //       case directionUp:
    //         character[3] -= speed;
    //         break;
    //       case directionUpRight:
    //         character[2] += speed * 0.5;
    //         character[3] -= speed * 0.5;
    //         break;
    //       case directionRight:
    //         character[2] += speed;
    //         break;
    //       case directionDownRight:
    //         character[2] += speed * 0.5;
    //         character[3] += speed * 0.5;
    //         break;
    //       case directionDown:
    //         character[2] += speed;
    //         break;
    //       case directionDownLeft:
    //         character[2] -= speed * 0.5;
    //         character[3] += speed * 0.5;
    //         break;
    //       case directionLeft:
    //         character[2] -= speed;
    //         break;
    //       case directionUpLeft:
    //         character[2] -= speed * 0.5;
    //         character[3] -= speed * 0.5;
    //         break;
    //     }
    //     break;
    //   }
    // }

    controlCamera();

    if (!initialized) {
      initialized = true;
      return;
    }

    if (!playerAssigned) return;

    dynamic playerCharacter = getPlayerCharacter();
    double playerScreenX = posX(playerCharacter) - cameraX;
    double playerScreenY = posY(playerCharacter) - cameraY;
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
      request['d'] = requestDirection;
      request[keyId] = id;
      if (requestCharacterState == characterStateAiming && mouseAvailable) {
        request[keyAimAngle] = getMouseRotation();
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
      cameraX = posX(playerCharacter) - (size.width * 0.5);
      cameraY = posY(playerCharacter) - (size.height * 0.5);
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
  void draw(Canvas canvas, Size size) {
    this.size = size;
    this.canvas = canvas;
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
    drawCharacters();

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
        radius: bulletRange, x: posX(player), y: posY(player), color: white);
  }

  void setColor(Color value) {
    globalPaint.color = value;
  }

  void drawCircleOutline(
      {int sides = 16, double radius, double x, double y, Color color}) {
    double r = (pi * 2) / sides;
    List<Offset> points = [];
    Offset z = Offset(x, y);
    setColor(color);
    for (int i = 0; i <= sides; i++) {
      double a1 = i * r;
      points
          .add(Offset(cos(a1) * radius - cameraX, sin(a1) * radius - cameraY));
    }
    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i] + z, points[i + 1] + z, globalPaint);
    }
  }

  void drawBullets() {
    bullets.forEach((bullet) {
      drawCircle(bullet['x'], bullet['y'], 2, Colors.white);
    });
  }

  void drawTiles() {
    if (tileGrass01 == null) return;

    double size = tileGrass01.width * 1.0;
    double sizeH = size * 0.5;

    int tiles = 5;

    for (int x = 0; x < tiles; x++) {
      drawGrassTile((sizeH * (5 - x)), (sizeH * x));
    }

    return;

    double d = 250;
    drawGrassTile(d + (sizeH * 3), d + (sizeH * 0));
    drawGrassTile(d + (sizeH * 2), d + (sizeH * 1));
    drawGrassTile(d + (sizeH * 1), d + (sizeH * 2));
    drawGrassTile(d + (sizeH * 0), d + (sizeH * 3));

    drawGrassTile(d + (sizeH * 4), d + (sizeH * 1));
    drawGrassTile(d + (sizeH * 3), d + (sizeH * 2));
    drawGrassTile(d + (sizeH * 2), d + (sizeH * 3));
    drawGrassTile(d + (sizeH * 1), d + (sizeH * 4));

    drawGrassTile(d + (sizeH * 5), d + (sizeH * 2));
    drawGrassTile(d + (sizeH * 4), d + (sizeH * 3));
    drawGrassTile(d + (sizeH * 3), d + (sizeH * 4));
    drawGrassTile(d + (sizeH * 2), d + (sizeH * 5));

    drawGrassTile(d + (sizeH * 6), d + (sizeH * 3));
    drawGrassTile(d + (sizeH * 5), d + (sizeH * 4));
    drawGrassTile(d + (sizeH * 4), d + (sizeH * 5));
    drawGrassTile(d + (sizeH * 3), d + (sizeH * 6));
  }

  void drawGrassTile(double x, double y) {
    drawImage(tileGrass01, x, y);
  }

  void drawCharacters() {
    if (spriteTemplate == null) return;
    players.sort((a, b) => posY(a) > posY(b) ? 1 : -1);
    players.where(isDead).forEach((drawCharacter));
    players.where(isAlive).forEach((drawCharacter));
    npcs.sort((a, b) => posY(a) > posY(b) ? 1 : -1);
    npcs.where(isDead).forEach((drawCharacter));
    npcs.where(isAlive).forEach((drawCharacter));
  }

  bool isAlive(dynamic character) {
    return getState(character) != characterStateDead;
  }

  bool isDead(dynamic character) {
    return getState(character) == characterStateDead;
  }

  void drawCharacter(dynamic character) {
    int totalFrames = 1;
    int startFrame = 0;

    switch (getState(character)) {
      case characterStateIdle:
        totalFrames = 1;
        switch (getDirection(character)) {
          case directionUp:
            startFrame = 3;
            break;
          case directionUpRight:
            startFrame = 0;
            break;
          case directionRight:
            startFrame = 1;
            break;
          case directionDownRight:
            startFrame = 2;
            break;
          case directionDown:
            startFrame = 3;
            break;
          case directionDownLeft:
            startFrame = 0;
            break;
          case directionLeft:
            startFrame = 1;
            break;
          case directionUpLeft:
            startFrame = 2;
            break;
        }
        break;
      case characterStateWalking:
        totalFrames = 3;
        switch (getDirection(character)) {
          case directionUp:
            startFrame = 13;
            break;
          case directionUpRight:
            startFrame = 4;
            break;
          case directionRight:
            startFrame = 7;
            break;
          case directionDownRight:
            startFrame = 10;
            break;
          case directionDown:
            startFrame = 13;
            break;
          case directionDownLeft:
            startFrame = 4;
            break;
          case directionLeft:
            startFrame = 7;
            break;
          case directionUpLeft:
            startFrame = 10;
            break;
        }
        break;
      case characterStateDead:
        switch (getDirection(character)) {
          case directionUp:
            startFrame = 19;
            break;
          case directionUpRight:
            startFrame = 16;
            break;
          case directionRight:
            startFrame = 17;
            break;
          case directionDownRight:
            startFrame = 19;
            break;
          case directionDown:
            startFrame = 19;
            break;
          case directionDownLeft:
            startFrame = 16;
            break;
          case directionLeft:
            startFrame = 17;
            break;
          case directionUpLeft:
            startFrame = 19;
            break;
        }
        break;
      case characterStateAiming:
        double eight = pi / 8.0;
        double quarter = pi / 4.0;
        if (character[keyAimAngle] < eight) {
          startFrame = 23;
        } else if (character[keyAimAngle] < eight + (quarter * 1)) {
          startFrame = 24;
        } else if (character[keyAimAngle] < eight + (quarter * 2)) {
          startFrame = 25;
        } else if (character[keyAimAngle] < eight + (quarter * 3)) {
          startFrame = 26;
        } else if (character[keyAimAngle] < eight + (quarter * 4)) {
          startFrame = 27;
        } else if (character[keyAimAngle] < eight + (quarter * 5)) {
          startFrame = 20;
        } else if (character[keyAimAngle] < eight + (quarter * 6)) {
          startFrame = 21;
        } else if (character[keyAimAngle] < eight + (quarter * 7)) {
          startFrame = 22;
        } else {
          startFrame = 23;
        }
        break;
      case characterStateFiring:
        double eight = pi / 8.0;
        double quarter = pi / 4.0;
        if (character[keyAimAngle] < eight) {
          startFrame = 31;
        } else if (character[keyAimAngle] < eight + (quarter * 1)) {
          startFrame = 32;
        } else if (character[keyAimAngle] < eight + (quarter * 2)) {
          startFrame = 33;
        } else if (character[keyAimAngle] < eight + (quarter * 3)) {
          startFrame = 34;
        } else if (character[keyAimAngle] < eight + (quarter * 4)) {
          startFrame = 35;
        } else if (character[keyAimAngle] < eight + (quarter * 5)) {
          startFrame = 28;
        } else if (character[keyAimAngle] < eight + (quarter * 6)) {
          startFrame = 29;
        } else if (character[keyAimAngle] < eight + (quarter * 7)) {
          startFrame = 30;
        } else {
          startFrame = 31;
        }
        break;
    }

    int spriteFrame = (drawFrame % totalFrames) + startFrame;
    int frameCount = 36;

    // drawCharacterCircle(
    //     character, character[keyCharacterId] == id ? Colors.blue : Colors.red);

    drawSprite(spriteTemplate, frameCount, spriteFrame, posX(character),
        posY(character));

    // drawText(character[keyPlayerName], posX(character),
    //     posY(character), Colors.white);
  }

  void drawCharacterCircle(dynamic value, Color color) {
    drawCircle(posX(value), posY(value), characterRadius, color);
  }
}
