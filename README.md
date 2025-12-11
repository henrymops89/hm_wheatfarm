# 🌾 Wheat Farm System for QBox

A comprehensive and feature-rich wheat farming system for FiveM servers running QBox framework. Players can manually or automatically farm wheat with realistic mechanics, durability systems, and multi-language support.

![Version](https://img.shields.io/badge/version-1.0.0-blue)
![Framework](https://img.shields.io/badge/framework-QBox-purple)
![License](https://img.shields.io/badge/license-MIT-green)

## ✨ Features

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

## 📋 Requirements

- [QBox Framework](https://github.com/Qbox-project/qbx_core)
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

4. **Configure** `config.lua` to your preferences
5. **Add** to `server.cfg`:
```cfg
ensure ox_lib
ensure ox_inventory
ensure qbx_core
ensure wheat_farm
```
6. **Restart** your server

## ⚙️ Configuration

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

### Animations
```lua
Config.Animation = "shovel"  -- Options: "plant", "dig", "shovel", "hammer"
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

## 📸 Screenshots

*Add your screenshots here*

## 🐛 Known Issues

None currently. Report issues on GitHub!

## 📝 Changelog

### Version 1.0.0 (2024-12-11)
- Initial release
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

- **Framework**: [QBox Project](https://qbox.re)
- **Libraries**: [Overextended (ox_lib, ox_inventory)](https://github.com/overextended)
- **Developer**: [Your Name]

## ⭐ Show Your Support

If you like this resource, please give it a star on GitHub!

---

Made with ❤️ for the FiveM community
```

## 📋 **Zusätzliche Dateien für GitHub:**

### **LICENSE (MIT)**
```
MIT License

Copyright (c) 2024 [Your Name]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

### **.gitignore**
```
# FiveM
stream/**/*.cache
cache/

# OS
.DS_Store
Thumbs.db

# IDE
.vscode/
.idea/
*.code-workspace
