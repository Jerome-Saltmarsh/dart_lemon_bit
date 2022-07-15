


import 'package:gamestream_flutter/isometric/edit_state.dart';
import 'package:gamestream_flutter/isometric/grid.dart';

import '../../network/send_client_request.dart';

class EditorActions {
  void increaseCanvasSizeZ(){
    sendClientRequestSetCanvasSize(gridTotalZ + 1, gridTotalRows, gridTotalColumns);
  }

  void elevate(){
    final r = edit.row.value;
    final c = edit.column.value;
    for (var z = gridTotalZ - 2; z >= 0; z--) {
      sendClientRequestSetBlock(r, c, z + 1, grid[z][r][c]);
    }
  }
}

