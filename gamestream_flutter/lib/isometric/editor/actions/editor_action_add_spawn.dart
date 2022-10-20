
import 'package:gamestream_flutter/game_network.dart';
import 'package:gamestream_flutter/game_editor.dart';

void editorActionAddGameObject(int type) =>
  GameNetwork.sendClientRequestAddGameObject(
      index: GameEditor.nodeIndex.value,
      type: type,
  );
