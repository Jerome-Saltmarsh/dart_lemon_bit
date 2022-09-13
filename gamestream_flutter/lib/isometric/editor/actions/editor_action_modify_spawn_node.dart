

import 'package:gamestream_flutter/isometric/edit_state.dart';
import 'package:gamestream_flutter/network/send_client_request.dart';

void editorActionModifySpawnNode({
  required int spawnType,
  required int spawnAmount,
  required int spawnRadius,
}) {
  assert (edit.nodeTypeSpawnSelected.value);

  sendClientRequestSpawnNodeDataModify(
    z: edit.z.value,
    row: edit.row.value,
    column: edit.column.value,
    spawnType: spawnType,
    spawnAmount: spawnAmount,
    spawnRadius: spawnRadius,
  );
}
