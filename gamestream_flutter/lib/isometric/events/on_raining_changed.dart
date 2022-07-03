
import '../grid/actions/rain_off.dart';
import '../grid/actions/rain_on.dart';

void onRainingChanged(bool value){
  value ? apiGridActionRainOn() : apiGridActionRainOff();
}