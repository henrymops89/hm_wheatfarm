# Changelog

All notable changes to this project will be documented in this file.

## [2.0.0] - 2024-12-11

### ✨ Added
- **Multi-Framework Support**: QBox (Native!), QBCore, ESX Legacy
- **Framework Auto-Detection**: Automatically detects installed framework
- **Manual Framework Selection**: Option to manually set framework in config
- **Improved Security System**: Enhanced anti-cheat and validation
- **Better Error Handling**: More robust error checking and logging
- **Framework-Specific Helpers**: Optimized functions for each framework

### 🔧 Fixed
- **Critical QBox Bug**: Removed incorrect `GetCoreObject()` usage
- **QBox Native Exports**: Now uses direct exports like `exports.qbx_core:GetPlayer(source)`
- **QBox Notifications**: Fixed notification system for QBox
- **Client-Side Tool Check**: Improved tool validation across frameworks
- **ESX Compatibility**: Added proper ESX callback system

### 🚀 Changed
- **Code Structure**: Separated framework logic for better maintainability
- **Notification System**: Universal notification function supporting all frameworks
- **Inventory Integration**: Better support for both ox_inventory and qs-inventory
- **Documentation**: Comprehensive README with framework-specific examples

### 📝 Technical Details

#### QBox Changes
```lua
-- ❌ OLD (WRONG):
local QBCore = exports['qbx_core']:GetCoreObject()

-- ✅ NEW (CORRECT):
local player = exports.qbx_core:GetPlayer(source)
exports.qbx_core:Notify(source, text, type)
```

#### Framework Detection
```lua
-- Auto-detection on server/client start
if GetResourceState('qbx_core') == 'started' then
    FrameworkName = 'QBox'
elseif GetResourceState('qb-core') == 'started' then
    FrameworkName = 'QBCore'
elseif GetResourceState('es_extended') == 'started' then
    FrameworkName = 'ESX'
end
```

### 🔐 Security
- Rate limiting improved
- Server-side cooldown enforcement
- Distance validation with tolerance
- Tool verification on both client and server
- Optional kick on exploit detection

### 📚 Documentation
- Added framework-specific setup guides
- Troubleshooting section
- API documentation
- Configuration examples for all frameworks

---

## [1.0.0] - 2024-12-11

### ✨ Initial Release

#### Features
- Manual farming system (E key)
- Auto-farm mode (G key)
- Tool durability system
- Permanent tool option
- Multi-language support (6 languages)
- ox_lib UI integration
- Progress bars with animations
- 4 different farming animations
- Configurable markers and blips
- Field-leave detection
- Death protection
- Basic security system

#### Supported Systems
- QBox Framework (with incorrect implementation)
- ox_inventory
- qs-inventory

#### Languages
- German (Deutsch)
- English
- French (Français)
- Spanish (Español)
- Polish (Polski)
- Turkish (Türkçe)

---

## Version Types

- **Major** (X.0.0): Breaking changes, major features
- **Minor** (0.X.0): New features, no breaking changes
- **Patch** (0.0.X): Bug fixes, small improvements

---

## Links

- [GitHub Repository](https://github.com/yourusername/wheat_farm)
- [Issues](https://github.com/yourusername/wheat_farm/issues)
- [Pull Requests](https://github.com/yourusername/wheat_farm/pulls)
