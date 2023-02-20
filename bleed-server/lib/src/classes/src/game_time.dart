import 'package:bleed_server/common/src/seconds_per_day.dart';
import 'package:bleed_server/common/src/seconds_per_hour.dart';

class GameTime {
  var secondsPerFrame = 2;
  /// In seconds
  var time = 0;
  var enabled = true;

  GameTime({
    this.secondsPerFrame = 2,
    int hour = 12,
    int minute = 0,
    this.enabled = true,
  }) {
    time = hour * 60 + minute;
  }

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
