
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/ui/builders/player.dart';

import 'build_row_tech_type.dart';
import 'package:lemon_watch/watch_builder.dart';

Widget buildPanelEquippedWeapon(){
  return WatchBuilder(player.equippedWeapon, (int equipped) {
    return buildRowTechType(equipped, player.equippedLevel);
  });
}