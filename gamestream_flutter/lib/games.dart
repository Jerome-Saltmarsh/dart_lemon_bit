
import 'package:gamestream_flutter/design.dart';

const dota = GameDesign(
    mode: GameMode.Party,
    time: GameTime.Wait_For_Players,
    goal: GameGoal.Destroy_Fortress,
    control: GameControl.Hero,
    abilities: GameAbilities.Fixed,
    weapons: GameWeapons.None,
    duration: GameDuration.Game_45_Minutes,
    promises: [
      GamePromise.Abilities,
      GamePromise.Defend_Base,
      GamePromise.Destroy_Structures,
      GamePromise.Farm_Creeps,
      GamePromise.Kill_Players,
      GamePromise.Kill_Players,
      GamePromise.Purchase_Items,
      GamePromise.Improve_Hero_Stat_With_Items,
      GamePromise.Increase_Hero_Level,
      GamePromise.Increase_Ability_Levels,
      GamePromise.Last_Hit_Bonus,
    ]
);

const chess = GameDesign(
    mode: GameMode.One_V_One,
    duration: GameDuration.Game_45_Minutes,
    time: GameTime.Wait_For_Players,
    goal: GameGoal.Kill_Enemy_King,
    control: GameControl.Micro_Manage,
    abilities: GameAbilities.Fixed,
    weapons: GameWeapons.None,
    promises: [
          GamePromise.Defend_Base,
          GamePromise.Destroy_Structures,
          GamePromise.Destroy_Structures,
    ],
);

const ultimate_sandbox = GameDesign(
  mode: GameMode.Alone,
  duration: GameDuration.No_End,
  goal: GameGoal.Sandbox,
  time: GameTime.Instant,
  control: GameControl.Hero,
  abilities: GameAbilities.None,
  weapons: GameWeapons.Fixed,
  promises: [
    GamePromise.Kill_Players,
    GamePromise.Farm_Creeps,
    GamePromise.Mine_Resources,
    GamePromise.Defend_Base,
  ]
);

const ultimate_royal = GameDesign(
    mode: GameMode.Alone,
    duration: GameDuration.Game_45_Minutes,
    goal: GameGoal.Last_One_Standing,
    time: GameTime.Wait_For_Players,
    control: GameControl.Hero,
    abilities: GameAbilities.None,
    weapons: GameWeapons.Fixed,
    promises: [
      GamePromise.Kill_Players,
      GamePromise.Farm_Creeps,
      GamePromise.Mine_Resources,
      GamePromise.Defend_Base,
    ]
);

///
const ultimate_battlefield = GameDesign(
    mode: GameMode.Party,
    time: GameTime.Instant,
    duration: GameDuration.Game_45_Minutes,
    goal: GameGoal.Destroy_Fortress,
    control: GameControl.Hero,
    abilities: GameAbilities.Fixed,
    weapons: GameWeapons.Fixed,
    promises: [
       GamePromise.Defend_Base,
       GamePromise.Kill_Players,
       GamePromise.Kill_Units,
       GamePromise.Capture_Flags,
    ]
);