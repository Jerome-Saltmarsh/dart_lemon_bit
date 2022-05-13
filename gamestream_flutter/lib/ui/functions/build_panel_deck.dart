
import 'package:bleed_common/card_type.dart';
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/ui/functions/build_panel.dart';
import 'package:lemon_watch/watch_builder.dart';

import 'player.dart';


Widget buildPanelDeck(){
  return WatchBuilder(player.deck, (List<CardType> deck){
    if (deck.isEmpty) return const SizedBox();
    return buildPanel(child: Column(
       children: deck.map((card) => text(getCardTypeName(card))).toList(),
    ));
  });
}