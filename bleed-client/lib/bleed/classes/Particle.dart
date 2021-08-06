class Particle {
  double x;
  double y;
  double z;
  double xv;
  double yv;
  double zv;
  double weight;
  int duration;
  double rotation;
  double rotationV;
  double scale;
  double scaleV;

  Particle({
      this.x,
      this.y,
      this.z,
      this.xv,
      this.yv,
      this.zv,
      this.weight,
      this.duration,
      this.rotation = 0,
      this.rotationV = 0,
      this.scale = 1,
      this.scaleV = 1
  });
}
