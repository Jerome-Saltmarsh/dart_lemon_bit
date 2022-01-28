const Shade_Bright = 0;
const Shade_Medium = 1;
const Shade_Dark = 2;
const Shade_VeryDark = 3;
const Shade_PitchBlack = 4;

String shadeName(int shade){
  switch(shade){
    case Shade_Bright:
      return "Bright";
    case Shade_Medium:
      return "Medium";
    case Shade_Dark:
      return "Dark";
    case Shade_VeryDark:
      return "Very Dark";
    case Shade_PitchBlack:
      return "Pitch Black";
    default:
      throw Exception("could not parse shade $shade to string");
  }
}