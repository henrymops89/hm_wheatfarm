# 🌾 HM Wheat Farm

[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/henrymops89/hm_wheatfarm/releases)
[![Framework](https://img.shields.io/badge/framework-Multi--Framework-purple.svg)](https://github.com/henrymops89/hm_wheatfarm)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![ox_lib](https://img.shields.io/badge/ox__lib-required-red.svg)](https://github.com/overextended/ox_lib)

> A feature-rich, optimized wheat farming system for FiveM servers. Supports **QBox (Native)**, **QBCore**, and **ESX Legacy** with automatic framework detection, multi-language support, and advanced features.

---

## ✨ Features

### 🎮 **Dual Farming Modes**
- **Manual Mode** - Press `E` to farm wheat with higher yield (1-3 wheat)
- **Auto-Farm Mode** - Press `G` to activate automatic farming with cooldown progressbar (1-2 wheat)

### 🌍 **Multi-Framework Support**
- ✅ **QBox** - Native Exports (no bridge required!)
- ✅ **QBCore** - Full compatibility
- ✅ **ESX Legacy** - Complete support with dynamic import
- ✅ **Auto-Detection** - Automatically detects your framework

### 🛠️ **Advanced Tool System**
- **Durability Mode** - Tools degrade with use (100 uses + 5% break chance)
- **Permanent Mode** - Buy once, use forever
- Client & server-side validation

### 🎨 **Rich User Experience**
- 4 different farming animations with props
- ox_lib TextUI integration with smart hide/show
- Progressbars with cancel instructions
- Field-leave & death detection
- Instant input response (0.00-0.01ms)

### 🌐 **Multi-Language Support**
6 fully translated languages:
- 🇩🇪 German (Deutsch)
- 🇬🇧 English
- 🇫🇷 French (Français)
- 🇪🇸 Spanish (Español)
- 🇵🇱 Polish (Polski)
- 🇹🇷 Turkish (Türkçe)

### 📦 **Inventory Compatibility**
- ox_inventory (with metadata support) ✅
- qs-inventory (Quasar Advanced Inventory) ✅
- qs-inventory

### 🔒 **Security Features**
- Rate limiting (Anti-Spam)
- Server-side cooldown enforcement
- Distance validation with tolerance
- Tool verification (client & server)
- Optional kick on exploit detection

### ⚡ **Performance Optimized**
- **0.00-0.01ms** resmon when in field
- **0.00ms** when outside field
- Separate threads for markers & interactions
- Smart throttling system
- Optional marker disable for maximum performance

---

## 📋 Requirements

**Framework** (choose one):
- [QBox Framework](https://github.com/Qbox-project/qbx_core) OR
- [QBCore Framework](https://github.com/qbcore-framework) OR
- [ESX Legacy](https://github.com/esx-framework/esx_core)

**Dependencies:**
- [ox_lib](https://github.com/overextended/ox_lib) (required)
- [ox_inventory](https://github.com/overextended/ox_inventory) OR [qs-inventory](https://quasar-store.com)

---

## 🚀 Installation

### 1. Download & Extract
```bash
cd resources
git clone https://github.com/henrymops89/hm_wheatfarm.git
```

### 2. Add Items to Inventory

#### For ox_inventory (`ox_inventory/data/items.lua`):
```lua
['hoe'] = {
    label = 'Hoe',
    weight = 1000,
    stack = false,
    close = true,
    description = 'A farming hoe with 100 uses',
},

['wheat'] = {
    label = 'Wheat',
    weight = 100,
    stack = true,
    close = true,
    description = 'Freshly harvested wheat',
}
```

#### For qs-inventory (`qs-inventory/shared/items.lua`):
```lua
['hoe'] = {
    name = 'hoe',
    label = 'Hoe',
    weight = 1000,
    type = 'item',
    image = 'hoe.png',
    unique = false,
    useable = false,
    shouldClose = true,
    description = 'A farming hoe with durability system',
},

['wheat'] = {
    name = 'wheat',
    label = 'Wheat',
    weight = 100,
    type = 'item',
    image = 'wheat.png',
    unique = false,
    useable = false,
    shouldClose = true,
    description = 'Freshly harvested wheat',
}
```

### 3. Configure (Optional)
Edit `config.lua` to customize:
- Field location & radius
- Tool settings (durability/permanent)
- Farming yields & cooldowns
- Language & inventory system
- Security settings

### 4. Add to server.cfg

**For QBox:**
```cfg
ensure ox_lib
ensure ox_inventory
ensure qbx_core
ensure hm_wheatfarm
```

**For QBCore:**
```cfg
ensure ox_lib
ensure ox_inventory
ensure qb-core
ensure hm_wheatfarm
```

**For ESX:**
```cfg
ensure ox_lib
ensure ox_inventory
ensure es_extended
ensure hm_wheatfarm
```

### 5. Restart Server
```bash
restart hm_wheatfarm
```

---

## ⚙️ Configuration

### Framework Selection
```lua
Config.Framework = "auto"  -- Auto-detect (recommended)
-- Or manually: "QBox", "QBCore", "ESX"
```

### Inventory System
```lua
Config.Inventory = "auto"  -- Auto-detect (recommended)
-- Or manually: "ox_inventory", "qs-inventory"
```

### Language
```lua
Config.Language = "en"  -- de, en, fr, es, pl, tr
```

### Inventory System
```lua
Config.Inventory = "auto"  -- "auto" (recommended), "ox_inventory" or "qs-inventory"
```

**Auto-detection:**
- Automatically detects ox_inventory or qs-inventory
- No manual configuration needed
- Fallback to ox_inventory if neither found

**Manual override:**
```lua
Config.Inventory = "ox_inventory"  -- Force ox_inventory
Config.Inventory = "qs-inventory"  -- Force qs-inventory
```

### Field Location
```lua
Config.FieldLocation = vector3(2229.68, 5577.36, 53.85)
Config.FieldRadius = 2.0  -- 2 meter radius
```

### Tool System
```lua
Config.RequiredTool = {
    enabled = true,
    item = "hoe",
    toolType = "durability",  -- "durability" or "permanent"
    durabilityPerUse = 1,
    maxDurability = 100,
    breakChance = 5,  -- 5% chance per use
}
```

### Farming Yields
```lua
-- Manual Mode (E key)
Config.MinWheatPerPlow = 1
Config.MaxWheatPerPlow = 3

-- Auto-Farm Mode (G key)
Config.AutoFarm = {
    enabled = true,
    minWheat = 1,
    maxWheat = 2,  -- Lower yield than manual
    cooldown = 8000,  -- 8 seconds
}
```

### Performance Options
```lua
Config.ShowMarker = true  -- Set to false for 0.00ms guaranteed
```

---

## 🎮 How to Use

### Manual Farming
1. Go to the wheat field (marked on map)
2. Stand within the marker (2m radius)
3. Press **E** to start farming
4. Wait 5 seconds (progressbar shows)
5. Press **E** again to cancel (optional)
6. Receive 1-3 wheat

### Auto-Farm Mode
1. Stand in the field
2. Press **G** to activate auto-farm
3. Farming repeats automatically every 8 seconds
4. Cooldown progressbar shows between farms
5. Press **G** anytime to stop
6. Lower yield (1-2 wheat) than manual mode

### Controls
| Key | Action | Context |
|-----|--------|---------|
| **E** | Start/Cancel Manual Farming | In field |
| **G** | Toggle Auto-Farm | In field |
| **G** | Cancel during cooldown | Auto-Farm active |

---

## 🔧 Framework-Specific Notes

### QBox (Native Exports)
```lua
-- ✅ CORRECT - Uses native QBox exports
local player = exports.qbx_core:GetPlayer(source)
exports.qbx_core:Notify(source, text, type)

-- ❌ WRONG - Don't use GetCoreObject() for QBox
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
-- ✅ Dynamic ESX import (no manual fxmanifest edit needed)
-- Automatically loads via exports['es_extended']:getSharedObject()
```

---

## 📊 Performance

### Resmon Results
```
Outside field: 0.00ms
In field (with marker): 0.00-0.01ms
In field (without marker): 0.00ms
```

### Optimizations
- Separate threads for marker rendering & interaction logic
- Smart throttling (distance checks every 200ms)
- Instant input detection (Wait(0) for key checks)
- Optional marker disable for maximum performance

---

## 🐛 Troubleshooting

### Script doesn't start
**Check:**
1. ox_lib is installed and started before hm_wheatfarm
2. Framework resource is running
3. Console for error messages

### Framework not detected
**Solution:**
```lua
-- In config.lua, set manually:
Config.Framework = "QBox"  -- or "QBCore" or "ESX"
```

### Notifications not showing
**Check:**
1. ox_lib is properly installed
2. Framework exports are working

### Tool not working
**Check:**
1. Item name matches `Config.RequiredTool.item`
2. Inventory system setting is correct
3. Item exists in inventory database

---

## 📝 Changelog

### [1.0.0] - 2024-12-12
**Initial Release**

#### Features
- ✨ Multi-Framework support (QBox Native, QBCore, ESX)
- ✨ Manual & Auto-Farm modes
- ✨ Dual tool system (durability/permanent)
- ✨ Multi-language support (6 languages)
- ✨ Performance optimized (0.00-0.01ms)
- ✨ Security system (rate limiting, distance validation)
- ✨ TextUI management (smart hide/show)
- ✨ Cancel functionality in progressbar
- ✨ 4 farming animations with props

#### Technical
- QBox uses native exports (no GetCoreObject)
- ESX dynamic import (no manual fxmanifest edit)
- Separate threads for optimal performance
- Universal helper functions for all frameworks

---

## 🤝 Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 💬 Support

- **Issues**: [GitHub Issues](https://github.com/henrymops89/hm_wheatfarm/issues)
- **Wiki**: [Documentation](https://github.com/henrymops89/hm_wheatfarm/wiki)

---

## 🙏 Credits

**Frameworks:**
- [QBox Project](https://qbox.re) - QBox Framework
- [QBCore Team](https://qbcore.org) - QBCore Framework
- [ESX Team](https://esx-framework.org) - ESX Legacy

**Libraries:**
- [Overextended](https://github.com/overextended) - ox_lib, ox_inventory

**Developer:**
- [henrymops89](https://github.com/henrymops89)

---

## ⭐ Show Your Support

If you like this resource, please give it a star on GitHub! It helps others find the project.

---

<div align="center">

**Made with ❤️ for the FiveM Community**

[⬆ Back to Top](#-hm-wheat-farm)

</div>
