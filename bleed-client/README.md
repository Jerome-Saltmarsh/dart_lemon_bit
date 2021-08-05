# TODO
[ ] Persist World on firebase
[ ] Reload
[ ] Sniper Rifle
[ ] Keep aiming for duration after shot fired
[ ] Oozie
[ ] Shot Animation
[ ] Bullet Hit Animation
[ ] Publish dart-blade-game-engine
[ ] Create bleed-common library
[ ] Optimize Server Collision Detection
[ ] Design Town Center
[ ] HUD
[ ] Ammo
[ ] Particle Smoke
[ ] Adjustable FPS
[ ] Accuracy
[ ] Critical Damage
[ ] Fix center camera on spawn
[ ] Weapon: Machine Gun
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
Run send commands on a separate thread to the receive commands

# Attributes
- sprint duration
- bag size
- reload speed
- accuracy
- luck (critical damage chance)
- merchant (item cost)
- health regen
- max health

## IDEA
Only redraw game when an event arrives (this will save a lot of draw calls)
- The drawback is you cannot have client side effects