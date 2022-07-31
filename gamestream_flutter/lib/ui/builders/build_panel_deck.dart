
import 'package:bleed_common/card_type.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/colours.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/classes/deck_card.dart';
import 'package:gamestream_flutter/isometric/player.dart';
import 'package:gamestream_flutter/isometric/ui/build_card_type_icon.dart';
import 'package:gamestream_flutter/network/send_client_request.dart';
import 'package:gamestream_flutter/styles.dart';
import 'package:gamestream_flutter/ui/builders/build_panel.dart';
import 'package:gamestream_flutter/ui/builders/styles.dart';
import 'package:golden_ratio/constants.dart';
import 'package:lemon_watch/watch_builder.dart';

Widget buildPanelDeck(){
  return WatchBuilder(player.deck, (List<DeckCard> deck){
    if (deck.isEmpty) return const SizedBox();
    return Column(
      children: deck.map((card) {
        final cardIndex = deck.indexOf(card);

        final cardText = text(getCardTypeName(card.type));
        final cardTextNotSelectable = text(getCardTypeName(card.type), color: colours.white70);

           final levelBoxes = <Widget>[];
           for (var i = 0; i < 5; i++) {
             levelBoxes.add(
               Container(
                 width: 16,
                 height: 16,
                 color: colours.blue.withOpacity(i < card.level ? 1.0 : goldenRatio_0381),
                 margin: EdgeInsets.only(right: 6),
               ),
             );
           }


        const cardHeight = 50.0;

        if (card.genre == CardGenre.Passive){
          return Container(
            margin: EdgeInsets.only(bottom: 6),
            child: buildPanel(
                width: defaultPanelWidth,
                height: cardHeight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(color: colours.white10, shape: BoxShape.circle),
                        child: buildCardTypeIcon(card.type)),
                    text(card.name, color: colours.white85),
                  ],
                )),
          );
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          child: WatchBuilder(player.deckActiveCardIndex, (int index) {
            final selected = index == cardIndex;

            return WatchBuilder(card.selectable, (bool selectable){

              final container = Container(
                  padding: padding4,
                  decoration: BoxDecoration(
                    color: selected ? colours.green : colours.brownDark,
                    borderRadius: borderRadius2,
                    // border: Border.all(color: selected ? colours.green : colours.transparent, width: 4),
                  ),
                  width: defaultPanelWidth,
                  height: cardHeight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
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
                                decoration: BoxDecoration(color: card.selectable.value ? colours.white382 : colours.redDark, shape: BoxShape.circle),
                              ),
                              Container(
                                  width: 50,
                                  height: 50,
                                  alignment: Alignment.center,
                                  child: buildCardTypeIcon(card.type)),
                              if (remaining > 0)
                                Container(
                                  width: 50,
                                  height: 50,
                                  alignment: Alignment.center,
                                  child: Container(
                                      alignment: Alignment.center,
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(color: colours.black618, shape: BoxShape.circle),
                                      child: remaining > 0 ? text(remaining) : null
                                  ),
                                ),
                            ],
                          ),
                        );
                      }),
                      width6,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (selectable)
                                cardText,
                              if (!selectable)
                                cardTextNotSelectable
                            ],
                          ),
                          Row(
                            children: levelBoxes,
                          )
                        ],
                      ),
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
          }),
        );
      }).toList(),
    );
  });
}