import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';

import 'common.dart';
import 'common_functions.dart';
import 'functions/spawn_random_zombie.dart';
import 'maths.dart';
import 'physics.dart';
import 'settings.dart';
import 'utils.dart';
import 'state.dart';

void main() {
  print('starting web socket server');

  void updateBullets() {
    for (int i = 0; i < bullets.length; i++) {
      dynamic bullet = bullets[i];
      bullet[keyFrame]++;
      bullet[keyPositionX] += bullet[keyVelocityX];
      bullet[keyPositionY] += bullet[keyVelocityY];

      if (bulletDistanceTravelled(bullet) > bulletRange) {
        bullets.removeAt(i);
        i--;
        continue;
      }

      for (int j = 0; j < characters.length; j++) {
        if (bullet[keyCharacterId] == characters[j][keyCharacterId]) continue;
        if (isDead(characters[j])) continue;
        double dis = distanceBetween(characters[j], bullet);
        if (dis < characterBulletRadius) {
          dynamic characterJ = characters[j];
          bullets.removeAt(i);
          i--;
          characterJ[keyHealth]--;
          if (characterJ[keyHealth] <= 0) {
            characterJ[keyState] = characterStateDead;
            characterJ[keyFrameOfDeath] = frame;
          }



          break;
        }
      }
    }
  }

  void updateCharacters() {
    for (int i = 0; i < characters.length; i++) {
      dynamic character = characters[i];

      if (isHuman(character) && connectionExpired(character)) {
        characters.removeAt(i);
        i--;
        continue;
      }
      if (isDead(character)) {
        if (frame - character[keyFrameOfDeath] > 120) {
          if (isNpc(character)) {
            characters.removeAt(i);
            i--;
          } else {
            character[keyState] = characterStateIdle;
            setPosition(character, x: 0, y: 0);
          }
        }
      }
    }

    for (int i = 0; i < characters.length; i++) {
      dynamic character = characters[i];
      // TODO Remove this hack
      if (character[keyPositionX] == double.nan) {
        print("character x is nan");
        character[keyPositionX] = 0;
        character[keyPositionY] = 0;
      }

      if (isNpc(character) && isAlive(character)) {
        if (!npcTargetSet(character)) {
          for (int j = 0; j < characters.length; j++) {
            if (isNpc(characters[j])) continue;
            dynamic characterJ = characters[j];
            if (distanceBetween(character, characterJ) < 300) {
              character[keyNpcTarget] = characterJ[keyCharacterId];
              break;
            }
          }
        } else {
          dynamic target = npcTarget(character);
          double angle = radionsBetweenObject(character, target);
          setCharacterState(character, characterStateWalking);
          setDirection(character, convertAngleToDirection(angle));
        }
      }

      character[keyPositionX] += character[keyVelocityX];
      character[keyPositionY] += character[keyVelocityY];
      character[keyVelocityX] *= velocityFriction;
      character[keyVelocityY] *= velocityFriction;

      switch (character[keyState]) {
        case characterStateIdle:
          break;
        case characterStateWalking:
          double speed = getSpeed(character);
          switch (character[keyDirection]) {
            case directionUp:
              character[keyPositionY] -= speed;
              break;
            case directionUpRight:
              character[keyPositionX] += speed * 0.5;
              character[keyPositionY] -= speed * 0.5;
              break;
            case directionRight:
              character[keyPositionX] += speed;
              break;
            case directionDownRight:
              character[keyPositionX] += speed * 0.5;
              character[keyPositionY] += speed * 0.5;
              break;
            case directionDown:
              character[keyPositionY] += speed;
              break;
            case directionDownLeft:
              character[keyPositionX] -= speed * 0.5;
              character[keyPositionY] += speed * 0.5;
              break;
            case directionLeft:
              character[keyPositionX] -= speed;
              break;
            case directionUpLeft:
              character[keyPositionX] -= speed * 0.5;
              character[keyPositionY] -= speed * 0.5;
              break;
          }
          break;
      }
    }
  }

  void fixedUpdate() {
    frame++;
    updateCharacters();
    updateCollisions(characters);
    updateBullets();
  }

  void spawnZombieJob() {
    if (getNpcs().length >= maxZombies) return;
    spawnRandomZombie();
  }

  Timer.periodic(Duration(milliseconds: 1000 ~/ 60), (timer) {
    fixedUpdate();
  });

  Timer.periodic(Duration(seconds: 5), (timer) {
    spawnZombieJob();
  });

  var handler = webSocketHandler((webSocket) {
    void sendToClient(dynamic response) {
      webSocket.sink.add(jsonEncode(response));
    }

    void handleCommandSpawn(dynamic request) {
      var character = spawnPlayer(0, 0, request[keyPlayerName]);
      Map<String, dynamic> response = Map();
      response[keyCharacterId] = getId(character);
      response[keyCharacters] = characters;
      response[keyBullets] = bullets;
      sendToClient(response);
      return;
    }

    void onEvent(requestString) {
      dynamic request = jsonDecode(requestString);
      switch (request[keyCommand]) {
        case commandSpawn:
          handleCommandSpawn(request);
          return;
        case commandUpdate:
          Map<String, dynamic> response = Map();
          response[keyCommand] = commandUpdate;
          response[keyCharacters] = characters;
          response[keyBullets] = bullets;
          if (request[keyCharacterId] != null) {
            int playerId = request[keyCharacterId];
            dynamic playerCharacter = findCharacterById(playerId);
            if (playerCharacter == null) {
              handleCommandSpawn(request);
              return;
            } else if (playerCharacter[keyState] != characterStateDead) {
              int direction = request[keyDirection];
              int characterState = request[keyState];
              playerCharacter[keyState] = characterState;
              playerCharacter[keyDirection] = direction;
              playerCharacter[keyLastUpdateFrame] = frame;
              playerCharacter[keyAimAngle] = request[keyAimAngle];
            }
          }
          sendToClient(response);
          return;
        case commandSpawnZombie:
          spawnRandomZombie();
          return;
        case commandAttack:
          if (request[keyCharacterId] == null) return;
          int playerId = request[keyCharacterId];
          dynamic playerCharacter = findCharacterById(playerId);
          if (playerCharacter == null) return;
          if (!isAiming(playerCharacter)) return;
          Map<String, dynamic> bullet = Map();
          bullet[keyPositionX] = playerCharacter[keyPositionX];
          bullet[keyPositionY] = playerCharacter[keyPositionY];
          bullet[keyStartX] = playerCharacter[keyPositionX];
          bullet[keyStartY] = playerCharacter[keyPositionY];
          setVelocity(bullet, request[keyRotation], bulletSpeed);
          bullet[keyRotation] = request[keyRotation];
          bullet[keyFrame] = 0;
          bullet[keyCharacterId] = playerId;
          bullets.add(bullet);
      }
    }

    // onEvent
    webSocket.stream.listen(onEvent);
  });

  shelf_io.serve(handler, host, port).then((server) {
    print('Serving at wss://${server.address.host}:${server.port}');
  });
}
