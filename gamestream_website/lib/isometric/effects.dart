import 'classes/explosion.dart';

final effects = <Effect>[];

Effect getEffect(){
  for(final effect in effects){
    if (effect.enabled) continue;
    return effect;
  }
  final effect = Effect();
  effects.add(effect);
  return effect;
}
