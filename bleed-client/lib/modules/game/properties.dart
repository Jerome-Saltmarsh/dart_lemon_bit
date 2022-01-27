
import 'package:bleed_client/modules/modules.dart';

class GameProperties {

  int get timeInHours {
    return timeInMinutes ~/ Duration.minutesPerHour;
  }

  double get timeInMinutes {
    return modules.isometric.state.time.value / Duration.secondsPerMinute;
  }
}