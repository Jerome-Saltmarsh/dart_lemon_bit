
import 'package:bleed_client/common/ClientRequest.dart';
import 'package:bleed_client/common/HeroType.dart';
import 'package:bleed_client/network/functions/send.dart';
import 'package:bleed_client/state/game.dart';

final _Server server = _Server();

class _Server {
  _Send send = _Send();
}

class _Send {
  void selectHeroType(HeroType value){
    send('${ClientRequest.SelectHeroType.index} ${game.player.uuid} ${value.index}');
  }
}