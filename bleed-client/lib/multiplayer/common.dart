const commandSpawn = 1;
const commandUpdate = 2;
const commandAttack = 3;
const commandSpawnZombie = 4;
const commandEquip = 5;

const characterStateIdle = 0;
const characterStateWalking = 1;
const characterStateDead = 2;
const characterStateAiming = 3;
const characterStateFiring = 4;

const directionUp = 0;
const directionUpRight = 1;
const directionRight = 2;
const directionDownRight = 3;
const directionDown = 4;
const directionDownLeft = 5;
const directionLeft = 6;
const directionUpLeft = 7;

const weaponUnarmed = 0;
const weaponHandgun = 1;
const weaponShotgun = 2;

const typeNpc = 1;
const typeHuman = 0;

// [id, state, direction, positionX, positionY, weapon]
const indexId = 0;
const indexState = 1;
const indexDirection = 2;
const indexPosX = 3;
const indexPosY = 4;
const indexWeapon = 5;

const keyFrame = 'f';
const keyCommand = 'c';
const keyId = 'i';
const keyRotation = 'r';
const keyCharacters = 'c';
const keyBullets = 'b';
const keyFrameOfDeath = 'z';
const keyPlayerName = 'n';
const keyLastUpdateFrame = 'lf';
const keyAimAngle = 'a';
const keyStartX = 'sx';
const keyStartY = 'sy';
const keyRange = 'ra';
const keyAccuracy = 'ka';
const keyEquipValue = 'equip';
const keyWeapon = 'w';


// private
const keyHealth = 'h';
const keyType = 't';
const keyNpcTargetId = 'nt';
const keyVelocityX = 'vX';
const keyVelocityY = 'vY';
const keyDestinationX = 'dX';
const keyDestinationY = 'dY';
const keyShotCoolDown = 'sc';

const double bulletRadius = 3;
const double characterRadius = 7;
const double characterRadius2 = characterRadius * 2;
const double characterBulletRadius = characterRadius + bulletRadius;
const double bulletRange = 220;