
import 'package:gamestream_flutter/game_network.dart';
import 'package:gamestream_flutter/isometric/edit.dart';

void editorActionAddGameObject(int type) =>
  GameNetwork.sendClientRequestAddGameObject(
      index: EditState.nodeIndex.value,
      type: type,
  );
