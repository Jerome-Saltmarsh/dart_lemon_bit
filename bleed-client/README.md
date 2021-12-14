-- FEATURES -- 
[ ] Critical Damage
[ ] Accuracy
[ ] Weapon Smg
[ ] Weapon: Bazooka
[ ] Weapon: Mini gun
[ ] Game Type: Capture The Squares
[ ] Game Type: Sandbox
[ ] Throw Animation
[ ] Line of Sight
[ ] Particle Gunshot smoke
[ ] Faster to walk on concrete than grass, mud is very slow.
[ ] Zombie Hurt Animation
[ ] Grenade tile collision
[ ] Stamina Potion
[ ] Rag doll death
[ ] Cursor Cooldown Circle
[ ] Explosion Crater
[ ] Random Power up Square 
    [ ] Double Damage
    [ ] Infinite Sprint
    [ ] Full Health
    [ ] Full Ammo
    [ ] Points 50
[ ] Fire Shotgun Animation
[ ] Fire Handgun Animation
[ ] Fire Assault Rifle Animation
[ ] Bullet holes in blocks
[ ] Item.RevivalKit (revive fallen squad member)
[ ] Ranged zombies
[ ] Bullet fired Flash
[ ] Player chat
[ ] Giant Zombie
[ ] Flying Bat Enemy
[ ] Improve Connection Failed Dialog
[ ] Activate Shield
[ ] Heal animation
[ ] Find Promotions for you weapons
[ ] Right click activates items special ability
    [ ] Shotgun double bullets
    [ ] Handgun double damage / Speed
    [ ] Sniper 
[ ] Body Armor
[ ] Connect to specific container instance
    [ ] Support auto reconnect
    [ ] Invite friend to container
[ ] Gain XP and levelsp
    [ ] Perk Stamina Boost
    [ ] Perk Health Boost
    [ ] Perk Damage Boost (cost 2 perks)
