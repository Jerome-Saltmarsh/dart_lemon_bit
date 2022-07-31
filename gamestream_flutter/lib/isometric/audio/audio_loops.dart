import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/isometric/grid/state/wind.dart';
import 'package:gamestream_flutter/isometric/player.dart';
import 'package:gamestream_flutter/isometric/time.dart';
import 'package:gamestream_flutter/isometric/utils/screen_utils.dart';
import 'package:gamestream_flutter/isometric/watches/ambient_shade.dart';
import 'package:gamestream_flutter/isometric/watches/lightning.dart';
import 'package:gamestream_flutter/isometric/watches/torches_ignited.dart';
import 'package:gamestream_flutter/isometric/weather/breeze.dart';

import '../queries/grid_foreach_nearby.dart';
import '../watches/rain.dart';
import 'audio_loop.dart';
import 'convert_distance_to_volume.dart';

final audioLoops = <AudioLoop> [
  AudioLoop(name: 'wind', getTargetVolume: getVolumeTargetWind),
  AudioLoop(name: 'rain', getTargetVolume: getVolumeTargetRain),
  AudioLoop(name: 'crickets', getTargetVolume: getVolumeTargetCrickets),
  AudioLoop(name: 'day-ambience', getTargetVolume: getVolumeTargetDayAmbience),
  AudioLoop(name: 'fire', getTargetVolume: getVolumeTargetFire),
  AudioLoop(name: 'distant-thunder', getTargetVolume: getVolumeTargetDistanceThunder),
  AudioLoop(name: 'heart-beat', getTargetVolume: getVolumeHeartBeat),
  AudioLoop(name: 'stream', getTargetVolume: getVolumeStream),
];

void updateAudioLoops(){
  for (final audioSource in audioLoops){
    audioSource.update();
  }
}


double getVolumeTargetWind() {
  final windLineDistance = (screenCenterRenderX - windLineRenderX).abs();
  final windLineDistanceVolume = convertDistanceToVolume(windLineDistance, maxDistance: 300);
  var target = 0.0;
  if (windLineRenderX - 250 <= screenCenterRenderX) {
    target += windLineDistanceVolume;
  }
  final index = windAmbient.value.index;
  if (index <= windIndexCalm) {
    if (hours.value < 6) return target;
    if (hours.value < 18) return target + 0.1;
    return target;
  }
  if (index <= windIndexGentle) return target + 0.5;
  return 1.0;
}

double getVolumeTargetRain() {
   if (rain.value == Rain.None) return 0.0;
   const r = 7;
   const maxDistance = r * tileSize;
   final distance = getClosestByType(radius: r, type: GridNodeType.Rain_Landing) * tileSize;
   final v = convertDistanceToVolume(distance, maxDistance: maxDistance);
   return v * (rain.value == Rain.Light ? 0.5 : 1.0) * 0.5;
}

double getVolumeTargetCrickets() {
  final hour = hours.value;
  const max = 0.8;
  if (hour >= 5 && hour < 7) return max;
  if (hour >= 17 && hour < 19) return max;
  return 0;
}

double getVolumeTargetDayAmbience() {
  if (ambientShade.value == Shade.Very_Bright) return 0.2;
  return 0;
}

double getVolumeTargetFire(){
  const r = 4;
  const maxDistance = r * tileSize;
  var closest = getClosestByType(radius: r, type: GridNodeType.Fireplace) * tileSize;
  if (torchesIgnited.value) {
      final closestTorch = getClosestByType(radius: r, type: GridNodeType.Torch) * tileSize;
      if (closestTorch < closest) {
         closest = closestTorch;
      }
  }
  return convertDistanceToVolume(closest, maxDistance: maxDistance) * 1.0;
}

double getVolumeTargetDistanceThunder(){
   if (lightningOn) return 1.0;
   return 0;
}

double getVolumeHeartBeat(){
   return 1.0 - player.health.value / player.maxHealth;
}

double getVolumeStream(){
  const r = 7;
  const maxDistance = r * tileSize;
  final distance = getClosestByType(radius: r, type: GridNodeType.Water_Flowing) * tileSize;
  return convertDistanceToVolume(distance, maxDistance: maxDistance) * 0.3;
}
