
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:gamestream_flutter/packages/common.dart';
import 'package:lemon_watch/src.dart';
import 'package:gamestream_flutter/packages/utils/parse.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_component.dart';
import 'package:gamestream_flutter/gamestream/sprites/character_sprite_group.dart';
import 'package:gamestream_flutter/gamestream/sprites/kid_character_sprites.dart';
import 'package:lemon_sprite/lib.dart';
import 'package:lemon_widgets/lemon_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'enums/render_direction.dart';
import 'types/sprite_group_type.dart';



class IsometricImages with IsometricComponent {

  var imagesCached = false;
  
  final byteDataEmpty = ByteData(0);
  late final CharacterSpriteGroup kidCharacterSpriteGroupShadow;
  final kidCharacterSpritesIsometricNorth = KidCharacterSprites();
  final kidCharacterSpritesIsometricEast = KidCharacterSprites();
  final kidCharacterSpritesIsometricSouth = KidCharacterSprites();
  final kidCharacterSpritesIsometricWest = KidCharacterSprites();

  late final kidCharacterSpritesIsometric = {
    RenderDirection.north: kidCharacterSpritesIsometricNorth,
    RenderDirection.east: kidCharacterSpritesIsometricEast,
    RenderDirection.south: kidCharacterSpritesIsometricSouth,
    RenderDirection.west: kidCharacterSpritesIsometricWest,
  };

  final kidCharacterSpritesFrontSouth = KidCharacterSprites();
  final kidCharacterSpritesFrontWest = KidCharacterSprites();

  late final kidCharacterSpritesFrontDirections = [kidCharacterSpritesFrontSouth, kidCharacterSpritesFrontWest];

  final totalImages = Watch(0);
  final totalImagesLoaded = Watch(0);
  final values = <Image>[];
  final _completerImages = Completer();

  late final CharacterSpriteGroup spriteGroupFallenWest;
  late final CharacterSpriteGroup spriteGroupFallenSouth;
  late final CharacterSpriteGroup spriteGroupFallenShadow;

  late final CharacterSpriteGroup spriteGroupSkeletonWest;
  late final CharacterSpriteGroup spriteGroupSkeletonSouth;
  late final CharacterSpriteGroup spriteGroupSkeletonShadow;

  late final Sprite rock1;
  late final Sprite crystal;
  late final Sprite tree1;
  late final Sprite flame0;
  late final Sprite flame1;
  late final Sprite flame2;
  late final Sprite butterfly;
  late final Sprite moth;
  late final Sprite bat;
  late final Sprite crystalSouth;
  late final Sprite crystalWest;

  late final CharacterSpriteGroup spriteGroupEmpty;

  late final Sprite spriteEmpty;
  late final dstEmpty = Uint16List(0);

  late final Image empty;
  late final Image sphereTop;
  late final Image sphereNorth;
  late final Image sphereEast;
  late final Image sphereSouth;
  late final Image sphereWest;
  late final Image shades;
  late final Image shadesTransparent;
  late final Image pixel;
  late final Image atlas_projectiles;
  late final Image zombie;
  late final Image zombie_shadow;
  late final Image character_dog;
  late final Image atlas_particles;
  late final Image atlas_helms;
  late final Image atlas_hands;
  late final Image atlas_body;
  late final Image atlas_legs;
  late final Image atlas_shoes;
  late final Image atlas_gameobjects;
  late final Image atlas_nodes;
  late final Image atlas_characters;
  late final Image atlas_icons;
  late final Image atlas_consumables;
  late final Image atlas_treasures;
  late final Image atlas_nodes_mini;
  late final Image atlas_weapons;
  late final Image atlas_spells;
  late final Image atlas_talents;
  late final Image sprite_stars;
  late final Image sprite_shield;
  late final Image square;
  late final Image template_spinning;

  late final Sprite emptySprite;

  late final Map<int, Image> itemTypeAtlases;

