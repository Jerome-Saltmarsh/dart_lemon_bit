

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
   static const Old_Village = 9;
   static const Cemetery_Crypts = 10;

   static String getName(int value) => const {
        Town: "Town",
        Cemetery: "Haunted Cemetery",
        Farm: "Farmlands",
        Forest: "Spooky Forest",
        Mountains: "Mystic Mountains",
        Plains: "Endless Plains",
        Lake: "Ancient Lake",
        Dark_Fortress: "Dark Fortress",
        Old_Village: "Wolford Village",
        Cemetery_Crypts: "Cemetery Crypts",
   }[value] ?? "unknown-region-$value";
}