-- REFACTOR --
[ ] Merge Maths lib into common
[ ] Client Cache Particles-
-- BUSINESS --
[ ] Setup Patreon
[ ] Setup Discord
[ ] Publish on Reddit
[ ] Setup Youtube Channel
-- MINOR BUGS --
[ ] Dead players pass through barriers
[ ] Score ui displays error on respawn
[ ] Prevent Duplicate Names
[ ] UI Score Lag
-- UI --
-- IDEAS --
[ ] Animate tiles flowing water
[ ] Dynamic Shadow direction
[ ] Black Fade Screen on change scene
[ ] 4 sides light sources to light up rock
[ ] Trees apply shadow to tile
[ ] Anti lights, opposite of torches to apply darkness 
[ ] Elevate ground like aoe2
[ ] Getting kills charges your weapons super ability
[ ] Deploy auto turret
[ ] Standing on home base heals health && refills handgun ammo
[ ] Send custom news updates to client
[ ] Guards on walls
[ ] Fall into water and die
-- OPEN WORLD -- 
[ ] Convert Project to Null Safe
[ ] Persist Character on cloud
[ ] Complete Quests to earn income and unlock upgrades
[ ] Quest Window
[ ] Zombies run through environment objects
[ ] Deploy dev endpoint
[ ] Water Particles
[ ] House 3
[ ] Npc view range decreases at night
[ ] Audio walk on grass
[ ] Right click to pan
[ ] Glow worms
[ ] Zombie Ragdoll Physics
[ ] Flowing Bat
[ ] Weapon Baseball Bat
[ ] Design Tree Model
[ ] Remove player walk (its always better to run, no stamina)
[ ] Right Click to aim (aiming improves accuracy)
[ ] Fix Firing AssaultRifle animation
[ ] Speech Box split sentences 
[ ] Remove material design to reduce disk size
[ ] Add Name to Speech box
[ ] Shoot Arrow (Archer)
[ ] Slash Sword (Warrior)
[ ] Design Cottage
[ ] Zombies drop gems on death
[ ] Quest Kill the vampire
[ ] Splash Screen
[ ] Cave Level
[ ] Ability Tree
[RELEASE]
-- The plan is to release several game modes like the warcraft 3 custom maps
-- When the player loads into the game they start in the open world mode. To begin with this will be hard
-- core mode and won't be possible to persist characters. 
-- In the future the player will be able to store their character inside an sql database
-- Game Modes include MMO, Dota, Base defense, 
-- The name of the land is Atlas
[ ] Save / Load Character
[ ] Items
[ ] Enemy Archer
[ ] Enemy Mage
[ ] Enemy Tank
[ ] Attributes (Intelligence, Strength, Agility)
[ ] Cooldown widget
[ ] Remove old atlas sprites
[ ] Fix Bug render objects culled bottom
[ ] Player AI to walk towards out of range enemies and attack them
[ ] UI Indicate ability insufficient mana
[COMPLETED]
[x] UI Indicate selected ability
[x] Health bars
[x] Character - Swordsman
[x] Fix Bug - blue orb shoots off if target is killed
[x] Archer
[x] FIX BUG Sometimes left click does not register attack
[x] Orb attacks heat seek target
[x] FIX BUG Can control player while text box open
[x] Ability cool down
[x] Magic Regen
[x] Magic
[x] Witch Cast Spell Slow Circle
[x] Witch Caste Slowing Circle
[x] Object Cave Wall
[x] Fix chat
[x] Unlock firebolt
[x] Human Sword
[x] Tree Colors
[x] Fix Editor
[x] Sparkle Particles
[x] Smoke Particle
[x] Add myst to atlas
[x] Zombie Death
[x] Zombie Torso Particle
[x] Zombie Legs Particle
[x] Fix Zombies vanish on death bug
[x] Blood Particle
[x] Optimize Parser
[x] Shell Particle
[x] Zombie Idle
[x] Zombie Striking
[x] Zombie Walking
[x] Handgun Firing
[x] Human Shotgun Firing
[x] Human Shotgun Walking
-- FINISHED --
[x] Handgun Idle
[x] Handgun Walking
[x] Shotgun Idle
[x] Running
[x] Changing
[x] Fix Animated Torches
[x] Pack character into sprite sheets
[x] Fix Zombie.Blender so all animations are in one file
[x] Fix Human.Blender so all animations are in one file
[x] Fix firing shotgun bug
[x] Fix culling bug
[x] Downloading Screen
[x] Level Max Ambient Light
[x] Ability Caste Fireball (Wizard)
[x] Change scene
[x] Cave Level
[x] Tavern Level
[x] Camera Pans up
[x] Player disappears when firing
[?] Zombies aren't drawing
[x] FIX BUG Torches don't go out during daylight
[x] Spawn Myst at night    
[x] UI Display Clock    
[x] Fix Npc when wall is in the way
[x] Smooth Zooming
[x] Fix Npc aim direction incorrect
[x] UI Health Bar
[x] FIX can turn while shooting bug
[x] Fix AI target
[x] Bullets environment object collision
[x] Fix Map Fading Bug
[x] Publish Game Engine
[x] Man Dead Shades
[x] Zombie Strike Animation
[x] Animate Pistol Shoot
[x] Refactor server collision detection
[x] Zombie Walk Shadow
[x] Fix boundary error
[x] Fix Server nan error
[x] Fix chat bug
[x] FIX Npc aim
[x] NPC draw order
[x] Particle dynamic lighting
[x] Environment Object: Bush
[x] Shading Very Dark
[x] Day / Night
[x] Zombie dynamic lighting
[x] Zombies 3D render
[x] Zombies 3D model
[x] Human 3d Render
[x] Idle Handgun
[x] Walking Handgun
[x] Dead
[x] Striking
[x] Changing Weapon
[x] Firing Handgun
[x] Running
[x] Firing Shotgun
[x] Walking
[x] Idle
[x] Tree Stump
[x] Design Bridge
[x] Animated Torches
[x] Particles 3D Rendering
[x] Draw tiles using drawRawAtlas
[x] Torch
[x] Myst Particles
[x] Left click npc to interact
[x] FIX Zombies walk into walls
[x] FIX Player message box not showing up
[x] Chat
[x] Fix particle float on water
[x] Chimney Smoke Particles
[x] Fix guards stop shooting bug
[x] Walls 3d
[x] Edit mode select tile
[x] Environment object zordering
[x] Editor delete environment object
[x] Respawn on death
[x] Environment object collision
[x] Switch between Quest Mode and Battle Mode
[x] BUG Can't shoot over water
[x] Npc's attack zombies
[x] Npc player collision
[x] Zombies spawn on edge of map
[x] Interactable Npc Name Tag
[x] Walls Tiles
[x] Npc Talk Text
[x] Fix movement controls
[x] Disable spawn npcs request
[x] Auto refresh browser once per day
[x] Fix GCP Security
[x] Optimize ammo circle
[x] Draw health Ring same as ammo ring
[x] Disable squads
[x] Sniper bullet goes through multiple enemies
[x] Cursor indicates ammo remaining
[x] Collect item audio
[x] Crate broken animation
[x] Knife strike audio
[x] Grenades break crate
[x] Remove Reload
[x] Player health 100
[x] Finding weapons adds ammo
[x] Players are not getting disconnected
[x] Prevent Blood from bouncing
[x] Knife attack blood effect
[x] Break crate with knife
[x] Crate boundary physics
[x] Sprint down human sprite wrong
[x] Loot Box (Drops Item when destroyed)
[x] Bullets not being draw
[x] Collect Magnum
[x] Collect Shotgun
[x] Collect Sniper Rifle
[x] Rebuilding the ui unnecessarily is extremely expensive
[x] Improve Connection screen 
    [x] Add cancel button
    [x] Show animation
