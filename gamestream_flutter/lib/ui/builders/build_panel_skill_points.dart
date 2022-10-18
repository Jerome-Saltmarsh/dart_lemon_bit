
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/colours.dart';
import 'package:gamestream_flutter/game_widgets.dart';
import 'package:gamestream_flutter/game.dart';
import 'package:lemon_watch/watch_builder.dart';


Widget buildPanelSkillPoints() {
   return WatchBuilder(Game.player.points, (int skillPoints){
      return text("Points $skillPoints", color: skillPoints == 0 ? colours.white60 : colours.white);
   });
}