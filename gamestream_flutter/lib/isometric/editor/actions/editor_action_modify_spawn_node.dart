

import 'package:gamestream_flutter/isometric/edit.dart';
import 'package:gamestream_flutter/network/send_client_request.dart';

void editorActionModifySpawnNode({
  required int spawnType,
  required int spawnAmount,
  required int spawnRadius,
}) {
  assert (EditState.nodeTypeSpawnSelected.value);

  sendClientRequestSpawnNodeDataModify(
    z: EditState.z,
    row: EditState.row,
    column: EditState.column,
    spawnType: spawnType,
    spawnAmount: spawnAmount,
    spawnRadius: spawnRadius,
  );
}
