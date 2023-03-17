
class PowerType {
   static const None        = 0;
   static const Bomb        = 1;
   static const Teleport    = 2;
   static const Invisible   = 3;
   static const Shield      = 4;
   static const Stun        = 5;
   static const Revive      = 6;

   static const values = [
      Bomb,
      Teleport,
      Invisible,
      Shield,
      Stun,
      Revive,
   ];
   
   static String getName(int value) => const <int, String> {
      None        : "None",
      Bomb        : "Bomb",
      Teleport    : "Swift",
      Invisible   : "Vanish",
      Shield      : "Shield",
      Stun        : "Stun",
      Revive      : "Revive",
   }[value] ?? "power-type-?-$value";
}