  @override
  Future onComponentInit(SharedPreferences sharedPreferences) async {
    print('isometric.images.onComponentInitialize()');



    empty = await loadPng('empty');
    loadPng('shades').then((value) => shades = value);
    loadPng('shades_transparent').then((value) => shadesTransparent = value);
    loadPng('sphere/top').then((value) => sphereTop = value);
    loadPng('sphere/north').then((value) => sphereNorth = value);
    loadPng('sphere/east').then((value) => sphereEast = value);
    loadPng('sphere/south').then((value) => sphereSouth = value);
    loadPng('sphere/west').then((value) => sphereWest = value);
    loadPng('square').then((value) => square = value);
    loadPng('atlas_nodes').then((value) => atlas_nodes = value);
    loadPng('atlas_characters').then((value) => atlas_characters = value);
    loadPng('atlas_zombie').then((value) => zombie = value);
    loadPng('atlas_zombie_shadow').then((value) => zombie_shadow = value);
    loadPng('atlas_gameobjects').then((value) => atlas_gameobjects = value);
    loadPng('atlas_particles').then((value) => atlas_particles = value);
    loadPng('atlas_projectiles').then((value) => atlas_projectiles = value);
    loadPng('atlas_nodes_mini').then((value) => atlas_nodes_mini = value);
    loadPng('atlas_weapons').then((value) => atlas_weapons = value);
    loadPng('atlas_talents').then((value) => atlas_talents = value);
    loadPng('atlas_icons').then((value) => atlas_icons = value);
    loadPng('atlas_consumables').then((value) => atlas_consumables = value);
    loadPng('atlas_treasures').then((value) => atlas_treasures = value);
    loadPng('atlas_spells').then((value) => atlas_spells = value);
    loadPng('atlas_helms').then((value) => atlas_helms = value);
    loadPng('atlas_hands').then((value) => atlas_hands = value);
    loadPng('atlas_body').then((value) => atlas_body = value);
    loadPng('atlas_legs').then((value) => atlas_legs = value);
    loadPng('atlas_shoes').then((value) => atlas_shoes = value);
    loadPng('character-dog').then((value) => character_dog = value);
    loadPng('sprites/sprite-stars').then((value) => sprite_stars = value);
    loadPng('sprites/sprite-shield').then((value) => sprite_shield = value);

    emptySprite = Sprite(
        image: empty,
        src: Float32List(0),
        dst: Float32List(0),
        rows: 0,
        columns: 0,
        mode: 0,
        srcWidth: 0,
        srcHeight: 0,
    );

    totalImagesLoaded.onChanged((totalImagesLoaded) {
      if (totalImagesLoaded < totalImages.value)
        return;

      _completerImages.complete(true);
    });

    spriteEmpty = Sprite(
        image: empty,
        src: Float32List(0),
        dst: Float32List(0),
        srcWidth: 0,
        srcHeight: 0,
        rows: 0,
        columns: 0,
        mode: AnimationMode.single,
    );

    spriteGroupEmpty = CharacterSpriteGroup(
        idle: emptySprite,
        running: emptySprite,
        change: emptySprite,
        dead: emptySprite,
        fire: emptySprite,
        strike1: emptySprite,
        strike2: emptySprite,
        hurt: emptySprite,
        casting: emptySprite,
    );

    kidCharacterSpriteGroupShadow = CharacterSpriteGroup(
      idle: await loadSprite(name: 'sprites/isometric/kid/shadow/idle', mode: AnimationMode.bounce),
      running: await loadSprite(name: 'sprites/isometric/kid/shadow/running', mode: AnimationMode.loop),
      change: await loadSprite(name: 'sprites/isometric/kid/shadow/change', mode: AnimationMode.bounce),
      dead: await loadSprite(name: 'sprites/isometric/kid/shadow/dead', mode: AnimationMode.single),
      fire: await loadSprite(name: 'sprites/isometric/kid/shadow/fire', mode: AnimationMode.single),
      strike1: await loadSprite(name: 'sprites/isometric/kid/shadow/strike', mode: AnimationMode.single),
      strike2: await loadSprite(name: 'sprites/isometric/kid/shadow/strike_2', mode: AnimationMode.single),
      hurt: emptySprite,
      casting: await loadSprite(name: 'sprites/isometric/kid/shadow/casting', mode: AnimationMode.single),
    );

    for (final kidCharacterSpritesIsometric in kidCharacterSpritesIsometric.values){
      kidCharacterSpritesIsometric.handLeft[0] = spriteGroupEmpty;
      kidCharacterSpritesIsometric.handRight[0] = spriteGroupEmpty;
      kidCharacterSpritesIsometric.weapons[0] = spriteGroupEmpty;
      kidCharacterSpritesIsometric.helm[0] = spriteGroupEmpty;
      kidCharacterSpritesIsometric.bodyMale[0] = spriteGroupEmpty;
      kidCharacterSpritesIsometric.bodyFemale[0] = spriteGroupEmpty;
      kidCharacterSpritesIsometric.bodyArms[0] = spriteGroupEmpty;
      kidCharacterSpritesIsometric.legs[0] = spriteGroupEmpty;
      kidCharacterSpritesIsometric.hairFront[0] = spriteGroupEmpty;
      kidCharacterSpritesIsometric.hairBack[0] = spriteGroupEmpty;
      kidCharacterSpritesIsometric.hairTop[0] = spriteGroupEmpty;
      kidCharacterSpritesIsometric.shoesLeft[0] = spriteGroupEmpty;
      kidCharacterSpritesIsometric.shoesRight[0] = spriteGroupEmpty;
    }

    for (final renderDirection in const [RenderDirection.south, RenderDirection.west]){
      loadSpriteGroupFront(type: SpriteGroupType.Arms_Left, subType: ArmType.regular, renderDirection: renderDirection);
      loadSpriteGroupFront(type: SpriteGroupType.Arms_Right, subType: ArmType.regular, renderDirection: renderDirection);
      loadSpriteGroupFront(type: SpriteGroupType.Body_Male, subType: BodyType.Shirt_Blue, renderDirection: renderDirection);
      loadSpriteGroupFront(type: SpriteGroupType.Body_Male, subType: BodyType.Leather_Armour, renderDirection: renderDirection);
      loadSpriteGroupFront(type: SpriteGroupType.Body_Female, subType: BodyType.Leather_Armour, renderDirection: renderDirection);
      loadSpriteGroupFront(type: SpriteGroupType.Body_Arms, subType: BodyType.Shirt_Blue, renderDirection: renderDirection);
      loadSpriteGroupFront(type: SpriteGroupType.Hands_Left, subType: HandType.Gauntlets, renderDirection: renderDirection);
      loadSpriteGroupFront(type: SpriteGroupType.Hands_Right, subType: HandType.Gauntlets, renderDirection: renderDirection);
      loadSpriteGroupFront(type: SpriteGroupType.Heads, subType: HeadType.boy, renderDirection: renderDirection);
      loadSpriteGroupFront(type: SpriteGroupType.Heads, subType: HeadType.girl, renderDirection: renderDirection);
      loadSpriteGroupFront(type: SpriteGroupType.Helms, subType: HelmType.Steel, renderDirection: renderDirection);
      loadSpriteGroupFront(type: SpriteGroupType.Helms, subType: HelmType.Wizard_Hat, renderDirection: renderDirection);
      loadSpriteGroupFront(type: SpriteGroupType.Legs, subType: LegType.Leather, renderDirection: renderDirection);
      loadSpriteGroupFront(type: SpriteGroupType.Torso_Top, subType: Gender.male, renderDirection: renderDirection);
      loadSpriteGroupFront(type: SpriteGroupType.Torso_Top, subType: Gender.female, renderDirection: renderDirection);
      loadSpriteGroupFront(type: SpriteGroupType.Torso_Bottom, subType: Gender.male, renderDirection: renderDirection);
      loadSpriteGroupFront(type: SpriteGroupType.Torso_Bottom, subType: Gender.female, renderDirection: renderDirection);
      loadSpriteGroupFront(type: SpriteGroupType.Weapons, subType: WeaponType.Bow, renderDirection: renderDirection);
      loadSpriteGroupFront(type: SpriteGroupType.Weapons, subType: WeaponType.Staff, renderDirection: renderDirection);
      loadSpriteGroupFront(type: SpriteGroupType.Weapons, subType: WeaponType.Sword, renderDirection: renderDirection);
      loadSpriteGroupFront(type: SpriteGroupType.Shoes_Left, subType: ShoeType.Leather_Boots, renderDirection: renderDirection);
      loadSpriteGroupFront(type: SpriteGroupType.Shoes_Right, subType: ShoeType.Leather_Boots, renderDirection: renderDirection);
      loadSpriteGroupFront(type: SpriteGroupType.Shoes_Left, subType: ShoeType.Iron_Plates, renderDirection: renderDirection);
      loadSpriteGroupFront(type: SpriteGroupType.Shoes_Right, subType: ShoeType.Iron_Plates, renderDirection: renderDirection);
    }


    for (final direction in const[RenderDirection.south, RenderDirection.west]){
      loadSpriteGroupIsometric(
          direction: direction,
          type: SpriteGroupType.Arms_Left,
          subType: ArmType.regular,
          skipHurt: true,
      );
      loadSpriteGroupIsometric(
          direction: direction,
          type: SpriteGroupType.Arms_Right,
          subType: ArmType.regular,
          skipHurt: true,
      );
      loadSpriteGroupIsometric(
          direction: direction,
          type: SpriteGroupType.Body_Male,
          subType: BodyType.Shirt_Blue,
          skipHurt: true,
      );
      loadSpriteGroupIsometric(
          direction: direction,
          type: SpriteGroupType.Body_Male,
          subType: BodyType.Leather_Armour,
          skipHurt: true,
      );
      loadSpriteGroupIsometric(
          direction: direction,
          type: SpriteGroupType.Body_Female,
          subType: BodyType.Leather_Armour,
          skipHurt: true,
      );
      loadSpriteGroupIsometric(
          direction: direction,
          type: SpriteGroupType.Body_Arms,
          subType: BodyType.Shirt_Blue,
          skipHurt: true,
      );
      // loadSpriteGroupIsometric(
      //   direction: direction,
      //   type: SpriteGroupType.Body_Arms,
      //   subType: BodyType.Leather_Armour,
      //   skipHurt: true,
      //   skipFire: true,
      //   skipStrike: true,
      //   skipChange: true,
      //   skipDead: true,
      //   skipIdle: true,
      //   skipRunning: true,
      // );
      loadSpriteGroupIsometric(
        direction: direction,
        type: SpriteGroupType.Hands_Left,
        subType: HandType.Gauntlets,
        skipHurt: true,
      );
      loadSpriteGroupIsometric(
        direction: direction,
        type: SpriteGroupType.Hands_Right,
        subType: HandType.Gauntlets,
        skipHurt: true,
      );
      loadSpriteGroupIsometric(
        direction: direction,
        type: SpriteGroupType.Heads,
        subType: HeadType.boy,
        skipHurt: true,
      );
      loadSpriteGroupIsometric(
        direction: direction,
        type: SpriteGroupType.Heads,
        subType: HeadType.girl,
        skipHurt: true,
      );
      loadSpriteGroupIsometric(
        direction: direction,
        type: SpriteGroupType.Helms,
        subType: HelmType.Steel,
        skipHurt: true,
      );
      loadSpriteGroupIsometric(
        direction: direction,
        type: SpriteGroupType.Helms,
        subType: HelmType.Wizard_Hat,
        skipHurt: true,
      );
      loadSpriteGroupIsometric(
        direction: direction,
        type: SpriteGroupType.Legs,
        subType: LegType.Leather,
        skipHurt: true,
      );
      loadSpriteGroupIsometric(
        direction: direction,
        type: SpriteGroupType.Torso_Top,
        subType: Gender.male,
        skipHurt: true,
      );
      loadSpriteGroupIsometric(
        direction: direction,
        type: SpriteGroupType.Torso_Top,
        subType: Gender.female,
        skipHurt: true,
      );
      loadSpriteGroupIsometric(
        direction: direction,
        type: SpriteGroupType.Torso_Bottom,
        subType: Gender.male,
        skipHurt: true,
      );
      loadSpriteGroupIsometric(
        direction: direction,
        type: SpriteGroupType.Torso_Bottom,
        subType: Gender.female,
        skipHurt: true,
      );
      loadSpriteGroupIsometric(
        direction: direction,
        type: SpriteGroupType.Weapons,
        subType: WeaponType.Bow,
        skipHurt: true,
        skipStrike: true,
      );
      loadSpriteGroupIsometric(
        direction: direction,
        type: SpriteGroupType.Weapons,
        subType: WeaponType.Staff,
        skipHurt: true,
        skipFire: true,
      );
      loadSpriteGroupIsometric(
        direction: direction,
        type: SpriteGroupType.Weapons,
        subType: WeaponType.Sword,
        skipHurt: true,
        skipFire: true,
      );
      loadSpriteGroupIsometric(
        direction: direction,
        type: SpriteGroupType.Shoes_Left,
        subType: ShoeType.Leather_Boots,
        skipHurt: true,
      );
      loadSpriteGroupIsometric(
        direction: direction,
        type: SpriteGroupType.Shoes_Right,
        subType: ShoeType.Leather_Boots,
        skipHurt: true,
      );
      loadSpriteGroupIsometric(
        direction: direction,
        type: SpriteGroupType.Shoes_Left,
        subType: ShoeType.Iron_Plates,
        skipHurt: true,
      );
      loadSpriteGroupIsometric(
        direction: direction,
        type: SpriteGroupType.Shoes_Right,
        subType: ShoeType.Iron_Plates,
        skipHurt: true,
      );

      HairType.valuesNotNone.forEach((hairType) {

        loadSpriteGroupFront(
            type: SpriteGroupType.Hair_Front,
            subType: hairType,
            renderDirection: direction
        );
        loadSpriteGroupFront(
            type: SpriteGroupType.Hair_Back,
            subType: hairType,
            renderDirection: direction
        );
        loadSpriteGroupFront(
            type: SpriteGroupType.Hair_Top,
            subType: hairType,
            renderDirection: direction
        );
        loadSpriteGroupIsometric(
          direction: direction,
          type: SpriteGroupType.Hair_Front,
          subType: hairType,
          skipHurt: true,
        );
        loadSpriteGroupIsometric(
          direction: direction,
          type: SpriteGroupType.Hair_Back,
          subType: hairType,
          skipHurt: true,
        );
        loadSpriteGroupIsometric(
          direction: direction,
          type: SpriteGroupType.Hair_Top,
          subType: hairType,
          skipHurt: true,
        );
      });
    }

    await _completerImages.future;

    loadSprite(
        name: 'sprites/isometric/butterfly/butterfly',
        mode: AnimationMode.loop,
    ).then((value) => butterfly = value);

    loadSprite(
        name: 'sprites/isometric/moth/moth',
        mode: AnimationMode.loop,
    ).then((value) => moth = value);

    loadSprite(
        name: 'sprites/isometric/crystal',
        mode: AnimationMode.single,
    ).then((value) => crystal = value);

    loadSprite(
        name: 'sprites/isometric/gameobjects/rock1',
        mode: AnimationMode.single,
    ).then((value) => rock1 = value);

    loadSprite(
        name: 'sprites/isometric/gameobjects/tree1',
        mode: AnimationMode.single,
    ).then((value) => tree1 = value);

    loadSprite(
        name: 'sprites/isometric/bat/bat',
        mode: AnimationMode.bounce,
    ).then((value) => bat = value);

    loadSprite(
        name: 'sprites/isometric/crystal/south',
        mode: AnimationMode.loop,
    ).then((value) => crystalSouth = value);

    loadSprite(
        name: 'sprites/isometric/crystal/west',
        mode: AnimationMode.loop,
    ).then((value) => crystalWest = value);

    itemTypeAtlases = {
      ItemType.Weapon: atlas_weapons,
      ItemType.Object: atlas_gameobjects,
      ItemType.Helm: atlas_helms,
      ItemType.Body: atlas_body,
      ItemType.Legs: atlas_legs,
      ItemType.Shoes: atlas_shoes,
      ItemType.Consumable: atlas_consumables,
      ItemType.Hand: atlas_hands,
      ItemType.Treasure: atlas_treasures,
      ItemType.Spell: atlas_spells,
    };

    final spriteFallenWestStrike = await loadSprite(name: 'sprites/isometric/fallen/strike/west', mode: AnimationMode.single);

    spriteGroupFallenWest = CharacterSpriteGroup(
      idle: await loadSprite(name: 'sprites/isometric/fallen/idle/west', mode: AnimationMode.bounce),
      running: await loadSprite(name: 'sprites/isometric/fallen/running/west', mode: AnimationMode.loop),
      dead: await loadSprite(name: 'sprites/isometric/fallen/dead/west', mode: AnimationMode.single),
      strike1: spriteFallenWestStrike,
      strike2: spriteFallenWestStrike,
      hurt: await loadSprite(name: 'sprites/isometric/fallen/hurt/west', mode: AnimationMode.single),
      fire: emptySprite,
      change: emptySprite,
      casting: emptySprite,
    );

    final spriteFallenSouthStrike = await loadSprite(name: 'sprites/isometric/fallen/strike/south', mode: AnimationMode.single);

    spriteGroupFallenSouth = CharacterSpriteGroup(
      idle: await loadSprite(name: 'sprites/isometric/fallen/idle/south', mode: AnimationMode.bounce),
      running: await loadSprite(name: 'sprites/isometric/fallen/running/south', mode: AnimationMode.loop),
      dead: await loadSprite(name: 'sprites/isometric/fallen/dead/south', mode: AnimationMode.single),
      strike1: spriteFallenSouthStrike,
      strike2: spriteFallenSouthStrike,
      hurt: await loadSprite(name: 'sprites/isometric/fallen/hurt/south', mode: AnimationMode.single),
      fire: emptySprite,
      change: emptySprite,
      casting: emptySprite,
    );

    final spriteFallenShadowStrike = await loadSprite(name: 'sprites/isometric/fallen/strike/shadow', mode: AnimationMode.single);

    spriteGroupFallenShadow = CharacterSpriteGroup(
      idle: await loadSprite(name: 'sprites/isometric/fallen/idle/shadow', mode: AnimationMode.bounce),
      running: await loadSprite(name: 'sprites/isometric/fallen/running/shadow', mode: AnimationMode.loop),
      dead: await loadSprite(name: 'sprites/isometric/fallen/dead/shadow', mode: AnimationMode.single),
      strike1: spriteFallenShadowStrike,
      strike2: spriteFallenShadowStrike,
      hurt: await loadSprite(name: 'sprites/isometric/fallen/hurt/shadow', mode: AnimationMode.single),
      fire: emptySprite,
      change: emptySprite,
      casting: emptySprite,
    );

    spriteGroupSkeletonWest = CharacterSpriteGroup(
      idle: await loadSprite(name: 'sprites/isometric/skeleton/west/idle', mode: AnimationMode.bounce),
      running: await loadSprite(name: 'sprites/isometric/skeleton/west/walk', mode: AnimationMode.loop),
      dead: await loadSprite(name: 'sprites/isometric/skeleton/west/dead', mode: AnimationMode.single),
      strike1: emptySprite,
      strike2: emptySprite,
      hurt: await loadSprite(name: 'sprites/isometric/skeleton/west/hurt', mode: AnimationMode.single),
      fire: await loadSprite(name: 'sprites/isometric/skeleton/west/fire', mode: AnimationMode.single),
      change: emptySprite,
      casting: emptySprite,
    );

    spriteGroupSkeletonSouth = CharacterSpriteGroup(
      idle: await loadSprite(name: 'sprites/isometric/skeleton/south/idle', mode: AnimationMode.bounce),
      running: await loadSprite(name: 'sprites/isometric/skeleton/south/walk', mode: AnimationMode.loop),
      dead: await loadSprite(name: 'sprites/isometric/skeleton/south/dead', mode: AnimationMode.single),
      strike1: emptySprite,
      strike2: emptySprite,
      hurt: await loadSprite(name: 'sprites/isometric/skeleton/south/hurt', mode: AnimationMode.single),
      fire: await loadSprite(name: 'sprites/isometric/skeleton/south/fire', mode: AnimationMode.single),
      change: emptySprite,
      casting: emptySprite,
    );

    spriteGroupSkeletonShadow = CharacterSpriteGroup(
      idle: await loadSprite(name: 'sprites/isometric/skeleton/shadow/idle', mode: AnimationMode.bounce),
      running: await loadSprite(name: 'sprites/isometric/skeleton/shadow/walk', mode: AnimationMode.loop),
      dead: await loadSprite(name: 'sprites/isometric/skeleton/shadow/dead', mode: AnimationMode.single),
      strike1: emptySprite,
      strike2: emptySprite,
      hurt: await loadSprite(name: 'sprites/isometric/skeleton/shadow/hurt', mode: AnimationMode.single),
      fire: await loadSprite(name: 'sprites/isometric/skeleton/shadow/fire', mode: AnimationMode.single),
      change: emptySprite,
      casting: emptySprite,
    );

    flame0 = await loadSprite(
        name: 'sprites/isometric/flame/wind0',
        mode: AnimationMode.loop,
        atlasX: 664,
        atlasY: 1681,
        image: atlas_nodes,
    );
    flame1 = await loadSprite(
        name: 'sprites/isometric/flame/wind1',
        mode: AnimationMode.loop,
        atlasX: 664,
        atlasY: 1733,
        image: atlas_nodes,
    );
    flame2 = await loadSprite(
        name: 'sprites/isometric/flame/wind2',
        mode: AnimationMode.loop,
        atlasX: 664,
        atlasY: 1778,
        image: atlas_nodes,
    );
  }

