using Mafi;
using Mafi.Collections;
using Mafi.Core;
using Mafi.Core.Game;
using Mafi.Core.Mods;
using Mafi.Core.Prototypes;

namespace {{MOD_ID}};

/// <summary>
/// Main mod entry point. The game discovers this class because it implements IMod.
///
/// What this hello-world version does:
///   On startup, writes a friendly message to the game log so you can confirm
///   the mod loaded. That's it. From here, you and Claude will build out
///   whatever you actually want the mod to do.
///
/// Where to find the game log:
///   Windows: %APPDATA%\Captain of Industry\Logs\
///   Look for the most recently modified file. Lines starting with "{{MOD_ID}}:"
///   are from this mod.
/// </summary>
public sealed class {{MOD_ID}}Mod : IMod {

	public string Name => "{{MOD_ID}}";
	public int Version => 1;
	public bool IsUiOnly => false;

	public ModManifest Manifest { get; }
	public Option<IConfig> ModConfig => Option<IConfig>.None;
	public ModJsonConfig JsonConfig { get; }

	public {{MOD_ID}}Mod(ModManifest manifest) {
		Manifest = manifest;
		JsonConfig = new ModJsonConfig(this);
		Log.Info("{{MOD_ID}}: constructed");
	}

	public void Initialize(DependencyResolver resolver, bool gameWasLoaded) {
		Log.Info("{{MOD_ID}}: Hello, Captain! The mod loaded successfully. (gameWasLoaded=" + gameWasLoaded + ")");
	}

	public void ChangeConfigs(Lyst<IConfig> configs) { }

	public void RegisterPrototypes(ProtoRegistrator registrator) {
		Log.Info("{{MOD_ID}}: RegisterPrototypes called");
	}

	public void RegisterDependencies(
		DependencyResolverBuilder depBuilder, ProtosDb protosDb, bool wasLoaded) {
	}

	public void EarlyInit(DependencyResolver resolver) { }

	public void MigrateJsonConfig(VersionSlim savedVersion, Dict<string, object> savedValues) { }

	public void Dispose() { }
}
