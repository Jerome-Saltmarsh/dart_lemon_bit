import 'package:bleed_server/common/src/seconds_per_day.dart';
import 'package:bleed_server/common/src/seconds_per_hour.dart';

class GameTime {
  var secondsPerFrame = 2;
  /// In seconds
  var time = 12 * 60 * 60;
  var enabled = true;

  GameTime({
    this.secondsPerFrame = 2,
    this.time = 12 * 60 * 60,
    this.enabled = true,
  });

  int get hour => time ~/ secondsPerHour;

  set hour(int value) {
    time = value * 60 * 60;
  }

  void update(){
    if (!enabled) return;
    setTime(time + secondsPerFrame);
  }

  void setTime(int value) {
    time = value % secondsPerDay;
  }

}
