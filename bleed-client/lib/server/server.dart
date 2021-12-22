
import 'package:bleed_client/common/CharacterType.dart';
import 'package:bleed_client/common/ClientRequest.dart';
import 'package:bleed_client/network.dart';
import 'package:bleed_client/send.dart';

final _Server server = _Server();

class _Server {
  _Send send = _Send();

  void leaveLobby(){
    sendClientRequest(ClientRequest.Leave_Lobby);
  }
}

class _Send {
  void selectCharacterType(CharacterType value){
    send('${ClientRequest.SelectCharacterType.index} $session ${value.index}');
  }
}