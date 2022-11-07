
class DialogType {
   static const None = 0;
   static const Inventory = 1;
   static const Talk = 2;
   static const Trade = 3;

   static String getName(int value)=> {
          None: "None",
          Inventory: "Inventory",
          Talk: "Talk",
          Trade: "Trade",
       }[value] ?? "unknown-dialog-type($value)";
}