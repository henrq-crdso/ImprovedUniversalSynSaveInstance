# ImprovedUniversalSynSaveInstance

> A passion-driven, faster fork of [UniversalSynSaveInstance](https://github.com/luau/UniversalSynSaveInstance) — the universal saveinstance revival, running smoother than ever. Also doubles as a fully editable Roblox Format File writer.
[![Star History Chart](https://api.star-history.com/chart?repos=henrq-crdso%2Fimproveduniversalsynsaveinstance&type=date&legend=top-left)](https://www.star-history.com/?repos=henrq-crdso%2FImprovedUniversalSynSaveInstance&type=date&legend=top-left)

[![USSI License](https://img.shields.io/badge/USSI-License-green)](https://github.com/luau/UniversalSynSaveInstance/blob/main/LICENSE)

# Their Discord
[<img src="https://discordapp.com/api/guilds/1022465460517740654/widget.png?style=banner2" alt="Our Official Discord Server!"></img>](https://discord.com/invite/wx4ThpAsmw)

---

## What's Different from UniversalSynSaveInstance?

This fork significantly extends and improves on the original in every major area.

### New Features & Options

| Feature | Description |
|---|---|
| `SaveAsAttributes` | Saves non-serializable (NotSaveable) properties as Roblox Attributes on each instance, making previously inaccessible data visible in Studio |
| `SavePropsAsAttributesForNotCreatableFixes` | When saving non-creatable instances as Folder substitutes, also preserves their original properties as Attributes |
| `Crashlog` | Writes a detailed per-step crash log to disk using `appendfile`, making crash investigation possible without a debugger |
| `DisableGethiddenpropertyFallback` | Opt-out of the `UGCValidationService` fallback for reading special properties, useful when it causes slowdowns or errors |
| `SaveBytecodeIfDecompilerFails` | Automatically includes raw bytecode (Base64) when decompilation fails, so you never lose script data |
| `SaveCompilationErrors` | Captures and includes compilation error messages in the output instead of leaving the source blank |
| `IgnoreSpecialStrings` | Skips NotScriptable string properties that cause crashes on certain executors (e.g. Velocity) |
| `IgnoreSpecialClassProperties` | Skips NotScriptable Class-category properties that cause crashes on certain executors |
| `decomptype` | Allows explicitly choosing the decompiler type, including `"custom"` to load the bundled Konstant Decompiler |
| Custom `mode` via table | The `mode` option now also accepts a table of service names, letting you define a precise list of services to save instead of relying on the built-in `optimized` preset |

### Konstant Decompiler Integration

When no native decompiler is found (or when `decomptype = "custom"` is set), the script automatically attempts to load **Konstant V2.1**, a standalone Luau decompiler. This means executors without a built-in decompiler can still produce decompiled output.

### Per-API-Class Property Separation

During the API dump parsing phase, properties are now split into two lists per class: saveable (`Properties`) and non-saveable (`NotSaveableProperties`). This separation powers `SaveAsAttributes` efficiently without re-iterating the full property list at runtime.

### `GetInheritedProps` Improvements

The inherited property resolver now accepts optional parameters to walk only up to a specific superclass, and to choose between saveable or non-saveable property sets. This is what allows `SaveAsAttributes` to correctly scope which properties to dump for each instance.

### Bug Fixes

| Bug | Status |
|---|---|
| `gsubCaseInsensitive` was performing the case-insensitive check on the original input instead of the lowercased version, causing misses on mixed-case strings | Fixed |
| `Crashlog` mode now overrides `warn` globally so all internal warnings are also captured in the log file | Fixed |
| `CanLoad`-only check was too permissive — properties that can load but not save were being serialized | Fixed (now requires both `CanSave` and `CanLoad`) |
| Compilation errors were silently dropped, leaving script sources blank | Fixed via `SaveCompilationErrors` |

### Executor Compatibility

| Executor | Improvement |
|---|---|
| **Nihon** | Special handling: `gethiddenproperty` is restricted to BinaryString and SharedString types only, preventing crashes on other NotScriptable properties |
| **Velocity** | `IgnoreSpecialStrings` and `IgnoreSpecialClassProperties` are auto-enabled to prevent hangs |
| **Xeno / Zorara / Solara** | `TreatUnionsAsParts` enabled by default to avoid invisible geometry |
| **Wave / Zenith / Swift / Potassium / Volcano / Codex / Nihon** | `IgnoreSharedStrings` is disabled by default for these executors (they handle SharedStrings correctly), while remaining enabled for all others |
| **WRD / Xeno / Zorara** | `AlternativeWritefile` disabled for these, as their `appendfile` implementations are incompatible with the segment-write approach |
| **SirHurt / Volt** | `hookfunction` is skipped during `KillAllScripts` to avoid breaking executor internals |

### Performance

- All `PropertyReadCache`, `PropertySpecialCache`, `PropertyGHPFFailed`, and `PropertyFallbackFailed` caches are properly scoped and reset between save calls, preventing stale state from affecting subsequent runs.
- `gethiddenproperty_fallback` is initialized eagerly rather than lazily when `DisableGethiddenpropertyFallback = false`, reducing cold-path overhead.
- `benchmark()` now runs across three `base64encode` candidates (executor built-in, rbxcrypt, EncodingService) and selects the fastest one at runtime.

---

## Loadstring

```lua
local Params = {
    RepoURL = "https://raw.githubusercontent.com/henrq-crdso/ImprovedUniversalSynSaveInstance/main/",
    SSI = "saveinstance",
}

local synsaveinstance = loadstring(
    game:HttpGet(Params.RepoURL .. Params.SSI .. ".luau", true), Params.SSI)()

local Options = { SafeMode = false, Decompile = true }
synsaveinstance(Options)
```

---

## Options Reference

All option names are **case-insensitive**. Pass any combination in the options table.

### Execution & Safety

| Option | Default | Description |
|---|---|---|
| `__DEBUG_MODE` | `false` | Print debug logs for unusual scenarios |
| `Crashlog` | `false` | Write a detailed crash log to disk (requires `writefile` + `appendfile`) |
| `ReadMe` | `true` | Include auxiliary readme file when supported |
| `SafeMode` | `true` | Run a protection flow before saving |
| `KillAllScripts` | `true` | Stop all scripts during the save process |
| `BoostFPS` | `false` | Reduce visual load during export for better performance |
| `ShutdownWhenDone` | `false` | Close/shutdown the environment when finished |
| `AntiIdle` | `true` | Prevent idle disconnection during long saves |
| `ShowStatus` | `true` | Show live progress during the save |

### File & Mode

| Option | Default | Description |
|---|---|---|
| `mode` | `"optimized"` | Save mode: `full`, `optimized`, `scripts`, a table of service names, or any invalid string to save only `ExtraInstances` |
| `FilePath` | `false` | Output file name or path (no extension needed) |
| `AvoidFileOverwrite` | `true` | Skip save if a file with the same name already exists |
| `Callback` | `false` | Send serialized data to a function instead of writing to disk |
| `SaveCacheInterval` | `0x1600 * 10` | How often the cache is flushed during saving |
| `AlternativeWritefile` | `true` | Split file writes using `appendfile` when available |

### Scripts

| Option | Default | Description |
|---|---|---|
| `Decompile` | `true` | Attempt to decompile scripts when environment allows |
| `decomptype` | `""` | Decompiler type. Set to `"custom"` to load the bundled Konstant Decompiler |
| `scriptcache` | `true` | Reuse cache for duplicate scripts |
| `DecompileTimeout` | `10` | Per-script decompile time limit (seconds) |
| `DecompileJobless` | `false` | Include already-available bytecode without spawning new jobs |
| `SaveBytecode` | `false` | Include raw bytecode in output when supported |
| `SaveBytecodeIfDecompilerFails` | `false` | Include bytecode only when decompilation fails |
| `SaveCompilationErrors` | `true` | Include compilation error messages in output instead of blank source |
| `DecompileIgnore` | `{TextChatService}` | Classes or instances to skip during decompile |
| `IgnorePropertiesOfNotScriptsOnScriptsMode` | `false` | In `scripts` mode, skip non-script object properties |

### Instances & Filters

| Option | Default | Description |
|---|---|---|
| `IgnoreList` | `{CoreGui, CorePackages}` | Exclude instances by reference, ClassName, or ClassName + Name |
| `ExtraInstances` | `{}` | Additional instances to include in the save |
| `IgnoreProperties` | `{}` | Property names to exclude from all instances |
| `Object` | `false` | Save a specific instance as a model or place |
| `IsModel` | `false` | When using `Object`, output as a `.rbxmx` model |
| `NilInstances` | `false` | Include parented-to-nil instances when accessible |
| `NilInstancesFixes` | `table` | Per-class fixes for nil instances |
| `IgnoreDefaultProperties` | `true` | Skip properties that match their default value |
| `IgnoreNotArchivable` | `true` | Save instances even when `Archivable = false` |
| `IgnoreSpecialProperties` | `false` | Avoid calling special properties; use fallback values instead |
| `IgnoreSpecialStrings` | executor-dependent | Skip NotScriptable string properties (auto-enabled on Velocity) |
| `IgnoreSpecialClassProperties` | executor-dependent | Skip NotScriptable Class-category properties (auto-enabled on Velocity) |

### Players & Isolation

| Option | Default | Description |
|---|---|---|
| `IsolateStarterPlayer` | `false` | Save StarterPlayer into a separate folder |
| `IsolatePlayers` | `false` | Save Players service into a separate folder |
| `IsolateLocalPlayer` | `false` | Save LocalPlayer into a separate folder |
| `IsolateLocalPlayerCharacter` | `false` | Save LocalPlayer.Character separately |
| `SavePlayerCharacters` | `false` | Control whether player characters are included |
| `IgnoreDefaultPlayerScripts` | `true` | Ignore default player scripts to prevent crashes |

### Attributes & Compatibility

| Option | Default | Description |
|---|---|---|
| `SaveAsAttributes` | `false` | Save non-serializable (NotSaveable) properties as Attributes on each instance |
| `SavePropsAsAttributesForNotCreatableFixes` | `false` | Also save original properties as Attributes when using NotCreatableFixes |
| `SaveNotCreatable` | `false` | Include non-serializable instances as Folder substitutes |
| `NotCreatableFixes` | `table` | Map non-creatable classes to replacement classes |
| `IgnoreSharedStrings` | executor-dependent | Skip SharedStrings to avoid crashes (disabled for executors that handle them correctly) |
| `SharedStringOverwrite` | `false` | Allow overwriting SharedStrings to reduce output size |
| `TreatUnionsAsParts` | executor-dependent | Convert UnionOperations to Parts (auto-enabled on Solara, Xeno, Zorara) |
| `DisableGethiddenpropertyFallback` | executor-dependent | Disable the UGCValidationService fallback for reading special properties |
| `Anonymous` | `false` | Scrub identifying data (Name, UserId) from the final file |

---

## Aliases

Aliases are resolved before options. Some invert boolean values.

### Standard Aliases

| Alias | Resolves to |
|---|---|
| `timeout` | `DecompileTimeout` |
| `FileName` | `FilePath` |
| `IgnoreArchivable` | `IgnoreNotArchivable` |
| `IgnoreDefaultProps` | `IgnoreDefaultProperties` |
| `InstancesBlacklist` | `IgnoreList` |
| `SaveLocalPlayer` | `IsolateLocalPlayer` |
| `IsolatePlayerGui` | `IsolateLocalPlayer` |
| `SavePlayerGui` | `IsolateLocalPlayer` |
| `SavePlayers` | `IsolatePlayers` |
| `SaveNonCreatable` | `SaveNotCreatable` |
| `SaveCharacters` | `SavePlayerCharacters` |

### Inverse Aliases (inverts the boolean)

| Alias | Resolves to |
|---|---|
| `noscripts` | `Decompile` |
| `RemovePlayers` | `IsolatePlayers` |
| `RemovePlayerCharacters` | `SavePlayerCharacters` |

---

## Usage Examples

**Save the full game:**
```lua
local Options = { mode = "full", SafeMode = true }
```

**Save only scripts:**
```lua
local Options = { mode = "scripts", DecompileTimeout = 20 }
```

**Save a specific object:**
```lua
local Options = { Object = workspace, IsModel = true, FilePath = "WorkspaceExport", mode = "full" }
```

**Save a specific list of instances:**
```lua
synsaveinstance({
    workspace.Map,
    game.ReplicatedStorage.Assets,
}, {
    FilePath = "SelectedInstances",
    mode = "invalid",
    IsModel = true,
})
```

**Fast export with no decompile:**
```lua
local Options = { noscripts = true, SafeMode = false, BoostFPS = true, FilePath = "FastExport" }
```

**Save non-serializable properties as Attributes (for inspection in Studio):**
```lua
local Options = { SaveAsAttributes = true, mode = "full" }
```

**Enable crash logging for debugging:**
```lua
local Options = { Crashlog = true, __DEBUG_MODE = true }
```

**Use Konstant Decompiler on an executor without a native decompiler:**
```lua
local Options = { decomptype = "custom", DecompileTimeout = 30 }
```

---

## Credits

- **Original Project:** [luau/UniversalSynSaveInstance](https://github.com/luau/UniversalSynSaveInstance) — The foundation of this revival tool.
- **Decompiler Support:** Special thanks to **plugiant5** for providing essential decompiler logic.
- **Konstant Decompiler:** Credits to **daily3014** and **XoifaiI** for the Base64 implementation, and the Konstant team.
- **Fork Maintainer:** henrq-crdso — Focused on performance optimization, API refinement, and executor compatibility.

---

## License

This project is licensed under the GNU Affero General Public License v3.0 (AGPL-3.0).
This license ensures that the software remains free and that any modifications or network-based implementations are also shared with the community. See the [LICENSE](./LICENSE) file for the full legal text.
