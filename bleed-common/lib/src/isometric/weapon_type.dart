class WeaponType {
  static const Unarmed = 0;
  static const Handgun = 1;
  static const Smg = 2;
  static const Machine_Gun = 3;
  static const Sniper_Rifle = 4;
  static const Shotgun = 5;
  static const Sword = 6;
  static const Bow = 7;
  static const Plasma_Pistol = 8;
  static const Crowbar = 9;
  static const Grenade = 10;
  static const Flame_Thrower = 11;
  static const Bazooka = 12;
  static const Minigun = 13;
  static const Crossbow = 14;
  static const Staff = 15;
  static const Musket = 16;
  static const Revolver = 17;
  static const Pistol = 19;
  static const Plasma_Rifle = 20;
  static const Hammer = 21;
  static const Pickaxe = 22;
  static const Knife = 23;
  static const Axe = 24;
  static const Rifle = 26;

  static const Firearms = [
    Handgun,
    Smg,
    Machine_Gun,
    Sniper_Rifle,
    Shotgun,
    Plasma_Pistol,
    Minigun,
    Musket,
    Rifle,
  ];

  static const Firearms_Automatic = [
    Smg,
    Machine_Gun,
    Minigun,
  ];

  static const Melee = [
    Unarmed,
    Sword,
    Crowbar,
    Hammer,
    Staff,
  ];

  static bool isMelee(int value) => Melee.contains(value);

  static bool isFirearm(int value) => Firearms.contains(value);

  static bool isThrowable(int value) => const [Grenade].contains(value);

  static bool isFirearmAutomatic(int value) => Firearms_Automatic.contains(value);

  static String getName(int value) {
    return const {
      Unarmed: 'unarmed',
      Handgun: 'handgun',
      Smg: 'SMG',
      Machine_Gun: 'Machine Gun',
      Sniper_Rifle: 'Sniper Rifle',
      Shotgun: 'Shotgun',
      Sword: 'Sword',
      Bow: 'Bow',
      Plasma_Pistol: 'Plasma Pistol',
      Crowbar: 'Crowbar',
      Grenade: 'Grenade',
      Flame_Thrower: 'Flame Thrower',
      Bazooka: 'Bazooka',
      Minigun: 'Minigun',
      Crossbow: 'Crossbow',
      Staff: 'staff',
      Musket: 'Musket',
      Revolver: 'Revolver',
      Pistol: 'Pistol',
      Plasma_Rifle: 'Plasma Rifle',
      Hammer: 'Hammer',
      Pickaxe: 'Pickaxe',
      Knife: 'Knife',
      Axe: 'Axe',
      Rifle: 'Rifle',
    }[value] ?? 'weapon-type-unknown-$value';
  }

  static const values = [
    Unarmed,
    Handgun,
    Smg,
    Machine_Gun,
    Sniper_Rifle,
    Shotgun,
    Sword,
    Bow,
    Plasma_Pistol,
    Crowbar,
    Grenade,
    Flame_Thrower,
    Bazooka,
    Minigun,
    Crossbow,
    Staff,
    Musket,
    Revolver,
    Pistol,
    Plasma_Rifle,
    Hammer,
    Pickaxe,
    Knife,
    Axe,
    Rifle,
    Staff,
  ];
}
