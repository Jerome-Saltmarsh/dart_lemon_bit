class Shade {
  static const Very_Bright = 0;
  static const Bright = 1;
  static const Medium = 2;
  static const Dark = 3;
  static const Very_Dark = 4;
  static const Pitch_Black = 5;
  
  static int fromHour(int hour){
      if (hour < 2) return Pitch_Black;
      if (hour < 3) return Very_Dark;
      if (hour < 5) return Dark;
      if (hour < 7) return Medium;
      if (hour < 9) return Bright;
      if (hour < 16) return Very_Bright;
      if (hour < 18) return Bright;
      if (hour < 20) return Medium;
      if (hour < 21) return Dark;
      if (hour < 23) return Very_Dark;
      return Pitch_Black;
  }
}

const Pitch_Black = Shade.Pitch_Black;

String shadeName(int shade){
  switch(shade){
    case Shade.Bright:
      return "Bright";
    case Shade.Medium:
      return "Medium";
    case Shade.Dark:
      return "Dark";
    case Shade.Very_Dark:
      return "Very Dark";
    case Shade.Pitch_Black:
      return "Pitch Black";
    default:
      throw Exception("could not parse shade $shade to string");
  }
}