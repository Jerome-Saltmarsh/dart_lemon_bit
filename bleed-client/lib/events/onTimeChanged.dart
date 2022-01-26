import 'package:bleed_client/mappers/mapHourToPhase.dart';
import 'package:bleed_client/modules.dart';

const _secondsPerMinute = 60;
const _minutesPerHour = 60;

int _hour = 0;

void onTimeChanged(int timeInSeconds) {
  double timeInMinutes = timeInSeconds / _secondsPerMinute;
  double timeInHours = timeInMinutes / _minutesPerHour;
  int _h = timeInHours.toInt();
  if (_hour == _h) return;
  _hour = _h;
  modules.isometric.state.phase.value = mapHourToPhase(_hour);
}
