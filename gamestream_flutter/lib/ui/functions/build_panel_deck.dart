
import 'package:bleed_common/card_type.dart';
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/send.dart';
import 'package:gamestream_flutter/ui/functions/build_panel.dart';
import 'package:gamestream_flutter/ui/functions/styles.dart';
import 'package:lemon_watch/watch_builder.dart';

import 'player.dart';

Widget buildPanelDeck(){
  return WatchBuilder(player.deck, (List<CardType> deck){
    if (deck.isEmpty) return const SizedBox();
    return buildPanel(
        width: defaultPanelWidth,
        child: Column(
        children: deck.map((card) {
         final cardIndex = deck.indexOf(card);
         final cardText = text(getCardTypeName(card), onPressed: (){
           sendClientRequestDeckSelectCard(deck.indexOf(card));
         });
         return WatchBuilder(player.deckActiveCardIndex, (int index) {
           if (index == cardIndex){
             return border(child: cardText);
           }
           return cardText;
         });
       }).toList(),
    ));
  });
}