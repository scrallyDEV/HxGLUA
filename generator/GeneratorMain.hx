import haxe.Json;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
using StringTools;

class GeneratorMain
{
    static inline var API_ROOT = "api/raw";
    static inline var LUA_ROOT = "api/lua";
    static inline var OUTPUT_ROOT = "src/gmod/generated";
    static inline var PUBLIC_ROOT = "src/gmod";
    static inline var PUBLIC_ALIAS_MARKER = "@hxgmod-generated-public-alias";

    static var pages:Array<Dynamic> = [];
    static var knownClasses:Map<String, Bool> = new Map();
    static var classParents:Map<String, String> = new Map();
    static var ignoredHookClasses:Map<String, Bool> = new Map();
    static var knownStructs:Map<String, Bool> = new Map();
    static var knownEnums:Map<String, Bool> = new Map();
    static var multiReturnTypes:Map<String, String> = new Map();

    static final RESERVED = [
        "break", "case", "cast", "catch", "class", "continue",
        "default", "do", "dynamic", "else", "enum", "extends",
        "extern", "false", "final", "for", "function", "if",
        "implements", "import", "in", "inline", "interface", "macro",
        "new", "null", "override", "package", "private", "public",
        "return", "static", "super", "switch", "this", "throw",
        "true", "try", "typedef", "untyped", "using", "var", "while"
    ];

    static function main():Void
    {
        if (!FileSystem.exists(API_ROOT))
        {
            Sys.println('[HxGMod] Missing ${API_ROOT}.');
            Sys.println('[HxGMod] Run tools/update_api.py first.');
            Sys.exit(1);
        }

        var files:Array<String> = [];
        collectJsonFiles(API_ROOT, files);
        files.sort(Reflect.compare);

        if (files.length == 0)
            throw "No API JSON files found; refusing to replace bindings.";
        for (file in files)
            loadJsonFile(file);
        if (pages.length == 0)
            throw "No API entries loaded; refusing to replace bindings.";

        indexKnownClasses();
        indexKnownStructs();
        indexKnownEnums();

        var classFunctions:Map<String, Array<Dynamic>> = new Map();
        var libraryFunctions:Map<String, Array<Dynamic>> = new Map();
        var hooks:Array<Dynamic> = [];
        var structs:Array<Dynamic> = [];
        var enums:Array<Dynamic> = [];

        var hookCount = 0;
        var skippedCount = 0;

        for (page in pages)
        {
            var type = fieldString(page, "type");

            switch (type)
            {
                case "classfunc":
                    var parent = fieldString(page, "parent");

                    if (!ignoredHookClasses.exists(parent))
                        addGrouped(classFunctions, parent, page);

                case "libraryfunc":
                    addGrouped(libraryFunctions, fieldString(page, "parent"), page);

                case "hook":
                    hookCount++;
                    hooks.push(page);

                case "struct":
                    structs.push(page);

                case "enum":
                    enums.push(page);

                default:
                    skippedCount++;
            }
        }

        var recoveredCount = mergeLuaFallbacks(classFunctions, libraryFunctions);

        // Make sure every documented GLua class exists as a Haxe type,
        // even if it happens to have no methods of its own.
        for (className in knownClasses.keys())
            if (!classFunctions.exists(className))
                classFunctions.set(className, []);

        if (FileSystem.exists(OUTPUT_ROOT))
            removeTree(OUTPUT_ROOT);

        FileSystem.createDirectory(OUTPUT_ROOT);

        var enumCount = generateEnums(enums);
        var multiReturnCount = generateMultiReturns(classFunctions, libraryFunctions);
        var classCount = generateClasses(classFunctions);
        var libraryCount = generateLibraries(libraryFunctions);
        var generatedHookCount = generateHooks(hooks);
        var structCount = generateStructs(structs);
        var publicAliasCount = generatePublicAliases();

        Sys.println('[HxGMod] Loaded ${pages.length} API entries from ${files.length} JSON files.');
        Sys.println('[HxGMod] Known GLua classes: ${countMap(knownClasses)}');
        Sys.println('[HxGMod] Ignored hook-family pseudo classes: ${countMap(ignoredHookClasses)}');
        Sys.println('[HxGMod] Known GLua structs: ${countMap(knownStructs)}');
        Sys.println('[HxGMod] Known GLua enums: ${countMap(knownEnums)}');
        Sys.println('[HxGMod] Generated ${classCount} class externs.');
        Sys.println('[HxGMod] Generated ${libraryCount} library externs.');
        Sys.println('[HxGMod] Recovered ${recoveredCount} missing functions from Lua annotations.');
        Sys.println('[HxGMod] Generated ${generatedHookCount} typed GM hook helpers from ${hookCount} hook entries.');
        Sys.println('[HxGMod] Generated ${structCount} struct typedefs.');
        Sys.println('[HxGMod] Generated ${enumCount} enum abstracts.');
        Sys.println('[HxGMod] Generated ${multiReturnCount} multi-return result types.');
        Sys.println('[HxGMod] Generated ${publicAliasCount} public gmod.* aliases.');
        Sys.println('[HxGMod] Other API entries skipped for now: ${skippedCount}.');
    }

