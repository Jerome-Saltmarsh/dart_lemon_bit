
enum AmuletElement {
  fire, // red
  water, // blue
  air, // green
  stone; // grey

  static AmuletElement max({
    required int water,
    required int fire,
    required int air,
    required int stone,
  }) {
    var max = water;
    var maxElement = AmuletElement.water;

    if (stone > max) {
      max = stone;
      maxElement = AmuletElement.stone;
    }

    if (air > max) {
      max = air;
      maxElement = AmuletElement.air;
    }

    if (fire > max) {
      maxElement = AmuletElement.fire;
    }

    return maxElement;
  }

}