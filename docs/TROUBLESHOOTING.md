# 🔧 Troubleshooting Guide

## 🐛 Problem: Items werden nicht hinzugefügt

### Symptome:
- ✅ Verarbeitung zeigt "erfolgreich"
- ❌ Items erscheinen nicht im Inventar
- ❌ Oder: Items verschwinden aber nichts kommt rein

### 🔍 Debug-Schritte:

#### 1. **Aktiviere Debug-Logging**
In `config.lua`:
```lua
Config.EnableLogging = true   -- Muss auf true sein!
```

#### 2. **Prüfe Server-Console**
Nach dem Verarbeiten solltest du sehen:
```
[WheatFarm DEBUG] RemoveItem: source=1, item=potato, amount=8, inventory=ox_inventory
[WheatFarm DEBUG] ox_inventory:RemoveItem returned: true
[WheatFarm DEBUG] AddItem: source=1, item=fries, amount=4, inventory=ox_inventory
[WheatFarm DEBUG] ox_inventory:AddItem returned: [object]
[WheatFarm DEBUG] ox_inventory AddItem success=true, result=[object]
```

#### 3. **Häufige Probleme:**

**Problem: "Cannot carry item (inventory full)"**
- ✅ Lösung: Inventar hat keinen Platz mehr
- 🔧 Fix: Platz im Inventar machen

**Problem: "ox_inventory:AddItem returned: false"**
- ❌ Ursache: Item existiert nicht in ox_inventory items.lua
- 🔧 Fix: Füge das Item hinzu:

```lua
-- In ox_inventory/data/items.lua
['fries'] = {
    label = 'Pommes',
    weight = 100,
    stack = true,
    close = true,
    description = 'Frische Pommes Frites'
},

['flour'] = {
    label = 'Mehl',
    weight = 100,
    stack = true,
    close = true,
    description = 'Frisch gemahlenes Mehl'
},

['wheat'] = {
    label = 'Weizen',
    weight = 50,
    stack = true,
    close = true,
    description = 'Frisch geernteter Weizen'
},

['potato'] = {
    label = 'Kartoffel',
    weight = 50,
    stack = true,
    close = true,
    description = 'Frische Kartoffel'
},

['hoe'] = {
    label = 'Hacke',
    weight = 1000,
    stack = false,
    close = true,
    description = 'Werkzeug zum Ernten',
    durability = 100
},

['shovel'] = {
    label = 'Schaufel',
    weight = 1200,
    stack = false,
    close = true,
    description = 'Werkzeug zum Graben',
    durability = 80
},
```

**Problem: "Player not found"**
- ❌ Ursache: Framework nicht korrekt geladen
- 🔧 Fix: Prüfe Framework-Start-Reihenfolge in server.cfg

---

## 🔍 Weitere Debug-Checks:

### Check 1: Inventory System erkannt?
```
[WheatFarm] =====================================
[WheatFarm] Framework: qbox
[WheatFarm] Inventory: ox_inventory  ← Muss richtig sein!
[WheatFarm] =====================================
```

### Check 2: Items in Config richtig?
In `config.lua`:
```lua
Config.Processor = {
    input = {
        item = "potato",  -- ← Muss EXAKT so in items.lua sein!
        amount = 8,
    },
    output = {
        item = "fries",   -- ← Muss EXAKT so in items.lua sein!
        amount = 4,
    },
}
```

### Check 3: ox_inventory läuft?
```bash
# In F8 Console:
ensure ox_inventory
```

---

## 🚨 Error Messages Decoder:

| Error Message | Bedeutung | Lösung |
|--------------|-----------|--------|
| `attempt to call a nil value` | Funktion existiert nicht | Prüfe ob ox_inventory läuft |
| `Cannot carry item` | Inventar voll | Platz machen |
| `AddItem returned: false` | Item existiert nicht | Item in items.lua hinzufügen |
| `Player not found` | Framework-Problem | Server-Startreihenfolge prüfen |
| `Unknown inventory system` | Inventory nicht erkannt | Config.Inventory prüfen |

---

## 💡 Schnelle Fixes:

### Fix 1: Server neu starten
```bash
restart hm_wheatfarm
```

### Fix 2: ox_inventory neu starten
```bash
restart ox_inventory
restart hm_wheatfarm
```

### Fix 3: Cache leeren
```bash
refresh
```

### Fix 4: Items manuell testen
```lua
-- In F8 Console (als Admin):
/giveitem fries 10
```

---

## 📞 Support:

Wenn nichts hilft:
1. **Kopiere die komplette Server-Console** beim Verarbeiten
2. **Mache Screenshot** vom Inventar
3. **Erstelle GitHub Issue** mit allen Infos

---

## ✅ Checkliste vor Support-Anfrage:

- [ ] Config.EnableLogging = true
- [ ] Server neu gestartet
- [ ] ox_inventory läuft
- [ ] Items in items.lua hinzugefügt
- [ ] F8 Console gecheckt
- [ ] Server-Console gecheckt
- [ ] /giveitem funktioniert

---

**Viel Erfolg! 🌾**
