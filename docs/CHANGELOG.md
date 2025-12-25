# Changelog

All notable changes to HM Wheat Farm will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [2.1.1] - 2024-12-25

### 🎉 What's New

**Peak Hours Display** 🔥
- Peak hour bonuses are now clearly displayed when selling!
- Players see exactly how much bonus money they receive
- Example: "Du hast $324 für 2x fries bekommen! + $74 (Peak Hours Bonus: +30%)"

**Auto-Farm Continuous Loop** 🔄
- Auto-farm now runs continuously until stopped (not just once!)
- Press [G] to toggle auto-farm on/off
- Automatically stops when leaving zone or tool breaks
- Dynamic TextUI shows current status:
  - "Auto-Farm starten 🔄" when idle
  - "Auto-Farm läuft - Drücke G zum Stoppen 🔴" when running

**Better User Experience** 💚
- Removed cooldowns from Mill, Processor, Bakery, and Restaurant
- Farm markers now properly sized (yellow circle = interaction zone)
- Security distance tolerance increased to 12m (no more "too far away" errors)
- TextUI hides manual harvest option when auto-farm is active

### 🔧 Critical Fixes

**Server Inventory System** ⚠️
- FIXED: Complete rewrite of server-side inventory functions
- FIXED: `GetItemCount()`, `AddItem()`, `RemoveItem()` now use direct inventory API calls
- FIXED: Added `CanCarryItem()` check for ox_inventory (prevents item loss)
- FIXED: Better error handling with detailed debug logging
- Now properly supports: ox_inventory, tgiann-inventory, qs-inventory, qb-inventory

**Locale System** 🌍
- FIXED: `locale.lua` now loads BEFORE `locales/de.lua` (was causing "Locale is nil" errors)
- All translations now work correctly

**Tool Durability** 🔨
- FIXED: Simplified tool system that works with ALL inventories
- FIXED: Removed complex metadata handling that was causing crashes
- Tools are now required for farming (as intended)
- Small random chance for tool breaking (works universally)

**Event Handlers** 📡
- FIXED: Added missing `wheat:notify` event handler in client
- Server notifications now properly reach the client
- All error messages are now visible to players

### 🚀 Improvements

**Debug Logging** 🔍
- Added comprehensive debug logging for troubleshooting
- Shows Peak Hour status, pricing calculations, and inventory operations
- Controlled via `Config.EnableLogging` (enabled by default)
- Minimal performance impact (~0.0001ms per operation)

**Code Quality** 📝
- Better error messages for players
- Improved code documentation
- More consistent naming conventions

### 🔄 Changed

**Configuration**
- Security distance tolerance: 2.0m → 12.0m
- Farm marker sizes now properly configured
- All farm/processor locations maintained from user config

**Processing & Selling**
- Removed all cooldowns (Mill, Processor, Bakery, Restaurant)
- Only rate limiting remains (20 requests/minute for anti-spam)

### 📊 Technical Details

**Files Modified:**
- `server/utils.lua` - Complete inventory system rewrite + debug logging
- `server/bakery.lua` - Peak hours display + cooldown removal
- `server/restaurant.lua` - Peak hours display + cooldown removal
- `server/mill.lua` - Cooldown removal
- `server/processor.lua` - Cooldown removal + debug logging
- `client/main.lua` - Added wheat:notify event handler
- `client/farming.lua` - Auto-farm loop + dynamic TextUI
- `config.lua` - Security distance tolerance update
- `fxmanifest.lua` - Locale loading order fix

**New Features:**
- `CalculateDynamicPrice()` now returns: `price, isPeakHour, bonusPercent`
- Auto-farm loop with proper cleanup on zone exit
- Dynamic TextUI updates based on auto-farm state

### 🐛 Bug Reports Fixed
- ❌ Items not being added to ox_inventory after processing
- ❌ "Too far away" error when inside farm zone
- ❌ Auto-farm only running once instead of continuous
- ❌ Locale errors on resource start
- ❌ Tool durability system crashing
- ❌ Peak hours bonus not visible to players
- ❌ Notifications not showing up

### 💡 Known Issues
None! Everything is working as intended.

### 🔮 Coming in v2.2.0
See "Upcoming in v2.2.0" section below.

---

## [2.1.0] - 2024-12-25

