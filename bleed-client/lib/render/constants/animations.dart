
final _Animations animations = _Animations();

class _Animations {
  final _Man man = _Man();
  final _Witch witch = _Witch();
  final _Archer archer = _Archer();
}

class _Man {
  final List<int> firingHandgun = [0, 1, 0];
  final List<int> firingShotgun = [0, 1, 0, 0, 0, 2, 0];
  final List<int> strikingSword = [0, 0, 1, 1];
}

class _Witch {
  final List<int> attacking = [0, 0, 1, 1];
}

class _Archer {
  final List<int> firing = [0, 1, 2, 3, 3, 3];
}

