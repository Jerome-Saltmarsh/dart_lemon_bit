
class HeadType {
   static const None = 0;
   static const Steel_Helm = 1;
   static const Rogues_Hood = 2;
   static const Wizards_Hat = 3;
   
   static const values = [
      None,
      Steel_Helm,
      Rogues_Hood,
      Wizards_Hat,
   ];
   
   static String getName(int type){
       return <int, String>{
          None: "None",
          Steel_Helm: "Steel Helm",
          Rogues_Hood: "Rogues Hood",
          Wizards_Hat: "Wizards Hat",
       }[type]!;
   }
}