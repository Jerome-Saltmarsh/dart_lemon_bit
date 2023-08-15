import 'package:gamestream_server/common/src/isometric/lightning_type.dart';
import 'package:gamestream_server/common/src/isometric/rain_type.dart';
import 'package:gamestream_server/common/src/isometric/wind_type.dart';
import 'package:gamestream_server/common/src/types/myst_type.dart';

import 'package:gamestream_server/lemon_math.dart';

class Environment {

  static const Lightning_Flash_Duration_Total = 7;

  var _rainType = RainType.None;
  var _breezy = false;
  var _lightningType = LightningType.Off;
  var _windType = WindType.Calm;
  var _mystType = MystType.None;

  var durationMyst = 0;
  var mystEnabled = true;

  var durationRain = randomInt(1000, 3000);
  var nextLightningChanged = 300;
  var durationBreeze = 500;
  var durationWind = randomInt(500, 1000);
  var durationThunder = 0;
  var nextLightningFlash = 0;
  var lightningFlashDuration = 0;
  var onChanged = false;

  int get mystType => _mystType;

  int get lightningType => _lightningType;

  int get rainType => _rainType;

  bool get breezy => _breezy;

  bool get lightningFlashing => lightningFlashDuration > 0;

  int get windType => _windType;

  set mystType(int value){
    if (_mystType == value)
      return;

    _mystType = value.clamp(MystType.None, MystType.Heavy);
    onChanged = true;
  }

  set windType(int value) {
    if (_windType == value) return;
    if (value < WindType.Calm) return;
    if (value > WindType.Strong) return;
    _windType = value;
    onChanged = true;
    onChangedWeather();
  }

  set rainType(int value) {
    if (_rainType == value) return;
    _rainType = value;
    onChangedWeather();
  }

  set breezy(bool value){
    if(_breezy == value) return;
    _breezy = value;
    onChangedWeather();
  }

  set lightningType(int value) {
    if(_lightningType == value) return;
    _lightningType = value;
    onChangedWeather();
  }

  void toggleBreeze(){
    breezy = !breezy;
  }

  void update(){
    updateRain();
    updateLightning();
    updateBreeze();
    updateWind();
    updateMyst();
  }

  void updateRain(){
    if (durationRain-- > 0) return;
    durationRain = randomInt(1000, 3000);
    switch (rainType) {
      case RainType.None:
        rainType = RainType.Light;
        break;
      case RainType.Light:
        rainType = randomBool() ? RainType.Heavy : RainType.None;
        break;
      case RainType.Heavy:
        rainType = RainType.Light;
        break;
    }
  }

  void updateLightning(){

    if (lightningFlashDuration > 0){
      lightningFlashDuration--;
      if (lightningFlashDuration <= 0){
        onChangedWeather();
      }
    }

    if (lightningType == LightningType.On) {
      if (nextLightningFlash-- <= 0) {
        nextLightningFlash = randomInt(500, 1000);
        lightningFlashDuration = Lightning_Flash_Duration_Total;
        onChanged = true;
      }
    }

    if (nextLightningChanged-- > 0) return;
    nextLightningChanged = randomInt(1000, 3000);
    switch (lightningType) {
      case LightningType.Off:
        lightningType = LightningType.Nearby;
        break;
      case LightningType.Nearby:
        lightningType = randomBool() ? LightningType.Off : LightningType.Nearby;
        break;
      case LightningType.On:
        lightningType = LightningType.Nearby;
        nextLightningFlash = 0;
        break;
    }
  }

  void updateBreeze(){
    durationBreeze--;
    if (durationBreeze > 0) return;
    durationBreeze = randomInt(2000, 5000);
    breezy = !breezy;
  }

  void updateWind() {
    durationWind--;
    if (durationWind > 0) return;
    durationWind = randomInt(2000, 4000);

    if (windType == WindType.Calm) {
      windType++;
      return;
    }
    if (windType == WindType.Strong) {
      windType--;
      return;
    }
    if (randomBool()) {
      windType--;
    } else {
      windType++;
    }
  }

  void onChangedWeather(){
    onChanged = true;
  }

  void updateMyst() {
    if (!mystEnabled)
      return;

    if (durationMyst-- > 0)
      return;

    durationMyst = randomInt(1000, 2000);
    mystType = randomInt(0, 2);
    onChanged = true;
  }
}