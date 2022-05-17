
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/ui/functions/build_health_bar.dart';
import 'package:gamestream_flutter/ui/functions/build_panel.dart';
import 'package:gamestream_flutter/ui/functions/build_panel_card_choices.dart';
import 'package:gamestream_flutter/ui/functions/build_panel_experience.dart';
import 'package:gamestream_flutter/ui/functions/build_panel_menu.dart';
import 'package:gamestream_flutter/ui/functions/build_panel_select_character_class.dart';

import 'build_panel_deck.dart';
import 'build_time.dart';
import 'package:lemon_watch/watch_builder.dart';

import 'player.dart';

Widget buildPanelGameRandom() {

  return WatchBuilder(player.alive, (bool alive) {
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
          buildPanelCardChoices(),
          height8,
          buildPanelDeck(),
        ],
      ),
    );
  });
}