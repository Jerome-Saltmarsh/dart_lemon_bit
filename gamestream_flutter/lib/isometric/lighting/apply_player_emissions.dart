import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/isometric/grid.dart';
import 'package:gamestream_flutter/isometric/players.dart';

void applyPlayerEmissions() {
  var shade = ambient.value - 1;
  if (shade < Shade.Bright){
    shade = Shade.Bright;
  }
  if (shade > Shade.Medium) {
    shade = Shade.Medium;
  }
  for (var i = 0; i < totalPlayers; i++) {
    final player = players[i];
    gridEmitDynamic(player.indexZ, player.indexRow, player.indexColumn,
        maxBrightness: shade);
  }
}
