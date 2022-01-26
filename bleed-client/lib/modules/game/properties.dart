
import 'package:bleed_client/modules.dart';

class GameProperties {

  double get timeInHours {
    return timeInMinutes / 60;
  }

  double get timeInMinutes {
    return modules.isometric.state.time.value / 60.0;
  }
}