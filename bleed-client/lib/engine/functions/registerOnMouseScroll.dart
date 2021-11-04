
import 'package:bleed_client/engine/state/onMouseScroll.dart';

void registerOnMouseScroll(Function(double value) value){
  onMouseScroll = value;
}