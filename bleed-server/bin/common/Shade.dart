class Shade {
  static const Very_Bright = 0;
  static const Bright = 1;
  static const Medium = 2;
  static const Dark = 3;
  static const Very_Dark = 4;
  static const Pitch_Black = 5;
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