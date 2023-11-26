import 'package:bleed_common/wind.dart';
import 'package:gamestream_flutter/isometric/events/on_changed_wind.dart';
import 'package:gamestream_flutter/isometric/grid.dart';
import 'package:lemon_watch/watch.dart';

final windAmbient = Watch(Wind.Calm, onChanged: onChangedWind);

void gridWindResetToAmbient(){
  final ambientIndex = windAmbient.value.index;
  for (final plain in grid){
     for (final row in plain){
        for (final node in row){
          node.wind = ambientIndex;
        }
     }
  }
}

