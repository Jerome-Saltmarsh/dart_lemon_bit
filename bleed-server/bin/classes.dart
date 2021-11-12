


import 'interfaces/HasSquad.dart';

extension HasSquadExtensions on HasSquad {
  bool get noSquad => getSquad() == -1;
}

bool allies(HasSquad a, HasSquad b) {
  if (a.noSquad) return false;
  if (b.noSquad) return false;
  return a.getSquad() == b.getSquad();
}

bool enemies(HasSquad a, HasSquad b) {
  return !allies(a, b);
}

