import 'package:bleed_common/card_type.dart';
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/send.dart';
import 'package:gamestream_flutter/ui/functions/build_panel.dart';
import 'package:gamestream_flutter/ui/functions/player.dart';
import 'package:lemon_watch/watch_builder.dart';

import 'build_panel_game_random.dart';

Widget buildPanelCardChoices() {
  return WatchBuilder(player.cardChoices, (List<CardType> cardChoices) {
    if (cardChoices.isEmpty) return empty;

    return Row(
      children: spread(cardChoices
          .map(
              (cardType){
            return buildPanel(
              child: Column(
                children: [
                  text(
                    getCardTypeName(cardType),
                    onPressed: ()=> sendClientRequestChooseCard(cardType),
                  ),

                ],
              ),
            );
          }
      ).toList(), EdgeInsets.only(right: 4)),
    );
  });
}
