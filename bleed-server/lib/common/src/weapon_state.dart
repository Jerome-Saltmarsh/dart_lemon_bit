
class WeaponState {
   static const Firing = 1;
   static const Idle = 2;
   static const Reloading = 3;
   static const Aiming = 4;
   static const Changing = 5;
   
   static String getName(int weaponState){
      return const {
         Firing: "Firing",
         Idle: "Idle",
         Reloading: "Reloading",
         Aiming: "Aiming",
         Changing: "Changing",
      }[weaponState] ?? "unknown-weapon-state-$weaponState";
   }
}