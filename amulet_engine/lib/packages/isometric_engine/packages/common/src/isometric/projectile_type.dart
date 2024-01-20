
class ProjectileType {
   static const Arrow = 0;
   static const Fireball = 2;
   static const FrostBall = 6;

   static double getSpeed(int type) => const {
      Arrow: 5.0,
      Fireball: 4.5,
      FrostBall: 3.0,
   }[type] ?? 0;

   static double getRadius(int type) => const {
      Arrow    : 10.0,
      Fireball : 10.0,
      FrostBall : 10.0,
   }[type] ?? 10;

   static String getName(int value) => const {
         Arrow: 'Arrow',
         Fireball: 'Fireball',
         FrostBall: 'FrostBall',
      }[value] ?? 'projectile-name-unknown-$value';
}