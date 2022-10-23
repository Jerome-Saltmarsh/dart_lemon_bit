import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/game_state.dart';
import 'package:gamestream_flutter/isometric/grid/state/wind.dart';
import 'package:gamestream_flutter/isometric/utils/screen_utils.dart';
import 'package:gamestream_flutter/isometric/weather/breeze.dart';

import '../queries/grid_foreach_nearby.dart';
import '../watches/rain.dart';
import 'convert_distance_to_volume.dart';



double getVolumeTargetWind() {
  final windLineDistance = (screenCenterRenderX - windLineRenderX).abs();
  final windLineDistanceVolume = convertDistanceToVolume(windLineDistance, maxDistance: 300);
  var target = 0.0;
  if (windLineRenderX - 250 <= screenCenterRenderX) {
    target += windLineDistanceVolume;
  }
  final index = windAmbient.value.index;
  if (index <= windIndexCalm) {
    if (GameState.hours.value < 6) return target;
    if (GameState.hours.value < 18) return target + 0.1;
    return target;
  }
  if (index <= windIndexGentle) return target + 0.5;
  return 1.0;
}

double getVolumeTargetRain() {
   if (rain.value == Rain.None) return 0.0;
   const r = 7;
   const maxDistance = r * tileSize;
   final distance = getClosestByType(radius: r, type: NodeType.Rain_Landing) * tileSize;
   final v = convertDistanceToVolume(distance, maxDistance: maxDistance);
   return v * (rain.value == Rain.Light ? 0.5 : 1.0) * 0.5;
}

double getVolumeTargetCrickets() {
  final hour = GameState.hours.value;
  const max = 0.8;
  if (hour >= 5 && hour < 7) return max;
  if (hour >= 17 && hour < 19) return max;
  return 0;
}



double getVolumeTargetFire(){
  const r = 4;
  const maxDistance = r * tileSize;
  var closest = getClosestByType(radius: r, type: NodeType.Fireplace) * tileSize;
  if (GameState.torchesIgnited.value) {
      final closestTorch = getClosestByType(radius: r, type: NodeType.Torch) * tileSize;
      if (closestTorch < closest) {
         closest = closestTorch;
      }
  }
  return convertDistanceToVolume(closest, maxDistance: maxDistance) * 1.0;
}

double getVolumeTargetDistanceThunder(){
   if (GameState.lightningOn) return 1.0;
   return 0;
}

double getVolumeHeartBeat(){
   return 1.0 - GameState.player.health.value / GameState.player.maxHealth;
}

double getVolumeStream(){
  const r = 7;
  const maxDistance = r * tileSize;
  final distance = getClosestByType(radius: r, type: NodeType.Water_Flowing) * tileSize;
  return convertDistanceToVolume(distance, maxDistance: maxDistance) * 0.3;
}