    static function generatePublicAliases():Int
    {
        if (!FileSystem.exists(PUBLIC_ROOT))
            FileSystem.createDirectory(PUBLIC_ROOT);

        cleanPublicAliases();

        var aliases:Map<String, Array<String>> = new Map();
        var displayNames:Map<String, String> = new Map();
        var usedNames:Map<String, Bool> = new Map();

        collectPublicAliasCandidates(
            OUTPUT_ROOT,
            "gmod.generated",
            aliases,
            displayNames
        );

        var count = 0;

        for (key in mapKeys(aliases))
        {
            var targets = aliases.get(key);
            var aliasName = displayNames.get(key);

            if (targets == null || aliasName == null)
                continue;

            if (targets.length == 1)
            {
                // Active global tables are handwritten externs; retain structural aliases.
                if (aliasName == "ENT" || aliasName == "SWEP")
                    aliasName += "Struct";
                if (writePublicAlias(aliasName, targets[0], usedNames))
                    count++;

                continue;
            }

            // When a root generated type collides with a struct/enum/multi type,
            // keep the important class/library name clean (Player, Material, etc.)
            // and suffix only the secondary aliases.
            var primaryTarget:String = null;

            for (target in targets)
            {
                if (isDirectGeneratedTarget(target))
                {
                    primaryTarget = target;
                    aliasName = publicTypeName(target);
                    break;
                }
            }

            if (primaryTarget != null)
            {
                if (writePublicAlias(aliasName, primaryTarget, usedNames))
                    count++;
            }
            else
            {
                Sys.println(
                    '[HxGMod] WARNING: Public alias gmod.${aliasName} has no '
                    + 'unambiguous root type; generating suffixed aliases only.'
                );
            }

            for (target in targets)
            {
                if (target == primaryTarget)
                    continue;

                var suffix = publicAliasSuffix(target);

                if (suffix == "")
                {
                    Sys.println(
                        '[HxGMod] WARNING: Public alias target ${target} '
                        + 'could not be categorized; skipped.'
                    );
                    continue;
                }

                var suffixedName = aliasName + suffix;

                if (writePublicAlias(suffixedName, target, usedNames))
                    count++;
            }
        }

        return count;
    }

    static function writePublicAlias(
        aliasName:String,
        target:String,
        usedNames:Map<String, Bool>
    ):Bool
    {
        var key = aliasName.toLowerCase();

        if (usedNames.exists(key))
        {
            Sys.println(
                '[HxGMod] WARNING: Public alias gmod.${aliasName} skipped; '
                + 'another generated alias already uses that name.'
            );
            return false;
        }

        var destination = Path.join([PUBLIC_ROOT, aliasName + ".hx"]);

        // Handwritten public API always wins. Generator-owned aliases were
        // already removed by cleanPublicAliases().
        if (FileSystem.exists(destination))
        {
            Sys.println(
                '[HxGMod] WARNING: Public alias gmod.${aliasName} skipped; '
                + '${destination} already exists and is not generator-owned.'
            );
            return false;
        }

        var out = new StringBuf();
        out.add('// ${PUBLIC_ALIAS_MARKER}\n');
        out.add("package gmod;\n\n");
        out.add("/**\n");
        out.add(' * Public HxGMod alias for `${target}`.\n');
        out.add(" * Automatically generated. Do not edit by hand.\n");
        out.add(" */\n");
        out.add('typedef ${aliasName} = ${target};\n');

        File.saveContent(destination, out.toString());
        usedNames.set(key, true);
        return true;
    }

    static function isDirectGeneratedTarget(target:String):Bool
    {
        var prefix = "gmod.generated.";

        if (!target.startsWith(prefix))
            return false;

        return target.substr(prefix.length).indexOf(".") == -1;
    }

    static function publicTypeName(target:String):String
    {
        var dot = target.lastIndexOf(".");
        return dot == -1 ? target : target.substr(dot + 1);
    }

    static function publicAliasSuffix(target:String):String
    {
        if (target.startsWith("gmod.generated.enums."))
            return "Enum";

        if (target.startsWith("gmod.generated.structs."))
            return "Struct";

        if (target.startsWith("gmod.generated.multi."))
            return "Result";

        return "";
    }

    static function collectPublicAliasCandidates(
        directory:String,
        packageName:String,
        aliases:Map<String, Array<String>>,
        displayNames:Map<String, String>
    ):Void
    {
        for (name in FileSystem.readDirectory(directory))
        {
            var full = Path.join([directory, name]);

            if (FileSystem.isDirectory(full))
            {
                collectPublicAliasCandidates(
                    full,
                    packageName + "." + name,
                    aliases,
                    displayNames
                );
                continue;
            }

            if (!name.toLowerCase().endsWith(".hx"))
                continue;

            var aliasName = name.substr(0, name.length - 3);
            var key = aliasName.toLowerCase();
            var target = packageName + "." + aliasName;
            var targets = aliases.get(key);

            if (targets == null)
            {
                targets = [];
                aliases.set(key, targets);
                displayNames.set(key, aliasName);
            }

            targets.push(target);
        }
    }

