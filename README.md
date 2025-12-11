# 🌾 Wheat Farm System - Multi-Framework

A comprehensive and feature-rich wheat farming system for FiveM servers. Supports **QBox (Native!)**, **QBCore**, and **ESX Legacy** frameworks with realistic mechanics, durability systems, and multi-language support.

![Version](https://img.shields.io/badge/version-2.0.0-blue)
![Framework](https://img.shields.io/badge/framework-Multi--Framework-purple)
![License](https://img.shields.io/badge/license-MIT-green)

## ✨ Features

### 🎯 Multi-Framework Support
- ✅ **QBox** (Native Exports - No Bridge!)
- ✅ **QBCore** (Full Support)
- ✅ **ESX Legacy** (Full Support)
- ✅ **Auto-Detection** or manual configuration

### 🎮 Farming Mechanics
- **Manual Farming** - Press `E` to farm wheat (1-3 yield)
- **Auto-Farm Mode** - Press `G` to activate automatic farming (1-2 yield, lower output)
- **Configurable Cooldowns** - Adjustable timings for balanced gameplay
- **2-Meter Precision** - Stand exactly at the marker to farm

### 🛠️ Tool System (Dual Mode)
Choose between two tool modes in config:
- **Durability Mode** (Option 1): Tools degrade with use and break after 100 uses + 5% break chance
- **Permanent Mode** (Option 3): Buy once, use forever
- Client-side and server-side validation to prevent exploits

### 🎭 Animations & Props
4 different farming animations with realistic props:
- **Plant** - Gardening with shovel
- **Dig** - Digging with pickaxe
- **Shovel** - Shoveling action
- **Hammer** - Sledgehammer ground work

### 🌍 Multi-Language Support
Fully translated in 6 languages:
- 🇩🇪 German (Deutsch)
- 🇬🇧 English
- 🇫🇷 French (Français)
- 🇪🇸 Spanish (Español)
- 🇵🇱 Polish (Polski)
- 🇹🇷 Turkish (Türkçe)

### 📦 Inventory Support
Compatible with multiple inventory systems:
- ✅ ox_inventory (with metadata support)
- ✅ qs-inventory

### 🎨 Visual Features
- Customizable marker and blip
- ox_lib TextUI integration
- ox_lib Progress Bar with animations
- Field-leave detection (auto-cancel)
- Death protection (no ghost farming)

### 🔒 Security Features
- Rate limiting (Anti-Spam)
- Server-side cooldown enforcement
- Distance validation
- Tool verification
- Optional kick on exploit detection

## 📋 Requirements

**Choose your Framework:**
- [QBox Framework](https://github.com/Qbox-project/qbx_core) **OR**
- [QBCore Framework](https://github.com/qbcore-framework) **OR**
- [ESX Legacy](https://github.com/esx-framework/esx_core)

**Additional:**
- [ox_lib](https://github.com/overextended/ox_lib)
- [ox_inventory](https://github.com/overextended/ox_inventory) **OR** [qs-inventory](https://github.com/qbcore-framework/qs-inventory)

## 🚀 Installation

1. **Download** the latest release
2. **Extract** `wheat_farm` to your resources folder
3. **Add items** to your inventory:

### For ox_inventory (`ox_inventory/data/items.lua`):
```lua
-- Option 1: Durability Tool
['hoe'] = {
    label = 'Hoe',
    weight = 1000,
    stack = false,
    close = true,
    description = 'A farming hoe with 100 uses. Can break!',
},

-- Option 3: Permanent Tool
['farming_tool'] = {
    label = 'Farming Tool',
    weight = 2000,
    stack = false,
    close = true,
    description = 'Professional farming tool. Never breaks!',
},

-- Wheat item
['wheat'] = {
    label = 'Wheat',
    weight = 100,
    stack = true,
    close = true,
    description = 'Freshly harvested wheat',
}
```

### For qs-inventory:
Add the same items to your shared items configuration.

4. **Configure** `config.lua` to your preferences
5. **Add** to `server.cfg`:

**For QBox:**
```cfg
ensure ox_lib
ensure ox_inventory
ensure qbx_core
ensure wheat_farm
```

**For QBCore:**
```cfg
ensure ox_lib
ensure ox_inventory  # or qs-inventory
ensure qb-core
ensure wheat_farm
```

**For ESX:**
```cfg
ensure ox_lib
ensure ox_inventory
ensure es_extended
ensure wheat_farm
```

6. **Restart** your server

## ⚙️ Configuration

### Framework Selection
```lua
-- Choose your framework
Config.Framework = "auto"  -- "auto", "QBox", "QBCore", "ESX"
-- "auto" automatically detects your framework (recommended)
```

### Basic Settings
```lua
-- Language
Config.Language = "de"  -- "de", "en", "fr", "es", "pl", "tr"

-- Inventory System
Config.Inventory = "ox_inventory"  -- "ox_inventory" or "qs-inventory"

-- Field Location (Change to your coordinates)
Config.FieldLocation = vector3(2229.68, 5577.36, 53.85)
Config.FieldRadius = 2.0  -- 2 meters
```

### Tool System
```lua
Config.RequiredTool = {
    enabled = true,
    item = "hoe",
    
    -- Choose tool type:
    toolType = "durability",  -- "durability" or "permanent"
    
    -- Only for "durability" mode:
    durabilityPerUse = 1,
    maxDurability = 100,
    breakChance = 5,  -- 5% chance to break per use
}
```

### Farming Modes
```lua
-- Manual Mode (E key)
Config.MinWheatPerPlow = 1
Config.MaxWheatPerPlow = 3

-- Auto-Farm Mode (G key)
Config.AutoFarm = {
    enabled = true,
    minWheat = 1,
    maxWheat = 2,  -- Lower yield than manual!
    cooldown = 8000,  -- 8 seconds between farms
}
```

### Security Settings
```lua
Config.Security = {
    enabled = true,
    maxRequestsPerMinute = 20,
    enforceCooldown = true,
    enforceDistance = true,
    kickOnRateLimit = false,  -- Set to true for strict enforcement
    kickOnDistanceExploit = false,
}
```

## 🎮 How to Use

### Manual Farming
1. Go to the wheat field (marked on map)
2. Stand within the marker (2m radius)
3. Press **E** to farm
4. Wait 5 seconds
5. Receive 1-3 wheat

### Auto-Farm Mode
1. Stand in the field
2. Press **G** to activate auto-farm
3. Farming will repeat automatically every 8 seconds
4. Press **G** again to stop
5. **Note**: Lower yield (1-2 wheat) than manual mode

## 🔧 Framework-Specific Notes

### QBox (Native Exports)
```lua
-- ✅ CORRECT - Uses native QBox exports
local player = exports.qbx_core:GetPlayer(source)
exports.qbx_core:Notify(source, text, type)

-- ❌ WRONG - Don't use GetCoreObject() for QBox!
local QBCore = exports['qbx_core']:GetCoreObject()
```

### QBCore
```lua
-- ✅ Standard QBCore methods
local QBCore = exports['qb-core']:GetCoreObject()
local Player = QBCore.Functions.GetPlayer(source)
```

### ESX Legacy
```lua
-- ✅ Modern ESX import method
local xPlayer = ESX.GetPlayerFromId(source)
```

## 📸 Screenshots

*Add your screenshots here*

## 🐛 Known Issues

None currently. Report issues on GitHub!

## 📝 Changelog

### Version 2.0.0 (2024-12-11)
- ✅ **Multi-Framework Support** (QBox Native, QBCore, ESX)
- ✅ **Fixed QBox Native Exports** (no GetCoreObject!)
- ✅ **Framework Auto-Detection**
- ✅ **Improved Security System**
- ✅ **Better Error Handling**

### Version 1.0.0 (2024-12-11)
- Initial release (QBox only)
- Manual and auto-farm modes
- Dual tool system (durability/permanent)
- Multi-language support (6 languages)
- Multi-inventory support
- Death and field-leave protection

## 🤝 Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 💬 Support

- **Discord**: [Your Discord Server]
- **Issues**: [GitHub Issues](https://github.com/yourusername/wheat_farm/issues)

## 🙏 Credits

- **Frameworks**: 
  - [QBox Project](https://qbox.re) - QBox Framework
  - [QBCore Team](https://qbcore.org) - QBCore Framework
  - [ESX Team](https://esx-framework.org) - ESX Legacy
- **Libraries**: [Overextended (ox_lib, ox_inventory)](https://github.com/overextended)
- **Developer**: [Your Name]

## ⭐ Show Your Support

If you like this resource, please give it a star on GitHub!

---

Made with ❤️ for the FiveM community

## 🔧 Troubleshooting

### QBox Issues
**Problem:** Script doesn't work on QBox
**Solution:** Make sure you're using QBox, not the QBCore bridge. The script uses native QBox exports.

### Framework Detection
**Problem:** Wrong framework detected
**Solution:** Set `Config.Framework` manually instead of using "auto"

### Notifications Not Showing
**Problem:** No notifications appear
**Solution:** Check if ox_lib is properly installed and started before wheat_farm

### Tool Not Working
**Problem:** Can't farm even with tool
**Solution:** 
1. Check if tool item name matches `Config.RequiredTool.item`
2. Verify inventory system is correctly set in config
3. Check server console for error messages

## 📚 API Documentation

### Events

#### Client Events
```lua
-- Notify success (triggered by server)
RegisterNetEvent('wheat:notifySuccess')
```

#### Server Events
```lua
-- Plow wheat (triggered by client)
RegisterNetEvent('wheat:plow', function(isAutoFarm))
```

### Exports

#### Server Exports
```lua
-- Check if player has tool (internal use)
local hasTool, slot = HasTool(source)

-- Add item to player
local success = AddItem(source, item, amount)

-- Remove item from player
local success = RemoveItem(source, item, amount)
```

## 🎯 Roadmap

- [ ] Multiple field locations
- [ ] Different crop types
- [ ] Farming levels/experience
- [ ] Special farming tools
- [ ] Weather effects on yield
- [ ] Seasonal variations
- [ ] Fertilizer system
- [ ] Crop quality system
```
