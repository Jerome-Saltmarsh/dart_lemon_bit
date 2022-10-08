import 'package:gamestream_flutter/isometric/grid.dart';
import 'package:gamestream_flutter/isometric/grid_state.dart';
import 'package:gamestream_flutter/isometric/watches/ambient_shade.dart';

int getNodeShade(int z, int row, int column) =>
  outOfBounds(z, row, column)
      ? ambientShade.value
      : nodesShade[
          getGridNodeIndexZRC(z, row, column)
        ];