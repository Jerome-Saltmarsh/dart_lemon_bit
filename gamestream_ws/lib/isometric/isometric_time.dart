import 'package:gamestream_ws/packages/common.dart';

class IsometricTime {
  var secondsPerFrame = 2;
  /// In seconds
  var time = 0;
  var enabled = true;

  IsometricTime({
    this.secondsPerFrame = 2,
    int hour = 12,
    int minute = 0,
    this.enabled = true,
  }) {
    assert (hour >= 0);
    assert (hour <= 24);
    assert (minute >= 0);
    assert (minute <= 60);
    time = (hour * Duration.secondsPerHour) + (minute * Seconds_Per_Minute);
  }

  int get hour => time ~/ Duration.secondsPerHour;

  set hour(int value) {
    time = value * 60 * 60;
  }

  void update(){
    if (!enabled) return;
    setTime(time + secondsPerFrame);
  }

  void setTime(int value) {
    time = value % Duration.secondsPerDay;
  }

}
