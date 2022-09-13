
import 'package:gamestream_flutter/isometric/editor/actions/editor_action_refresh_selected_node_data.dart';

void onChangeNodeTypeSpawnSelected(bool value) =>
  value
      ? editorActionRefreshSelectedNodeData()
      : editorActionClearSelectedNodeData()
;
