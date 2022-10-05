

import 'package:gamestream_flutter/isometric/edit.dart';
import 'package:gamestream_flutter/network/send_client_request.dart';

void editorActionModifySpawnNode({
  required int spawnType,
  required int spawnAmount,
  required int spawnRadius,
}) {
  assert (edit.nodeTypeSpawnSelected.value);

  sendClientRequestSpawnNodeDataModify(
    z: edit.z,
    row: edit.row,
    column: edit.column,
    spawnType: spawnType,
    spawnAmount: spawnAmount,
    spawnRadius: spawnRadius,
  );
}
