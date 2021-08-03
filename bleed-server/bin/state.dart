import 'package:uuid/uuid.dart';

import 'classes.dart';
import 'enums.dart';

List<List<Tile>> tiles = [];
int frame = 0;
List<Npc> npcs = [];
List<Player> players = [];
List<Bullet> bullets = [];
List<Blood> blood = [];
List<Particle> particles = [];
List<GameEvent> gameEvents = [];
DateTime frameTime = DateTime.now();
Duration frameDuration = Duration();
int fps = 30;
StringBuffer buffer = StringBuffer();
String compiledState = "";
Uuid uuidGenerator = Uuid();

bool firstPass = true;
bool secondPass  = true;
bool thirdPass = true;
bool fourthPass = true;
int firstPassMS = 30;
int secondPassMS = 60;
int thirdPassMS = 120;
int fourthPassMS = 240;

