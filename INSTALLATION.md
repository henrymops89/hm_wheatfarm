# 📦 Installation Guide - Wheat Farm System

This guide will help you install the Wheat Farm System on your FiveM server.

## Prerequisites

Before installing, make sure you have:

1. **A FiveM Server** (Build 2802 or higher recommended)
2. **One of these frameworks**:
   - QBox Framework
   - QBCore Framework
   - ESX Legacy
3. **Required Resources**:
   - ox_lib
   - ox_inventory OR qs-inventory

---

## Step 1: Download & Extract

1. Download the latest release from GitHub
2. Extract the `wheat_farm` folder
3. Place it in your server's `resources` folder

```
server/
└── resources/
    └── wheat_farm/
        ├── client.lua
        ├── server.lua
        ├── config.lua
        ├── fxmanifest.lua
        ├── locale.lua
        ├── locales/
        │   ├── de.lua
        │   ├── en.lua
        │   ├── fr.lua
        │   └── ...
        └── README.md
```

---

## Step 2: Add Items to Inventory

### For ox_inventory

Open `ox_inventory/data/items.lua` and add:

```lua
-- Farming Tool (Durability Version)
['hoe'] = {
    label = 'Hoe',
    weight = 1000,
    stack = false,
    close = true,
    description = 'A farming hoe with 100 uses. Can break!',
    client = {
        image = 'hoe.png',
    }
},

-- Farming Tool (Permanent Version)
['farming_tool'] = {
    label = 'Professional Farming Tool',
    weight = 2000,
    stack = false,
    close = true,
    description = 'Professional farming tool. Never breaks!',
    client = {
        image = 'farming_tool.png',
    }
},

-- Wheat
['wheat'] = {
    label = 'Wheat',
    weight = 100,
    stack = true,
    close = true,
    description = 'Freshly harvested wheat',
    client = {
        image = 'wheat.png',
    }
}
```

**Note:** Add item images to `ox_inventory/web/images/` if you have them.

---

### For qs-inventory (QBCore/QBox)

#### QBCore: `qb-core/shared/items.lua`
```lua
['hoe'] = {
    name = 'hoe',
    label = 'Hoe',
    weight = 1000,
    type = 'item',
    image = 'hoe.png',
    unique = true,
    useable = false,
    shouldClose = true,
    description = 'A farming hoe with 100 uses. Can break!'
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
    description = 'Freshly harvested wheat'
},
```

#### QBox: `qbx_core/shared/items.lua`
Same as QBCore above.

---

### For qs-inventory (ESX)

#### ESX: `es_extended/config.lua` or database
Add items via SQL or your items configuration file.

---

## Step 3: Configure the Script

Open `wheat_farm/config.lua`:

### 3.1 Framework Selection
```lua
-- Auto-detect (recommended)
Config.Framework = "auto"

-- Or manually set:
-- Config.Framework = "QBox"    -- For QBox
-- Config.Framework = "QBCore"  -- For QBCore
-- Config.Framework = "ESX"     -- For ESX
```

### 3.2 Language
```lua
Config.Language = "en"  -- "de", "en", "fr", "es", "pl", "tr"
```

### 3.3 Inventory System
```lua
Config.Inventory = "ox_inventory"  -- or "qs-inventory"
```

### 3.4 Field Location
```lua
-- Change to your desired coordinates
Config.FieldLocation = vector3(2229.68, 5577.36, 53.85)
Config.FieldRadius = 2.0
```

### 3.5 Tool Type
```lua
Config.RequiredTool = {
    enabled = true,
    item = "hoe",  -- or "farming_tool"
    
    toolType = "durability",  -- "durability" or "permanent"
    
    -- If using durability:
    durabilityPerUse = 1,
    maxDurability = 100,
    breakChance = 5,
}
```

---

## Step 4: Add to server.cfg

Add the following to your `server.cfg`:

### For QBox:
```cfg
ensure ox_lib
ensure ox_inventory     # or qs-inventory
ensure qbx_core
ensure wheat_farm
```

### For QBCore:
```cfg
ensure ox_lib
ensure ox_inventory     # or qs-inventory
ensure qb-core
ensure wheat_farm
```

### For ESX:
```cfg
ensure ox_lib
ensure ox_inventory
ensure es_extended
ensure wheat_farm
```

**Important:** Make sure `wheat_farm` is loaded **AFTER** your framework and inventory!

