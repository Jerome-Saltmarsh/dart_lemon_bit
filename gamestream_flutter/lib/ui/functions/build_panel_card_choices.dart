
import 'package:bleed_common/card_type.dart';
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/ui/functions/build_panel.dart';
import 'package:gamestream_flutter/ui/functions/player.dart';
import 'package:lemon_watch/watch_builder.dart';


Widget buildPanelCardChoices(){
   return WatchBuilder(player.cardChoices, (List<CardType> cardChoices){
     if (cardChoices.isEmpty) return empty;

     return buildPanel(child: Column(
       children: cardChoices.map((e) => text(e.name)).toList(),
     ));
   });
}