import 'package:gamestream_flutter/isometric/audio.dart';

import 'audio_loop.dart';

final audioLoops = <AudioLoop> [
  AudioLoop(name: 'wind', getTargetVolume: getVolumeTargetWind),
  AudioLoop(name: 'rain', getTargetVolume: getVolumeTargetRain),
  AudioLoop(name: 'crickets', getTargetVolume: getVolumeTargetCrickets),
  AudioLoop(name: 'day-ambience', getTargetVolume: getVolumeTargetDayAmbience),
];

void updateAudioLoops(){
  for (final audioSource in audioLoops){
    audioSource.update();
  }
}
