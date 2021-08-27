# TODO
[ ] Fix Block Collision Bug
[ ] Critical Damage
[ ] Accuracy
[ ] Weapon Oozie
[ ] Weapon: Bazooka
[ ] Game Type: Open World
[ ] Game Type: Capture The Flag
[ ] Game Type: Sandbox
[ ] Throw Animation
[ ] Player Name Text
[ ] Particle Gunshot smoke
[ ] Cache Particles
[ ] Zombie Hurt Animation
[ ] Npc Text
[ ] Grenade building collision
[ ] Collect Audio
[ ] Find / Join Game 
[ ] Stamina Potion
[ ] Refactor inventory painter
[ ] Create Game
[ ] Menu Screen Game
[ ] Fix Shot Looping Animation
[ ] Fix Npc Wander
[ ] FIX NPC pathfinding stops bug
[ ] NPC surround player
[ ] Ragdoll death
[ ] Fire Shotgun Animation
[ ] Lobby
[ ] Game Type: Death Match
[ ] Game Type: Fortress
[ ] Fix Zombie Attack Bug
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


# IDEA
- Run send commands on a separate thread to the receive commands

# Attributes
- sprint duration
- bag size
- reload speed
- accuracy
- luck (critical damage chance)
- merchant (item cost)
- health regen
- max health

# Open World
Diablo clone

# Death Match - Free for all
No teams, last man standing wins

# Death Match - Coop Survival
Two players per team, last team alive wins

# Death Match - Teams
Two teams

# Fortress Defense
Survive against waves of enemy zombies

# Fortress Battle
Two teams 

Death Match
When the player joins the game they have to wait until the current round is finished.
Once the all 32 players have joined the lobby the game begins. The player spawns in a random
location and must try their best to survive as long as possible

Open World
The player begins playing instantly and does not have to wait for the round to finish

