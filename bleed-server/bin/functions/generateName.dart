import '../maths.dart';

List<String> adjectives = [
  "Blue",
  "Golden",
  "Old",
  "Smelly",
  "Stinky"
  "Mouldy",
  "Green",
  "Solid",
  "Curious",
  "Ironic",
  "Scary",
  "Rusty",
  "Jagged",
  "Greasy",
  "Soggy",
  "Shiny",
  "Hairy"
  "Bright",
  "Dark",
  "Sweet",
  "Sweaty",
];

List<String> nouns = [
  "Horse",
  "Sock",
  "Shoe",
  "Cake",
  "Fart",
  "Puss",
  "Dog",
  "Cat",
  "Frog"
  "Crow",
  "Mouse"
  "Turkey",
  "Fridge",
  "Armpit",
  "Nostril",
  "Pimple",
  "Snot",
  "Scar",
  "Vomit"
  "Mucous",
  "Guts",
  "Slime",
  "Ooze",
  "Nail",
  "Splinter",
  "Ship",
  "Salt",
];

String generateName() {
  return '${randomValue(adjectives)}_${randomValue(nouns)}';
}
