import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';

import 'common.dart';
import 'common_functions.dart';
import 'functions/spawn_random_zombie.dart';
import 'settings.dart';
import 'update.dart';
import 'utils.dart';
import 'state.dart';

void main() {
  print('starting web socket server');

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
