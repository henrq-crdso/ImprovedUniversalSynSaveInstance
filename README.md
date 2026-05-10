# ImprovedUniversalSynSaveInstance

> A passion-driven, faster fork of [UniversalSynSaveInstance](https://github.com/luau/UniversalSynSaveInstance) — the universal saveinstance revival, running smoother than ever. Also doubles as a fully editable Roblox Format File writer.

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

## Quick Start

Minimal setup — just paste and run:

```lua
local Params = {
    RepoURL = "https://raw.githubusercontent.com/henrq-crdso/ImprovedUniversalSynSaveInstance/main/",
    SSI = "saveinstance",
}
local synsaveinstance = loadstring(game:HttpGet(Params.RepoURL .. Params.SSI .. ".luau", true), Params.SSI)()

local Options = { SafeMode = true, Decompile = true, mode = "optimized" }
synsaveinstance(Options)
```

---

## Options Reference

All option names are **case-insensitive**. Pass any combination in the options table.

### Execution & Safety

| Option | Default | Description |
|---|---|---|
| `__DEBUG_MODE` | `false` | Print debug logs for unusual scenarios |
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
| `mode` | `"optimized"` | Save mode: `full`, `optimized`, or `scripts`. Use any invalid string to save only `ExtraInstances` |
| `FilePath` | `false` | Output file name or path (no extension needed) |
| `AvoidFileOverwrite` | `true` | Skip save if a file with the same name already exists |
| `Callback` | `false` | Send serialized data to a function instead of writing to disk |
| `SaveCacheInterval` | `0x1600 * 10` | How often the cache is flushed during saving |
| `AlternativeWritefile` | `true` | Split file writes using `appendfile` when available |

### Scripts

| Option | Default | Description |
|---|---|---|
| `Decompile` | `true` | Attempt to decompile scripts when environment allows |
| `scriptcache` | `true` | Reuse cache for duplicate scripts |
| `DecompileTimeout` | `10` | Per-script decompile time limit (seconds) |
| `DecompileJobless` | `false` | Include already-available bytecode without spawning new jobs |
| `SaveBytecode` | `false` | Include raw bytecode in output when supported |
| `DecompileIgnore` | `{TextChatService}` | Classes or instances to skip during decompile |
| `IgnorePropertiesOfNotScriptsOnScriptsMode` | `false` | In `scripts` mode, skip non-script object properties |

### Instances & Filters

| Option | Default | Description |
|---|---|---|
| `IgnoreList` | `{CoreGui, CorePackages}` | Exclude instances by reference, ClassName, or ClassName + Name |
| `ExtraInstances` | `{}` | Additional instances to include in the save |
| `IgnoreProperties` | `{}` | Property names to exclude from all instances |
| `Object` | `false` | Save a specific instance as a model or place |
| `IsModel` | `false` | When using `Object`, output as a `.rbxm` model |
| `NilInstances` | `false` | Include parented-to-nil instances when accessible |
| `NilInstancesFixes` | `table` | Per-class fixes for nil instances |
| `IgnoreDefaultProperties` | `true` | Skip properties that match their default value |
| `IgnoreNotArchivable` | `true` | Save instances even when `Archivable = false` |
| `IgnoreSpecialProperties` | `false` | Avoid calling special properties; use fallback values instead |

### Players & Isolation

| Option | Default | Description |
|---|---|---|
| `IsolateStarterPlayer` | `false` | Save StarterPlayer into a separate folder |
| `IsolatePlayers` | `false` | Save Players service into a separate folder |
| `IsolateLocalPlayer` | `false` | Save LocalPlayer into a separate folder |
| `IsolateLocalPlayerCharacter` | `false` | Save LocalPlayer.Character separately |
| `SavePlayerCharacters` | `false` | Control whether player characters are included |
| `IgnoreDefaultPlayerScripts` | `true` | Ignore default player scripts to prevent crashes |

### Compatibility

| Option | Default | Description |
|---|---|---|
| `SaveNotCreatable` | `false` | Include non-serializable instances as Folder substitutes |
| `NotCreatableFixes` | `table` | Map non-creatable classes to replacement classes |
| `IgnoreSharedStrings` | `true` | Skip SharedStrings to avoid crashes in some environments |
| `SharedStringOverwrite` | `false` | Allow overwriting SharedStrings to reduce output size |
| `TreatUnionsAsParts` | `false` | Convert UnionOperations to Parts when union reading fails |
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
local Options = {
    workspace.Map,
    game.ReplicatedStorage.Assets,
}, {
    FilePath = "SelectedInstances",
    mode = "invalid", -- invalid mode = only ExtraInstances
    IsModel = true,
}
```

**Fast export with no decompile:**
```lua
local Options = { noscripts = true, SafeMode = false, BoostFPS = true, FilePath = "FastExport" }
```

---

## Credits

- **Original author:** [luau/UniversalSynSaveInstance](https://github.com/luau/UniversalSynSaveInstance) ❤️ — an incredible tool for the Roblox community
- **Thank you plugiant5 to make an incredible decompiler for us too ❤️**
- **This fork:** improved performance, cleaner option handling, and expanded documentation

---

## License

MIT — see [LICENSE](./LICENSE) for details.
