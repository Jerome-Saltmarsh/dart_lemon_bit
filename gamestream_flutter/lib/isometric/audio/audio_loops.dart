import 'package:bleed_common/grid_node_type.dart';
import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/isometric/grid.dart';
import 'package:gamestream_flutter/isometric/grid/state/wind.dart';
import 'package:gamestream_flutter/isometric/player.dart';
import 'package:gamestream_flutter/isometric/time.dart';
import 'package:gamestream_flutter/isometric/utils/screen_utils.dart';
import 'package:gamestream_flutter/isometric/weather/breeze.dart';

import '../render/weather.dart';
import 'audio_loop.dart';
import 'convert_distance_to_volume.dart';

final audioLoops = <AudioLoop> [
  AudioLoop(name: 'wind', getTargetVolume: getVolumeTargetWind),
  AudioLoop(name: 'rain', getTargetVolume: getVolumeTargetRain),
  AudioLoop(name: 'crickets', getTargetVolume: getVolumeTargetCrickets),
  AudioLoop(name: 'day-ambience', getTargetVolume: getVolumeTargetDayAmbience),
  AudioLoop(name: 'fire', getTargetVolume: getVolumeTargetFire),
];

void updateAudioLoops(){
  for (final audioSource in audioLoops){
    audioSource.update();
  }
}


double getVolumeTargetWind() {
  final windLineDistance = (screenCenterRenderX - windLineRenderX).abs();
  final windLineDistanceVolume = convertDistanceToVolume(windLineDistance);
  var target = 0.0;
  if (windLineRenderX - 250 <= screenCenterRenderX) {
    target += windLineDistanceVolume;
  }
  if (windAmbient.value <= Wind.Calm) {
    if (hours.value < 6) return target;
    if (hours.value < 18) return target + 0.1;
    return target;
  }
  if (windAmbient.value <= Wind.Gentle) return target + 0.5;
  return 1.0;
}

double getVolumeTargetRain() => raining ? 0.4 : 0;

double getVolumeTargetCrickets() {
  final hour = hours.value;
  const max = 0.8;
  if (hour >= 5 && hour < 7) return max;
  if (hour >= 17 && hour < 19) return max;
  return 0;
}

double getVolumeTargetDayAmbience() {
  if (ambient.value == Shade.Very_Bright) return 0.2;
  return 0;
}

double getFootstepVolume(){
  return 1.0;
}

double getVolumeTargetFire(){
  var nearestFlame = 99999;
  final isDay = ambient.value == Shade.Very_Bright;
  gridForEach(where: GridNodeType.isFire, apply: (z, row, column, type){
    if (isDay && type == GridNodeType.Torch) return;;
    var distance = player.getGridDistance(z, row, column);
    if (distance < nearestFlame) {
      nearestFlame = distance;
    }
  });
  final distance = nearestFlame * tileSize;
  return convertDistanceToVolume(distance);
}