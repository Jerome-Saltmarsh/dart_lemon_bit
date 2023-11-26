
import 'package:bleed_common/ClientRequest.dart';
import 'package:gamestream_flutter/isometric/message_box.dart';
import 'package:gamestream_flutter/isometric/server_response_reader.dart';
import 'package:gamestream_flutter/network/send_client_request.dart';
import 'package:gamestream_flutter/network/web_socket.dart';

import 'state.dart';

final _bulletHoles = serverResponseReader.bulletHoles;

class GameActions {

  final GameState state;

  GameActions(this.state);

  void spawnBulletHole(double x, double y){
    final bulletHole = _bulletHoles[serverResponseReader.bulletHoleIndex];
    bulletHole.x = x;
    bulletHole.y = y;
    serverResponseReader.bulletHoleIndex++;
    serverResponseReader.bulletHoleIndex %= _bulletHoles.length;
  }

  void playerEquip(int index) {
    print("game.actions.playerEquip(index: $index)");
    // webSocket.send('${ClientRequest.Equip.index} $session ${index - 1}');
  }

  void deselectAbility() {
    print("game.actions.deselectAbility()");
    // webSocket.send('${ClientRequest.DeselectAbility.index} $session');
  }

  void sendAndCloseTextBox(){
    print("sendAndCloseTextBox()");
    sendRequestSpeak(state.textEditingControllerMessage.text);
    messageBoxHide();
  }

  void toggleDebugMode() {
    print("game.actions.enableDebugNpc()");
    sendClientRequestTogglePaths();
  }

  void sendClientRequest(ClientRequest request, dynamic value){
    webSocket.send('${request.index} $value');
  }
}