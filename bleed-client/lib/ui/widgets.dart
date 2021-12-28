import 'package:bleed_client/common/ClientRequest.dart';
import 'package:bleed_client/enums/Region.dart';
import 'package:bleed_client/send.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/ui/build.dart';
import 'package:bleed_client/ui/compose/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:lemon_watch/watch_builder.dart';

import '../logic.dart';
import '../toString.dart';
import 'compose/hudUI.dart';

final _Widgets widgets = _Widgets();
final _Buttons buttons = _Buttons();

class _Widgets {
  final Widget experienceBar = build.experienceBar();
  final Widget healthBar = build.healthBar();
  final Widget magicBar = build.magicBar();
  final Widget abilities = build.abilities();
  final Widget gamesList = build.gamesList();
  final Widget title = Container(alignment: Alignment.center, height: 80, child: text("GAMESTREAM", fontSize: 40));
}

class _Buttons {
  final Widget debug = button("Debug", toggleDebugMode);
  final Widget exit = button('Exit', logic.exit);
  final Widget edit = button("Edit", logic.toggleEditMode);
  final Widget changeCharacter = button("Change Hero", () {
    sendClientRequest(ClientRequest.Reset_Character_Type);
  });
  final Widget audio = WatchBuilder(game.settings.audioMuted, (bool audio) {
    return onPressed(
        callback: logic.toggleAudio,
        child: border(child: text(audio ? "Audio On" : "Audio Off")));
  });

  final Widget region = WatchBuilder(game.region, (Region region) {
    return button("REGION ${enumString(region).toUpperCase()}",
        logic.deselectRegion,
        width: 200, hint: 'Region');
  });
}