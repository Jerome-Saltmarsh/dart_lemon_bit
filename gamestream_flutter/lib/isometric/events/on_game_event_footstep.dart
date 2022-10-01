import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/isometric/audio/audio_singles.dart';
import 'package:gamestream_flutter/isometric/grid_state.dart';
import 'package:gamestream_flutter/isometric/particles.dart';
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
    audioSingleFootstepMud6.playXYZ(x, y, z);
    final amount = rain.value == Rain.Heavy ? 3 : 2;
    for (var i = 0; i < amount; i++){
      spawnParticleWaterDrop(x: x, y: y, z: z);
    }
  }

  final nodeType = gridNodeXYZTypeSafe(x, y, z - 2);
  if (NodeType.isMaterialStone(nodeType)) {
    return audioSingleFootstepStone.playXYZ(x, y, z);
  }
  if (NodeType.isMaterialWood(nodeType)) {
    return audioSingleFootstepWood.playXYZ(x, y, z);
  }
  if (randomBool()){
    return audioSingleFootstepGrass8.playXYZ(x, y, z);
  }
  return audioSingleFootstepGrass7.playXYZ(x, y, z);
}