    static function cleanPublicAliases():Void
    {
        if (!FileSystem.exists(PUBLIC_ROOT))
            return;

        for (name in FileSystem.readDirectory(PUBLIC_ROOT))
        {
            var full = Path.join([PUBLIC_ROOT, name]);

            if (
                FileSystem.isDirectory(full)
                || !name.toLowerCase().endsWith(".hx")
            )
                continue;

            var content = File.getContent(full);

            if (content.startsWith('// ' + PUBLIC_ALIAS_MARKER))
                FileSystem.deleteFile(full);
        }
    }


    static function mergeLuaFallbacks(
        classFunctions:Map<String, Array<Dynamic>>,
        libraryFunctions:Map<String, Array<Dynamic>>
    ):Int
    {
        if (!FileSystem.exists(LUA_ROOT))
        {
            Sys.println('[HxGMod] WARNING: ${LUA_ROOT} is missing; Lua reconciliation skipped.');
            return 0;
        }

        var files:Array<String> = [];
        collectLuaFiles(LUA_ROOT, files);
        files.sort(Reflect.compare);

        var recovered = 0;

        for (file in files)
            recovered += mergeLuaFile(file, classFunctions, libraryFunctions);

        return recovered;
    }

    static function collectLuaFiles(directory:String, output:Array<String>):Void
    {
        for (name in FileSystem.readDirectory(directory))
        {
            var full = Path.join([directory, name]);

            if (FileSystem.isDirectory(full))
                collectLuaFiles(full, output);
            else if (name.toLowerCase().endsWith(".lua"))
                output.push(full);
        }
    }

    static function mergeLuaFile(
        path:String,
        classFunctions:Map<String, Array<Dynamic>>,
        libraryFunctions:Map<String, Array<Dynamic>>
    ):Int
    {
        var recovered = 0;
        var pendingParams:Map<String, Dynamic> = new Map();
        var pendingReturns:Array<Dynamic> = [];

        var paramPattern = ~/^---@param\s+([^\s]+)\s+([^\s]+)/;
        var returnPattern = ~/^---@return\s+([^\s]+)/;
        var functionPattern = ~/^function\s+([A-Za-z_][A-Za-z0-9_]*)([.:])([A-Za-z_][A-Za-z0-9_]*)\((.*)\)\s*end\s*$/;

        for (rawLine in File.getContent(path).split("\n"))
        {
            var line = rawLine.trim();

            if (paramPattern.match(line))
            {
                var rawName = paramPattern.matched(1);
                var type = paramPattern.matched(2);
                var optional = rawName.endsWith("?");
                var name = optional ? rawName.substr(0, rawName.length - 1) : rawName;

                pendingParams.set(name, {
                    type: type,
                    optional: optional
                });

                continue;
            }

            if (returnPattern.match(line))
            {
                pendingReturns.push({
                    name: "value",
                    type: returnPattern.matched(1)
                });

                continue;
            }

            if (functionPattern.match(line))
            {
                var parent = functionPattern.matched(1);
                var separator = functionPattern.matched(2);
                var nativeName = functionPattern.matched(3);
                var rawArguments = functionPattern.matched(4).trim();

                var kind = separator == ":" ? "classfunc" : "libraryfunc";
                var target = separator == ":" ? classFunctions : libraryFunctions;

                // Do not recover PLAYER:/ENTITY:/WEAPON: hook-family methods as
                // userdata class methods. Those pseudo classes intentionally share
                // names with real GLua types except for case.
                if (separator == ":" && ignoredHookClasses.exists(parent))
                {
                    pendingParams = new Map();
                    pendingReturns = [];
                    continue;
                }

                if (!hasNativeFunction(target, parent, nativeName))
                {
                    var args:Array<Dynamic> = [];

                    if (rawArguments != "")
                    {
                        for (rawArg in rawArguments.split(","))
                        {
                            var name = rawArg.trim();

                            if (name == "")
                                continue;

                            var info = pendingParams.get(name);
                            var arg:Dynamic = {
                                name: name,
                                type: info == null ? "any" : fieldString(info, "type")
                            };

                            if (info != null && Reflect.field(info, "optional") == true)
                                Reflect.setField(arg, "default", "nil");

                            args.push(arg);
                        }
                    }

                    var page:Dynamic = {
                        type: kind,
                        parent: parent,
                        name: nativeName,
                        description: "Recovered from the published Lua annotation set.",
                        realm: "",
                        arguments: [{ args: args }],
                        returns: pendingReturns.copy()
                    };

                    addGrouped(target, parent, page);
                    recovered++;
                }

                pendingParams = new Map();
                pendingReturns = [];
                continue;
            }

            if (line.startsWith("---") || line == "")
                continue;

            pendingParams = new Map();
            pendingReturns = [];
        }

        return recovered;
    }

    static function hasNativeFunction(
        groups:Map<String, Array<Dynamic>>,
        parent:String,
        nativeName:String
    ):Bool
    {
        var entries = groups.get(parent);

        if (entries == null)
            return false;

        for (entry in entries)
            if (fieldString(entry, "name") == nativeName)
                return true;

        return false;
    }

    static function collectJsonFiles(directory:String, output:Array<String>):Void
    {
        for (name in FileSystem.readDirectory(directory))
        {
            var full = Path.join([directory, name]);

            if (FileSystem.isDirectory(full))
                collectJsonFiles(full, output);
            else if (name.toLowerCase().endsWith(".json") && name != "__metadata.json")
                output.push(full);
        }
    }

