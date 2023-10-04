
class Gender {
  static const male = 0;
  static const female = 1;

  static const values = [
    male,
    female,
  ];

  static String getName(int value) => switch(value){
      male => 'male',
      female => 'female',
      _ => (throw Exception('Gender.getName($value)')),
    };
}