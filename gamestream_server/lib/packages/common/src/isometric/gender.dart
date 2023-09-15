
class Gender {
  static const male = 0;
  static const female = 1;

  static String getName(int value) => switch(value){
      male => 'male',
      female => 'female',
      _ => (throw Exception('Gender.getName($value)')),
    };
}