    static function loadJsonFile(path:String):Void
    {
        try
        {
            var value:Dynamic = Json.parse(File.getContent(path));

            if (Std.isOfType(value, Array))
            {
                var entries:Array<Dynamic> = cast value;

                for (entry in entries)
                    if (entry != null)
                        pages.push(entry);
            }
            else
                throw "Expected an array of API entries";
        }
        catch (error:Dynamic)
        {
            throw 'Failed to parse ${path}: ${error}. Existing bindings were not replaced.';
        }
    }

    static function indexKnownClasses():Void
    {
        // The wiki exposes hook-family pseudo classes such as PLAYER, ENTITY,
        // WEAPON, etc. Their addresses end in `_Hooks`. They are not the same
        // thing as the real Player/Entity/Weapon userdata classes, and on
        // Windows their generated filenames collide case-insensitively.
        for (page in pages)
        {
            if (fieldString(page, "type") != "class")
                continue;

            var address = fieldString(page, "address");
            var name = fieldString(page, "name");

            if (name != "" && address.endsWith("_Hooks"))
                ignoredHookClasses.set(name, true);
        }

        for (page in pages)
        {
            var type = fieldString(page, "type");

            if (type == "class")
            {
                var name = fieldString(page, "name");

                if (name != "" && !ignoredHookClasses.exists(name))
                {
                    knownClasses.set(name, true);

                    var parent = fieldString(page, "parent");

                    if (parent != "" && parent != name)
                        classParents.set(name, parent);
                }
            }
            else if (type == "classfunc")
            {
                var parent = fieldString(page, "parent");

                if (parent != "" && !ignoredHookClasses.exists(parent))
                    knownClasses.set(parent, true);
            }
        }
    }

    static function indexKnownStructs():Void
    {
        for (page in pages)
        {
            if (fieldString(page, "type") != "struct")
                continue;

            var name = fieldString(page, "name");

            if (name != "")
                knownStructs.set(name, true);
        }
    }

    static function indexKnownEnums():Void
    {
        for (page in pages)
        {
            if (fieldString(page, "type") != "enum")
                continue;

            var name = fieldString(page, "name");

            if (name != "")
                knownEnums.set(name, true);
        }
    }

    static function addGrouped(groups:Map<String, Array<Dynamic>>, key:String, page:Dynamic):Void
    {
        if (key == "")
            return;

        var entries = groups.get(key);

        if (entries == null)
        {
            entries = [];
            groups.set(key, entries);
        }

        entries.push(page);
    }

    static function generateEnums(enums:Array<Dynamic>):Int
    {
        var directory = Path.join([OUTPUT_ROOT, "enums"]);
        FileSystem.createDirectory(directory);

        enums.sort(comparePages);

        var count = 0;

        for (page in enums)
        {
            var nativeName = fieldString(page, "name");

            if (nativeName == "")
                continue;

            var enumName = enumTypeName(nativeName);
            var items = dynamicArray(Reflect.field(page, "items"));

            var out = new StringBuf();
            out.add("package gmod.generated.enums;\n\n");
            out.add("/**\n");
            out.add(' * Automatically generated GLua enum for ${nativeName}.\n');
            out.add(" * Values come from the Garry's Mod API documentation.\n");
            out.add(" * Do not edit this file by hand.\n");
            out.add(" */\n");
            out.add('enum abstract ${enumName}(Float) from Float to Float\n');
            out.add("{\n");

            var used:Map<String, Int> = new Map();

            for (index in 0...items.length)
            {
                var item = items[index];
                var rawKey = fieldString(item, "key");
                var rawValue = fieldString(item, "value");

                if (rawKey == "" || rawValue == "")
                    continue;

                var key = identifier(rawKey, "Value" + (index + 1));
                var seen = used.exists(key) ? used.get(key) : 0;
                seen++;
                used.set(key, seen);

                if (seen > 1)
                    key += "_" + seen;

                var description = cleanDescription(fieldString(item, "description"));
                var deprecated = cleanDescription(fieldString(item, "deprecated"));

                if (description != "" || deprecated != "")
                {
                    out.add("    /**\n");

                    if (description != "")
                        out.add('     * ${description}\n');

                    if (deprecated != "")
                        out.add('     * Deprecated: ${deprecated}\n');

                    out.add("     */\n");
                }

                out.add('    var ${key} = ${rawValue};\n\n');
            }

            out.add("}\n");

            File.saveContent(Path.join([directory, enumName + ".hx"]), out.toString());
            count++;
        }

        return count;
    }

    static function generateMultiReturns(
        classFunctions:Map<String, Array<Dynamic>>,
        libraryFunctions:Map<String, Array<Dynamic>>
    ):Int
    {
        var directory = Path.join([OUTPUT_ROOT, "multi"]);
        FileSystem.createDirectory(directory);

        var count = 0;
        count += generateMultiReturnsForGroups(classFunctions, directory);
        count += generateMultiReturnsForGroups(libraryFunctions, directory);
        return count;
    }

