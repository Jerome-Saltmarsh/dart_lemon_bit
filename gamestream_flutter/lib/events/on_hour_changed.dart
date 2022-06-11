
import 'package:gamestream_flutter/convert/convert_hour_to_ambient.dart';
import 'package:gamestream_flutter/modules/modules.dart';

void onHourChanged(int hour){
    isometric.ambient.value = convertHourToAmbient(hour);
}