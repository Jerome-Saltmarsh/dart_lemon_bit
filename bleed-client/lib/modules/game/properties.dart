
import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/modules/modules.dart';

class GameProperties {

  int get timeInHours {
    return timeInMinutes ~/ Duration.minutesPerHour;
  }

  double get timeInMinutes {
    return modules.isometric.state.time.value / Duration.secondsPerMinute;
  }
}