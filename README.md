# 🌾 HM Wheat Farm v2.1.1

**Professional Multi-Framework Farming Economy System for FiveM**

[![Framework](https://img.shields.io/badge/Framework-QBox%20%7C%20QBCore%20%7C%20ESX-blue)](https://github.com/henrymops89/hm_wheatfarm)
[![Inventory](https://img.shields.io/badge/Inventory-ox__inventory%20%7C%20qb--inventory%20%7C%20tgiann--inventory%20%7C%20qs--inventory-green)](https://github.com/henrymops89/hm_wheatfarm)
[![Version](https://img.shields.io/badge/version-2.1.0-brightgreen)](https://github.com/henrymops89/hm_wheatfarm/releases)
[![License](https://img.shields.io/badge/license-Custom-red)](LICENSE)

---
## 🎉 VERSION 2.1.1 -

**NEW**🔥 Peak Hours Display

Bonus-Betrag wird jetzt angezeigt!
"Du hast $324 für 2x fries bekommen! + $74 (Peak Hours Bonus: +30%)"

### 🔄 Auto-Farm Continuous Loop

Farmt jetzt kontinuierlich bis gestoppt
Toggle mit [G]
Dynamic TextUI zeigt Status

### ⚡ Better UX

Keine Cooldowns mehr bei Verarbeitung/Verkauf
Marker richtig dimensioniert
Security Distance auf 12m erhöht

### 🔧 Critical Fixes

Server Inventory System komplett neu
Locale-Loading-Order gefixt
Tool Durability vereinfacht
wheat:notify Event-Handler hinzugefügt

### 🔍 Debug Logging

Comprehensive logging für Troubleshooting
Minimal Performance-Impact

## 🚀 What's New in v2.1.0

### ✨ Modular Bridge Architecture
- **NEW**: Completely rewritten bridge system
- Auto-detection of framework & inventory
- Support for **tgiann-inventory** added
- Easier to extend with new systems
- Better error handling and logging

### 🛠️ Bug Fixes
- Fixed farm/mill/bakery radius from 2.0 → 10.0m
- Fixed mill & processor ped Z-coordinates
- Fixed security distance tolerance (2.0m instead of 5.0m)
- Improved tool durability system
- Enhanced client-side item checking

See [CHANGELOG.md](CHANGELOG.md) for full details.

---

## 📋 Features

### 🌾 Complete Farm-to-Market Chain
- **Wheat Farming** → Mill → Bakery
- **Potato Farming** → Processor → Restaurant
- Dynamic pricing based on time of day
- Auto-farm system with cooldowns

### 🔧 Technical Excellence
- Multi-framework support (QBox, QBCore, ESX)
- Multi-inventory support (ox, qb, tgiann, qs)
- Modular bridge architecture
- Advanced anti-cheat system
- Tool durability system
- Rate limiting & exploit protection

### 🎨 User Experience
- ox_lib integration (TextUI, Progress Bars, Notifications)
- 3D markers and blips
- Multiple interaction modes (ox_target, qb-target, 3D text)
- Multi-language support (DE, EN, FR, ES, PL, TR)

---

## 📦 Installation

### Prerequisites
```
- ox_lib (required)
- Framework: qbx_core OR qb-core OR es_extended
- Inventory: ox_inventory OR qb-inventory OR tgiann-inventory OR qs-inventory
```

### Steps

1. **Download** the latest release
2. **Extract** to your `resources` folder
3. **Add** to `server.cfg`:
```lua
ensure ox_lib
ensure hm_wheatfarm
```
4. **Configure** `config.lua` to your liking
5. **Restart** your server

### Database Setup
No database setup required! Everything works out of the box.

---

## ⚙️ Configuration

### Language
```lua
Config.Language = "de"  -- de, en, fr, es, pl, tr
```

### Framework & Inventory
```lua
Config.Framework = "auto"  -- auto-detects: qbox, qbcore, esx
Config.Inventory = "auto"  -- auto-detects: ox, qb, tgiann, qs
```

### Farm Locations
```lua
Config.Farms = {
    {
        id = "wheat_farm",
        enabled = true,
        crop = "wheat",
        location = vector3(2229.68, 5577.36, 53.85),
        radius = 10.0,  -- Interaction radius
    }
}
```

### Processing & Selling
- **Mill**: Wheat (10x) → Flour (5x) at Grapeseed
- **Processor**: Potato (8x) → Fries (4x) at Farm
- **Bakery**: Sells flour for $175/unit at Paleto Bay
- **Restaurant**: Sells fries for $125/unit at Paleto Bay

Full config documentation: See `config.lua` comments

---

## 🎮 How to Use

### For Players

1. **Get Tools** (optional):
   - Hoe (for wheat)
   - Shovel (for potatoes)

2. **Farm**:
   - Go to farm location (marked on map)
   - Press `E` to harvest
   - Press `G` for auto-farm

3. **Process**:
   - Take wheat to Mill
   - Take potatoes to Processor

4. **Sell**:
   - Sell flour at Bakery
   - Sell fries at Restaurant

---

## 🔌 Bridge System

### Auto-Detection
The bridge automatically detects your framework and inventory on startup:

```
[WheatFarm] ===================================
[WheatFarm] Framework: qbox
[WheatFarm] Inventory: ox_inventory
[WheatFarm] ===================================
```

### Manual Override
Force specific systems in config:
```lua
Config.Framework = "qbcore"  -- Force QBCore
Config.Inventory = "tgiann-inventory"  -- Force tgiann
```

### Supported Systems

**Frameworks:**
- ✅ QBox (qbx_core)
- ✅ QBCore (qb-core)
- ✅ ESX (es_extended)

**Inventories:**
- ✅ ox_inventory
- ✅ qb-inventory
- ✅ tgiann-inventory (NEW in v2.1.0!)
- ✅ qs-inventory

### Extending the Bridge
See [bridge/README.md](bridge/README.md) for developer documentation.

---

## 🛡️ Security Features

- **Rate Limiting**: Max 20 requests/minute per player
- **Cooldown System**: Prevents spam (6s minimum)
- **Distance Validation**: 2.0m tolerance (anti-teleport)
- **Item Validation**: Server-side checks (anti-duplication)
- **Logging**: All suspicious activity logged

Configure in `config.lua`:
```lua
Config.Security = {
    enabled = true,
    maxRequestsPerMinute = 20,
    distanceTolerance = 2.0,
}
```

---

## 🌍 Multi-Language

Included translations:
- 🇩🇪 German (de)
- 🇬🇧 English (en)
- 🇫🇷 French (fr)
- 🇪🇸 Spanish (es)
- 🇵🇱 Polish (pl)
- 🇹🇷 Turkish (tr)

Add your own in `locales/` folder!

---

## 📊 Performance

- **Client**: 0.00-0.01ms idle
- **Server**: <0.01ms per event
- **Optimized**: ox_lib points, minimal loops
- **Scalable**: Tested with 100+ players

---

## 🤝 Support & Issues

### Found a Bug?
1. Check [existing issues](https://github.com/henrymops89/hm_wheatfarm/issues)
2. Create a new issue with:
   - FiveM Server version
   - Framework & Inventory versions
   - Steps to reproduce
   - F8 console logs

### Feature Requests
Use the [feature request template](.github/ISSUE_TEMPLATE/feature_request.md)

---

## 📝 License

**Custom License** - See [LICENSE](LICENSE)

- ✅ Free for personal use
- ✅ Modification allowed for own use
- ❌ Redistribution prohibited
- ❌ Commercial use prohibited without permission

---

## 🙏 Credits

**Created by**: henrymops89  
**Powered by**: ox_lib  
**Thanks to**: QBox, QBCore, ESX communities

---

## 📈 Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history.

---

## 🔗 Links

- **GitHub**: https://github.com/henrymops89/hm_wheatfarm
- **Discord**: https://dsc.gg/mopsscripts
- **Documentation**: [Full docs](bridge/README.md)

---

**Enjoy farming! 🌾🚜**
