-- =====================================================
-- OX_INVENTORY ITEMS.LUA - HM WHEAT FARM
-- Kopiere diese Items in deine ox_inventory/data/items.lua
-- =====================================================

-- CROPS (Feldfrüchte)
['wheat'] = {
    label = 'Weizen',
    weight = 50,
    stack = true,
    close = true,
    description = 'Frisch geernteter Weizen vom Feld'
},

['potato'] = {
    label = 'Kartoffel',
    weight = 50,
    stack = true,
    close = true,
    description = 'Frische Kartoffel vom Feld'
},

-- PROCESSED (Verarbeitete Produkte)
['flour'] = {
    label = 'Mehl',
    weight = 100,
    stack = true,
    close = true,
    description = 'Frisch gemahlenes Mehl aus der Mühle'
},

['fries'] = {
    label = 'Pommes Frites',
    weight = 100,
    stack = true,
    close = true,
    description = 'Knusprige Pommes Frites'
},

-- TOOLS (Werkzeuge)
['hoe'] = {
    label = 'Hacke',
    weight = 1000,
    stack = false,
    close = true,
    description = 'Werkzeug zum Ernten von Weizen',
    durability = 100,  -- Optional: Nur mit Durability-System
    degrade = 1        -- Optional: Wie viel Durability pro Nutzung
},

['shovel'] = {
    label = 'Schaufel',
    weight = 1200,
    stack = false,
    close = true,
    description = 'Werkzeug zum Graben und Ernten von Kartoffeln',
    durability = 80,   -- Optional: Nur mit Durability-System
    degrade = 2        -- Optional: Wie viel Durability pro Nutzung
},

-- =====================================================
-- INSTALLATION:
-- 1. Öffne: ox_inventory/data/items.lua
-- 2. Füge die obigen Items hinzu
-- 3. restart ox_inventory
-- 4. restart hm_wheatfarm
-- =====================================================
