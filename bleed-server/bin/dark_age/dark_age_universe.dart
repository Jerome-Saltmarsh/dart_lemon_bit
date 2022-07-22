
import '../common/lightning.dart';
import '../common/rain.dart';
import '../common/seconds_per_day.dart';
import '../common/wind.dart';
import '../engine.dart';
import 'game_dark_age.dart';
import 'package:lemon_math/library.dart';


class DarkAgeTime {
  var minutesPassingPerSecond = 5;
  var time = 12 * 60 * 60;
  var timePassing = true;

  void update(){
    setTime(time + minutesPassingPerSecond);
  }

  void setTime(int value) {
    time = value % secondsPerDay;
  }
}

class DarkAgeUniverse {
   var durationRain = randomInt(1000, 3000);
   var durationLightning = 300;
   var durationBreeze = 500;
   var durationWind = randomInt(500, 1000);
   var _raining = Rain.None;
   var _breezy = false;
   var _lightning = Lightning.Off;
   var _wind = 0;

   final DarkAgeTime time;


   DarkAgeUniverse(this.time);

  Lightning get lightning => _lightning;
   Rain get raining => _raining;
   bool get breezy => _breezy;
   bool get timePassing => time.timePassing;
   int get wind => _wind;

   set wind(int value){
      if (_wind == value) return;
      if (value < windIndexCalm) return;
      if (value > windIndexStrong) return;
      _wind = value;
      onChangedWeather();
   }

   set raining(Rain value) {
      if (_raining == value) return;
      _raining = value;
      onChangedWeather();
   }

   set breezy(bool value){
      if(_breezy == value) return;
      _breezy = value;
      onChangedWeather();
   }

   set lightning(Lightning value){
      if(_lightning == value) return;
      _lightning = value;
      onChangedWeather();
   }

   set timePassing(bool value) {
      if(timePassing == value) return;
      time.timePassing = value;
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

   void setTime(int value) {
      time.time = value % secondsPerDay;
   }

   void update(){
      if (!timePassing) return;
      updateRain();
      updateLightning();
      updateBreeze();
      updateWind();
   }

   void updateRain(){
      if (durationRain-- > 0) return;
      durationRain = randomInt(1000, 3000);
      switch (raining) {
         case Rain.None:
            raining = Rain.Light;
            break;
         case Rain.Light:
            raining = randomBool() ? Rain.None : Rain.Heavy;
            break;
         case Rain.Heavy:
            raining = Rain.Light;
            break;
      }
   }

   void updateLightning(){
      if (durationLightning-- > 0) return;
      durationLightning = randomInt(1000, 3000);
      switch (lightning) {
         case Lightning.Off:
            lightning = Lightning.Nearby;
            break;
         case Lightning.Nearby:
            lightning = randomBool() ? Lightning.Off : Lightning.On;
            break;
         case Lightning.On:
            lightning = Lightning.Nearby;
            break;
      }
   }

   void updateBreeze(){
      durationBreeze -= time.minutesPassingPerSecond;
      if (durationBreeze > 0) return;
      durationBreeze = randomInt(2000, 5000);
      breezy = !breezy;
   }

   void updateWind(){
      durationWind -= time.minutesPassingPerSecond;
      if (durationWind <= 0) {
         durationWind = randomInt(3000, 6000);

         if (wind == Wind.Calm) {
            wind++;
            return;
         }
         if (wind == Wind.Strong){
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
         if (this != gameDarkAge.universe) continue;
         gameDarkAge.playersWriteWeather();
      }
   }
}