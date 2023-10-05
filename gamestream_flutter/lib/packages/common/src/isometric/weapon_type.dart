class WeaponType {
  static const Unarmed = 0;
  static const Sword = 6;
  static const Bow = 7;
  static const Grenade = 10;
  static const Crossbow = 14;
  static const Staff = 15;
  static const Musket = 16;
  static const Revolver = 17;
  static const Hammer = 21;
  static const Pickaxe = 22;
  static const Knife = 23;
  static const Axe = 24;
  static const Spell_Thunderbolt = 27;

  static const Melee = [
    Unarmed,
    Sword,
    Hammer,
    Staff,
  ];

  static bool isMelee(int value) => Melee.contains(value);

  static bool isThrowable(int value) => const [Grenade].contains(value);

  static String getName(int value) => const {
      Unarmed: 'unarmed',
      Sword: 'Sword',
      Bow: 'Bow',
      Grenade: 'Grenade',
      Crossbow: 'Crossbow',
      Staff: 'staff',
      Musket: 'Musket',
      Revolver: 'Revolver',
      Hammer: 'Hammer',
      Pickaxe: 'Pickaxe',
      Knife: 'Knife',
      Axe: 'Axe',
      Spell_Thunderbolt: 'Thunderbolt',
    }[value] ?? 'weapon-type-unknown-$value';

  static const values = [
    Unarmed,
    Sword,
    Bow,
    Grenade,
    Crossbow,
    Staff,
    Musket,
    Revolver,
    Hammer,
    Pickaxe,
    Knife,
    Axe,
    Staff,
    Spell_Thunderbolt,
  ];
}