[x] Multiple pistol shot audios
[x] How do players acquire more grenades?
[x] How do players acquire more ammo?
[x] How do players acquire more health kits?
[x] UI not update clips on reload
[x] UI Score not showing
[x] Check client version
[x] Expand score on hover
[x] Separate credits and points
[x] Show high score, order by high score
[x] Select Server (Germany, USA-East, USA-West, Japan, Russia, Australia)
[x] Shared Preference: remember last server
[x] Killed zombies drop health pack etc,
[x] Color Palette
[x] Melee Attack
[x] Golden Zombie earns 10x kills
[x] Purchase Sniper Rifle
[x] Purchase Assault Rifle
[x] NPC Build up in the right corner
[x] Observe mode
[x] Pathfinding bug
[x] Exit Fullscreen Mode
[x] Weapon Square - purchase new weapons
[x] Prevent equip weapon which hasn't been acquired
[x] Compile Player Events in Update
[x] Show points earned floating text on zombie killed
[x] Player squirts blood when attacked by zombie
[x] Zombie Animations
[x] dynamically enable compile paths
[x] UI Flashes red on load
[x] Respawn ui lag
[x] Respawn button appears before death
[x] Score board
[x] Grenade kills earn points
[x] Highlight players score
[x] On respawn gain standard items
[x] grenade kills earn no points
[x] Bullets reappear
[x] Npcs stop wandering
[x] Show high score record
[x] Reload Assault Rifle is broken
[x] Score board
[x] Earn Points on zombie kill
[x] Grenades do not hurt players
[x] Player cache error
[x] BUG: Assault rifle ammo doesn't update ui
[s] Tutorial Text
[x] Player Name text
[x] Improve Assault Rifle Audio
[x] Disable friendly fire
[x] Player Names
[x] FIX BUG: On victory did not appear
[x] Auto Assign balanced Teams
[x] Zombies Auto Spawn
[x] Teams
[x] Control Spawn Point
[x] Victory / Lost
[x] Prevent Respawn in DeathMatch 
[x] Game Start Countdown
[x] Fix Join Fortress
[x] FIX Dialog can be opened multiple times
[x] Close dialog on game start
[x] Fix Join Death Match
[x] UI Show Stamina 
[x] Cursor goes red when aimed on zombie
[x] UI Handgun Clips Remaining
[x] Collect Item Audio
[x] Draw Random Item
[x] Collectable Type: Shotgun
[x] Collectable Type: Grenade
[x] Respawn Random Item
[x] Random Item Square
[x] Create / Find / Join Game 
[x] Show Shots remaining text at cursor
[x] Deployed client auto connect to gcp
[x] Lobby
[x] Fix parse bullet bugs
[x] Mute Audio Icon
[x] Fix UI Lag
[x] Fortress UI Show Game over
[x] Fortress UI Show Next Wave
[x] Fortress UI Show Current Wave
[x] Fortress UI Show lives remaining
[x] NPC surround player
[x] Fix Shot Looping Animation
[x] Fix Zombie Attack Bug
[x] Map Editor: Translate GameObjects
[x] Inventory Grenade
[x] Inventory Shotgun
[x] Throw Grenade Audio
[x] Use Medkit Audio
[x] Fix zoom in / out bug
[x] Draw Handgun Ammo
[x] Draw Health Pack
[x] FIX Throw Grenade Angle
[x] Remove Path Corners
[x] FIX NPC Attack Bug
[x] NPC Pathfinding
[x] Use Health Kit
[x] UI Show rounds remaining
[x] On Spawn - center camera
[x] Space bar pan camera
[x] Auto join sandbox on connect
[x] AudioPlayer Pool
[x] Zombie Spawn Points
[x] Editor Modify Tiles
[x] Editor Pan Camera
[x] FIX Game crashes on death
[x] FIX Zombies npcs keep attacking after player vanishes
[x] Player Spawn Points
[x] Ammo
[x] Health
[x] Resize Structures
[x] Fix Zoom out aim bug
[x] Fix Zoom out camera follow
[x] Zoom in / out
[x] Object Collision
[x] FIX BUG: Sniper Aim 
[x] Tile Boundaries
[x] Stamina
[x] FIX BUG: Player hurt audio makes zombie sound
[x] Optimize Server Collision Detection
[x] Audio Distance
[x] Animate Change Weapon 
[x] Explosion Shrapnel Particle
[x] Reload Animation  
[x] Bug: Npc bodies don't always dissappear
[x] Process Particles on client
[x] Make grenade 3d;
[x] Weapon: Machine Gun
[x] Particle Smoke
[x] Weapon: Sniper Rifle
[x] BUG: Bullet hole sometimes doesn't appear
[x] run to mouse key
[x] Throw Grenade
[x] Fix explosion doesn't render sometimes
[x] Particle height 
[x] Explosion
[x] Fix bug grenade remains after explosion
[x] Fix throws multiple grenades on press
[x] HUD
[x] Fix center camera on spawn
[x] Equip weapon audio
[x] Connection Failed Error dialog
[x] Sprint
[x] Player Death Audio
[x] Zombies eat dead players bodies
[x] Zombie Strike Audio
[x] Fix Zombie Strike animation
[x] Shot kickback
[x] Particle Bullet Hole
[x] Zombie ragdoll death
[x] Zombie target set audio (talk)
[x] Zombie Death Audio
[x] Zombie Hurt Audio
[x] Shotgun Audio
[x] spawn shell on fire bullet
[x] Shotgun bullet range
[x] Fix zombie spawn position
[x] Fix shot body position
[x] Blood Effect
[x] Weapon Shotgun
[x] Fix Sound
[x] Implement tiles on server
[x] Player respawn after death
[x] Players disappear after prolonged disconnect
[x] Animate fire weapon
[x] Player Auto aim when cursor near zombie
[x] Fix Npc Roaming
[x] Zombies disappear after death
[x] Show Health UI
[x] Zombie Attack
[x] Security (UUID)
[x] Auto Reconnect
[x] Handle Player Not Found
[x] Fix Bullet collision detection
[x] Fix Character draw center
[x] Fix bullet stutter
[x] Fix Shooting
[x] Client should not compress sending to server (too expensive)
[x] Remove JSON Object mapping
[x] Frame Smoothing (50ms before previous package)
[x] Shotgun
[x] Ping Check
[x] Shot cool-down
[x] Reduce Client Lag
[x] Aim Accuracy
[x] Draw Debug UI Toggle 
[x] NPC Wander
[x] Icon
[x] Zombie inertia
[x] Zombie Health
[x] Zombie Npc
[x] Bullet Max Range
[x] Aim (Right Click)
[x] Character Names
[x] Respawn player characters after death
[x] Destroy Dead Zombies after
[x] buy play-bleed.com
[x] Death on bullet
[x] Refactor Client
[x] Shoot Weapon
[x] Camera Follow
[x] Fix draw order
[x] Merge update and player commands
[x] Websocket client / server
[x] Deploy Server on GCP
[x] Isometric characters

