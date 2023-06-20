enum CaptureTheFlagPowerMode {
  Self,
  Positional,
  Targeted,
}

enum CaptureTheFlagPowerType {
   Blink(CaptureTheFlagPowerMode.Positional),
   Slow(CaptureTheFlagPowerMode.Targeted);

   final CaptureTheFlagPowerMode mode;
   const CaptureTheFlagPowerType(this.mode);
}

class CaptureTheFlagPower {
  final CaptureTheFlagPowerType type;
  CaptureTheFlagPower(this.type);

  bool get isPositional => type.mode == CaptureTheFlagPowerMode.Positional;
  bool get isTargeted => type.mode == CaptureTheFlagPowerMode.Targeted;
  bool get isSelf => type.mode == CaptureTheFlagPowerMode.Self;
}

