import 'package:bleed_common/GameType.dart';
import 'package:lemon_engine/engine.dart';

import 'isometric/game.dart';
import 'modules/modules.dart';
import 'package:lemon_watch/watch.dart';

final gamestream = GameStream();

class GameStream {
  final gameType = Watch<int?>(null, onChanged: onChangedGameType);

  void onError(Object error, StackTrace stack){
    print(error.toString());
    print(stack);
    core.state.error.value = error.toString();
  }

  static void onChangedGameType(int? value){
    print("gamestream.onChangedGameType(${GameType.getName(value)})");
    if (value == null) {
      return;
    }
    game.edit.value = value == GameType.Editor;
    game.timeVisible.value = GameType.isTimed(value);
    game.mapVisible.value = value == GameType.Dark_Age;
    Engine.fullScreenEnter();
  }
}