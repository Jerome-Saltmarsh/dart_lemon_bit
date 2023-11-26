
double convertDistanceToVolume(double distance, {required double maxDistance}){
  // const distanceFade = 0.0065;
  // final v = 1.0 / ((distance * distanceFade) + 1);
  // return v * v;
  if (distance > maxDistance) return 0;
  if (distance < 1) return 1.0;
  final perc = distance / maxDistance;
  return 1.0 - perc;
}