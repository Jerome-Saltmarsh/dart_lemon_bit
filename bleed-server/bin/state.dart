import 'package:uuid/uuid.dart';

import 'classes.dart';

int frame = 0;
List<Npc> npcs = [];
List<Character> players = [];
List<Bullet> bullets = [];
DateTime frameTime = DateTime.now();
Duration frameDuration = Duration();
int fps = 30;
StringBuffer buffer = StringBuffer();
String compiledState = "";
int id = 0;
Uuid uuidGenerator = Uuid();

bool firstPass = true;
bool secondPass  = true;
bool thirdPass = true;
bool fourthPass = true;
int firstPassMS = 30;
int secondPassMS = 60;
int thirdPassMS = 120;
int fourthPassMS = 240;