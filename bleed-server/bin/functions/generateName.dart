import '../maths.dart';

List<String> adjectives = [
  "Blue",
  "Golden",
  "Old",
  "Smelly",
];

List<String> nouns = [
  "Horse",
  "Sock",
  "Shoe",
  "Cake",
  "Fart",
];

String generateName() {
  return randomValue(adjectives) + randomValue(nouns);
}
