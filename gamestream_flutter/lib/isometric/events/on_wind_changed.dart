import 'package:gamestream_flutter/isometric/audio.dart';
import 'package:gamestream_flutter/isometric/grid/state/wind.dart';

void onWindChanged(Wind value) {
  switch (value) {
    case Wind.Calm:
      audio.windStop();
      break;
    case Wind.Gentle:
      audio.windGentleStart();
      break;
    case Wind.Strong:
      audio.windStrongStart();
      break;
  }
}