# Symbolic Hard Link
mklink /J common C:\Users\Jerome\github\bleed\bleed-common\lib

// IDEAS
// Captured Flags increase passive income

#Goal
The goal is to build something that people enjoy playing. If I can get a user base that plays consistently
then that is success for me.


# Architecture 



Network -> Parse -> Game State -> Render

Input -> Network

Game Loop -> Network Update

receive compiled game state from the network, parse it into game state then render.

-- DESIGN -- 
[ ] Staff can upgrade in three ways
[ ] Chakra
[ ] Water (Support Healing)
[ ] Fire (Glass Cannon)
[ ] Electric (AOE)
[ ] Bow can be upgraded in three ways
[ ] Offensive
[ ] Split arrow
[ ] Other
[ ] Sword can be upgraded in three ways
[ ] Each upgrade requires specific minerals and a character level

Gunman Class
[ ] Handgun
[ ] Shotgun

Warlock Class
[ ] 

Samurai Class
[ ] Specializes in sword

Ninja Class
[ ] Katana,
[ ] throwing stars skills,
[ ] Dash
[ ] Explosives

// Each character has a standard attack
// Knights slash their swords
// Archers shoot arrows (longer range)
// Witches shoot an orb (shorter range)

// Hero's then have access to special abilities which can be unlocked as they gain levels