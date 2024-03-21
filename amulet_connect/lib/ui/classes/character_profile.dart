
import 'package:amulet_common/src.dart';

class CharacterProfile {
  final String name;
  final int complexion;
  final int hairType;
  final int hairColor;
  final int gender;
  final int headType;
  final Difficulty difficulty;

  CharacterProfile({
    required this.name,
    required this.complexion,
    required this.hairType,
    required this.hairColor,
    required this.gender,
    required this.headType,
    required this.difficulty,
  });
}