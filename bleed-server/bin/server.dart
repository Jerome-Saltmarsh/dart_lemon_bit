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
        setCharacterState(player, requestedState);
        setDirection(player, requestedDirection);
        sendCompiledState();

        Future.delayed(Duration(milliseconds: 7),(){
          sendCompiledState();
        });
        Future.delayed(Duration(milliseconds: 14),(){
          sendCompiledState();
        });
        Future.delayed(Duration(milliseconds: 28),(){
          sendCompiledState();
        });

        return;
      }
      if (request == "spawn"){
        handleRequestSpawn();
        return;
      }
      if(request == "update"){
        sendCompiledState();
        return;
      }
      if(request.startsWith("fire:")){
        List<String> attributes = request.split(" ");
        int id = int.parse(attributes[1]);
        Character player = findPlayerById(id);
        fireWeapon(player, double.parse(attributes[2]));
      }
    }

    webSocket.stream.listen(onEvent);
  });

  shelf_io.serve(handler, host, port).then((server) {
    print('Serving at wss://${server.address.host}:${server.port}');
  });
}
