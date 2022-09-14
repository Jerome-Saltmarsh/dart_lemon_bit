class AttackType {
   static const Unarmed = 0;
   static const Blade = 1;
   static const Crossbow = 2;
   static const Orb = 3;
   static const Teleport = 4;
   static const Particle = 5;
   static const Node_Cannon = 6;
   static const Shotgun = 7;
   static const Handgun = 8;
   static const Assault_Rifle = 11;
   static const Fireball = 12;
   static const Bow = 13;
   static const Baseball_Bat = 14;
   static const Crowbar = 15;
   static const Rifle = 16;
   static const Staff = 17;

   static bool requiresRounds(int value) =>
        value == Crossbow ||
        value == Shotgun ||
        value == Handgun ||
        value == Assault_Rifle ||
        value == Bow ||
        value == Rifle;


   static bool isMelee(int value) =>
         value == Unarmed ||
         value == Blade;

   static String getName(int value)  =>
       const {
          Unarmed: "Unarmed",
          Blade: "Blade",
          Crossbow: "Crossbow",
          Orb: "Orb",
          Teleport: "Teleport",
          Particle: "Particle",
          Node_Cannon: "Editor",
          Shotgun: "Shotgun",
          Handgun: "Handgun",
          Assault_Rifle: "Assault Rifle",
          Fireball: "Fireball",
          Bow: "Bow",
          Baseball_Bat: "Baseball Bat",
          Crowbar: "Crow-bar",
          Rifle: "Rifle",
          Staff: "Staff",
       }[value] ?? "? ($value)";
}
