
import 'package:gamestream_flutter/gamestream/isometric/atlases/atlas_nodes.dart';
import 'package:gamestream_flutter/gamestream/isometric/isometric.dart';
import 'package:gamestream_flutter/library.dart';

class IsometricEnvironment {
  final Isometric isometric;

  var srcXRainFalling = 6640.0;
  var srcXRainLanding = 6739.0;

  final lightningFlashing = Watch(false);
  final rainType = Watch(RainType.None);
  final seconds = Watch(0);
  final hours = Watch(0);
  final windTypeAmbient = Watch(WindType.Calm);
  final raining = Watch(false);
  final gameTimeEnabled = Watch(false);
  final lightningType = Watch(LightningType.Off);
  final weatherBreeze = Watch(false);
  final minutes = Watch(0);

  IsometricEnvironment(this.isometric){
    lightningFlashing.onChanged(onChangedLightningFlashing);
    rainType.onChanged(onChangedRain);
    seconds.onChanged(onChangedSeconds);
    hours.onChanged(onChangedHour);
    windTypeAmbient.onChanged(onChangedWindType);
    raining.onChanged(onChangedRaining);
  }

  bool get lightningOn =>  lightningType.value != LightningType.Off;

  int get currentTimeInSeconds =>
      (hours.value * Duration.secondsPerHour) +
      (minutes.value * Duration.secondsPerMinute);

  void onChangedLightningFlashing(bool lightningFlashing){
    if (lightningFlashing) {
      isometric.audio.thunder(1.0);
    }
  }

  void onChangedRain(int value) {
    raining.value = value != RainType.None;
    refreshRain();
    isometric.scene.updateAmbientAlphaAccordingToTime();
  }

  void onChangedSeconds(int seconds){
    final minutes = seconds ~/ 60;
    hours.value = minutes ~/ Duration.minutesPerHour;
    this.minutes.value = minutes % Duration.minutesPerHour;
  }

  void onChangedHour(int hour){
    isometric.scene.updateAmbientAlphaAccordingToTime();
  }

  void onChangedWindType(int windType) {
    refreshRain();
  }

  void refreshRain(){
    switch (rainType.value) {
      case RainType.None:
        break;
      case RainType.Light:
        srcXRainLanding = AtlasNode.Node_Rain_Landing_Light_X;
        if ( windTypeAmbient.value == WindType.Calm){
          srcXRainFalling = AtlasNode.Node_Rain_Falling_Light_X;
        } else {
          srcXRainFalling = 1851;
        }
        break;
      case RainType.Heavy:
        srcXRainLanding = AtlasNode.Node_Rain_Landing_Heavy_X;
        if ( windTypeAmbient.value == WindType.Calm){
          srcXRainFalling = 1900;
        } else {
          srcXRainFalling = 1606;
        }
        break;
    }
  }

  void onChangedRaining(bool raining){
    raining ? isometric.scene.rainStart() :  isometric.scene.rainStop();
    isometric.scene.resetNodeColorsToAmbient();
  }
}