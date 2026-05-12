using Mafi;
using Mafi.Collections;
using Mafi.Core;
using Mafi.Core.Game;
using Mafi.Core.Mods;
using Mafi.Core.Prototypes;

namespace {{MOD_ID}};

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
	}

	public void Initialize(DependencyResolver resolver, bool gameWasLoaded) { }

	public void ChangeConfigs(Lyst<IConfig> configs) { }

	public void RegisterPrototypes(ProtoRegistrator registrator) { }

	public void RegisterDependencies(
		DependencyResolverBuilder depBuilder, ProtosDb protosDb, bool wasLoaded) {
	}

	public void EarlyInit(DependencyResolver resolver) { }

	public void MigrateJsonConfig(VersionSlim savedVersion, Dict<string, object> savedValues) { }

	public void Dispose() { }
}
