
class ProjectileType {
   static const Arrow = 0;
   static const Orb = 1;
   static const Fireball = 2;
   static const Bullet = 3;
   static const Wave = 4;
   static const FrostBall = 6;

   static double getSpeed(int type) => const {
      Arrow: 5.0,
      Orb: 4.5,
      Fireball: 4.5,
      Bullet: 7.0,
      Wave: 6.0,
      FrostBall: 3.0,
   }[type] ?? 0;

   static double getRadius(int type) => const {
      Arrow    : 10.0,
      Orb      : 10.0,
      Fireball : 10.0,
      Bullet   : 10.0,
      Wave     : 10.0,
   }[type] ?? 10;

   static String getName(int value) => const {
         Arrow: 'Arrow',
         Orb: 'Orb',
         Fireball: 'Fireball',
         Bullet: 'Bullet',
         Wave: 'Wave',
         FrostBall: 'FrostBall',
      }[value] ?? 'projectile-name-unknown-$value';
}