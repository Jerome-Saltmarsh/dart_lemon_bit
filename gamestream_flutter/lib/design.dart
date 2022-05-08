enum GameMode {
    Party,
    Alone,
    Hybrid,
    One_V_One,
}

enum GameTime {
    /// Wait for a specific number of players to join before the game begins
    Wait_For_Players,
    /// Instantly join an existing game
    Instant,
}

enum GameGoal {
  Destroy_Fortress,
  Kill_Enemies,
  Survive_Waves,
  Kill_Enemy_King,
  Last_One_Standing,
  Sandbox,
}

enum GameDuration {
  Persistent,
  Game_45_Minutes,
  Rounds_10_Minutes,
  No_End,
}

enum GameControl {
   Hero,
   Micro_Manage,
}

enum GameAbilities {
  Fixed,
  Dynamic,
  None,
  Item_Based,
}

enum GameWeapons {
  Fixed,
  Dynamic,
  None
}

enum GamePromise {
  Mine_Resources,
  Tower_Defense,
  Defend_Base,
  Find_Loot,
  Purchase_Items,
  Abilities,
  Farm_Creeps,
  Kill_Players,
  Kill_Units,
  Destroy_Structures,
  Improve_Hero_Stat_With_Items,
  Increase_Hero_Level,
  Increase_Ability_Levels,
  Last_Hit_Bonus,
  Passive_Income,
  Increase_Passive_Income_By_Sending_Creeps,
  Capture_Flags,
}

class GameDesign {
  final GameMode mode;
  final GameTime time;
  final GameGoal goal;
  final GameDuration duration;
  final GameControl control;
  final GameAbilities abilities;
  final GameWeapons weapons;
  final List<GamePromise> promises;

  const GameDesign({
    required this.mode,
    required this.time,
    required this.duration,
    required this.goal,
    required this.control,
    required this.abilities,
    required this.weapons,
    required this.promises
  });
}


/// Shoot Off
/// Passive_Income
/// Isometric_FPS
/// 1_v_1
/// Purchase_Weapons
/// Upgrade_Weapons
///
/// The player has a passive income which gets increased when they purchase offensives
/// Income can also be used to unlock new weapons and improve weapons
/// Weapons have an accuracy, rate of fire, damage, etc, number of rounds
/// Units automatically spawn and run towards the enemy finish line
/// the aim of the game is to reach the enemy finish line
///
/// The player has to strategically choose between investing in their offensive and defensive