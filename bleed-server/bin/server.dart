
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';

import 'classes/Game.dart';
import 'classes.dart';
import 'compile.dart';
import 'enums/Weapons.dart';
import 'enums.dart';
import 'instances/game.dart';
import 'settings.dart';
import 'state.dart';
import 'update.dart';
import 'utils.dart';

void main() {
  print('starting web socket server');
  generateTiles(game);
  initUpdateLoop();
  // initEvents();

  var handler = webSocketHandler((webSocket) {
    void sendToClient(String response) {
      webSocket.sink.add(response);
    }

    void sendCompiledState(Game game) {
      sendToClient(game.compiled);
    }

    void sendCompiledPlayerState(Game game, Player player) {
      StringBuffer buffer = StringBuffer(game.compiled);
      compilePlayer(buffer, player);
      sendToClient(buffer.toString());
    }

    void handleRequestSpawn() {
      var player = game.spawnPlayer(name: "Test");
      String response =
          "id: ${player.id} ${player.uuid} ${player.x.toInt()} ${player.y.toInt()} ; ";
      sendToClient(response);
      return;
    }

    void onEvent(requestD) {
      String request = requestD;

      if (request.startsWith("u:")) {
        List<String> attributes = request.split(" ");
        int id = int.parse(attributes[1]);
        Player? player = game.findPlayerById(id);
        if (player == null) {
          sendToClient('player-not-found ; ');
          return;
        }
        String uuid = attributes[2];
        if (uuid != player.uuid) {
          sendToClient('invalid-uuid ; ');
          return;
        }
        player.lastEventFrame = frame;
        CharacterState requestedState =
            CharacterState.values[int.parse(attributes[3])];
        Direction requestedDirection =
            Direction.values[int.parse(attributes[4])];
        double aim = double.parse(attributes[5]);
        player.aimAngle = aim;
        setDirection(player, requestedDirection);
        game.setCharacterState(player, requestedState);
        sendCompiledPlayerState(game, player);
        return;
      }
      if (request.startsWith('revive:')) {
        List<String> attributes = request.split(" ");
        int id = int.parse(attributes[1]);
        Player? player = game.findPlayerById(id);
        if (player == null) {
          sendToClient('player-not-found ; ');
          return;
        }
        String uuid = attributes[2];
        if (uuid != player.uuid) {
          sendToClient('invalid-uuid ; ');
          return;
        }
        if (player.alive) {
          sendToClient('player-alive ;');
          return;
        }
        revive(player);
      }

      if (request == "spawn") {
        handleRequestSpawn();
        return;
      }
      if (request == "spawn-npc") {
        print("received spawn npc request. Npcs: ${game.npcs.length}");
        game.spawnRandomNpc();
        return;
      }
      if (request == "clear-npcs") {
        print("received clear npcs request");
        game.clearNpcs();
      }
      if (request == "update") {
        sendCompiledState(game);
        return;
      }
      if (request.startsWith('equip')) {
        List<String> attributes = request.split(" ");
        int id = int.parse(attributes[1]);
        Player? player = game.findPlayerById(id);
        if (player == null) {
          sendToClient('player-not-found ; ');
          return;
        }
        String uuid = attributes[2];
        if (uuid != player.uuid) {
          sendToClient('invalid-uuid ; ');
          return;
        }
        Weapon weapon = Weapon.values[int.parse(attributes[3])];
        if(player.stateDuration > 0) return;
        if(player.weapon == weapon) return;
        player.weapon = weapon;
        game.setCharacterState(player, CharacterState.ChangingWeapon);
        print('player equipped $weapon');
      }
      if (request.startsWith('grenade')) {
        List<String> attributes = request.split(" ");
        int id = int.parse(attributes[1]);
        Player? player = game.findPlayerById(id);
        if (player == null) {
          sendToClient('player-not-found ; ');
          return;
        }
        String uuid = attributes[2];
        if (uuid != player.uuid) {
          sendToClient('invalid-uuid ; ');
          return;
        }
        double strength = double.parse(attributes[3]);
        game.throwGrenade(player.x, player.y, player.aimAngle, strength);
      }
      if (request == 'get-tiles') {
        sendToClient(compileTiles(StringBuffer(), game.tiles));
      }
    }

    webSocket.stream.listen(onEvent);
  });

  shelf_io.serve(handler, host, port).then((server) {
    print('Serving at wss://${server.address.host}:${server.port}');
  });
}
