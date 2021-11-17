enum Shade {
  Bright,
  Medium,
  Dark,
  VeryDark,
  PitchBlack,
}

const List<Shade> shades = Shade.values;

extension ShadeExtensions on Shade {
  bool isLighterThan(Shade shade){
    return index < shade.index;
  }

  bool isDarkerThan(Shade shade){
    return index > shade.index;
  }
}