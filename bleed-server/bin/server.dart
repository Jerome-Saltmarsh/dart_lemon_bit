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
        if (bullet[keyId] == characters[j][keyId]) continue;
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
          characterJ[keyVelocityX] += bullet[keyVelocityX] * 0.25;
          characterJ[keyVelocityY] += bullet[keyVelocityY] * 0.25;
          break;
        }
      }
    }
  }

  void updateCharacter(dynamic character) {
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
          if (distanceBetween(character, characterJ) < zombieViewRange) {
            npcSetTarget(character, characterJ);
            break;
          }
        }

        if (npcDestinationSet(character)) {
          if (npcArrivedAtDestination(character)) {
            setCharacterStateIdle(character);
            npcClearDestination(character);
          } else {
            npcFaceDestination(character);
            setCharacterStateWalk(character);
          }
        }
      } else {
        dynamic target = npcTarget(character);
        if (target == null || isDead(target)) {
          npcClearTarget(character);
        } else {
          double angle = radionsBetweenObject(character, target);
          setCharacterState(character, characterStateWalking);
          setDirection(character, convertAngleToDirection(angle));
        }
      }
    }

    character[keyPositionX] += character[keyVelocityX];
    character[keyPositionY] += character[keyVelocityY];
    character[keyVelocityX] *= velocityFriction;
    character[keyVelocityY] *= velocityFriction;

    switch (character[keyState]) {
      case characterStateAiming:
        if (character[keyPreviousState] != characterStateAiming) {
          character[keyAccuracy] = startingAccuracy;
        }
        if (character[keyAccuracy] > 0.05) {
          character[keyAccuracy] -= 0.005;
        }
        break;
      case characterStateFiring:
        character[keyShotCoolDown]--;
        if (character[keyShotCoolDown] <= 0) {
          setCharacterStateIdle(character);
        }
        break;
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

    if (character[keyPreviousState] != character[keyState]) {
      character[keyPreviousState] = character[keyState];
      character[keyStateDuration] = 0;
    } else {
      character[keyStateDuration]++;
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

    characters.forEach(updateCharacter);
  }

  void fixedUpdate() {
    frame++;
    updateCharacters();
    updateCollisions(characters);
    updateBullets();

    for (dynamic character in characters) {
      roundKey(character, keyPositionX);
      roundKey(character, keyPositionY);
      if (character[keyDestinationX] != null) {
        roundKey(character, keyDestinationX);
        roundKey(character, keyDestinationY);
      }
      if (character[keyVelocityX] != null) {
        roundKey(character, keyVelocityX, decimals: 2);
        roundKey(character, keyVelocityY, decimals: 2);
      }
    }
  }

  void spawnZombieJob() {
    if (getNpcs().length >= maxZombies) return;
    spawnRandomZombie();
  }

  createJob(fixedUpdate, ms: 1000 ~/ 60);
  createJob(spawnZombieJob, seconds: 5);
  createJob(npcWanderJob, seconds: 10);

  var handler = webSocketHandler((webSocket) {
    void sendToClient(dynamic response) {
      webSocket.sink.add(encode(response));
    }

    void handleCommandSpawn(dynamic request) {
      var character = spawnPlayer(0, 0, request[keyPlayerName]);
      Map<String, dynamic> response = Map();
      response[keyId] = getId(character);
      response[keyCharacters] = characters;
      response[keyBullets] = bullets;
      sendToClient(response);
      return;
    }

    void handleCommandUpdate(dynamic request){
      Map<String, dynamic> response = Map();
      response[keyCommand] = commandUpdate;
      response[keyCharacters] = characters;
      response[keyBullets] = bullets;
      if (request[keyId] != null) {
        int playerId = request[keyId];
        dynamic character = findCharacterById(playerId);
        if (character == null) {
          handleCommandSpawn(request);
          return;
        } else if (isAlive(character) && !isFiring(character)) {
          int direction = request[keyDirection];
          int characterState = request[keyState];
          character[keyState] = characterState;
          character[keyDirection] = direction;
          character[keyLastUpdateFrame] = frame;
          character[keyAimAngle] = request[keyAimAngle];
        }
      }
      sendToClient(response);
    }

    void handleCommandAttack(dynamic request){
      if (request[keyId] == null) return;
      int playerId = request[keyId];
      dynamic character = findCharacterById(playerId);
      if (character == null) return;
      if (!isAiming(character)) return;
      character[keyRotation] = request[keyRotation];
      fireWeapon(character);
    }

    void handleRequestEquip(dynamic request){
      if (request[keyId] == null) return;
      int playerId = request[keyId];
      dynamic character = findCharacterById(playerId);
      if (character == null) return;
      switch (request[keyEquipValue]) {
        case weaponHandgun:
          character[keyWeapon] = weaponHandgun;
          break;
        case weaponShotgun:
          character[keyWeapon] = weaponShotgun;
          break;
      }
    }

    void onEvent(data) {
      dynamic request = decode(data);
      switch (request[keyCommand]) {
        case commandSpawn:
          handleCommandSpawn(request);
          break;
        case commandUpdate:
          handleCommandUpdate(request);
          break;
        case commandSpawnZombie:
          spawnRandomZombie();
          break;
        case commandAttack:
          handleCommandAttack(request);
          break;
        case commandEquip:
          handleRequestEquip(request);
          break;
      }
    }

    webSocket.stream.listen(onEvent);
  });

  shelf_io.serve(handler, host, port).then((server) {
    print('Serving at wss://${server.address.host}:${server.port}');
  });
}
