import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/isometric/audio/audio_singles.dart';
import 'package:gamestream_flutter/isometric/grid.dart';
import 'package:gamestream_flutter/isometric/particles.dart';
import 'package:gamestream_flutter/isometric/watches/rain.dart';
import 'package:gamestream_flutter/isometric/watches/raining.dart';
import 'package:lemon_math/library.dart';


void onGameEventFootstep(double x, double y, double z) {
  final tile = getNodeXYZ(x, y, z - 2);
  if (
  raining.value && (
      getNodeXYZ(x, y, z).type == NodeType.Rain_Landing ||
          getNodeXYZ(x, y, z + 24).type == NodeType.Rain_Landing
  )
  ){
    audioSingleFootstepMud6.playXYZ(x, y, z);
    final amount = rain.value == Rain.Heavy ? 3 : 2;
    for (var i = 0; i < amount; i++){
      spawnParticleWaterDrop(x: x, y: y, z: z);
    }
  }
  if (tile.isStone) {
    return audioSingleFootstepStone.playXYZ(x, y, z);
  }
  if (tile.isWood) {
    return audioSingleFootstepWood.playXYZ(x, y, z);
  }
  if (randomBool()){
    return audioSingleFootstepGrass8.playXYZ(x, y, z);
  }
  return audioSingleFootstepGrass7.playXYZ(x, y, z);
}