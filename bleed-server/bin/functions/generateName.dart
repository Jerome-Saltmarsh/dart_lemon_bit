import '../maths.dart';

List<String> adjectives = [
  "Blue",
  "Golden",
  "Old",
  "Smelly",
  "Mouldy",
  "Green",
  "Solid",
  "Curious",
  "Sarcastic",
  "Ironic",
  "Expedient",
  "Scary",
  "Rusty",
  "Jagged",
  "Greasy",
  "Soggy",
  "New",
  "Shiny",
  "Bright",
  "Dark",
  "Sweet",
  "Sweaty",
  "Tough",
];

List<String> nouns = [
  "Horse",
  "Sock",
  "Shoe",
  "Cake",
  "Fart",
  "Dog",
  "Cat",
  "House",
  "Turkey",
  "Fridge",
  "Armpit",
  "Nostril",
  "Pimple",
  "Snot",
  "Scar",
  "Mucous",
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