  void loadSpriteGroupIsometric({
    required int type,
    required int subType,
    required RenderDirection direction,
    bool skipIdle = false,
    bool skipRunning = false,
    bool skipChange = false,
    bool skipDead = false,
    bool skipFire = false,
    bool skipStrike = false,
    bool skipHurt = false,
    bool skipCasting = false,
  }) async {
    final typeName = SpriteGroupType.getName(type).toLowerCase();
    final subTypeName = SpriteGroupType.getSubTypeName(type, subType).toLowerCase().replaceAll(' ', '_');

    final kidCharacterSprites = kidCharacterSpritesIsometric[direction];

    if (kidCharacterSprites == null){
      throw Exception('loadSpriteGroupIsometric() - kidCharacterSprites == null: $direction');
    }

    final kidCharacterSpriteGroup = kidCharacterSprites.values[type] ?? (throw Exception('images.loadSpriteGroup2($typeName, $subTypeName)'));
    final directory = 'sprites/isometric/kid/${direction.name}/$typeName/$subTypeName';

    if (
      const[RenderDirection.north, RenderDirection.east].contains(direction) &&
      !const[SpriteGroupType.Heads, SpriteGroupType.Body_Male].contains(type)
    ) {
        return;
    }

    kidCharacterSpriteGroup[subType] = CharacterSpriteGroup(
        idle: skipIdle ? emptySprite : await loadSprite(name: '$directory/idle', mode: AnimationMode.bounce),
        running: skipRunning ? emptySprite : await loadSprite(name: '$directory/running', mode: AnimationMode.loop),
        change: skipChange ? emptySprite : await loadSprite(name: '$directory/change', mode: AnimationMode.bounce),
        dead: skipDead ? emptySprite : await loadSprite(name: '$directory/dead', mode: AnimationMode.single),
        fire: skipFire ? emptySprite : await loadSprite(name: '$directory/fire', mode: AnimationMode.single),
        strike1: skipStrike ? emptySprite : await loadSprite(name: '$directory/strike', mode: AnimationMode.single),
        strike2: skipStrike ? emptySprite : await loadSprite(name: '$directory/strike_2', mode: AnimationMode.single),
        hurt: skipHurt ? emptySprite : await loadSprite(name: '$directory/hurt', mode: AnimationMode.single),
        casting: skipCasting ? emptySprite : await loadSprite(name: '$directory/casting', mode: AnimationMode.single),
    );
  }

