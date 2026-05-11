# COI Modding Reference

Technical reference for **Captain of Industry** modding (Update 4+). Universal patterns and APIs that apply to most mods.

> **Notice:** This document includes short excerpts of and references to Captain of Industry game code (type names, method signatures, field names, and small code samples) as reasonably necessary to develop and maintain mods. Any such Game Code is © MaFi Games and is used only under the [Captain of Industry Modding Policy](https://www.captain-of-industry.com/modding-policy). It is **not** covered by this repository's MIT license.

> **This is a living document.** Whenever you (or Claude) discover something new about how the game works, append it here. The reference grows with the project.

---

## Quick Reference

The most commonly needed facts.

**`Option<T>` unwrapping (used everywhere in game APIs):**
```csharp
bool has = (bool)optionValue.GetType().GetProperty("HasValue").GetValue(optionValue);
object val = optionValue.GetType().GetProperty("ValueOrNull").GetValue(optionValue);
// NOTE: There is NO .Value property - use ValueOrNull
// NOTE: Option<T>.None is a static FIELD, not a property - use GetField("None", ...) not GetProperty
```

**Logging (anywhere in mod code):**
```csharp
Log.Info("MyMod: something happened");
Log.Warning("MyMod: something looks off");
Log.Error("MyMod: something broke");
```
Logs land in `%APPDATA%\Captain of Industry\Logs\` - most recent file wins.

**Resolving a service from DI:**
```csharp
var mgr = resolver.GetResolvedInstance<ResearchManager>().Value;
```

---

## Critical Gotchas

These are easy to get wrong. Read before writing reflection code.

- **`Option<T>.None` is a static field, not a property** - `GetProperty("None")` silently returns null. Use `GetField("None", BindingFlags.Static | BindingFlags.Public)`.
- **`Option<T>` has no `.Value` property** - use `ValueOrNull` with a `HasValue` guard.
- **Many UI windows are lazily created** - they don't exist until the player first opens that screen. Don't grab them at construction time. Defer with `someComponent.RootElement.schedule.Execute(() => { ... })`.
- **`AmbiguousMatchException` on reflection** - when a type has inherited members with the same name, use `BindingFlags.DeclaredOnly` to disambiguate.
- **Harmony is NOT bundled with the game** - there's no `0Harmony.dll` in `Managed/`. Reflection has been sufficient for everything. Look for a reflection-based approach before reaching for Harmony.

---

## DLL Inspection Tools

Game install path: set via `COI_ROOT` environment variable.
Game DLLs: `$env:COI_ROOT\Captain of Industry_Data\Managed\` - primarily `Mafi.dll`, `Mafi.Core.dll`, `Mafi.Base.dll`, `Mafi.Unity.dll`.

**Game version from DLLs:**
```powershell
[System.Diagnostics.FileVersionInfo]::GetVersionInfo((Join-Path $env:COI_ROOT 'Captain of Industry_Data\Managed\Mafi.Core.dll')).ProductVersion
# Returns e.g. "0.8.2.0" -- strip trailing ".0" to get "0.8.2"
```
Note: hotfix letter suffixes (e.g. the `c` in `0.8.2c`) are not in DLL metadata - they're only on the game's main menu and in the game's `changelog.txt`.

**`inspect_dll.ps1`** - bundled with this template. Inspects any game type:
```powershell
# Inspect a specific type in a specific DLL
powershell -ExecutionPolicy Bypass -File scripts\inspect_dll.ps1 ResearchManager Mafi.Core.dll

# Inspect a type across all game DLLs
powershell -ExecutionPolicy Bypass -File scripts\inspect_dll.ps1 PanelWithHeader

# If no exact match, prints partial matches to help find the right name
powershell -ExecutionPolicy Bypass -File scripts\inspect_dll.ps1 Toolbar
```
Output includes: inheritance chain, interfaces, constructors, public properties, fields, and methods.

**ILSpy CLI** (`ilspycmd`) - installable via `dotnet tool install -g ilspycmd`. Decompiles game types to readable C#. Essential when you need to understand *how* something works:
```bash
ilspycmd "$COI_ROOT/Captain of Industry_Data/Managed/Mafi.Unity.dll" -t Mafi.Unity.Ui.Some.Type
```

**PowerShell reflection** - for quick checks without full decompilation:
```powershell
$asm = [System.Reflection.Assembly]::LoadFrom("$env:COI_ROOT\Captain of Industry_Data\Managed\Mafi.Unity.dll")
$type = $asm.GetType('Mafi.Unity.UiToolkit.Library.Panel')
$type.GetConstructors() | ForEach-Object { $_.GetParameters() }
```

---

## Modding API Resources

- **Official examples repo:** https://github.com/MaFi-Games/Captain-of-industry-modding (cloned locally during `/kickoff` - see CLAUDE.md for path)
- **Official wiki (WIP):** https://wiki.coigame.com/Modding
- **Game assemblies:** `Mafi.dll`, `Mafi.Core.dll`, `Mafi.Base.dll`, `Mafi.Unity.dll`
- **Discord:** `#modding-dev-general` channel

### Mod Base Classes

| Class | When to use |
|---|---|
| `DataOnlyMod` | Simple mods that only modify data/prototypes (new buildings, recipes, etc.) |
| `IMod` | Full mods with UI, lifecycle hooks, DI services |

### `IMod` Implementation (Update 4 - verified working)

```csharp
public sealed class MyMod : IMod
{
    public string Name => "MyMod";
    public int Version => 1;
    public bool IsUiOnly => false;
    public ModManifest Manifest { get; }
    public Option<IConfig> ModConfig => Option<IConfig>.None;
    public ModJsonConfig JsonConfig { get; }

    // Constructor MUST take ModManifest as first param
    public MyMod(ModManifest manifest) {
        Manifest = manifest;
        JsonConfig = new ModJsonConfig(this);  // REQUIRED - null crashes the game
    }

    public void Initialize(DependencyResolver resolver, bool gameWasLoaded) { }
    public void ChangeConfigs(Lyst<IConfig> configs) { }
    public void RegisterPrototypes(ProtoRegistrator registrator) { }
    public void RegisterDependencies(DependencyResolverBuilder depBuilder, ProtosDb protosDb, bool wasLoaded) { }
    public void EarlyInit(DependencyResolver resolver) { }
    public void MigrateJsonConfig(VersionSlim savedVersion, Dict<string, object> savedValues) { }
    public void Dispose() { }
}
```

**Important gotchas:**
- Constructor takes `ModManifest`, not `(CoreMod, BaseMod)` (older pattern)
- `JsonConfig` must be `new ModJsonConfig(this)`, never null
- `Manifest` property must be stored from constructor
- `Option<IConfig>` for `ModConfig`, not `IModConfig`

### `IMod` Lifecycle (Official Order)

1. **Constructor** - mod loaded
2. **`RegisterPrototypes()`** - register all game content (machines, recipes, research, etc.)
3. **`RegisterDependencies()`** - register custom services with DI container
4. **`EarlyInit()`** - early initialization before map generation
5. **`Initialize()`** - final initialization before game starts

### Key Concepts

- **`RegisterPrototypes(ProtoRegistrator)`** - override to add/modify game data
- **`ModManifest`** - passed to constructor, contains mod metadata at runtime
- **`[GlobalDependency(RegistrationMode.AsEverything)]`** - attribute that auto-registers a class with the game's dependency injection system

---

## Reflection Patterns

Standard C# reflection for accessing internal game state. This is the primary way to interact with game internals that aren't exposed via public API.

```csharp
// Access a private instance field
FieldInfo queueField = typeof(SomeClass).GetField(
    "m_someField",
    BindingFlags.NonPublic | BindingFlags.Instance
);
object value = queueField.GetValue(instance);

// Access a private property
PropertyInfo prop = typeof(SomeClass).GetProperty(
    "PropertyName",
    BindingFlags.NonPublic | BindingFlags.Instance | BindingFlags.Public
);
MethodInfo setter = prop.GetSetMethod(nonPublic: true);
setter.Invoke(instance, new object[] { newValue });

// Access a private static field
FieldInfo staticField = typeof(SomeClass).GetField(
    "FIELD_NAME",
    BindingFlags.Static | BindingFlags.NonPublic
);
staticField.SetValue(null, newValue);

// Invoke a private method
MethodInfo m = typeof(SomeClass).GetMethod(
    "MethodName",
    BindingFlags.NonPublic | BindingFlags.Instance
);
m.Invoke(instance, new object[] { arg1, arg2 });
```

### Why a `ReflectionProbe` helper is recommended

Once you start using reflection, the game updating can silently break things - types get renamed, fields move, methods change. A `ReflectionProbe` helper centralizes every reflection call so:

1. The mod can self-report at startup which targets resolved and which didn't.
2. The static diagnostic script (`scripts/check-reflection-targets.ps1`) can scan the source for `ReflectionProbe.*` calls and verify them against the actual game DLLs without running the game.
3. After a game update, `/game-updated` knows exactly what to verify.

When you add reflection to this mod, build the helper *first*. The ResearchQueue mod is a working reference for the pattern.

---

## Harmony Patching

**Harmony is not bundled with the game** - no `0Harmony.dll` in `Managed/`. Try reflection first.

If you genuinely need Harmony, **Lib.Harmony v2.2.2** (NuGet package) can be installed:

```csharp
[HarmonyPatch(typeof(TargetClass), "MethodName")]
internal static class MyPatcher
{
    public static void Prefix() { /* runs before original */ }
    public static void Postfix() { /* runs after original */ }
}

// Manual patching
var harmony = new Harmony("com.mymod.patch");
harmony.Patch(originalMethod, prefix, postfix);
```

---

## DependencyResolver API (`Mafi.DependencyResolver` in `Mafi.dll`)

The DI container used throughout the game. Available in `IMod.Initialize()`, `IMod.EarlyInit()`, and injected into `[GlobalDependency]` constructors.

### Key Methods

| Method | Purpose |
|--------|---------|
| `GetResolvedInstance<T>()` | Returns `Option<T>` - the resolved instance of a registered type |
| `TryGetResolvedDependency<T>(out T)` | Returns bool, sets `out` param if found |
| `Resolve<T>()` | Returns `T` directly (throws if not found) |
| `TryResolve<T>()` | Returns `Option<T>` |
| `AllResolvedInstances` | `IEnumerable<object>` - **all** resolved instances. Useful for finding non-public types by type name string matching. |
| `GetResolvedInstance(Type type)` | Non-generic overload - returns `Option<object>` |
| `Instantiate<T>()` | Creates a new instance with DI constructor injection |
| `Instantiate<T>(params object[] args)` | Creates with explicit constructor args + DI |
| `ResolveAll<T>()` | Returns all implementations of an interface |

### Finding Non-Public Types at Runtime

When a type is not public, you can't use `GetResolvedInstance<T>()` because you can't write `typeof(...)`. Iterate all instances:

```csharp
object targetInstance = null;
foreach (object obj in resolver.AllResolvedInstances) {
    if (obj.GetType().FullName == "Mafi.Some.Internal.Type") {
        targetInstance = obj;
        break;
    }
}
// Then use reflection on targetInstance.GetType() to access fields/methods
```

---

## Build Configuration

Standard setup for Update 4 mods:
- **.NET Framework:** `net48`
- **Unity modules referenced as needed:** `CoreModule`, `UIElementsModule`, `AudioModule`
- **Deployment:** Post-build copy to `%APPDATA%\Captain of Industry\Mods\<ModName>\`
- **Assembly version:** auto-generated from `manifest.json` `version` field

---

## manifest.json Fields (Official, from MaFi repo)

### Required Fields

| Field | Type | Purpose |
|---|---|---|
| `id` | string | Unique mod ID. Must match `[a-zA-Z0-9][a-zA-Z0-9_-]*`. Must NOT start with `COI-` (reserved). |
| `version` | string | Version string: `major.minor[.patch[letter]]` (e.g. `0.0.1`, `1.2.3a`) |
| `primary_dlls` | string[] | DLL filenames to load, in dependency order |

### Optional Fields

| Field | Type | Purpose |
|---|---|---|
| `display_name` | string | Human-readable name shown in UI (max 50 chars) |
| `description_short` | string | Short description (max 180 chars) |
| `description_long` | string | Detailed description in mod details panel |
| `authors` | string or string[] | Author name(s) |
| `min_game_version` | string | Minimum compatible game version |
| `max_verified_game_version` | string | Highest tested game version |
| `links` | string[] | Web URLs (GitHub, etc.) |
| `mod_dependencies` | string[] | Required mod IDs. Supports version constraints: `"OtherMod >= 1.0.0"` |
| `optional_mod_dependencies` | string[] | Optional mod IDs (same version constraint syntax) |
| `incompatible_mods` | string[] | Mod IDs that conflict with this mod |
| `non_locking_dll_load` | bool | If true, DLLs loaded into memory (allows updating without closing game) |
| `can_add_to_saved_game` | bool | If true, mod can be added to an existing save |
| `can_remove_from_saved_game` | bool | If true, mod can be removed from an existing save |
| `primary_mod_class_name` | string | Class name when multiple `IMod` implementations exist |

### Hub limits (cannot be edited after upload)

- `display_name` - max 50 chars
- `description_short` - max 180 chars

Verify before packaging a release.

---

## Mod Configuration System (config.json)

Mods can expose player-configurable options via a `config.json` file. The game renders these in its settings UI automatically.

### Supported Types

| Type | `default` value | Extra fields |
|---|---|---|
| Boolean | `true`/`false` | - |
| String | `"text"` | `max_length`, `regex` |
| Integer | `42` | `min`, `max`, `is_integer` (must be `true`) |
| Float | `5.3` | `min`, `max` |

Parameter names must be `snake_case`.

### Accessing Config in Code

```csharp
int multiplier = JsonConfig.GetInt("production_multiplier");
bool enabled = JsonConfig.GetBool("enable_feature");

// React to player changes in settings UI
JsonConfig.OnValueChanged += paramName => { /* handle change */ };
```

Config values are persisted in save files. Use `MigrateJsonConfig()` for schema changes between versions.

---

## Prototype Registration Patterns

### Research Node (Official Example)

```csharp
ResearchNodeProto nodeProto = registrator.ResearchNodeProtoBuilder
    .Start("Unlock MyMod stuff!", MyModIds.Research.UnlockMyModStuff, costMonths: 6)
    .Description("This unlocks all the awesome stuff in MyMod!")
    .AddProductToUnlock(MyModIds.Products.SomeProduct)
    .AddRecipeToUnlock(MyModIds.Recipes.SomeRecipe)
    .BuildAndAdd();

nodeProto.GridPosition = new Vector2i(4, 31);
nodeProto.AddParent(registrator.PrototypesDb.GetOrThrow<ResearchNodeProto>(Ids.Research.BasicFarming));
```

### ID Registration Pattern

IDs are static readonly fields in partial classes, using typed ID wrappers:

```csharp
using ResNodeID = Mafi.Core.Research.ResearchNodeProto.ID;
public static readonly ResNodeID MyId = Ids.Research.CreateId("MyId");
```

Same pattern for `ProductProto.ID`, `RecipeProto.ID`, `MachineProto.ID`.

Products can use attribute-based auto-registration:
- `[CountableProduct]`, `[FluidProduct]`, `[LooseProduct]`, `[MoltenProduct]`, `[VirtualProduct]`
- Then call `registrator.RegisterAllProducts()` to register them all.

---

## Update 4 Mod System Notes

The mod selection UI:
- Green checkmark = enabled, Red X = invalid/error, Unchecked = disabled
- Dependency validation (missing dependencies shown as "Missing" badge)
- Mod detail panel showing all manifest fields
- Invalid mod counter at bottom of mod list

---

## Useful Notes

- Logs at `%APPDATA%\Captain of Industry\Logs\` - check these for mod errors
- In-game console command `also_log_to_console` displays log output in the game console
- `manifest.RootDirectoryPath` - available in mod constructor for accessing mod files at runtime
- Discord `#modding-dev-general` is the best place for community + dev support

---

## Dead Ends - What Doesn't Work in Update 4

Approaches that have been tried and confirmed not to work. Do not re-attempt these.

| What | Why it fails |
|------|-------------|
| `optionType.GetProperty("None")` | `Option<T>.None` is a **static field**, not a property. `GetProperty` silently returns null. Use `GetField("None", BindingFlags.Static \| BindingFlags.Public)` instead. |
| `optionType.GetProperty("Value")` | `Option<T>` has no `.Value` property. Use `ValueOrNull` with a `HasValue` guard. |
| Harmony patching without bundling Harmony yourself | Harmony is not bundled with the game (no `0Harmony.dll` in `Managed/`). The official modding repo makes no mention of it. Reflection has been sufficient for every mod we've seen. |
| Accessing lazily-created UI windows in `ControllerActivated` on first open | Many UI windows are lazily created - they don't exist yet when `ControllerActivated` fires the first time. Defer with `schedule.Execute()`. |

---

## Mod-Specific Discoveries

> Append findings here as you (or Claude) discover game-specific details relevant to this particular mod. Group by feature or game subsystem. The point of this section is to keep a personalized log so you don't re-do research work later.

(Empty - start filling in as you go.)
