class Shade {
  static const Very_Bright = 0;
  static const Bright = 1;
  static const Medium = 2;
  static const Dark = 3;
  static const Very_Dark = 4;
  static const Very_Very_Dark = 5;
  static const Pitch_Black = 6;
  
  static int fromHour(int hour){
      if (hour < 1) return Pitch_Black;
      if (hour < 3) return Very_Very_Dark;
      if (hour < 5) return Very_Dark;
      if (hour < 6) return Dark;
      if (hour < 8) return Medium;
      if (hour < 10) return Bright;
      if (hour < 15) return Very_Bright;
      if (hour < 16) return Bright;
      if (hour < 18) return Medium;
      if (hour < 20) return Dark;
      if (hour < 22) return Very_Dark;
      if (hour < 23) return Very_Very_Dark;
      return Pitch_Black;
  }
}