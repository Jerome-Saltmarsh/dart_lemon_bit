
import 'dart:math';

import 'package:bleed_common/card_type.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/classes/Card.dart';
import 'package:gamestream_flutter/colours.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/send.dart';
import 'package:gamestream_flutter/styles.dart';
import 'package:gamestream_flutter/ui/functions/build_panel.dart';
import 'package:gamestream_flutter/ui/functions/styles.dart';
import 'package:lemon_watch/watch_builder.dart';

import 'player.dart';

Widget buildPanelDeck(){
  return WatchBuilder(player.deck, (List<DeckCard> deck){
    print("building deck");
    if (deck.isEmpty) return const SizedBox();
    return buildPanel(
        width: defaultPanelWidth,
        child: Column(
        children: deck.map((card) {
         final cardIndex = deck.indexOf(card);

         if (card.genre == CardGenre.Ability){
         }

         final cardText = text(getCardTypeName(card.type));
         final cardTextNotSelectable = text(getCardTypeName(card.type), color: colours.white70);

         // print("rebuilding card");
         // final frame = ValueNotifier<int>(0);
         // final paint = buildPainter(
         //     paint: (Canvas canvas, Size size) {
         //       final paint = Paint()
         //         ..color = colours.blue
         //         ..strokeWidth = 7
         //         ..strokeCap = StrokeCap.butt
         //         ..style = PaintingStyle.stroke;
         //
         //       canvas.drawCircle(size.center(Offset.zero), size.width / 2, paint);
         //       final progress = card.cooldownRemaining.value / card.cooldown.value;
         //       print("repainting ${card.type} $progress");
         //       paint.color = colours.yellow;
         //       canvas.drawArc(Offset.zero & size, 0, progress * (pi + pi), false, paint);
         //     },
         //     frame: frame);

         if (card.genre == CardGenre.Passive){

         }


         return WatchBuilder(player.deckActiveCardIndex, (int index) {

           return WatchBuilder(card.selectable, (bool selectable){

             final container = Container(
                 padding: padding4,
                 decoration: BoxDecoration(
                   color: index == cardIndex ? colours.brownLight : colours.brownDark,
                   borderRadius: borderRadius2,
                 ),
                 width: defaultPanelWidth,
                 height: 50,
                 child: Row(
                   children: [
                     WatchBuilder(card.cooldownRemaining, (int remaining){
                       return Container(
                         width: 50,
                         height: 50,
                         child: Stack(
                           children: [
                             Container(
                                 alignment: Alignment.center,
                                 width: 50,
                                 height: 50,
                                 child: text(remaining)
                             ),
                           ],
                         ),
                       );
                     }),
                     width16,
                     if (selectable)
                      cardText,
                     if (!selectable)
                       cardTextNotSelectable
                   ],
                 )
             );

             if (selectable) {
               return onPressed(child: container, callback: (){
                 sendClientRequestDeckSelectCard(deck.indexOf(card));
               });
             }
             return container;
           });
         });
       }).toList(),
    ));
  });
}