

import 'package:bleed_common/Shade.dart';
import 'package:gamestream_flutter/isometric/grid.dart';
import 'package:gamestream_flutter/isometric/watches/torches_ignited.dart';

void onChangedAmbientShade(int shade) {

  for (final z in grid){
    for (final row in z){
      for (final column in row){
        column.bake = shade;
        column.shade = shade;
      }
    }
  }

  apiGridActionRefreshLighting();
  torchesIgnited.value = shade != Shade.Very_Bright;
}
