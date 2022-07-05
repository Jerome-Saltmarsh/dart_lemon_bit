import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/isometric/grid.dart';
import 'package:gamestream_flutter/isometric/grid/state/wind.dart';
import 'package:gamestream_flutter/isometric/player.dart';
import 'package:gamestream_flutter/isometric/time.dart';
import 'package:gamestream_flutter/isometric/utils/screen_utils.dart';
import 'package:gamestream_flutter/isometric/weather/breeze.dart';
import 'package:gamestream_flutter/isometric/watches/lightning.dart';

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
   switch(rain.value){
     case Rain.None:
       return 0;
     case Rain.Light:
       return 0.5;
     case Rain.Heavy:
       return 1.0;
   }
}

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
  return convertDistanceToVolume(distance, maxDistance: 200);
}

double getVolumeTargetDistanceThunder(){
   if (lightningOn) return 1.0;
   return 0;
}

double getVolumeHeartBeat(){
   return 1.0 - player.health.value / player.maxHealth;
}