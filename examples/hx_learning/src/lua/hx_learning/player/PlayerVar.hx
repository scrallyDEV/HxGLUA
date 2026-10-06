package hx_learning.player;

class PlayerVar {
    public static var calls:Int = 0;

    public static function someFunction():Int {
        return ++calls;
    }
}
