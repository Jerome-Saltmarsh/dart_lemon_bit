

class AreaType {
   static const None = 0;
   static const Town = 1;
   static const Cemetery = 2;
   static const Farm = 3;
   static const Forest = 4;
   static const Mountains = 5;
   static const Plains = 6;
   static const Lake = 7;
   static const Dark_Fortress = 8;

   static String getName(int value) => {
        Town: "Town",
        Cemetery: "Cemetery",
        Farm: "Farm",
        Forest: "Forest",
        Mountains: "Mountains",
        Plains: "Plains",
        Lake: "Lake",
        Dark_Fortress: "Dark Fortress",
      }[value] ?? "unknown-region-$value";
}