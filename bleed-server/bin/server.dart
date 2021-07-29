import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';

import 'classes.dart';
import 'common.dart';
import 'conversion.dart';
import 'settings.dart';
import 'update.dart';
import 'utils.dart';

void main() {
  print('starting web socket server');

  initUpdateLoop();

  var handler = webSocketHandler((webSocket) {

    void sendToClient(String response) {
      webSocket.sink.add(compressText(response));
    }

    void handleRequestSpawn(dynamic request) {
      var character = spawnPlayer("test");
      String response = "id:${character.id};";
      sendToClient(response);
      return;
    }

    void handleRequestUpdate(dynamic request) {
      if (request[keyId] != null) {
        int playerId = request[keyId];
        try {
          Character character = findPlayerById(playerId);
          if (character.alive && !character.firing) {
            if (request['s'] != null){
              setCharacterState(character, CharacterState.values[request['s']]);
            }
            if (character.aiming) {
              if(request[keyAimAngle] != null){
                character.direction = convertAngleToDirection(request[keyAimAngle]);
              }
            } else {
              character.direction =  Direction.values[request['d']];
            }
          }
        } catch (exception) {
          print(exception);
        }
      }
      // Map<String, dynamic> response = Map();
      // response[keyBullets] = parseBullets();
      // response[keyNpcs] = parseNpcs();
      // response[keyPlayers] = parsePlayers();
      sendToClient(compileState());
    }

    void handleRequestAttack(dynamic request) {
      if (request[keyId] == null) return;
      if (request[keyRotation] == null) return;
      double angle = request[keyRotation];
      int playerId = request[keyId];
      Character player = findPlayerById(playerId);
      if (!player.aiming) return;
      player.direction = convertAngleToDirection(angle);
      fireWeapon(player, angle);
    }

    void handleRequestEquip(dynamic request) {
      if (request[keyId] == null) return;
      Character player = findPlayerById(request[keyId]);
      player.weapon = Weapon.values[request[keyEquipValue]];
    }

    void onEvent(data) {
      dynamic request = decode(data);
      switch (request[keyCommand]) {
        case commandSpawn:
          handleRequestSpawn(request);
          break;
        case commandUpdate:
          handleRequestUpdate(request);
          break;
        case commandSpawnZombie:
          spawnRandomNpc();
          break;
        case commandAttack:
          handleRequestAttack(request);
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
