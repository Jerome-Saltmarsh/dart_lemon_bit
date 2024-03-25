
class ProjectileType {
   static const Arrow = 0;
   static const Fireball = 1;
   static const FrostBall = 2;
   static const Ice_Arrow = 3;
   static const Fire_Arrow = 4;
   static const Orb_Gold = 5;

   static double getSpeed(int type) => const {
      Arrow: 5.0,
      Fireball: 4.5,
      FrostBall: 3.0,
      Ice_Arrow: 5.0,
      Fire_Arrow: 5.0,
      Orb_Gold: 5.0,
   }[type] ?? (throw Exception('ProjectileType.getSpeed(${getName(type)})'));

   static double getRadius(int type) => const {
      Arrow    : 10.0,
      Fire_Arrow    : 15.0,
      Ice_Arrow    : 15.0,
      Fireball : 10.0,
      FrostBall : 10.0,
      Orb_Gold : 10.0,
   }[type] ?? 10;

   static String getName(int value) => const {
         Arrow: 'Arrow',
         Fireball: 'Fireball',
         FrostBall: 'FrostBall',
         Ice_Arrow: 'Ice Arrow',
         Fire_Arrow: 'Fire Arrow',
         Orb_Gold: 'Orb Gold',
      }[value] ?? 'projectile-name-unknown-$value';
}