import '../maths.dart';

List<String> adjectives = [
  "Blue",
  "Golden",
  "Old",
  "Smelly",
  "Stinky",
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
  "Hairy",
  "Bright",
  "Dark",
  "Sweet",
  "Sweaty",
  "rotten",
  "Chipped",
  "Mild",
  "Spicy",
  "Wicked",
  "Sadistic",
  "Swift",
  "Shady",
  "Simple",
  "Bad",
  "Cold",
  "Strange",
  "Lost"
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
  "Frog",
  "Crow",
  "Mouse",
  "Turkey",
  "Fridge",
  "Armpit",
  "Nostril",
  "Pimple",
  "Snot",
  "Scar",
  "Vomit",
  "Mucous",
  "Guts",
  "Slime",
  "Ooze",
  "Nail",
  "Splinter",
  "Ship",
  "Salt",
  "Pizza",
  "Cheese",
  "Mushroom",
  "Olive",
  "Salami",
  "Hotdog",
  "Dust",
  "Tooth",
  "Pepper",
  "Stench",
  "Bandit",
  "Chief",
  "Maggot",
  "Dirt",
  "Mole",
  "Fungus",
  "Potato",
  "Ghost",
  "Wizard",
  "Knight",
  "Rogue",
  "Thief",
  "Worm",
  "Chicken"
  "Spider",
  "Crow",
  "Wolf",
  "Fox",
  "Dog",
  "Mouse",
  "Eagle",
  "Wasp",
  "Star",
  "Moon",
  "Comet",
  "Thimble",
  "Needle",
  "Thread",
  "Shark",
  "Fish",
  "Sword",
  "Knife",
];

String generateName() {
  return '${randomValue(adjectives)}_${randomValue(nouns)}';
}
