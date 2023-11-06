class AmuletItemLevel {
  final int damage;
  final int fire;
  final int water;
  final int electricity;
  final int health;
  final int quantity;
  final int charges;
  final int cooldown;
  final double range;
  final double movement;
  final String information;
  final int performDuration;

  const AmuletItemLevel({
    required this.information,
    this.damage = 0,
    this.health = 0,
    this.range = 0,
    this.fire = 0,
    this.water = 0,
    this.electricity = 0,
    this.movement = 0,
    this.quantity = 0,
    this.charges = 0,
    this.cooldown = 0,
    this.performDuration = 0,
  });
}
