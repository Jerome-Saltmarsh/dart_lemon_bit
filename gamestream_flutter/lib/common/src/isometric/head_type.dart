class HeadType {
   static const Plain = 0;
   static const Steel_Helm = 1;
   static const Rogue_Hood = 3;
   static const Wizards_Hat = 4;
   static const Blonde = 5;
   static const Swat = 6;

   static String getName(int value) {
      return const {
         Plain: "Plain",
         Steel_Helm: "Steel Helm",
         Rogue_Hood: "Rogue Hood",
         Wizards_Hat: "Wizard's Hat",
         Blonde: "Blonde",
         Swat: "Swat",
      }[value] ?? 'head-type-unknown-$value';
   }

   static const values = [
      Steel_Helm,
      Rogue_Hood,
      Wizards_Hat,
      Blonde,
      Swat,
   ];
}
