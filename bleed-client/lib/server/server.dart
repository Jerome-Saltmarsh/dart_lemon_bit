
import 'package:bleed_client/common/CharacterType.dart';
import 'package:bleed_client/common/ClientRequest.dart';
import 'package:bleed_client/network/functions/send.dart';
import 'package:bleed_client/state/game.dart';

final _Server server = _Server();

class _Server {
  _Send send = _Send();
}

class _Send {
  void selectCharacterType(CharacterType value){
    send('${ClientRequest.SelectCharacterType.index} ${game.player.uuid} ${value.index}');
  }
}