  void loadSpriteGroupFront({
    required int type,
    required int subType,
    required RenderDirection renderDirection,
  }) async {
    final typeName = SpriteGroupType.getName(type).toLowerCase();
    final subTypeName = SpriteGroupType.getSubTypeName(type, subType).toLowerCase().replaceAll(' ', '_');
    final sprites = renderDirection == RenderDirection.south ? kidCharacterSpritesFrontSouth : kidCharacterSpritesFrontWest;
    final kidCharacterSpriteGroup = sprites.values[type] ?? (throw Exception('images.loadSpriteGroupFront($typeName, $subTypeName)'));
    final directory = 'sprites/front/kid/${renderDirection.name}/$typeName/$subTypeName';

    kidCharacterSpriteGroup[subType] = CharacterSpriteGroup(
      idle: await loadSprite(name: '$directory/idle', mode: AnimationMode.bounce),
      running: emptySprite,
      change: emptySprite,
      dead: emptySprite,
      fire: emptySprite,
      strike1: emptySprite,
      strike2: emptySprite,
      hurt: emptySprite,
      casting: emptySprite,
    );
  }

  parseListDouble(List<dynamic> values) =>
      (values.cast<num>()).map((e) => e.toDouble()).toList(growable: false);

  List<double> readDoubles(dynamic values)=> parseListDouble(values as List);

