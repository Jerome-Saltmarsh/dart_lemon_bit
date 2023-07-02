class HeadType {
   static const Plain = 0;
   static const Steel_Helm = 1;
   static const Shirt_Cyan = 2;
   static const Rogue_Hood = 3;
   static const Wizards_Hat = 4;
   static const Head_Blonde = 5;
   static const Swat = 6;

   static String getName(int value) {
      return const {
         Plain: "Plain",
         Steel_Helm: "Steel Helm",
         Shirt_Cyan: "Cyan Shirt",
         Rogue_Hood: "Rogue Hood",
         Wizards_Hat: "Wizard's Hat",
         Head_Blonde: "Blonde Head",
         Swat: "Swat",
      }[value] ?? 'head-type-unknown-$value';
   }

   static const values = [
      Plain,
      Steel_Helm,
      Shirt_Cyan,
      Rogue_Hood,
      Wizards_Hat,
      Head_Blonde,
      Swat,
   ];
}
