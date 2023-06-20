import 'package:bleed_server/src/games/isometric/isometric_position.dart';

enum CaptureTheFlagPowerType {
   Blink,
   Slow,
}

abstract class CaptureTheFlagPower {
  final CaptureTheFlagPowerMode mode;
  CaptureTheFlagPower(this.mode);
}

abstract class CaptureTheFlagPowerPositional extends CaptureTheFlagPower {

  void activate({
    required IsometricPosition src,
    required double x,
    required double y,
    required double z,
  });

  CaptureTheFlagPowerPositional() : super(CaptureTheFlagPowerMode.Positional);
}

class CaptureTheFlagPowerBlink extends CaptureTheFlagPowerPositional {
  @override
  void activate({required IsometricPosition src, required double x, required double y, required double z}) {
    // TODO: implement activate
  }
}

enum CaptureTheFlagPowerMode {
  Self,
  Positional,
  Targeted,
}
