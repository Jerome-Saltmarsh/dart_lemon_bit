
import 'package:gamestream_flutter/isometric/audio.dart';

void onRainChanged(bool raining){
   raining ? audio.rainStart() : audio.rainStop();
}