    static function generateMultiReturnsForGroups(
        groups:Map<String, Array<Dynamic>>,
        directory:String
    ):Int
    {
        var count = 0;

        for (parent in mapKeys(groups))
        {
            var functions = groups.get(parent);

            if (functions == null)
                continue;

            for (page in functions)
            {
                var returns = dynamicArray(Reflect.field(page, "returns"));

                if (returns.length <= 1)
                    continue;

                var className = multiReturnClassName(page);
                var fullType = 'gmod.generated.multi.${className}';
                multiReturnTypes.set(multiReturnKey(page), fullType);

                var out = new StringBuf();
                out.add("package gmod.generated.multi;\n\n");
                out.add("/**\n");
                out.add(' * Multiple return values from ${fieldString(page, "parent")}.${fieldString(page, "name")}.\n');
                out.add(" * Automatically generated. Do not edit by hand.\n");
                out.add(" */\n");
                out.add('@:multiReturn extern class ${className}\n');
                out.add("{\n");

                var used:Map<String, Int> = new Map();

                for (index in 0...returns.length)
                {
                    var result = returns[index];
                    var rawName = fieldString(result, "name");

                    if (rawName == "")
                        rawName = "value" + (index + 1);

                    var fieldName = identifier(rawName, "value" + (index + 1));
                    var seen = used.exists(fieldName) ? used.get(fieldName) : 0;
                    seen++;
                    used.set(fieldName, seen);

                    if (seen > 1)
                        fieldName += "_" + seen;

                    var callback = Reflect.field(result, "callback");
                    var resultType = callback != null
                        ? callbackType(callback)
                        : mapType(fieldString(result, "type"));
                    var description = cleanDescription(fieldString(result, "description"));

                    if (description != "")
                    {
                        out.add("    /**\n");
                        out.add('     * ${description}\n');
                        out.add("     */\n");
                    }

                    out.add('    public var ${fieldName}:${resultType};\n\n');
                }

                out.add("}\n");
                File.saveContent(Path.join([directory, className + ".hx"]), out.toString());
                count++;
            }
        }

        return count;
    }

    static function multiReturnKey(page:Dynamic):String
    {
        return fieldString(page, "type") + "|"
            + fieldString(page, "parent") + "|"
            + fieldString(page, "name");
    }

    static function multiReturnClassName(page:Dynamic):String
    {
        var kind = fieldString(page, "type");
        var parent = fieldString(page, "parent");
        var nativeName = fieldString(page, "name");

        var prefix = kind == "classfunc"
            ? typeName(parent) + "Method"
            : libraryClassName(parent);

        return identifier(prefix + typeName(nativeName) + "Result", "GluaMultiResult");
    }

    static function generateStructs(structs:Array<Dynamic>):Int
    {
        var directory = Path.join([OUTPUT_ROOT, "structs"]);
        FileSystem.createDirectory(directory);

        structs.sort(comparePages);

        var count = 0;

        for (page in structs)
        {
            var nativeName = fieldString(page, "name");

            if (nativeName == "")
                continue;

            var structName = typeName(nativeName);
            var fields = dynamicArray(Reflect.field(page, "fields"));

            var out = new StringBuf();
            out.add("package gmod.generated.structs;\n\n");
            out.add("/**\n");
            out.add(' * Automatically generated GLua structure for ${nativeName}.\n');
            out.add(" * Do not edit this file by hand.\n");
            out.add(" */\n");
            out.add('typedef ${structName} = {\n');

            for (index in 0...fields.length)
            {
                var field = fields[index];
                var rawName = fieldString(field, "name");

                if (rawName == "")
                    rawName = "field" + (index + 1);

                var fieldName = identifier(rawName, "field" + (index + 1));
                var description = cleanDescription(fieldString(field, "description"));
                var callback = Reflect.field(field, "callback");
                var fieldType = callback != null
                    ? callbackType(callback)
                    : mapType(fieldString(field, "type"));

                if (description != "")
                {
                    out.add("    /**\n");
                    out.add('     * ${description}\n');
                    out.add("     */\n");
                }

                // Fields with documented defaults can be omitted when constructing
                // a GLua config table because the engine supplies that default.
                if (Reflect.hasField(field, "default"))
                    out.add("    @:optional\n");

                out.add('    var ${fieldName}:${fieldType};\n\n');
            }

            out.add("}\n");

            File.saveContent(Path.join([directory, structName + ".hx"]), out.toString());
            count++;
        }

        return count;
    }

    static function generateClasses(groups:Map<String, Array<Dynamic>>):Int
    {
        var names = mapKeys(groups);
        var count = 0;

        for (nativeName in names)
        {
            var className = typeName(nativeName);
            var methods = groups.get(nativeName);

            if (methods == null)
                continue;

            methods.sort(comparePages);

            var out = new StringBuf();
            out.add("package gmod.generated;\n\n");
            out.add("/**\n");
            out.add(' * Automatically generated GLua binding for ${nativeName}.\n');
            out.add(" * Do not edit this file by hand.\n");
            out.add(" */\n");
            out.add('extern class ${className}');

            var parent = classParents.get(nativeName);

            if (parent != null)
            {
                var parentName:String = parent;

                if (
                    parentName != "" &&
                    parentName != nativeName &&
                    knownClasses.exists(parentName)
                )
                    out.add(' extends ${typeName(parentName)}');
            }

            out.add("\n{\n");

            var used:Map<String, Int> = new Map();

            for (page in methods)
                out.add(renderFunction(page, false, used));

            out.add("}\n");

            File.saveContent(Path.join([OUTPUT_ROOT, className + ".hx"]), out.toString());
            count++;
        }

        return count;
    }

