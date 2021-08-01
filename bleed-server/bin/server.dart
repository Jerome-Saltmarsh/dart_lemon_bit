import 'dart:async';

import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';

import 'classes.dart';
import 'compiler.dart';
import 'constants.dart';
import 'settings.dart';
import 'spawn.dart';
import 'state.dart';
import 'update.dart';
import 'utils.dart';

void main() {
  print('starting web socket server');

  initUpdateLoop();

  var handler = webSocketHandler((webSocket) {
    void sendToClient(String response) {
      webSocket.sink.add(response);
    }

    void sendCompiledState() {
      sendToClient(compiledState);
    }

    void sendCompiledPlayerState(Character player){
      sendToClient(compilePlayer(player));
    }

    void handleRequestSpawn() {
      var character = spawnPlayer(name: "Test");
      String response = "id: ${character.id} ${character.uuid} ;";
      sendToClient(response);
      return;
    }

    void onEvent(requestD) {
      String request = requestD;

      if (request.startsWith("u:")) {
        List<String> attributes = request.split(" ");
        int id = int.parse(attributes[1]);
        Character? player = findPlayerById(id);
        if (player == null) {
          sendToClient('player-not-found');
          return;
        }
        String uuid = attributes[2];
        if (uuid != player.uuid) {
          sendToClient('invalid-uuid');
        }
        CharacterState requestedState =
            CharacterState.values[int.parse(attributes[3])];
        Direction requestedDirection =
            Direction.values[int.parse(attributes[4])];
        double aim = double.parse(attributes[5]);
        player.aimAngle = aim;
        setDirection(player, requestedDirection);
        setCharacterState(player, requestedState);
        // sendCompiledState();
        sendCompiledPlayerState(player);
        Future.delayed(duration15ms, () => sendCompiledPlayerState(player));
        // Future.delayed(duration30ms, sendCompiledState);
        // Future.delayed(duration45ms, sendCompiledState);
        // Future.delayed(duration90ms, sendCompiledState);
        return;
      }
      if (request == "spawn") {
        print("received spawn request");
        handleRequestSpawn();
        return;
      }
      if (request == "spawn-npc") {
        print("received spawn npc request");
        spawnRandomNpc();
        return;
      }
      if (request == "clear-npcs") {
        print("received clear npcs request");
        clearNpcs();
      }
      if (request == "update") {
        sendCompiledState();
        return;
      }
    }

    webSocket.stream.listen(onEvent);
  });

  shelf_io.serve(handler, host, port).then((server) {
    print('Serving at wss://${server.address.host}:${server.port}');
  });
}
