import 'dart:async';

import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';

import 'classes.dart';
import 'compile.dart';
import 'enums.dart';
import 'events.dart';
import 'settings.dart';
import 'spawn.dart';
import 'state.dart';
import 'update.dart';
import 'utils.dart';

void main() {
  print('starting web socket server');
  generateTiles();
  initUpdateLoop();
  initEvents();

  var handler = webSocketHandler((webSocket) {
    void sendToClient(String response) {
      webSocket.sink.add(response);
    }

    void sendCompiledState() {
      sendToClient(compiledState);
    }

    void sendCompiledPlayerState(Character player, {int pass = 1}) {
      sendToClient(compilePlayer(player) + compilePass(pass));
    }

    void handleRequestSpawn() {
      var player = spawnPlayer(name: "Test");
      String response = "id: ${player.id} ${player.uuid} ;";
      sendToClient(response);
      return;
    }

    void onEvent(requestD) {
      String request = requestD;

      if (request.startsWith("u:")) {
        List<String> attributes = request.split(" ");
        int id = int.parse(attributes[1]);
        Player? player = findPlayerById(id);
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
        // int lastServerFrame = int.parse(attributes[6]);
        // find all the events since then and send them to the server

        setDirection(player, requestedDirection);
        setCharacterState(player, requestedState);
        sendCompiledPlayerState(player, pass: 0);

        // if(firstPass){
        //   Future.delayed(Duration(milliseconds: firstPassMS), () => sendCompiledPlayerState(player, pass: 1));
        // }
        // if(secondPass){
        //   Future.delayed(Duration(milliseconds: secondPassMS), () => sendCompiledPlayerState(player, pass: 2));
        // }
        // if(thirdPass){
        //   Future.delayed(Duration(milliseconds: thirdPassMS), () => sendCompiledPlayerState(player, pass: 3));
        // }
        // if(fourthPass){
        //   Future.delayed(Duration(milliseconds: fourthPassMS), () => sendCompiledPlayerState(player, pass: 4));
        // }
        return;
      }
      if (request.startsWith('revive:')) {
        List<String> attributes = request.split(" ");
        int id = int.parse(attributes[1]);
        Player? player = findPlayerById(id);
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
      if (request == 'toggle-pass-1') {
        firstPass = !firstPass;
        print('first pass toggled: $firstPass');
      }
      if (request == 'toggle-pass-2') {
        secondPass = !secondPass;
        print('second pass toggled: $secondPass');
      }
      if (request == 'toggle-pass-3') {
        thirdPass = !thirdPass;
      }
      if (request == 'toggle-pass-4') {
        fourthPass = !fourthPass;
      }
      if (request == 'get-tiles') {
        sendToClient(compileTiles());
      }
    }

    webSocket.stream.listen(onEvent);
  });

  shelf_io.serve(handler, host, port).then((server) {
    print('Serving at wss://${server.address.host}:${server.port}');
  });
}
