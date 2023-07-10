

import 'dart:typed_data';

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
       case MMOResponse.Player_Item_Length:
         mmoGame.setItemLength(readUInt16());
         break;
       case MMOResponse.Player_Item:
         final index = readByte();
         final type = readByte();
         final subType = readByte();
         mmoGame.setItem(index: index, type: type, subType: subType);
         break;
     }
  }
}