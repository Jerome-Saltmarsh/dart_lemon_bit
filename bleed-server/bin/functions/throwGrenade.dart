import '../classes.dart';
import '../language.dart';
import '../maths.dart';
import '../settings.dart';
import '../state.dart';
import 'spawnExplosion.dart';

void throwGrenade(double x, double y, double angle, double strength){
  double speed = settingsGrenadeSpeed * strength;
  Grenade grenade = Grenade(x, y, adj(angle, speed), opp(angle, speed));
  grenades.add(grenade);
  delayed(() {
    grenades.remove(grenade);
    spawnExplosion(grenade.x, grenade.y);
  }, ms: settingsGrenadeDuration);
}