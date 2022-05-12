
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/ui/functions/player.dart';

import 'build_row_tech_type.dart';
import 'package:lemon_watch/watch_builder.dart';

Widget buildPanelEquippedWeapon(){
  return WatchBuilder(player.equipped, (int equipped) {
    return buildRowTechType(equipped, player.equippedLevel);
  });
}