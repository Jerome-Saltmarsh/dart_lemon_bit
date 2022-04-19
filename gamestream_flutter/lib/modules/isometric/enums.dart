import 'package:bleed_common/Shade.dart';

class Phase {
  static const Early_Morning = 0;
  static const Morning = 1; // 5 - 9
  static const Day = 2; // 9 - 5
  static const Early_Evening = 3;
  static const Evening = 4; // 5 - 9
  static const Night = 5; // 9
  static const MidNight = 6; // - 5

  static int fromHour(int hour){
    if (hour < 2) return MidNight;
    if (hour < 4) return Night;
    if (hour < 6) return Early_Morning;
    if (hour < 10) return Morning;
    if (hour < 16) return Day;
    if (hour < 18) return Early_Evening;
    if (hour < 20) return Evening;
    return Night;
  }

  static int toShade(int phase) {
    return const {
      Early_Morning: Shade.Dark,
      Morning: Shade.Medium,
      Day: Shade.Bright,
      Early_Evening: Shade.Medium,
      Evening: Shade.Dark,
      Night: Shade.Very_Dark,
      MidNight: Shade.Pitch_Black,
    }[phase]!;
  }
}

class ParticleType {
  static const Smoke = 0;
  static const Zombie_Head = 2;
  static const Shell = 3;
  static const Arm = 4;
  static const Leg = 5;
  static const Organ = 6;
  static const Blood = 7;
  static const Shrapnel = 8;
  static const FireYellow = 9;
  static const Myst = 10;
  static const Pixel = 11;
  static const Orb_Ruby = 12;
  static const Pot_Shard = 13;
  static const Rock = 14;
}
