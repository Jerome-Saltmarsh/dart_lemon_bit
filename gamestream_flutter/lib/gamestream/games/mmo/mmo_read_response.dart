

import 'package:bleed_common/src.dart';
import 'package:gamestream_flutter/gamestream/gamestream.dart';

extension MMOResponseReader on Gamestream {

  void readMMOResponse(){
    final game = games.mmo;
     switch (readByte()){
       case MMOResponse.Npc_Talk:
         game.npcText.value = readString();
         final length = readByte();
         final options = game.npcOptions;
         options.clear();
         for (var i = 0; i < length; i++){
           options.add(readString());
         }
         game.npcOptionsReads.value++;
         break;
       case MMOResponse.Player_Item_Length:
         game.setItemLength(readUInt16());
         break;
       case MMOResponse.Player_Item:
         final index = readUInt16();
         final type = readInt16();
         final item = type != -1 ? MMOItem.values[type] : null;
         game.setItem(index: index, item: item);
         break;
     }
  }
}