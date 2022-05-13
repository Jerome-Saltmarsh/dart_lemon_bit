
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/ui/functions/build_health_bar.dart';
import 'package:gamestream_flutter/ui/functions/build_panel.dart';
import 'package:gamestream_flutter/ui/functions/build_panel_card_choices.dart';
import 'package:gamestream_flutter/ui/functions/build_panel_experience.dart';
import 'package:gamestream_flutter/ui/functions/build_panel_menu.dart';

import 'build_panel_deck.dart';

Widget buildPanelGameRandom(){
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
}