
import 'package:gamestream_flutter/convert/convert_hour_to_ambient.dart';
import 'package:gamestream_flutter/state/grid.dart';

void onHourChanged(int hour){
    ambient.value = convertHourToAmbient(hour);
}