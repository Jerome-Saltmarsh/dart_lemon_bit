
// TODO remove enum
class RainType {
    static const None = 0;
    static const Light = 1;
    static const Heavy = 2;
    
    static const values = [
       None, Light, Heavy,  
    ];
    
    static String getName(int value) {
        return const {
            None: "None",
            Light: "Light",
            Heavy: "Heavy",
        }[value] ?? 'wind-type-unknown-$value';
    }
}