    static function generateLibraries(groups:Map<String, Array<Dynamic>>):Int
    {
        var names = mapKeys(groups);
        var count = 0;

        for (nativeName in names)
        {
            var className = libraryClassName(nativeName);
            var methods = groups.get(nativeName);

            if (methods == null)
                continue;

            methods.sort(comparePages);

            var out = new StringBuf();
            out.add("package gmod.generated;\n\n");
            out.add("/**\n");
            out.add(' * Automatically generated binding for the GLua `${nativeName}` library.\n');
            out.add(" * Do not edit this file by hand.\n");
            out.add(" */\n");
            out.add('@:native("${escapeString(nativeName)}")\n');
            out.add('extern class ${className}\n');
            out.add("{\n");

            var used:Map<String, Int> = new Map();

            for (page in methods)
                out.add(renderFunction(page, true, used));

            out.add("}\n");

            File.saveContent(Path.join([OUTPUT_ROOT, className + ".hx"]), out.toString());
            count++;
        }

        return count;
    }

    static function realmCondition(realm:String):String
    {
        return switch (realm.trim().toLowerCase())
        {
            case "server": "(!gmod_realm_strict || gmod_server)";
            case "client": "(!gmod_realm_strict || gmod_client)";
            case "menu": "(!gmod_realm_strict || gmod_menu)";
            case "shared": "(!gmod_realm_strict || gmod_server || gmod_client)";
            case "client and menu": "(!gmod_realm_strict || gmod_client || gmod_menu)";
            case "shared and menu": "(!gmod_realm_strict || gmod_server || gmod_client || gmod_menu)";
            default: "";
        };
    }

    static function beginRealmGuard(realm:String):String
    {
        var condition = realmCondition(realm);
        return condition == "" ? "" : '#if ${condition}\n';
    }

    static function endRealmGuard(realm:String):String
    {
        return realmCondition(realm) == "" ? "" : "#end\n";
    }

    static function renderArguments(args:Array<Dynamic>):String
    {
        var renderedArgs:Array<String> = [];
        var usedArgs:Map<String, Int> = new Map();

        for (index in 0...args.length)
        {
            var arg = args[index];
            var rawName = fieldString(arg, "name");

            if (rawName == "" || rawName == "...")
                rawName = "arg" + (index + 1);

            var argName = identifier(rawName, "arg" + (index + 1));
            var argSeen = usedArgs.exists(argName) ? usedArgs.get(argName) : 0;
            argSeen++;
            usedArgs.set(argName, argSeen);

            if (argSeen > 1)
                argName += "_" + argSeen;

            var callback = Reflect.field(arg, "callback");
            var type = callback != null
                ? callbackType(callback)
                : mapType(fieldString(arg, "type"));

            var optional = Reflect.hasField(arg, "default") && Reflect.field(arg, "default") != null;
            renderedArgs.push((optional ? "?" : "") + argName + ":" + type);
        }

        return renderedArgs.join(", ");
    }

    static function generateHooks(hooks:Array<Dynamic>):Int
    {
        hooks.sort(comparePages);

        var out = new StringBuf();
        out.add("package gmod.generated;\n\n");
        out.add("/**\n");
        out.add(" * Typed helpers for standard Garry's Mod GM hooks.\n");
        out.add(" * Automatically generated. Do not edit by hand.\n");
        out.add(" */\n");
        out.add("class Hooks\n");
        out.add("{\n");

        var used:Map<String, Int> = new Map();
        var count = 0;

        for (page in hooks)
        {
            // GM hooks are the normal global hooks that are appropriate for hook.Add.
            // Other hook families can have different semantics, so leave those
            // alone until they are modeled properly.
            if (fieldString(page, "parent") != "GM")
                continue;

            var nativeName = fieldString(page, "name");

            if (nativeName == "")
                continue;

            var haxeName = methodName(nativeName);
            var seen = used.exists(haxeName) ? used.get(haxeName) : 0;
            seen++;
            used.set(haxeName, seen);

            if (seen > 1)
                haxeName += "_" + seen;

            var argumentSets:Array<Dynamic> = dynamicArray(Reflect.field(page, "arguments"));
            var args:Array<Dynamic> = [];

            if (argumentSets.length > 0)
                args = dynamicArray(Reflect.field(argumentSets[0], "args"));

            var returns = dynamicArray(Reflect.field(page, "returns"));
            var callbackSignature = functionType(args, returns);
            var description = cleanDescription(fieldString(page, "description"));
            var realm = fieldString(page, "realm");
            var guard = beginRealmGuard(realm);

            if (guard != "")
                out.add(guard);

            out.add("    /**\n");

            if (description != "")
                out.add('     * ${description}\n');

            if (realm != "")
                out.add('     * Realm: ${realm}.\n');

            out.add("     */\n");
            out.add('    public static inline function ${haxeName}(identifier:String, callback:${callbackSignature}):Void\n');
            out.add("    {\n");
            out.add('        gmod.Hook.add("${escapeString(nativeName)}", identifier, callback);\n');
            out.add("    }\n");

            if (guard != "")
                out.add(endRealmGuard(realm));

            out.add("\n");
            count++;
        }

        out.add("}\n");

        File.saveContent(Path.join([OUTPUT_ROOT, "Hooks.hx"]), out.toString());
        return count;
    }

