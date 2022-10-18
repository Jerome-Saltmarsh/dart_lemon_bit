import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/game_audio.dart';
import 'package:gamestream_flutter/game.dart';
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
    GameAudio.audioSingleFootstepMud6.playXYZ(x, y, z);
    final amount = rain.value == Rain.Heavy ? 3 : 2;
    for (var i = 0; i < amount; i++){
      Game.spawnParticleWaterDrop(x: x, y: y, z: z);
    }
  }

  final nodeType = gridNodeXYZTypeSafe(x, y, z - 2);
  if (NodeType.isMaterialStone(nodeType)) {
    return GameAudio.audioSingleFootstepStone.playXYZ(x, y, z);
  }
  if (NodeType.isMaterialWood(nodeType)) {
    return GameAudio.audioSingleFootstepWood.playXYZ(x, y, z);
  }
  if (randomBool()){
    return GameAudio.audioSingleFootstepGrass8.playXYZ(x, y, z);
  }
  return GameAudio.audioSingleFootstepGrass7.playXYZ(x, y, z);
}