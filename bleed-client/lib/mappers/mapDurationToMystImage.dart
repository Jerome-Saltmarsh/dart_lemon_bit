import 'dart:ui';

import 'package:bleed_client/images.dart';
import 'package:bleed_client/state/particleSettings.dart';

final int _a = particleSettings.mystDuration - 25;
final int _b = particleSettings.mystDuration - 50;
final int _c = particleSettings.mystDuration - 75;
final int _d = particleSettings.mystDuration - 100;
final int _e = particleSettings.mystDuration - 150;
final int _f = particleSettings.mystDuration - 200;

Image mapMystDurationToImage(int duration) {
  if (duration > _a){
    return images.radial64_02;
  }
  if (duration > _b){
    return images.radial64_05;
  }
  if (duration > _c){
    return images.radial64_10;
  }
  if (duration > _d){
    return images.radial64_20;
  }
  if (duration > _d){
    return images.radial64_20;
  }
  if (duration > _e){
    return images.radial64_30;
  }
  if (duration > _f){
    return images.radial64_40;
  }
  if (duration > 150) {
    return images.radial64_40;
  }
  if (duration > 125) {
    return images.radial64_30;
  }
  if (duration > 100) {
    return images.radial64_30;
  }
  if (duration > 75) {
    return images.radial64_20;
  }
  if (duration > 50) {
    return images.radial64_10;
  }
  return images.radial64_05;
}