  Float32List readFloat32List(dynamic values) => Float32List.fromList(readDoubles(values));

  Future<Sprite> loadSprite({
    required String name,
    required int mode,
    Image? image,
    int atlasX = 0,
    int atlasY = 0,
  }) async {

    try {
      image = image ?? await loadImageAsset('$name.png');
      final json = await loadAssetJson('$name.json');

      final dst = parse<Float32List>(json['dst']);
      final length = dst.length;

      for (var i = 0; i < length; i += 4){
        dst[i + 0] += atlasX;
        dst[i + 1] += atlasY;
        dst[i + 2] += atlasX;
        dst[i + 3] += atlasY;
      }

      return Sprite(
        image: image,
        src: parse(json['src']),
        dst: dst,
        rows: parse(json['rows']),
        columns: parse(json['columns']),
        srcWidth: parse(json['width']),
        srcHeight: parse(json['height']),
        mode: mode,
      );
    } catch(e) {
      // print(e);
      return emptySprite;
    }
  }

   Future<Image> loadPng(String fileName) async => loadImage('$fileName.png');

   Future<Image> loadImage(String fileName) async {
     totalImages.value++;

     final image = await loadImageAsset('images/$fileName');
     values.add(image);
     totalImagesLoaded.value++;
     return image;
   }

  void cacheImages() {

    if (imagesCached)
      return;

    print('images.cacheImages()');
    imagesCached = true;
    for (final image in images.values) {
      engine.renderSprite(
        image: image,
        srcX: 0,
        srcY: 0,
        srcWidth: 1,
        srcHeight: 1,
        dstX: 0,
        dstY: 0,
      );
    }
  }
}



