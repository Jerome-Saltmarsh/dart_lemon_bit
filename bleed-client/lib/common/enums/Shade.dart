class Shade {
  static const Bright = 0;
  static const Medium = 1;
  static const Dark = 2;
  static const Very_Dark = 3;
  static const Pitch_Black = 4;
}

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