    static function renderFunction(page:Dynamic, isStatic:Bool, used:Map<String, Int>):String
    {
        var nativeName = fieldString(page, "name");

        if (nativeName == "")
            return "";

        var haxeName = methodName(nativeName);
        var seen = used.exists(haxeName) ? used.get(haxeName) : 0;
        seen++;
        used.set(haxeName, seen);

        if (seen > 1)
            haxeName += "_" + seen;

        var description = cleanDescription(fieldString(page, "description"));
        var realm = fieldString(page, "realm");
        var deprecated = fieldString(page, "deprecated");
        var argumentSets:Array<Dynamic> = dynamicArray(Reflect.field(page, "arguments"));
        var resultType = returnType(page);
        var guard = beginRealmGuard(realm);

        var out = new StringBuf();

        if (guard != "")
            out.add(guard);

        out.add("    /**\n");

        if (description != "")
            out.add('     * ${description}\n');

        if (realm != "")
            out.add('     * Realm: ${realm}.\n');

        if (deprecated != "")
            out.add('     * Deprecated: ${cleanDescription(deprecated)}\n');

        if (argumentSets.length > 1)
            out.add('     * Overloads: ${argumentSets.length} documented signatures.\n');

        out.add("     */\n");

        // Keep the first documented signature as the concrete extern field and
        // preserve every additional signature with Haxe's native overload metadata.
        if (argumentSets.length > 1)
        {
            for (index in 1...argumentSets.length)
            {
                var overloadArgs = dynamicArray(Reflect.field(argumentSets[index], "args"));
                out.add('    @:overload(function(${renderArguments(overloadArgs)}):${resultType} {})\n');
            }
        }

        out.add('    @:native("${escapeString(nativeName)}")\n');
        out.add("    public ");

        if (isStatic)
            out.add("static ");

        var args:Array<Dynamic> = [];

        if (argumentSets.length > 0)
            args = dynamicArray(Reflect.field(argumentSets[0], "args"));

        out.add('function ${haxeName}(${renderArguments(args)}):${resultType};\n');

        if (guard != "")
            out.add(endRealmGuard(realm));

        out.add("\n");
        return out.toString();
    }

    static function callbackType(callback:Dynamic):String
    {
        if (callback == null)
            return "Dynamic";

        var args = dynamicArray(Reflect.field(callback, "arguments"));
        var returns = dynamicArray(Reflect.field(callback, "returns"));

        return functionType(args, returns);
    }

    static function functionType(args:Array<Dynamic>, returns:Array<Dynamic>):String
    {
        return '(' + renderArguments(args) + ') -> ' + returnValuesType(returns);
    }

    static function returnValuesType(returns:Array<Dynamic>):String
    {
        if (returns.length == 0)
            return "Void";

        // Lua can return multiple values. A dedicated typed representation can
        // be added later; Dynamic keeps those hooks/functions callable for now.
        if (returns.length > 1)
            return "Dynamic";

        var result = returns[0];
        var callback = Reflect.field(result, "callback");

        return callback != null
            ? callbackType(callback)
            : mapType(fieldString(result, "type"));
    }

    static function returnType(page:Dynamic):String
    {
        var returns = dynamicArray(Reflect.field(page, "returns"));

        if (returns.length > 1)
        {
            var generated = multiReturnTypes.get(multiReturnKey(page));

            if (generated != null)
                return generated;

            return "Dynamic";
        }

        return returnValuesType(returns);
    }

