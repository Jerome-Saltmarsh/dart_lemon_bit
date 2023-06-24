

import 'package:bleed_common/src.dart';
import 'package:gamestream_flutter/gamestream/games/mmo/mmo_game.dart';
import 'package:gamestream_flutter/gamestream/gamestream.dart';

extension MMOResponseReader on Gamestream {

  MmoGame get mmoGame => games.mmo;

  void readMMOResponse(){
     switch (readByte()){
       case MMOResponse.Npc_Text:
         mmoGame.npcText.value = readString();
         break;
     }
  }
}