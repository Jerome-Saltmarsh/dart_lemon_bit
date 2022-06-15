
import 'package:bleed_common/StructureType.dart';
import 'package:gamestream_flutter/audio.dart';
import 'package:gamestream_flutter/isometric/state/player.dart';
import 'package:gamestream_flutter/modules/game/actions.dart';
import 'package:gamestream_flutter/modules/game/build.dart';
import 'package:gamestream_flutter/modules/game/events.dart';
import 'package:gamestream_flutter/modules/game/map.dart';
import 'package:gamestream_flutter/modules/game/queries.dart';
import 'package:gamestream_flutter/modules/game/render.dart';
import 'package:gamestream_flutter/modules/game/state.dart';
import 'package:gamestream_flutter/modules/game/style.dart';
import 'package:gamestream_flutter/modules/game/update.dart';
import 'package:lemon_watch/watch.dart';

class GameModule {

  final style = GameStyle();
  late final GameBuild build;
  late final GameState state;
  late final GameActions actions;
  late final GameRender render;
  late final GameEvents events;
  late final GameUpdate update;
  late final GameMap map;
  late final GameQueries queries;

  final structureType = Watch<int?>(null);

  GameModule(){
    state = GameState();
    actions = GameActions(state);
    queries = GameQueries(state);
    render = GameRender(state, style, queries);
    events = GameEvents(actions, state);
    update = GameUpdate(state);
    map = GameMap(state, actions);
    build = GameBuild(state, actions);
    structureType.onChanged(onStructureTypeChanged);
  }

  void exitBuildMode(){
    structureType.value = null;
  }

  void onStructureTypeChanged(int? value) {
     audio.clickSound8();
  }

  void enterBuildModeTower() {
    final cost = StructureType.getCost(StructureType.Tower);
    if (cost.wood > player.wood.value) return audio.error();
    if (cost.gold > player.gold.value) return audio.error();
    if (cost.stone > player.stone.value) return audio.error();
     structureType.value = StructureType.Tower;
  }

  void enterBuildModePalisade() {
    final cost = StructureType.getCost(StructureType.Palisade);
    if (cost.wood > player.wood.value) return audio.error();
    if (cost.gold > player.gold.value) return audio.error();
    if (cost.stone > player.stone.value) return audio.error();
     structureType.value = StructureType.Palisade;
  }

  void enterBuildModeTorch() {
    final cost = StructureType.getCost(StructureType.Torch);
    if (cost.wood > player.wood.value) return audio.error();
    if (cost.gold > player.gold.value) return audio.error();
    if (cost.stone > player.stone.value) return audio.error();
    structureType.value = StructureType.Torch;
  }
}