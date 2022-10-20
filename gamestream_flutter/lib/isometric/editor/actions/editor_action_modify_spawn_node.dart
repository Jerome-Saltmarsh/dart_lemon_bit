

import 'package:gamestream_flutter/game_library.dart';
import 'package:gamestream_flutter/game_editor.dart';

void editorActionModifySpawnNode({
  required int spawnType,
  required int spawnAmount,
  required int spawnRadius,
}) {
  assert (GameEditor.nodeTypeSpawnSelected.value);

  GameNetwork.sendClientRequestSpawnNodeDataModify(
    z: GameEditor.z,
    row: GameEditor.row,
    column: GameEditor.column,
    spawnType: spawnType,
    spawnAmount: spawnAmount,
    spawnRadius: spawnRadius,
  );
}
