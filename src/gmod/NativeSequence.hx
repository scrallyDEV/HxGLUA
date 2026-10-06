package gmod;

/**
 * A native sequential Lua table.
 *
 * Unlike Haxe Array<T>, this keeps Lua's native 1-based indexing.
 * GLua APIs such as player.GetAll() return tables like this.
 */
extern class NativeSequence<T> implements ArrayAccess<T>
{
}