---

## Step 5: Restart Server

1. Stop your server
2. Start your server
3. Check console for any errors

You should see:
```
[WheatFarm] Framework detected: QBox (Native Exports)
```
or
```
[WheatFarm] Framework detected: QBCore
```
or
```
[WheatFarm] Framework detected: ESX
```

---

## Step 6: Test In-Game

1. Join your server
2. Give yourself the farming tool:
   ```
   /giveitem [yourID] hoe 1
   ```
3. Go to the wheat field (marked on map)
4. Press **E** to farm manually
5. Press **G** to toggle auto-farm

---

## Troubleshooting

### Script Doesn't Start

**Check:**
1. `fxmanifest.lua` exists and is not corrupted
2. All Lua files are present
3. Framework is started before wheat_farm
4. Console shows any error messages

**Solution:**
```cfg
# Make sure order is correct:
ensure ox_lib
ensure [your_framework]
ensure [your_inventory]
ensure wheat_farm
```

---

### Framework Not Detected

**Error:** `[WheatFarm] ERROR: Kein unterstütztes Framework gefunden!`

**Solution:**
1. Set framework manually in `config.lua`:
   ```lua
   Config.Framework = "QBox"  -- or "QBCore" or "ESX"
   ```
2. Make sure framework resource name is correct:
   - QBox: `qbx_core`
   - QBCore: `qb-core`
   - ESX: `es_extended`

---

### Notifications Not Showing

**Problem:** No notifications appear

**Check:**
1. ox_lib is properly installed and started
2. Framework exports are working

**Test:**
```lua
-- In F8 console:
/lua exports.qbx_core:Notify("Test", "success")
```

---

### Tool Not Working

**Problem:** Can't farm even with tool

**Check:**
1. Item name in inventory matches `Config.RequiredTool.item`
2. Inventory system setting is correct in config
3. Server console for errors

**Solution:**
```lua
-- In config.lua, check:
Config.RequiredTool.item = "hoe"  -- Must match inventory item!
Config.Inventory = "ox_inventory"  -- Must match your inventory!
```

---

### Items Not Being Added

**Problem:** Farming works but no wheat received

**Check:**
1. Item `wheat` exists in inventory
2. Player has inventory space
3. Server console shows:
   ```
   [WheatFarm] Spieler [ID] hat [amount]x Weizen gepflügt
   ```

**Solution:**
Make sure wheat item is added to inventory (see Step 2)

---

### Distance/Exploit Warnings

**Problem:** Console shows distance or exploit warnings

**This is normal** if you have security enabled. If you're getting kicked:

```lua
-- In config.lua, disable kicks:
Config.Security = {
    enabled = true,
    kickOnRateLimit = false,      -- Set to false
    kickOnDistanceExploit = false, -- Set to false
}
```

---

## Optional: Add Images

If you want custom item images:

1. Create/download images: `hoe.png`, `wheat.png`
2. Place in:
   - ox_inventory: `ox_inventory/web/images/`
   - qs-inventory: `qs-inventory/html/images/`
3. Restart inventory resource

---

## Support

If you still have issues:

1. Check GitHub Issues: https://github.com/yourusername/wheat_farm/issues
2. Read the full README.md
3. Enable logging in config:
   ```lua
   Config.EnableLogging = true
   ```
4. Share console output when asking for help

---

## Update Instructions

To update from version 1.0.0 to 2.0.0:

1. **Backup** your current config.lua
2. **Replace** all files with new version
3. **Restore** your custom config settings
4. **Restart** server

**Breaking Changes in 2.0.0:**
- QBox implementation completely rewritten
- Framework detection added
- Config structure slightly changed

---

## Advanced Configuration

### Multiple Fields
Currently supports one field. To add more:

1. Duplicate marker/interaction code in `client.lua`
2. Add new coordinates to config
3. Or use multiple instances of the resource

### Custom Animations
Add your own animation in `config.lua`:

```lua
Config.Animations.custom = {
    dict = 'your_dict',
    clip = 'your_clip',
    label = 'Custom Animation',
    prop = {
        model = 'prop_name',
        bone = 28422,
        coords = vector3(0.0, 0.0, 0.0),
        rotation = vector3(0.0, 0.0, 0.0)
    }
}

Config.Animation = "custom"
```

---

Made with ❤️ for the FiveM community
```
