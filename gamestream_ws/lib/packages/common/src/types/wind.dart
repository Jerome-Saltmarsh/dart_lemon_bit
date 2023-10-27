


class Wind {

  // static bool getEnabled(int value) => (value & 0x01) != 0 ? true : false;

  static bool getEnabled(int value) => true;

  static int setEnabled(int value, bool enabled) {
    if (enabled) {
      return value | 0x01;
    } else {
      return value & 0xFFFFFFFE;
    }
  }

  static int getVelocityX(int value) {
    var velocityX = (value >> 1) & 0x1F;
    if ((value & 0x20) != 0) {
      velocityX |= 0xFFFFFFE0; // Sign extension for negative values
    }
    return velocityX;
  }

  static int getVelocityY(int value) {
    int velocityY = (value >> 6) & 0x1F;
    if ((value & 0x2000) != 0) {
      velocityY |= 0xFFFFFFE0;
    }
    return velocityY;
  }

  static int getVelocityZ(int value) {
    int velocityZ = (value >> 11) & 0x1F;
    if ((value & 0x4000) != 0) {
      velocityZ |= 0xFFFFFFE0;
    }
    return velocityZ;
  }

  static int setVelocityX(int value, int velocityX) {
    velocityX = velocityX.clamp(-15, 16);
    value &= 0xFFFE0;
    velocityX &= 0x1F;
    value |= velocityX << 1;
    return value;
  }

  static int setVelocityY(int value, int velocityY) {
    velocityY = velocityY.clamp(-15, 16);
    value &= 0xFFFFDFF;
    velocityY &= 0x1F;
    value |= velocityY << 6;
    return value;
  }

  static int setVelocityZ(int value, int velocityZ) {
    velocityZ = velocityZ.clamp(-15, 16);
    value &= 0xFFFFBFF;
    velocityZ &= 0x1F;
    value |= velocityZ << 11;
    return value;
  }

  static int getAccelerationX(int value) {
    int accelerationX = (value >> 16) & 0x1F;
    if ((value & 0x20000) != 0) {
      accelerationX |= 0xFFFFFFE0;
    }
    return accelerationX;
  }

  static int getAccelerationY(int value) {
    int accelerationY = (value >> 21) & 0x1F;
    if ((value & 0x40000) != 0) {
      accelerationY |= 0xFFFFFFE0;
    }
    return accelerationY;
  }

  static int getAccelerationZ(int value) {
    int accelerationZ = (value >> 26) & 0x1F;
    if ((value & 0x80000) != 0) {
      accelerationZ |= 0xFFFFFFE0;
    }
    return accelerationZ;
  }

  static int setAccelerationX(int value, int accelerationX) {
    accelerationX = accelerationX.clamp(-16, 15);
    value &= 0xFFFE0FF;
    accelerationX &= 0x1F;
    value |= accelerationX << 16;
    return value;
  }

  static int setAccelerationY(int value, int accelerationY) {
    accelerationY = accelerationY.clamp(-16, 15);
    value &= 0xFFFBFFF;
    accelerationY &= 0x1F;
    value |= accelerationY << 21;
    return value;
  }


  static int setAccelerationZ(int value, int accelerationZ) {
    accelerationZ = accelerationZ.clamp(-16, 15);
    value &= 0xFFF7FFF;
    accelerationZ &= 0x1F;
    value |= accelerationZ << 26;
    return value;
  }
}