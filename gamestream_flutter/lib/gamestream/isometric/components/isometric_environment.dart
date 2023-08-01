
import 'package:gamestream_flutter/gamestream/isometric/atlases/atlas_nodes.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/mixins/component_isometric.dart';
import 'package:gamestream_flutter/library.dart';

import 'isometric_audio.dart';

class IsometricEnvironment with IsometricComponent {

  var windLine = 0;
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

  IsometricEnvironment(){
    lightningFlashing.onChanged(onChangedLightningFlashing);
    rainType.onChanged(onChangedRain);
    seconds.onChanged(onChangedSeconds);
    hours.onChanged(onChangedHour);
    windTypeAmbient.onChanged(onChangedWindType);
    raining.onChanged(onChangedRaining);
  }

  double get windLineRenderX {
    var windLineColumn = 0;
    var windLineRow = 0;
    if (windLine < scene.totalRows){
      windLineColumn = 0;
      windLineRow =  scene.totalRows - windLine - 1;
    } else {
      windLineRow = 0;
      windLineColumn = windLine - scene.totalRows + 1;
    }
    return (windLineRow - windLineColumn) * Node_Size_Half;
  }


  bool get lightningOn =>  lightningType.value != LightningType.Off;

  int get currentTimeInSeconds =>
      (hours.value * Duration.secondsPerHour) +
      (minutes.value * Duration.secondsPerMinute);

  void onChangedLightningFlashing(bool lightningFlashing){
    if (lightningFlashing) {
      audio.thunder(1.0);
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

  double getVolumeTargetWind() {
    final windLineDistance = (engine.screenCenterRenderX - windLineRenderX).abs();
    final windLineDistanceVolume = IsometricAudio.convertDistanceToVolume(windLineDistance, maxDistance: 300);
    var target = 0.0;
    if (windLineRenderX - 250 <= engine.screenCenterRenderX) {
      target += windLineDistanceVolume;
    }
    final index = environment.windTypeAmbient.value;
    if (index <= WindType.Calm) {
      if (environment.hours.value < 6) return target;
      if (environment.hours.value < 18) return target + 0.1;
      return target;
    }
    if (index <= WindType.Gentle) return target + 0.5;
    return 1.0;
  }

}