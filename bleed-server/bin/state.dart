import 'package:uuid/uuid.dart';

import 'classes.dart';

int frame = 0;
List<Npc> npcs = [];
List<Character> players = [];
List<Bullet> bullets = [];
DateTime frameTime = DateTime.now();
Duration frameDuration = Duration();
int fps = 0;
StringBuffer buffer = StringBuffer();
String compiledState = "";
int id = 0;
Uuid uuidGenerator = Uuid();