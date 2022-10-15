import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/audio_engine.dart';
import 'package:gamestream_flutter/isometric/nodes.dart';
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
    AudioEngine.audioSingleFootstepMud6.playXYZ(x, y, z);
    final amount = rain.value == Rain.Heavy ? 3 : 2;
    for (var i = 0; i < amount; i++){
      spawnParticleWaterDrop(x: x, y: y, z: z);
    }
  }

  final nodeType = gridNodeXYZTypeSafe(x, y, z - 2);
  if (NodeType.isMaterialStone(nodeType)) {
    return AudioEngine.audioSingleFootstepStone.playXYZ(x, y, z);
  }
  if (NodeType.isMaterialWood(nodeType)) {
    return AudioEngine.audioSingleFootstepWood.playXYZ(x, y, z);
  }
  if (randomBool()){
    return AudioEngine.audioSingleFootstepGrass8.playXYZ(x, y, z);
  }
  return AudioEngine.audioSingleFootstepGrass7.playXYZ(x, y, z);
}