### ✨ Added
- **Modular Bridge Architecture**: Completely rewritten bridge system split into:
  - `bridge/framework.lua` - Framework detection and integration
  - `bridge/inventory.lua` - Inventory system integration
  - `bridge/main.lua` - Bridge initialization
  - `bridge/README.md` - Developer documentation
- **tgiann-inventory Support**: Full integration with tgiann-inventory system
- **Comprehensive Documentation**: 
  - Added CONTRIBUTING.md
  - Added MIGRATION.md (v2.0 → v2.1 guide)
  - Added PROJECT_SUMMARY.md
  - Enhanced bridge/README.md with API examples
- **GitHub Templates**:
  - Bug report template
  - Feature request template
  - Pull request template

### 🔧 Fixed
- **BUG #4**: Farm interaction radius (was 2.0m, now 10.0m)
- **BUG #5**: Mill interaction radius (was 2.5m, now 10.0m)
- **BUG #6**: Bakery interaction radius (was 2.5m, now 10.0m)
- **BUG #14**: Mill ped Z-coordinate (was underground at 44.52, now correct at 45.81)
- **BUG #14**: Processor ped spawning correctly
- **BUG #11**: Security distance tolerance (reduced from 5.0m to 2.0m)
- **BUG #10**: Tool checking system improved (better ox_inventory client-side checks)
- **BUG #1**: Notification system enhanced with better error handling

### 🚀 Improved
- Better error handling across all modules
- Enhanced logging system
- Improved auto-detection reliability
- Cleaner code structure (DRY principle)
- Better comments and documentation in code

### 🔄 Changed
- `fxmanifest.lua`: Updated to load new modular bridge
- All radius values standardized to 10.0m for consistency
- Text interaction distances increased from 2.5m to 5.0m
- Target interaction distances increased from 2.5m to 3.0m

### 📝 Technical
- Codebase reorganized for better maintainability
- Reduced code duplication across client/server
- Improved TypeScript-like JSDoc comments
- Better separation of concerns

---

## [2.0.0] - 2024-12-20

### ✨ Added
- Initial public release
- Multi-framework support (QBox, QBCore, ESX)
- Multi-inventory support (ox_inventory, qb-inventory, qs-inventory)
- Complete farm-to-market chain (Wheat & Potato)
- Auto-farm system
- Tool durability system
- Dynamic pricing
- Security features (rate limiting, distance checks)
- Multi-language support (6 languages)

### 🎮 Features
- Two crop types: Wheat and Potato
- Four locations: Farm, Mill, Processor, Bakery/Restaurant
- ox_lib integration (TextUI, Progress, Notifications)
- Multiple interaction modes (ox_target, qb-target, 3D text)
- Configurable everything

---

## [1.0.0] - 2024-12-01

### Initial Development
- Private beta version
- Basic wheat farming
- Single framework support

---

## Upcoming in v2.2.0 (Planned)

### 🔮 Planned Features
- [ ] Advanced crop system (seasons, weather effects)
- [ ] Company system (team farming)
- [ ] Crop quality system (different grades)
- [ ] Market economy (supply/demand pricing)
- [ ] Farm upgrades (better tools, automation)
- [ ] Statistics & leaderboards
- [ ] More crops (corn, tomato, etc.)
- [ ] Greenhouse system

### 🎯 Planned Improvements
- [ ] Further optimization
- [ ] More language translations
- [ ] Video tutorials
- [ ] Web-based config editor

---

## Release Strategy

- **Major versions** (X.0.0): Breaking changes, major features
- **Minor versions** (2.X.0): New features, backwards compatible
- **Patch versions** (2.1.X): Bug fixes, minor improvements

---

## How to Update

See [MIGRATION.md](MIGRATION.md) for upgrade guides.

### Quick Update (Same major version)
1. Backup your `config.lua`
2. Replace all files except `config.lua`
3. Check CHANGELOG for new config options
4. Restart resource

### Major Update (Breaking changes)
Follow the detailed migration guide in MIGRATION.md

---

**Legend:**
- ✨ Added: New features
- 🔧 Fixed: Bug fixes
- 🚀 Improved: Enhancements
- 🔄 Changed: Modifications
- ❌ Removed: Deprecated features
- 🔒 Security: Security improvements
- 📝 Technical: Code/internal changes
