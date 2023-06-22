
class WeaponState {
   static const Firing = 1;
   static const Idle = 2;
   static const Reloading = 3;
   static const Aiming = 4;
   static const Changing = 5;
   static const Throwing = 6;
   static const Melee = 7;

   static String getName(int weaponState) => const {
         Firing: "Firing",
         Idle: "Idle",
         Reloading: "Reloading",
         Aiming: "Aiming",
         Changing: "Changing",
         Throwing: "Throwing",
         Melee: "Melee",
   }[weaponState] ?? "unknown-weapon-state-$weaponState";
}