
import 'package:gamestream_flutter/colours.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:lemon_watch/watch_builder.dart';
import 'package:flutter/material.dart';
import 'player.dart';

Widget buildPanelSkillPoints() {
   return WatchBuilder(player.skillPoints, (int skillPoints){
      return text("Points $skillPoints", color: skillPoints == 0 ? colours.white60 : colours.white);
   });
}