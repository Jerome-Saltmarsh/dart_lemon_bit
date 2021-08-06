
import '../classes.dart';
import '../enums.dart';
import '../settings.dart';
import '../state.dart';
import '../utils.dart';

void spawnExplosion(double x, double y){
  dispatch(GameEventType.Explosion, x, y);
  for(Character character in npcs){
    if(objectDistanceFrom(character, x, y) < settingsGrenadeExplosionRadius){
      changeCharacterHealth(character, -settingsGrenadeExplosionDamage);
    }
  }
}