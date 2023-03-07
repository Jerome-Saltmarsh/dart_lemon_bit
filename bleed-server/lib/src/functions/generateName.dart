import 'package:lemon_math/library.dart';

String generateRandomName() {

  const adjectives = <String> [
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
    "Wicked",
    "Sadistic",
    "Swift",
    "Shady",
    "Simple",
    "Bad",
    "Cold",
    "Strange",
    "Lost",
    "Crispy",
    "Relaxed",
    "Angry",
    "Thirsty",
  ];

  const nouns = <String>[
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
    "Chicken",
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
    "Cactus",
    "Tiger",
    "Breeze",
    "Breath",
    "Foot",
    "Armpit",
  ];
  return '${randomItem(adjectives)}-${randomItem(nouns)}';
}
