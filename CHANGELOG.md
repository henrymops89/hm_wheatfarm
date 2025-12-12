# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.0] - 2024-12-12

### ✨ Added
- **Multi-Framework Support**
  - QBox Framework (Native Exports)
  - QBCore Framework (Standard Implementation)
  - ESX Legacy (Dynamic Import)
  - Automatic framework detection
  
- **Farming Features**
  - Manual farming mode (E key) - 1-3 wheat yield
  - Auto-farm mode (G key) - 1-2 wheat yield
  - Cancel farming anytime with same key
  - Cooldown progressbar with cancel instruction
  - 4 different farming animations with props
  
- **Tool System**
  - Durability mode (100 uses + 5% break chance)
  - Permanent mode (never breaks)
  - Client & server-side validation
  - Tool damage notifications
  
- **User Interface**
  - ox_lib TextUI with smart hide/show
  - Progressbars showing cancel instructions
  - Field markers with customizable appearance
  - Map blip for field location
  - Death & field-leave detection
  
- **Multi-Language Support**
  - German (Deutsch)
  - English
  - French (Français)
  - Spanish (Español)
  - Polish (Polski)
  - Turkish (Türkçe)
  
- **Performance Features**
  - Separate threads for markers & interactions
  - Smart throttling (200ms distance checks)
  - Instant input detection (Wait(0))
  - Optional marker disable for 0.00ms
  - Optimized resmon (0.00-0.01ms in field)
  
- **Security Features**
  - Rate limiting (20 requests/minute)
  - Server-side cooldown enforcement
  - Distance validation with tolerance
  - Tool verification (client & server)
  - Optional kick on exploit detection
  - Comprehensive logging
  
- **Inventory Compatibility**
  - ox_inventory (with metadata support)
  - qs-inventory

### 🔧 Technical Details

#### QBox Implementation
- Uses native QBox exports
- No GetCoreObject() usage (correct implementation)
- Direct exports for player management
- Proper notification system

#### ESX Implementation
- Dynamic import via getSharedObject()
- No manual fxmanifest.lua edit required
- Automatic fallback handling
- ESX callback support

#### Code Quality
- Universal helper functions for all frameworks
- Framework-specific optimizations
- Extensive error handling
- Clean, maintainable code structure

### 📝 Configuration Options
- Framework selection (auto/manual)
- Language selection (6 languages)
- Field location & radius
- Tool type (durability/permanent)
- Farming yields & cooldowns
- Animation selection
- Marker & blip customization
- Security settings
- Performance options

### 📦 Files Included
- `client.lua` - Client-side logic
- `server.lua` - Server-side handling
- `config.lua` - Configuration
- `fxmanifest.lua` - Resource manifest
- `locale.lua` - Locale system
- `locales/` - 6 language files
- `README.md` - Documentation
- `LICENSE` - MIT License
- `CHANGELOG.md` - This file

---

## Version Types

- **Major** (X.0.0): Breaking changes, major features
- **Minor** (0.X.0): New features, no breaking changes
- **Patch** (0.0.X): Bug fixes, small improvements

---

## Links

- [GitHub Repository](https://github.com/henrymops89/hm_wheatfarm)
- [Issues](https://github.com/henrymops89/hm_wheatfarm/issues)
- [Releases](https://github.com/henrymops89/hm_wheatfarm/releases)
- [Wiki](https://github.com/henrymops89/hm_wheatfarm/wiki)

---

[1.0.0]: https://github.com/henrymops89/hm_wheatfarm/releases/tag/v1.0.0
