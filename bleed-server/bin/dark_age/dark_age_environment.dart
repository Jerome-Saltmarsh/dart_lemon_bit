
import '../common/library.dart';
import '../engine.dart';
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
   var nextThunderStrike = 0;
   var _raining = RainType.None;
   var _breezy = false;
   var _lightning = LightningType.Off;
   var _wind = 0;
   var _shade = Shade.Bright;
   var maxShade = Shade.Very_Bright;

   final DarkAgeTime time;

   DarkAgeEnvironment(this.time, {this.maxShade = Shade.Very_Bright}){
     shade = maxShade;
   }

   int get lightning => _lightning;
   int get raining => _raining;
   bool get breezy => _breezy;
   bool get timePassing => time.enabled;
   int get wind => _wind;
   int get shade => _shade;

   set shade(int value) {
     final clampedValue = clamp(value, maxShade, Shade.Pitch_Black);
     if (_shade == clampedValue) return;
     _shade = clampedValue;
     onChangedWeather();
   }

   set wind(int value) {
      if (_wind == value) return;
      if (value < WindType.Calm) return;
      if (value > WindType.Strong) return;
      _wind = value;
      onChangedWeather();
   }

   set raining(int value) {
      if (_raining == value) return;
      _raining = value;
      onChangedWeather();
   }

   set breezy(bool value){
      if(_breezy == value) return;
      _breezy = value;
      onChangedWeather();
   }

   set lightning(int value) {
      if(_lightning == value) return;
      _lightning = value;
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

   void toggleWind(){
      wind = (_wind + 1) % 3;
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
     shade = Shade.fromHour(time.hour);
   }

   void updateRain(){
      if (durationRain-- > 0) return;
      durationRain = randomInt(1000, 3000);
      switch (raining) {
         case RainType.None:
            raining = RainType.Light;
            break;
         case RainType.Light:
            raining = randomBool() ? RainType.None : RainType.Heavy;
            break;
         case RainType.Heavy:
            raining = RainType.Light;
            break;
      }
   }

   void updateLightning(){
      if (nextLightningChanged-- > 0) return;
      nextLightningChanged = randomInt(1000, 3000);
      switch (lightning) {
         case LightningType.Off:
            lightning = LightningType.Nearby;
            break;
         case LightningType.Nearby:
            lightning = randomBool() ? LightningType.Off : LightningType.On;
            break;
         case LightningType.On:
            lightning = LightningType.Nearby;
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

         if (wind == WindType.Calm) {
            wind++;
            return;
         }
         if (wind == WindType.Strong){
            wind--;
            return;
         }
         if (randomBool()){
            wind--;
         } else {
            wind++;
         }
      }
   }

   void onChangedWeather(){
      for (final game in engine.games){
         if (game is GameDarkAge == false) continue;
         final gameDarkAge = game as GameDarkAge;
         if (this != gameDarkAge.environment) continue;
         gameDarkAge.playersWriteWeather();
      }
   }
}