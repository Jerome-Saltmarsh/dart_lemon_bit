
class ProjectileType {
   static const Arrow = 0;
   static const Orb = 1;
   static const Fireball = 2;
   static const Bullet = 3;
   static const Wave = 4;
   static const Rocket = 5;

   static double getSpeed(int type) => {
      Arrow: 5.0,
      Orb: 4.5,
      Fireball: 4.5,
      Bullet: 5.0,
      Wave: 6.0,
      Rocket: 2.5,
   }[type] ?? 0;

   static double getRadius(int type) => {
      Arrow    : 10.0,
      Orb      : 10.0,
      Fireball : 10.0,
      Bullet   : 15.0,
      Wave     : 10.0,
      Rocket   : 10.0,
   }[type] ?? 10;
}