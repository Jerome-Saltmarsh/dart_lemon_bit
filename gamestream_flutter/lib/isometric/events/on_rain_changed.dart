import 'package:bleed_common/grid_node_type.dart';
import 'package:gamestream_flutter/isometric/audio.dart';
import 'package:gamestream_flutter/isometric/grid.dart';

void onRainChanged(bool raining) {
  raining ? audio.rainStart() : audio.rainStop();

  if (raining) {
    for (var row = 0; row < gridTotalRows; row++) {
      for (var column = 0; column < gridTotalColumns; column++) {
        for (var z = gridTotalZ - 1; z >= 0; z--) {
          final type = grid[z][row][column];
          if (type != GridNodeType.Empty) break;
          grid[z][row][column] = GridNodeType.Rain;
        }
      }
    }
  } else {
    for (var z = gridTotalZ - 1; z >= 0; z--) {
      for (var row = 0; row < gridTotalRows; row++) {
        for (var column = 0; column < gridTotalColumns; column++) {
           if (grid[z][row][column] != GridNodeType.Rain) continue;
           grid[z][row][column] = GridNodeType.Empty;
        }
      }
    }
  }
}
