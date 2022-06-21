class ArmourType {
  static const shirtCyan = 0;
  static const shirtRed = 1;
  static const rogueHood = 2;
  static const wizardsRobes = 3;

  static const values = [
    shirtCyan,
    shirtRed,
    rogueHood,
    wizardsRobes,
  ];

  static String getName(int type){
     return const<int, String> {
         shirtCyan: "Shirt Cyan",
         shirtRed: "Shirt Red",
         rogueHood: "Rogue Hood",
         wizardsRobes: "Wizards Robes",
     }[type]!;
  }
}