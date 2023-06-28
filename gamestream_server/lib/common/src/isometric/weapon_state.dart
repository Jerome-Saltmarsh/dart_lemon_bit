
class WeaponState {
   static const Idle = 0;
   static const Firing = 1;
   static const Reloading = 2;
   static const Aiming = 3;
   static const Changing = 4;
   static const Throwing = 5;
   static String getName(int weaponState) => const {
         Firing: "Firing",
         Idle: "Idle",
         Reloading: "Reloading",
         Aiming: "Aiming",
         Changing: "Changing",
         Throwing: "Throwing",
         Melee: "Melee",
   }[weaponState] ?? "unknown-weapon-state-$weaponState";

   static const Melee = 6;
}