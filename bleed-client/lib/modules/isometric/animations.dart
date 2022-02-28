
final _Animations animations = _Animations();

class _Animations {
  final _Man human = _Man();
  final _Witch witch = _Witch();
  final _Archer archer = _Archer();
  final _Knight knight = _Knight();
  final _Zombie zombie = _Zombie();
  final _Bow bow = _Bow();

  final List<int> firingBow = [4, 4, 5, 7];
  final List<int> firingHandgun = [5, 6, 5];
  final List<int> firingShotgun = [5, 6, 5, 5, 4];
  final List<int> strikingSword = [4, 4, 5, 5];
  // final List<int> running = [9, 10, 11, 12];
}

class _Zombie {
  final List<int> striking = [7, 7, 8, 8];
  final List<int> running = [3, 4, 5, 6];
}

class _Man {
  final List<int> firingHandgun = [0, 1, 0];
  final List<int> firingShotgun = [0, 1, 0, 0, 0, 2, 0];
  final List<int> strikingSword = [0, 0, 1, 1];
  final List<int> performing = [0, 0, 1, 1];
  final List<int> changing = [1, 1];
  final List<int> firingBow = [0];
}

class _Bow {
  final List<int> firing = [0, 0, 0, 0];
}

class _Witch {
  final List<int> attacking = [0, 0, 1, 1];
}

class _Archer {
  final List<int> firing = [0, 1, 2, 3, 3, 3];
}

class _Knight {
  final List<int> striking = [0, 1, 2, 2, 2, 2, 2];
}

