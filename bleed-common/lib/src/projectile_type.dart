
class ProjectileType {
   static const Arrow = 0;
   static const Orb = 1;
   static const Fireball = 2;
   static const Bullet = 3;
   static const Wave = 4;

   static double getSpeed(int type) => {
      Arrow: 7.0,
      Orb: 4.5,
      Fireball: 4.5,
      Bullet: 14.0,
      Wave: 6.0,
   }[type] ?? 0;
}