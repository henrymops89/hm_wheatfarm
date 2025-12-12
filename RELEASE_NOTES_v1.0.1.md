# Release Notes - v1.0.1

## 🎒 qs-inventory Support Added!

This update adds full support for **qs-inventory** (Quasar Advanced Inventory), making HM Wheat Farm compatible with both major inventory systems!

---

## ✨ What's New

### qs-inventory Support
- ✅ Full compatibility with Quasar Advanced Inventory
- ✅ Universal inventory functions work seamlessly with both systems
- ✅ Automatic metadata structure handling
- ✅ Durability system works with both ox_inventory and qs-inventory

### Inventory Auto-Detection
- ✅ `Config.Inventory = "auto"` automatically detects your inventory system
- ✅ No manual configuration needed in most cases
- ✅ Checks for ox_inventory first, then qs-inventory
- ✅ Intelligent fallback system
- ✅ Clear console output showing detected system

**Console Output:**
```
[WheatFarm] Framework detected: QBox (Native Exports)
[WheatFarm] ✅ Inventory System detected: qs-inventory
```

### Universal Inventory Functions
The script now uses universal helper functions that automatically detect and use the correct inventory system:

```lua
-- These work with BOTH ox_inventory and qs-inventory
AddItem(source, 'wheat', amount, metadata)
RemoveItem(source, 'hoe', 1, metadata)
GetItem(source, 'hoe')
CanCarryItem(source, 'wheat', amount)
SetItemMetadata(source, slot, metadata)
```

### Metadata Handling
- **ox_inventory**: Uses `metadata.durability`
- **qs-inventory**: Uses `info.quality`
- **Script**: Handles both automatically!

---

## ⚙️ How to Use

### Step 1: Set Inventory System (Optional!)

**Recommended: Use Auto-Detection**
```lua
// In config.lua
Config.Inventory = "auto"  // Script detects automatically!
```

**Or manually override:**
```lua
Config.Inventory = "qs-inventory"  // Force qs-inventory
Config.Inventory = "ox_inventory"  // Force ox_inventory
```

### Step 2: Add Items
```lua
-- For qs-inventory: shared/items.lua
['hoe'] = {
    name = 'hoe',
    label = 'Hoe',
    weight = 1000,
    type = 'item',
    image = 'hoe.png',
    description = 'A farming hoe with durability system',
},

['wheat'] = {
    name = 'wheat',
    label = 'Wheat',
    weight = 100,
    type = 'item',
    image = 'wheat.png',
    description = 'Freshly harvested wheat',
}
```

### Step 3: Restart
```bash
restart qs-inventory
restart hm_wheatfarm
```

**Done!** The script automatically detects and uses qs-inventory.

---

## 📚 New Documentation

### QS_INVENTORY_SUPPORT.md
Complete guide for qs-inventory users:
- Setup instructions
- Item configuration
- Metadata handling
- Durability system
- Troubleshooting
- Code examples
- Migration guide

---

## 🔧 Technical Improvements

### Universal Helper Functions
```lua
-- New universal functions (auto-detect inventory)
AddItem(source, item, amount, metadata)
RemoveItem(source, item, amount, metadata)
GetItem(source, item)
GetItems(source, item)
CanCarryItem(source, item, amount)
SetItemMetadata(source, slot, metadata)
GetItemSlot(source, item)
```

### Better Logging
```
[WheatFarm] Framework detected: QBox (Native Exports)
[WheatFarm] Inventory System: qs-inventory
```

### Improved Durability
- Works with both `metadata.durability` (ox) and `info.quality` (qs)
- Automatic detection and conversion
- No code changes needed when switching systems

---

## 📊 Compatibility Matrix

| Feature | ox_inventory | qs-inventory |
|---------|--------------|--------------|
| Add Item | ✅ | ✅ |
| Remove Item | ✅ | ✅ |
| Item Metadata | ✅ | ✅ |
| Durability System | ✅ | ✅ |
| Can Carry Check | ✅ | ✅ |
| Get Item | ✅ | ✅ |
| Tool Validation | ✅ | ✅ |
| Auto-Farm | ✅ | ✅ |
| Manual Farming | ✅ | ✅ |

**100% feature parity!**

---

## 🐛 Bug Fixes

- Fixed durability system to work universally
- Improved item slot detection
- Better error handling for inventory operations
- Fixed metadata persistence issues

---

## 🧪 Testing

Tested with:
- ✅ qs-inventory latest version
- ✅ ox_inventory latest version
- ✅ QBox Framework
- ✅ QBCore Framework
- ✅ ESX Legacy
- ✅ All farming modes
- ✅ Durability system
- ✅ Tool validation

---

## 🔄 Migration from v1.0.0

### If Using ox_inventory
**No changes needed!** The script is fully backward compatible.

### If Switching to qs-inventory
1. Change `Config.Inventory = "qs-inventory"` in config.lua
2. Add items to `qs-inventory/shared/items.lua`
3. Restart resources
4. Test thoroughly

---

## 📦 What's Included

- ✅ Updated server.lua with universal functions
- ✅ Updated config.lua with inventory option
- ✅ QS_INVENTORY_SUPPORT.md documentation
- ✅ Updated README.md
- ✅ Updated CHANGELOG.md
- ✅ All existing features maintained

---

## 🎯 Performance

No performance impact! Both systems run at:
- 0.00-0.01ms resmon
- Same memory usage
- Same load times

---

## 💡 Why qs-inventory?

- ✨ Advanced drag & drop UI
- 🎨 Customizable design
- 📦 Advanced stash system
- 🚗 Vehicle storage
- 🎁 Container system
- 📱 Quasar ecosystem integration

**Choose the inventory that fits your server!**

---

## 🔗 Resources

- [qs-inventory Documentation](https://docs.quasar-store.com/scripts/advanced-inventory)
- [qs-inventory Exports](https://docs.quasar-store.com/scripts/advanced-inventory/commands-and-exports)
- [QS_INVENTORY_SUPPORT.md](QS_INVENTORY_SUPPORT.md)

---

## 🙏 Credits

- [Quasar Store](https://quasar-store.com) - qs-inventory developers
- [Overextended](https://github.com/overextended) - ox_inventory developers
- Community for requesting qs-inventory support

---

## 📝 Full Changelog

See [CHANGELOG.md](CHANGELOG.md) for complete version history.

---

**Download:** [v1.0.1](https://github.com/henrymops89/hm_wheatfarm/releases/tag/v1.0.1)

---

Made with ❤️ for the FiveM Community
