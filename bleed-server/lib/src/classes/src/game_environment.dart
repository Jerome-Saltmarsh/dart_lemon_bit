import 'package:bleed_server/gamestream.dart';
import 'package:bleed_server/src/games/isometric/isometric_game.dart';
import 'package:lemon_math/library.dart';

class GameEnvironment {
  var durationRain = randomInt(1000, 3000);
  var nextLightningChanged = 300;
  var durationBreeze = 500;
  var durationWind = randomInt(500, 1000);
  var durationThunder = 0;
  var _rainType = RainType.None;
  var _breezy = false;
  var _lightningType = LightningType.Off;
  var _windType = WindType.Calm;
  var nextLightningFlash = 0;
  var lightningFlashDuration = 0;

  static const Lightning_Flash_Duration_Total = 7;

  int get lightningType => _lightningType;
  int get rainType => _rainType;
  bool get breezy => _breezy;
  bool get lightningFlashing => lightningFlashDuration > 0;
  int get windType => _windType;

  set windType(int value) {
    if (_windType == value) return;
    if (value < WindType.Calm) return;
    if (value > WindType.Strong) return;
    _windType = value;
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
        for (final game in engine.games) {
          if (game is! IsometricGame) continue;
          if (this != game.environment) continue;
          for (final player in game.players){
            player.writeWeather();
          }
        }
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

  /// WARNING HACK
  void onChangedWeather(){
    for (final game in engine.games) {
      if (game is! IsometricGame) continue;
      if (game.environment != this) continue;
      game.playersWriteWeather();
    }
  }
}