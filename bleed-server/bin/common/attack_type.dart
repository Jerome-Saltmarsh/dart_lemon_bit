class AttackType {
   static const Unarmed = 0;
   static const Blade = 1;
   static const Crossbow = 2;
   static const Orb = 3;
   static const Teleport = 5;
   static const Particle = 6;
   static const Node_Cannon = 7;
   static const Shotgun = 8;
   static const Handgun = 9;
   static const Weather = 10;
   static const Time = 11;

   static String getName(int value){
       return const {
          Unarmed: "Unarmed",
          Blade: "Blade",
          Crossbow: "Crossbow",
          Orb: "Orb",
          Teleport: "Teleport",
          Particle: "Particle",
          Node_Cannon: "Node Cannon",
          Shotgun: "Shotgun",
          Handgun: "Handgun",
          Weather: "Weather",
          Time: "Time",
       }[value] ?? "? ($value)";
   }
}
