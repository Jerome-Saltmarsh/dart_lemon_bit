import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';

import 'common.dart';
import 'common_functions.dart';
import 'settings.dart';
import 'update.dart';
import 'utils.dart';
import 'state.dart';

void main() {
  print('starting web socket server');

  initUpdateLoop();

  var handler = webSocketHandler((webSocket) {
    void sendToClient(dynamic response) {
      webSocket.sink.add(encode(response));
    }

    void handleCommandSpawn(dynamic request) {
      var character = spawnPlayer(0, 0, request[keyPlayerName]);
      Map<String, dynamic> response = Map();
      response[keyId] = getId(character);
      response[keyCharacters] = parseCharacters();
      response[keyBullets] = bullets;
      response['p'] = parseCharacterToString(character);
      sendToClient(response);
      return;
    }

    void handleCommandUpdate(dynamic request){
      Map<String, dynamic> response = Map();
      // response[keyCharacters] = characters;
      response[keyBullets] = bullets;
      response[keyCharacters] = parseCharacters();

      if (request[keyId] != null) {
        int playerId = request[keyId];
        dynamic character = findCharacterById(playerId);
        if (character == null) {
          handleCommandSpawn(request);
          return;
        } else if (isAlive(character) && !isFiring(character)) {
          setCharacterState(character, request['s']);
          setDirection(character, request['d']);
          response['p'] = parseCharacterToString(character);

          // TODO
          // set that in privateCharacter
          // character[keyLastUpdateFrame] = frame;
          // character[keyAimAngle] = request[keyAimAngle];
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
