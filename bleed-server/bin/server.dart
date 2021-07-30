import 'dart:async';

import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';

import 'classes.dart';
import 'common.dart';
import 'compiler.dart';
import 'settings.dart';
import 'update.dart';
import 'utils.dart';

void main() {
  print('starting web socket server');

  initUpdateLoop();

  var handler = webSocketHandler((webSocket) {

    void sendToClient(String response) {
      webSocket.sink.add(compress(response));
    }

    void sendCompiledState() {
      sendToClient(compileState());
    }

    void handleRequestSpawn() {
      var character = spawnPlayer("test");
      String response = "id: ${character.id};";
      sendToClient(response);
      return;
    }

    void onEvent(requestD) {
      String request = requestD;

      if (request.startsWith("u:")) {
        List<String> attributes = request.split(" ");
        int id = int.parse(attributes[1]);
        Character player = findPlayerById(id);
        if (player.dead) return;
        if (player.shotCoolDown > 0) return;
        CharacterState requestedState = CharacterState.values[int.parse(attributes[2])];
        Direction requestedDirection =  Direction.values[int.parse(attributes[3])];
        double aim = double.parse(attributes[4]);
        player.aimAngle = aim;
        setDirection(player, requestedDirection);
        setCharacterState(player, requestedState);
        sendCompiledState();

        // Future.delayed(Duration(milliseconds: 3),(){
        //   sendCompiledState();
        // });
        // Future.delayed(Duration(milliseconds: 7),(){
        //   sendCompiledState();
        // });
        // Future.delayed(Duration(milliseconds: 13),(){
        //   sendCompiledState();
        // });
        Future.delayed(Duration(milliseconds: 30),(){
          sendCompiledState();
        });
        return;
      }
      if (request == "spawn"){
        handleRequestSpawn();
        return;
      }
      if (request == "spawn-npc"){
        spawnRandomNpc();
      }
      if(request == "update"){
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
