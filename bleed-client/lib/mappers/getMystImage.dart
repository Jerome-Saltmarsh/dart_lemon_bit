import 'dart:ui';

import 'package:bleed_client/images.dart';

Image mapMystDurationToImage(int duration) {
  if (duration > 150) {
    return images.radial64_50;
  }
  if (duration > 125) {
    return images.radial64_40;
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
