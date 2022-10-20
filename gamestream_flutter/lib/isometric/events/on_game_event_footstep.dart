import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/game_state.dart';
import 'package:gamestream_flutter/game_audio.dart';
import 'package:gamestream_flutter/isometric/nodes.dart';
import 'package:gamestream_flutter/isometric/watches/rain.dart';
import 'package:gamestream_flutter/isometric/watches/raining.dart';
import 'package:lemon_math/library.dart';


void onGameEventFootstep(double x, double y, double z) {
  if (raining.value && (
      gridNodeXYZTypeSafe(x, y, z) == NodeType.Rain_Landing
          ||
      gridNodeXYZTypeSafe(x, y, z + 24) == NodeType.Rain_Landing
  )
  ){
    GameAudio.footstep_mud_6.playXYZ(x, y, z);
    final amount = rain.value == Rain.Heavy ? 3 : 2;
    for (var i = 0; i < amount; i++){
      GameState.spawnParticleWaterDrop(x: x, y: y, z: z);
    }
  }

  final nodeType = gridNodeXYZTypeSafe(x, y, z - 2);
  if (NodeType.isMaterialStone(nodeType)) {
    return GameAudio.footstep_stone.playXYZ(x, y, z);
  }
  if (NodeType.isMaterialWood(nodeType)) {
    return GameAudio.footstep_wood_4.playXYZ(x, y, z);
  }
  if (randomBool()){
    return GameAudio.footstep_grass_8.playXYZ(x, y, z);
  }
  return GameAudio.footstep_grass_7.playXYZ(x, y, z);
}