    static function mapType(raw:String):String
    {
        var value = raw.trim();

        if (value == "")
            return "Dynamic";

        // The annotations sometimes qualify structure names as Structures/Foo.
        if (value.startsWith("Structures/"))
            value = value.substr("Structures/".length);

        // Nullable unions are extremely common in GLua, e.g. string|nil,
        // Entity|nil and Player|NULL. Preserve those instead of dropping to Dynamic.
        if (value.indexOf("|") != -1)
        {
            var parts = value.split("|");
            var nonNull:Array<String> = [];
            var hasNull = false;

            for (part in parts)
            {
                var trimmed = part.trim();
                var lowerPart = trimmed.toLowerCase();

                if (lowerPart == "nil" || lowerPart == "null")
                    hasNull = true;
                else if (trimmed != "")
                    nonNull.push(trimmed);
            }

            if (hasNull && nonNull.length == 1)
                return 'Null<${mapType(nonNull[0])}>';

            return "Dynamic";
        }

        if (value.endsWith("[]"))
        {
            var element = value.substr(0, value.length - 2).trim();
            return 'gmod.NativeSequence<${mapType(element)}>';
        }

        // Wiki JSON uses table<T> for sequential native Lua tables.
        if (value.startsWith("table<") && value.endsWith(">"))
        {
            var inner = value.substr(6, value.length - 7).trim();

            // Two-parameter table<K,V> shapes are dictionaries rather than
            // sequences. Keep those Dynamic until we add a NativeTable<K,V>.
            if (inner.indexOf(",") == -1)
                return 'gmod.NativeSequence<${mapType(inner)}>';

            return "Dynamic";
        }

        // Wiki JSON uses table{StructName} for structured Lua tables.
        if (value.startsWith("table{") && value.endsWith("}"))
        {
            var structName = value.substr(6, value.length - 7).trim();

            if (structName.startsWith("Structures/"))
                structName = structName.substr("Structures/".length);

            if (knownStructs.exists(structName))
                return 'gmod.generated.structs.${typeName(structName)}';

            return "Dynamic";
        }

        // Enum-qualified numbers such as number{DMG} become proper Haxe
        // enum abstracts while remaining raw integers at runtime.
        if (value.startsWith("number{") && value.endsWith("}"))
        {
            var enumName = value.substr(7, value.length - 8).trim();

            if (knownEnums.exists(enumName))
                return 'gmod.generated.enums.${enumTypeName(enumName)}';

            return "Int";
        }

        var lower = value.toLowerCase();

        return switch (lower)
        {
            case "string": "String";
            case "boolean", "bool": "Bool";
            case "integer", "int": "Int";
            case "number": "Float";
            case "table", "function", "any", "vararg", "userdata", "nil", "null": "Dynamic";
            default:
                if (lower.indexOf(" or ") != -1 || value.indexOf("/") != -1)
                    "Dynamic";
                else if (knownClasses.exists(value))
                    typeName(value);
                else if (knownStructs.exists(value))
                    'gmod.generated.structs.${typeName(value)}';
                else if (knownEnums.exists(value))
                    'gmod.generated.enums.${enumTypeName(value)}';
                else
                    "Dynamic";
        }
    }

    static function enumTypeName(nativeName:String):String
    {
        var value = typeName(nativeName);

        // Haxe type names need a normal leading type identifier. A few GLua
        // enum groups (notably `_USE`) begin with punctuation/underscores.
        if (value.length == 0 || value.charAt(0) == "_")
            value = "Enum" + value;

        return value;
    }

    static function typeName(nativeName:String):String
    {
        var value = identifier(nativeName, "GluaType");

        if (value.length > 0)
            value = value.substr(0, 1).toUpperCase() + value.substr(1);

        return value;
    }

    static function libraryClassName(nativeName:String):String
    {
        if (nativeName == "_G")
            return "GlobalLib";

        var clean = ~/[^A-Za-z0-9]+/g.replace(nativeName, " ").trim();
        var parts = clean.split(" ");
        var result = "";

        for (part in parts)
        {
            if (part == "")
                continue;

            result += part.substr(0, 1).toUpperCase() + part.substr(1);
        }

        if (result == "")
            result = "Glua";

        return identifier(result + "Lib", "GluaLib");
    }

    static function methodName(nativeName:String):String
    {
        var value = identifier(nativeName, "call");

        if (value.length > 0)
            value = value.substr(0, 1).toLowerCase() + value.substr(1);

        if (isReserved(value))
            value += "_";

        return value;
    }

    static function identifier(raw:String, fallback:String):String
    {
        var value = ~/[^A-Za-z0-9_]/g.replace(raw, "_");

        if (value == "")
            value = fallback;

        var first = value.charCodeAt(0);

        if (first >= "0".code && first <= "9".code)
            value = "_" + value;

        if (isReserved(value))
            value += "_";

        return value;
    }

    static function isReserved(value:String):Bool
    {
        return RESERVED.indexOf(value) != -1;
    }

    static function cleanDescription(value:String):String
    {
        if (value == null)
            return "";

        value = value.replace("*/", "* /");
        value = value.replace("\r", " ").replace("\n", " ");

        while (value.indexOf("  ") != -1)
            value = value.replace("  ", " ");

        value = value.trim();

        if (value.length > 180)
            value = value.substr(0, 177) + "...";

        return value;
    }

    static function escapeString(value:String):String
    {
        return value.replace("\\", "\\\\").replace("\"", "\\\"");
    }

    static function fieldString(object:Dynamic, field:String):String
    {
        if (object == null || !Reflect.hasField(object, field))
            return "";

        var value:Dynamic = Reflect.field(object, field);
        return value == null ? "" : Std.string(value);
    }

    static function dynamicArray(value:Dynamic):Array<Dynamic>
    {
        return value != null && Std.isOfType(value, Array) ? cast value : [];
    }

    static function comparePages(a:Dynamic, b:Dynamic):Int
    {
        return Reflect.compare(fieldString(a, "name"), fieldString(b, "name"));
    }

    static function mapKeys<T>(map:Map<String, T>):Array<String>
    {
        var result:Array<String> = [];

        for (key in map.keys())
            result.push(key);

        result.sort(Reflect.compare);
        return result;
    }

    static function countMap<T>(map:Map<String, T>):Int
    {
        var count = 0;
        for (_ in map.keys())
            count++;
        return count;
    }

    static function removeTree(path:String):Void
    {
        if (!FileSystem.exists(path))
            return;

        if (!FileSystem.isDirectory(path))
        {
            FileSystem.deleteFile(path);
            return;
        }

        for (name in FileSystem.readDirectory(path))
            removeTree(Path.join([path, name]));

        FileSystem.deleteDirectory(path);
    }
}
