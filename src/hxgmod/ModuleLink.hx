package hxgmod;

#if macro
import haxe.macro.Context;
import haxe.macro.Compiler;
import haxe.macro.Type;
import haxe.macro.TypedExprTools;

/** Filesystem linker: type against real sources, exclude foreign implementations. */
class ModuleLink {
    public static function prepare():Array<haxe.macro.Expr.Field> {
        var fields = Context.getBuildFields();
        var local = Context.getLocalClass();
        if (local != null) switch local.get().kind {
            case KAbstractImpl(_):
                Context.error("Executable mirrored abstracts are unsupported; use a class or an ordinary helper module", Context.currentPos());
            default:
        }
        for (field in fields) switch field.kind {
            case FFun(_):
                // Do this before typing: extern inline methods otherwise force inlining,
                // even with --no-inline, after foreign types have been excluded.
                if (field.access != null) field.access.remove(AInline);
                if (field.meta != null) for (meta in field.meta)
                    if (meta.name == ":extern") Context.error("Mirrored methods cannot use @:extern", field.pos);
            default:
        }
        return fields;
    }

    public static function setup():Void {
        var spec:Dynamic = haxe.Json.parse(sys.io.File.getContent(Context.definedValue("hxgmod_link")));
        var modules:Dynamic = spec.modules;
        var own:String = spec.own;
        var imports = new Map<String, Dynamic>();
        var exports = new Map<String, String>();
        var main:Null<String> = null;
        function symbol(b:BaseType):String {
            return "_hxgm_" + haxe.crypto.Md5.encode(b.module + ":" + b.name);
        }
        function foreign(b:BaseType):Bool {
            return b.module != own && Reflect.hasField(modules, b.module);
        }
        function reference(b:BaseType):Void {
            if (foreign(b) && !b.meta.has(":hxgmodOriginalExtern")) {
                var entry:Dynamic = Reflect.field(modules, b.module);
                if (entry.realm != "shared" && entry.realm != spec.realm)
                    Context.error('Mirrored module ${own} cannot load ${b.module} (${entry.realm}) in ${spec.realm}; guard the reference with #if gmod_${entry.realm}, or move the dependency into a shared module', b.pos);
                imports.set(symbol(b), {module: b.module, symbol: symbol(b)});
            }
        }
        Compiler.addGlobalMetadata(own, "@:keep", false, true, true);
        for (module in Reflect.fields(modules))
            Compiler.addGlobalMetadata(module, "@:build(hxgmod.ModuleLink.prepare())", false, true, false);
        Context.onAfterTyping(function(types) {
            for (t in types) {
                var b:BaseType = switch t {
                    case TClassDecl(c): c.get();
                    case TEnumDecl(e): e.get();
                    default: continue;
                };
                if (!Reflect.hasField(modules, b.module)) continue;
                if (b.isExtern) { b.meta.add(":hxgmodOriginalExtern", [], b.pos); continue; }
                if (b.meta.has(":generic") || b.meta.has(":genericBuild"))
                    Context.error("Mirrored generic specialization is unsupported; use an ordinary generic class or helper module", b.pos);
                if (b.meta.has(":native")) Context.error("Mirrored types cannot use @:native", b.pos);
                b.meta.add(":native", [macro $v{symbol(b)}], b.pos);
                if (foreign(b)) {
                    b.meta.add(":hxGen", [], b.pos);
                    b.exclude();
                } else {
                    b.meta.add(":keep", [], b.pos);
                    exports.set(symbol(b), symbol(b));
                    switch t {
                        case TClassDecl(c):
                            if (b.name == own.split(".").pop())
                                for (f in c.get().statics.get())
                                    if (f.name == "main") main = symbol(b) + ".main";
                        default:
                    }
                }
            }
        });
        function visit(e:TypedExpr):Void {
            if (e == null) return;
            switch e.expr {
                case TTypeExpr(TClassDecl(c)): reference(c.get());
                case TTypeExpr(TEnumDecl(c)): reference(c.get());
                case TNew(c, _, _): reference(c.get());
                case TField(_, FStatic(c, _)): reference(c.get());
                case TField(_, FEnum(c, _)): reference(c.get());
                default:
            }
            TypedExprTools.iter(e, visit);
        }
        Context.onGenerate(function(types) {
            for (t in types) switch t {
                case TInst(c, _):
                    var b = c.get();
                    if (b.isExtern) continue;
                    if (b.superClass != null) reference(b.superClass.t.get());
                    for (i in b.interfaces) reference(i.t.get());
                    for (f in b.statics.get().concat(b.fields.get())) visit(f.expr());
                    if (b.constructor != null) visit(b.constructor.get().expr());
                    visit(b.init);
                default:
            }
            sys.io.File.saveContent(spec.manifest, haxe.Json.stringify({
                imports: [for (i in imports) i], exports: [for (s in exports) s], main: main
            }));
        });
    }
}
#end
