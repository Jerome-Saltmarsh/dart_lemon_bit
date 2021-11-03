class Crate {
  double x;
  double y;
  int deactiveDuration = 0;

  bool get active => deactiveDuration <= 0;

  Crate({required this.x, required this.y});
}