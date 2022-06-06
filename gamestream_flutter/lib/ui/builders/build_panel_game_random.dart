
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/ui/builders/build_health_bar.dart';
import 'package:gamestream_flutter/ui/builders/build_panel.dart';
import 'package:gamestream_flutter/ui/builders/build_panel_card_choices.dart';
import 'package:gamestream_flutter/ui/builders/build_panel_experience.dart';
import 'package:gamestream_flutter/ui/builders/build_panel_menu.dart';
import 'package:gamestream_flutter/ui/builders/build_panel_select_character_class.dart';
import 'package:lemon_engine/engine.dart';

import 'build_panel_deck.dart';
import 'build_time.dart';
import 'package:lemon_watch/watch_builder.dart';


import 'player.dart';

List<Widget> spread(List<Widget> children, EdgeInsets margin) {
   return children.map((e) => Container(child: e, margin: margin)).toList();
}


Widget buildPanelGameRandom() {

  return Stack(
    children: [
      Positioned(
          top: 20,
          child: Container(
            width: engine.screen.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildPanelCardChoices(),
              ],
            ),
          )),
      WatchBuilder(player.alive, (bool alive) {
        if (!alive) return buildPanelSelectCharacterClass();

        return Positioned(
          top: 20,
          right: 20,
          child: Column(
            children: [
              buildPanel(
                  child: Column(
                    children: [
                      height8,
                      buildPanelMenu(),
                      height8,
                      buildTime(),
                      height8,
                      buildHealthBar(),
                      height8,
                      buildPanelExperience(),
                    ],
                  )
              ),
              height8,
              buildPanelDeck(),
            ],
          ),
        );
      }),
    ],
  );
}