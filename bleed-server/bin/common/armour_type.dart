class ArmourType {
  static const shirtCyan = 0;
  static const shirtBlue = 1;
  static const tunicPadded = 2;

  static const values = [
    shirtCyan,
    shirtBlue,
    tunicPadded,
  ];

  static String getName(int type){
     return const<int, String> {
         shirtCyan: "Cyan Shirt",
         shirtBlue: "Blue Shirt",
        tunicPadded: "Padded Tunic"
     }[type]!;
  }
}