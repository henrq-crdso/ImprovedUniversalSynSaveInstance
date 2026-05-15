# ImprovedUniversalSynSaveInstance

> A passion-driven, faster fork of [UniversalSynSaveInstance](https://github.com/luau/UniversalSynSaveInstance) — the universal saveinstance revival, running smoother than ever. Also doubles as a fully editable Roblox Format File writer.

[![USSI License](https://img.shields.io/badge/USSI-License-green)](https://github.com/luau/UniversalSynSaveInstance/blob/main/LICENSE)

---

## Key Improvements in this Fork

This fork significantly extends the original project with advanced features and better executor compatibility.

### Exclusive Features
| Feature | Description |
|---|---|
| **SaveAsAttributes** | Saves non-serializable properties as Roblox Attributes, making them visible in Studio. |
| **Crashlog** | Writes a per-step log to disk using `appendfile` for easier debugging. |
| **Konstant Integration** | Use decomptype = "custom" if your executor don't have an native decompiler. |
| **Bytecode Fallback** | `SaveBytecodeIfDecompilerFails` ensures script data is preserved as raw bytecode when decompilation fails. |
| **Custom Mode** | The `mode` option now accepts a table of service names for precise control. |

### Executor Compatibility
Auto-configures settings for specific executors to prevent crashes and improve output:
- **Velocity**: `IgnoreSpecialStrings` enabled to prevent hangs.
- **Xeno / Zorara / Solara**: `TreatUnionsAsParts` enabled to fix invisible geometry.
- **Nihon**: Restricted `gethiddenproperty` usage to prevent crashes.
- **Wave / Zenith / Codex**: Optimized `SharedStrings` handling.

---

## Quick Start

```lua
local Params = {
  RepoURL = "https://raw.githubusercontent.com/henrq-crdso/ImprovedUniversalSynSaveInstance/refs/heads/main/",
  SSI = "saveinstance",
}

local synsaveinstance = loadstring(
  game:HttpGet(Params.RepoURL .. Params.SSI .. ".luau", true), Params.SSI)()

local Options = { SafeMode = false, Decompile = true, decomptype = "custom", SaveBytecode = true }

synsaveinstance(Options)
```

---

## Options Reference (see https://henrq-crdso.github.io for more details.)

| Option | Default | Description |
|---|---|---|
| `mode` | `"optimized"` | `full`, `optimized`, `scripts`, or a `{ServiceNames}` table. |
| `SaveAsAttributes` | `false` | Save non-saveable properties as Attributes. |
| `Crashlog` | `false` | Write detailed step-by-step logs to disk. |
| `Decompile` | `true` | Attempt script decompilation. |
| `decomptype` | `""` | Set to `"custom"` to force Konstant Decompiler. |
| `SaveBytecodeIfDecompilerFails` | `false` | Fallback to bytecode if decompiler fails. |
| `BoostFPS` | `false` | Reduce visual load during export. |
| `IgnoreSpecialStrings` | `dynamic` | Skip problematic NotScriptable strings. |
| `FilePath` | `false` | Custom output filename (no extension). |

---

## Aliases
Convenient shortcuts that resolve before options:
- `timeout` → `DecompileTimeout`
- `FileName` → `FilePath`
- `IgnoreArchivable` → `IgnoreNotArchivable`
- `SavePlayers` → `IsolatePlayers`
- `noscripts` → `Decompile = false`

---

## Credits

- **Original Project:** [luau/UniversalSynSaveInstance](https://github.com/luau/UniversalSynSaveInstance) — The foundation of this revival tool.
- **Konstant Decompiler:** Special thanks to **plugiant5** for providing essential decompiler logic.
- **Fork Maintainer:** henrq-crdso — Focused on performance optimization, API refinement, and executor compatibility.

---

## License

This project is licensed under the GNU Affero General Public License v3.0 (AGPL-3.0).
This license ensures that the software remains free and that any modifications or network-based implementations are also shared with the community. See the [LICENSE](./LICENSE) file for the full legal text.
