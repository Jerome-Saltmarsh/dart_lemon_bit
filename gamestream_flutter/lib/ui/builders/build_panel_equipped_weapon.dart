
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/isometric/state/player.dart';
import 'package:lemon_watch/watch_builder.dart';

import 'build_row_tech_type.dart';

Widget buildPanelEquippedWeapon(){
  return WatchBuilder(player.equippedWeapon, (int equipped) {
    return buildRowTechType(equipped, player.equippedLevel);
  });
}