
import 'package:gamestream_flutter/gamestream/isometric/atlases/atlas_nodes.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_component.dart';
import 'package:gamestream_flutter/packages/common.dart';
import 'package:lemon_math/src.dart';
import 'package:lemon_watch/src.dart';

import 'isometric_audio.dart';

class IsometricEnvironment with IsometricComponent {

  var windLine = 0;
  var srcXRainFalling = 6640.0;
  var lightningFlashing = false;
  var lightningFlashing01 = 0.0;

  final night = WatchBool(false);
  final rainType = Watch(RainType.None);
  final seconds = Watch(0);
  final hours = Watch(0);
  final wind = Watch(WindType.Calm);
  final myst = Watch(0);
  final raining = Watch(false);
  final timeEnabled = Watch(false);
  final lightningType = Watch(LightningType.Off);
  final weatherBreeze = Watch(false);
  final minutes = Watch(0);

  IsometricEnvironment(){
    rainType.onChanged(onChangedRain);
    seconds.onChanged(onChangedSeconds);
    hours.onChanged(onChangedHour);
    wind.onChanged(onChangedWindType);
    raining.onChanged(onChangedRaining);
    night.onChanged(onChangedNight);
  }

  /// 0 at night is 0
  /// 12 at day is 1
  double get brightness => parabola(currentTimeInSeconds / Duration.secondsPerDay);

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

  void onChangedRain(int value) {
    raining.value = value != RainType.None;
    refreshRain();
    scene.updateAmbientAlphaAccordingToTime();
    scene.generateEmptyNodes();
  }

  void onChangedSeconds(int seconds){
    final minutes = seconds ~/ 60;
    hours.value = minutes ~/ Duration.minutesPerHour;
    this.minutes.value = minutes % Duration.minutesPerHour;
  }

  void onChangedHour(int hour){
    scene.updateAmbientAlphaAccordingToTime();
    night.value = hour < 6 || hour >= 18;
  }

  void onChangedNight(bool night){
    final particles = this.particles.activated;
      if (night){
        for (final particle in particles) {
          if (particle.type == ParticleType.Butterfly) {
            particle.type = ParticleType.Bat;
          }
        }
      } else {
        for (final particle in particles) {
          if (particle.type == ParticleType.Bat) {
            particle.type = ParticleType.Butterfly;
          }
        }
      }
  }

  void onChangedWindType(int windType) {
    refreshRain();
    final children = particles.activated;
    for (final particle in children) {
      particle.wind = windType;
    }
  }

  void refreshRain(){
    switch (rainType.value) {
      case RainType.None:
        break;
      case RainType.Light:
        rendererNodes.srcXRainLanding = AtlasNode.Node_Rain_Landing_Light_X;
        if ( wind.value == WindType.Calm){
          srcXRainFalling = AtlasNode.Node_Rain_Falling_Light_X;
        } else {
          srcXRainFalling = 1851;
        }
        break;
      case RainType.Heavy:
        rendererNodes.srcXRainLanding = AtlasNode.Node_Rain_Landing_Heavy_X;
        if ( wind.value == WindType.Calm){
          srcXRainFalling = 1900;
        } else {
          srcXRainFalling = 1606;
        }
        break;
    }
  }

  void onChangedRaining(bool raining){
    raining ? scene.rainStart() :  scene.rainStop();
    scene.resetNodeColorsToAmbient();
  }

  double getVolumeTargetWind() {
    final windLineDistance = (engine.screenCenterRenderX - windLineRenderX).abs();
    final windLineDistanceVolume = IsometricAudio.convertDistanceToVolume(windLineDistance, maxDistance: 300);
    var target = 0.0;
    if (windLineRenderX - 250 <= engine.screenCenterRenderX) {
      target += windLineDistanceVolume;
    }
    final index = environment.wind.value;
    if (index <= WindType.Calm) {
      if (environment.hours.value < 6) return target;
      if (environment.hours.value < 18) return target + 0.1;
      return target;
    }
    if (index <= WindType.Gentle) return target + 0.5;
    return 1.0;
  }

  void setMystType(int mystType) =>
      network.sendArgs2(
          NetworkRequest.Environment_Request,
          NetworkRequestEnvironment.Set_Myst,
          mystType,
      );

  void requestLightningFlash() {
    network.sendNetworkRequest(
      NetworkRequest.Environment_Request,
      NetworkRequestEnvironment.Lightning_Flash,
    );
  }

  void setLightningType(int lightningType) =>
    network.sendArgs2(
      NetworkRequest.Environment_Request,
      NetworkRequestEnvironment.Set_Lightning,
      lightningType,
    );

}