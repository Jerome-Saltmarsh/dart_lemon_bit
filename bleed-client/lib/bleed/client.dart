import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_game_engine/game_engine/game_input.dart';
import 'package:flutter_game_engine/game_engine/game_widget.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'common.dart';
import 'parsing.dart';
import 'connection.dart';
import 'draw.dart';
import 'resources.dart';
import 'input.dart';
import 'ui.dart';

import 'keys.dart';
import 'settings.dart';
import 'state.dart';
import 'utils.dart';

class BleedClient extends GameWidget {

  @override
  bool uiVisible() => true;

  @override
  Widget buildUI(BuildContext bc) {
    context = bc;
    return buildDebugUI(context);
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
    sendCommandFire();
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

  @override
  void draw(Canvas canvass, Size _size) {
    size = _size;
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
    // dynamic player = getPlayerCharacter();
    // if (player != null && getState(player) == characterStateAiming) {
    //   double accuracy = player[keyAccuracy];
    //   double l = player[keyAimAngle] - (accuracy * 0.5);
    //   double r = player[keyAimAngle] + (accuracy * 0.5);
    //   drawLineRotation(player, l, bulletRange);
    //   drawLineRotation(player, r, bulletRange);
    // }
  }
}
