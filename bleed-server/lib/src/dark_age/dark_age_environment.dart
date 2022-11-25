import 'package:bleed_server/gamestream.dart';
import 'game_dark_age.dart';
import 'package:lemon_math/library.dart';


class DarkAgeTime {
  var secondsPerFrame = 2;
  /// In seconds
  var time = 12 * 60 * 60;
  var enabled = true;

  int get hour => time ~/ secondsPerHour;

  void update(){
    if (!enabled) return;
    setTime(time + secondsPerFrame);
  }

  void setTime(int value) {
    time = value % secondsPerDay;
  }

}

class DarkAgeEnvironment {
   var durationRain = randomInt(1000, 3000);
   var nextLightningChanged = 300;
   var durationBreeze = 500;
   var durationWind = randomInt(500, 1000);
   var durationThunder = 0;
   var _rainType = RainType.None;
   var _breezy = false;
   var _lightningType = LightningType.Off;
   var _windType = WindType.Calm;
   var _shade = Shade.Bright;
   var maxShade = Shade.Very_Bright;
   var nextLightningFlash = 0;
   var lightningFlashDuration = 0;

   static const Lightning_Flash_Duration_Total = 7;

   final DarkAgeTime time;

   DarkAgeEnvironment(this.time, {this.maxShade = Shade.Very_Bright}){
     shade = maxShade;
   }

   int get lightningType => _lightningType;
   int get rainType => _rainType;
   bool get breezy => _breezy;
   bool get timePassing => time.enabled;
   int get windType => _windType;
   int get shade => _shade;

   set shade(int value) {
     final clampedValue = clamp(value, maxShade, Shade.Pitch_Black);
     if (_shade == clampedValue) return;
     _shade = clampedValue;
     onChangedWeather();
   }

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

   set timePassing(bool value) {
      if (timePassing == value) return;
      time.enabled = value;
      onChangedWeather();
   }

   void toggleBreeze(){
      breezy = !breezy;
   }

   void toggleTimePassing(){
      timePassing = !timePassing;
   }

   void update(){
      if (!timePassing) return;
      updateRain();
      updateLightning();
      updateBreeze();
      updateWind();
      updateShade();
   }

   void updateShade() {
      if (lightningFlashDuration > 0){
         shade = Shade.Very_Bright;
      } else {
         shade = Shade.fromHour(time.hour);
      }

   }

   void updateRain(){
      if (durationRain-- > 0) return;
      durationRain = randomInt(1000, 3000);
      switch (rainType) {
         case RainType.None:
            rainType = RainType.Light;
            break;
         case RainType.Light:
            rainType = rainType == RainType.None ? RainType.Heavy : RainType.None;
            break;
         case RainType.Heavy:
            rainType = RainType.Light;
            break;
      }
   }

   void updateLightning(){

      if (lightningFlashDuration > 0){
          lightningFlashDuration--;
      }

      if (lightningType == LightningType.On) {
         if (nextLightningFlash-- <= 0) {
            nextLightningFlash = randomInt(500, 1000);
            lightningFlashDuration = Lightning_Flash_Duration_Total;
            _shade = Shade.Very_Bright;
            for (final game in engine.games) {
               if (game is GameDarkAge == false) continue;
               final gameDarkAge = game as GameDarkAge;
               if (this != gameDarkAge.environment) continue;
               for (final player in gameDarkAge.players){
                  player.writeWeather();
                  player.writePlayerEvent(PlayerEvent.Lightning);
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
            lightningType = lightningType == LightningType.On ? LightningType.Off : LightningType.Nearby;
            break;
         case LightningType.On:
            lightningType = LightningType.Nearby;
            nextLightningFlash = 0;
            break;
      }
   }

   void updateBreeze(){
      durationBreeze -= time.secondsPerFrame;
      if (durationBreeze > 0) return;
      durationBreeze = randomInt(2000, 5000);
      breezy = !breezy;
   }

   void updateWind(){
      durationWind -= time.secondsPerFrame;
      if (durationWind <= 0) {
         durationWind = randomInt(3000, 6000);

         if (windType == WindType.Calm) {
            windType++;
            return;
         }
         if (windType == WindType.Strong){
            windType--;
            return;
         }
         if (randomBool()){
            windType--;
         } else {
            windType++;
         }
      }
   }

   /// WARNING HACK
   void onChangedWeather(){
      for (final game in engine.games){
         if (game is GameDarkAge == false) continue;
         final gameDarkAge = game as GameDarkAge;
         if (this != gameDarkAge.environment) continue;
         gameDarkAge.playersWriteWeather();
      }
   }
}