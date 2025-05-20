# Getting Started

UID is a unique identifier (UID) generator for Roblox, supporting multiple formats and high-performance randomization. This guide will help you install, set up, and use UID in your Roblox projects.

## Installation

1. **Via Wally** (recommended):
   - Add UID to your `wally.toml` dependencies:
     ```toml
     [dependencies]
     UID = "<your-namespace>/UID@<version>"
     ```
   - Run `wally install` to fetch the package.

2. **Manual Installation:**
   - Download the `src/init.luau` file and place it in your project (e.g., under `ReplicatedStorage/Modules/UID.luau`).

## Usage

### Importing UID

```lua
local UID = require(path.to.UID)
```

### Creating a UID Generator Instance

You can create a new UID generator with an optional seed:

```lua
local uidGen = UID.new() -- or UID.new(12345)
```

### Generating UIDs

UID supports several formats:

- **GUID** (128-bit, standard format)
- **Hex** (custom length)
- **Base64URL** (custom length)
- **Base94JSONSAFE** (custom length)
- **Base256ASCII** (custom length)

#### Generate a GUID
```lua
local guid = UID.guid()
print(guid) -- e.g., "b3e1c2d4-5f6a-7b8c-9d0e-1f2a3b4c5d6e"
```

#### Generate a Hex UID
```lua
local hex = uidGen:NextHex(16) -- 16 hex characters
print(hex)
```

#### Generate a Base64URL UID
```lua
local base64url = uidGen:NextBase64URL(16)
print(base64url)
```

#### Generate a Base94JSONSAFE UID
```lua
local base94 = uidGen:NextBase94JSONSAFE(16)
print(base94)
```

#### Generate a Base256ASCII UID
```lua
local base256 = uidGen:NextBase256ASCII(16)
print(base256)
```

### Validating UIDs

You can check if a UID string matches a specific format:

```lua
local isHex = UID.isbase(hex, "Hex")
local isGuid = UID.isbase(guid, "GUID")
```

### Cloning a UID Generator

```lua
local clone = uidGen:Clone()
```

## API Reference

See the [API documentation](./API.md) for detailed descriptions of all methods and types.

---

For more information, see the [intro](./intro.md) or the [Moonwave documentation](https://eryn.io/moonwave/docs/intro).