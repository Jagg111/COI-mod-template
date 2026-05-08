# {{MOD_DISPLAY_NAME}}

{{MOD_DESCRIPTION_SHORT}}

## About

{{MOD_DESCRIPTION_LONG}}

## Status

Hello-world stage — the project is set up and the build pipeline works. Ready to start building real features.

## Build

Requires:
- .NET 8 SDK
- The `COI_ROOT` environment variable pointing to your Captain of Industry install

```
dotnet build {{MOD_ID}}.sln
```

The mod auto-deploys to `%APPDATA%\Captain of Industry\Mods\{{MOD_ID}}\` on every build.

## Distribution

This mod will be distributed via the [COI Mod Hub](https://hub.coigame.com) once it's ready for release. Use `/ship-it` to package a release zip.

## Author

{{MOD_AUTHOR}}

## License

MIT for the mod's own code. See `LICENSE` for the Captain of Industry game code carve-out.
