

import 'package:gamestream_flutter/game_library.dart';
import 'package:gamestream_flutter/isometric/edit.dart';

void editorActionModifySpawnNode({
  required int spawnType,
  required int spawnAmount,
  required int spawnRadius,
}) {
  assert (EditState.nodeTypeSpawnSelected.value);

  GameNetwork.sendClientRequestSpawnNodeDataModify(
    z: EditState.z,
    row: EditState.row,
    column: EditState.column,
    spawnType: spawnType,
    spawnAmount: spawnAmount,
    spawnRadius: spawnRadius,
  );
}
