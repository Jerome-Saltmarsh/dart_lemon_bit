## INSTALL
rmdir /s /q "C:\Users\Jerome\github\amulet\isometric_engine\lib\packages\common" &
rmdir /s /q "C:\Users\Jerome\github\amulet\isometric_engine\lib\packages\lemon_math" &
rmdir /s /q "C:\Users\Jerome\github\amulet\isometric_engine\lib\packages\lemon_bits" &
rmdir /s /q "C:\Users\Jerome\github\amulet\isometric_engine\lib\packages\lemon_bytes" &
rmdir /s /q "C:\Users\Jerome\github\amulet\isometric_engine\lib\packages\type_def" &
mklink /J "C:\Users\Jerome\github\amulet\isometric_engine\lib\packages\common" "C:\Users\Jerome\github\amulet\isometric_common\lib" &
mklink /J "C:\Users\Jerome\github\amulet\isometric_engine\lib\packages\lemon_math" "C:\Users\Jerome\github\amulet\tools\lemon_math\lib" &
mklink /J "C:\Users\Jerome\github\amulet\isometric_engine\lib\packages\lemon_bits" "C:\Users\Jerome\github\amulet\tools\lemon_bits\lib" &
mklink /J "C:\Users\Jerome\github\amulet\isometric_engine\lib\packages\lemon_bytes" "C:\Users\Jerome\github\dart-lemon-byte\lib" &
mklink /J "C:\Users\Jerome\github\amulet\isometric_engine\lib\packages\type_def" "C:\Users\Jerome\github\dart\typedef\lib" &
pause

