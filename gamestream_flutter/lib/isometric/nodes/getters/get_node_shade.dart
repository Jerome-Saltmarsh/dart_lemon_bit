import 'package:gamestream_flutter/isometric/grid.dart';
import 'package:gamestream_flutter/isometric/nodes.dart';
import 'package:gamestream_flutter/isometric/watches/ambient_shade.dart';

int getNodeShade(int z, int row, int column) =>
  outOfBounds(z, row, column)
      ? ambientShade.value
      : nodesShade[
          getNodeIndexZRC(z, row, column)
        ];