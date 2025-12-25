# 🌉 HM Wheat Farm - Bridge Module

## Overview
The Bridge module provides a **unified interface** for working with different frameworks and inventory systems. This modular approach makes it easy to add support for new systems without modifying the core script.

---

## 📁 Structure

```
bridge/
├── framework.lua   - Framework detection (QBox, QBCore, ESX)
├── inventory.lua   - Inventory system (ox, qs, tgiann, qb)
└── main.lua        - Initialization & exports
```

---

## 🎯 Supported Systems

### Frameworks
- ✅ **QBox** - Native exports (no GetCoreObject needed)
- ✅ **QBCore** - Full support
- ✅ **ESX Legacy** - Full support

### Inventory Systems
- ✅ **ox_inventory** - Full support with metadata
- ✅ **qs-inventory** - Full support
- ✅ **tgiann-inventory** - Full support ⭐ **NEW!**
- ✅ **qb-inventory** - Basic support

---

## 🔧 How It Works

### Auto-Detection
The bridge automatically detects your framework and inventory system on startup:

```lua
[WheatFarm Bridge] ✅ Framework: QBox (Native Exports)
[WheatFarm Bridge] ✅ Inventory: ox_inventory
[WheatFarm Bridge] ✅ Bridge Initialized Successfully!
```

### No Configuration Needed
Just install the resource and it will detect everything automatically!

---

## 📖 API Reference

### Server-Side Functions

#### Player Functions
```lua
-- Get player object
local Player = GetPlayer(source)

-- Add money
AddMoney(source, 1000, 'cash')

-- Remove money
RemoveMoney(source, 500, 'cash')
```

#### Inventory Functions
```lua
-- Add item
AddItem(source, 'wheat', 10)
AddItem(source, 'hoe', 1, { durability = 100 })

-- Remove item
RemoveItem(source, 'wheat', 5)

-- Get item count
local count = GetItemCount(source, 'wheat')

-- Check if can carry
if CanCarryItem(source, 'flour', 10) then
    -- Add item
end

-- Get item with slot (for durability)
local toolItem = GetItemWithSlot(source, 'hoe')
if toolItem then
    print('Tool is in slot: ' .. toolItem.slot)
    print('Durability: ' .. (toolItem.metadata.durability or 100))
end
```

#### Notification
```lua
-- Send notification
Notify(source, 'Message here', 'success')
```

### Client-Side Functions

```lua
-- Get item count (client)
local count = GetItemCountClient('wheat')

-- Check if has tool
if HasRequiredTool('hoe') then
    -- Player has hoe
end

-- Send notification
Notify('Message here', 'error')
```

### Utility Functions

```lua
-- Get current framework name
local framework = GetFrameworkName() -- 'qbox', 'qbcore', or 'esx'

-- Get current inventory name
local inventory = GetInventoryName() -- 'ox_inventory', 'qs-inventory', etc.

-- Check if systems are ready
if IsFrameworkReady() and IsInventoryReady() then
    -- All systems loaded
end
```

---

## 🆕 Adding New Systems

### Adding a New Inventory System

Edit `bridge/inventory.lua`:

1. **Add Detection:**
```lua
if GetResourceState('my_inventory') == 'started' then
    Inventory.name = 'my_inventory'
    Inventory.ready = true
    print('[WheatFarm Bridge] ✅ Inventory: my_inventory')
    return true
end
```

2. **Add Functions:**
```lua
function AddItem(source, item, amount, metadata)
    -- ... existing code ...
    
    elseif Inventory.name == 'my_inventory' then
        return exports['my_inventory']:AddItem(source, item, amount)
    
    -- ... rest of code ...
end
```

### Adding a New Framework

Edit `bridge/framework.lua` following the same pattern.

---

## 🐛 Troubleshooting

### Bridge Not Detecting System

**Check console for errors:**
```
[WheatFarm Bridge] ❌ ERROR: No supported framework found!
```

**Solution:**
- Ensure your framework resource is started BEFORE hm_wheatfarm
- Check resource names match exactly (e.g., `qbx_core`, not `qb-core`)

### Items Not Adding

**Check which inventory you're using:**
```lua
/wheatdebug
```

**Common issues:**
- Item doesn't exist in items.lua
- Inventory weight/slot limit reached
- Wrong metadata format

### Notifications Not Working

**Framework not loaded:**
```lua
-- Check if ready
if not IsFrameworkReady() then
    print('Framework not ready!')
end
```

---

## 📊 Comparison: Old vs New

### Old Bridge (Single File)
```lua
bridge.lua (500+ lines)
❌ Hard to maintain
❌ Hard to add new systems
❌ Everything in one file
```

### New Bridge (Modular)
```lua
bridge/
├── framework.lua  (150 lines)
├── inventory.lua  (300 lines)
└── main.lua       (50 lines)

✅ Easy to maintain
✅ Easy to add systems
✅ Clean separation of concerns
✅ Easier to debug
```

---

## 🤝 Contributing

Want to add support for a new inventory/framework?

1. Fork the repository
2. Edit the appropriate bridge file
3. Test thoroughly
4. Submit a pull request

---

## 📝 License

Part of HM Wheat Farm - MIT License

---

## 💬 Support

- **Issues:** [GitHub Issues](https://github.com/henrymops89/hm_wheatfarm/issues)
- **Wiki:** [Documentation](https://github.com/henrymops89/hm_wheatfarm/wiki)

---

**Made with ❤️ for the FiveM Community**
