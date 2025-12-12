# Release Notes - v1.0.0

## 🎉 Initial Release

We're excited to announce the first stable release of HM Wheat Farm! This release brings a fully-featured, optimized wheat farming system with multi-framework support.

---

## ✨ Key Features

### Multi-Framework Support
- **QBox** - Native exports implementation (no bridge required)
- **QBCore** - Full compatibility with standard methods
- **ESX Legacy** - Complete support with dynamic import
- **Auto-Detection** - Automatically detects your framework

### Farming Modes
- **Manual Farming** - Press E for higher yield (1-3 wheat)
- **Auto-Farm** - Press G for automatic farming with cooldown (1-2 wheat)
- **Cancel Anytime** - Press the farming key again to cancel

### Tool System
- **Durability Mode** - Tools degrade with use (100 uses + 5% break chance)
- **Permanent Mode** - Buy once, use forever
- Full client & server validation

### User Experience
- 4 different farming animations with realistic props
- ox_lib TextUI with smart visibility management
- Progressbars showing cancel instructions
- Field-leave & death detection
- Instant input response

### Internationalization
- 6 fully translated languages (DE, EN, FR, ES, PL, TR)
- Easy to add more languages

### Performance
- **0.00-0.01ms** resmon in field
- **0.00ms** outside field
- Separate threads for optimal performance
- Optional marker disable for maximum performance

### Security
- Rate limiting (20 requests/minute)
- Server-side cooldown enforcement
- Distance validation with tolerance
- Tool verification on both sides
- Optional kick on exploit detection

---

## 📦 What's Included

- ✅ `client.lua` - Optimized client-side logic
- ✅ `server.lua` - Secure server-side handling
- ✅ `config.lua` - Extensive configuration options
- ✅ `fxmanifest.lua` - Resource manifest
- ✅ `locale.lua` - Locale system
- ✅ `locales/` - 6 language files (de, en, fr, es, pl, tr)
- ✅ `README.md` - Comprehensive documentation
- ✅ `LICENSE` - MIT License
- ✅ `CHANGELOG.md` - Version history

---

## 🚀 Installation

### Quick Start
```bash
# 1. Clone repository
cd resources
git clone https://github.com/henrymops89/hm_wheatfarm.git

# 2. Add items to inventory (see README)

# 3. Add to server.cfg
ensure ox_lib
ensure [your_framework]
ensure hm_wheatfarm

# 4. Restart server
restart hm_wheatfarm
```

### Requirements
- ox_lib
- One framework: QBox, QBCore, or ESX
- One inventory: ox_inventory or qs-inventory

---

## 🎯 Usage

### Manual Farming
1. Go to wheat field
2. Press **E** to farm
3. Press **E** again to cancel (optional)
4. Receive 1-3 wheat

### Auto-Farm
1. Press **G** to activate
2. Farming repeats automatically
3. Press **G** to stop anytime
4. Receive 1-2 wheat per cycle

---

## ⚙️ Configuration Highlights

```lua
-- Framework (auto-detect or manual)
Config.Framework = "auto"

-- Language support
Config.Language = "en"  -- de, en, fr, es, pl, tr

-- Field location
Config.FieldLocation = vector3(2229.68, 5577.36, 53.85)
Config.FieldRadius = 2.0

-- Tool system
Config.RequiredTool = {
    toolType = "durability",  -- or "permanent"
    maxDurability = 100,
    breakChance = 5,
}

-- Performance
Config.ShowMarker = true  -- false for 0.00ms guaranteed
```

---

## 🔧 Technical Highlights

### QBox Native Implementation
```lua
// ✅ Uses native QBox exports
local player = exports.qbx_core:GetPlayer(source)
exports.qbx_core:Notify(source, text, type)
```

### ESX Dynamic Import
```lua
// ✅ No manual fxmanifest edit needed
local success, ESX = pcall(function()
    return exports['es_extended']:getSharedObject()
end)
```

### Performance Optimization
- Separate marker & interaction threads
- Smart throttling (200ms distance checks)
- Instant key detection (Wait(0))
- Optional marker disable

---

## 📊 Benchmarks

| Scenario | Resmon | CPU |
|----------|--------|-----|
| Outside field | 0.00ms | 0.00 |
| In field (marker on) | 0.00-0.01ms | 0.02 |
| In field (marker off) | 0.00ms | 0.00 |

---

## 🐛 Known Issues

None! This is a stable release. If you find any issues, please report them on [GitHub Issues](https://github.com/henrymops89/hm_wheatfarm/issues).

---

## 🔮 Future Plans

- Multiple field locations
- Different crop types (corn, potatoes, etc.)
- Farming levels/experience system
- Weather effects on yield
- Seasonal variations
- Fertilizer system
- Quality system (poor/normal/excellent crops)

---

## 🙏 Thanks

Special thanks to:
- QBox, QBCore, and ESX teams for the frameworks
- Overextended for ox_lib and ox_inventory
- The FiveM community for feedback and support

---

## 📝 Upgrade Notes

This is the initial release - no upgrade needed!

---

## 💬 Support

Need help?
- **Documentation**: [README.md](README.md)
- **Issues**: [GitHub Issues](https://github.com/henrymops89/hm_wheatfarm/issues)
- **Wiki**: [GitHub Wiki](https://github.com/henrymops89/hm_wheatfarm/wiki)

---

## ⭐ Show Your Support

If you like this resource:
- ⭐ Star the repository
- 🐛 Report bugs
- 💡 Suggest features
- 🤝 Contribute code

---

**Download:** [v1.0.0](https://github.com/henrymops89/hm_wheatfarm/releases/tag/v1.0.0)

**Full Changelog:** [CHANGELOG.md](CHANGELOG.md)

---

Made with ❤️ for the FiveM Community
