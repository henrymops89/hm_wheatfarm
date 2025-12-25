-- =====================================================
-- LOCALE.LUA - Multi-Language System Engine
-- This is the system that loads translations
-- =====================================================

Locale = {}
Locale.__index = Locale

-- =====================================================
-- AVAILABLE LOCALES STORAGE (Initialize FIRST!)
-- =====================================================

Locales = {} -- ✅ CRITICAL: Initialize BEFORE locale files load!

-- =====================================================
-- CREATE NEW LOCALE INSTANCE
-- =====================================================

function Locale:new(options)
    local self = setmetatable({}, Locale)
    self.phrases = options.phrases or {}
    self.warnOnMissing = options.warnOnMissing or false
    return self
end

-- =====================================================
-- TRANSLATE FUNCTION
-- =====================================================

function Locale:t(key, ...)
    local phrase = self.phrases[key]
    
    -- Guard: Translation missing
    if not phrase then
        if self.warnOnMissing then
            print(('[WheatFarm] ^3WARNING: Translation missing for key: %s^7'):format(key))
        end
        return key -- Return key as fallback
    end
    
    -- If parameters were passed, format the string
    if ... then
        local success, result = pcall(string.format, phrase, ...)
        
        if success then
            return result
        else
            -- Format failed, return unformatted
            if self.warnOnMissing then
                print(('[WheatFarm] ^3WARNING: Failed to format translation: %s^7'):format(key))
            end
            return phrase
        end
    end
    
    return phrase
end

-- =====================================================
-- AUTO-SELECT LANGUAGE BASED ON CONFIG
-- =====================================================

CreateThread(function()
    local side = IsDuplicityVersion() and 'SERVER' or 'CLIENT'
    
    print(string.format('[WheatFarm %s] Locale system starting...', side))
    
    Wait(1000) -- ✅ Warte länger für Locale-Dateien
    
    -- Debug: Show available languages
    local available = {}
    for lang, _ in pairs(Locales) do
        table.insert(available, lang)
    end
    
    if #available > 0 then
        print(string.format('[WheatFarm %s] Available locales: %s', side, table.concat(available, ', ')))
    else
        print(string.format('[WheatFarm %s] ⚠️ WARNING: NO locales loaded!', side))
    end
    
    local selectedLang = Config.Language or 'de'
    print(string.format('[WheatFarm %s] Config.Language = %s', side, selectedLang))
    
    local attempts = 0
    
    -- Retry bis Sprache verfügbar ist (max 5 Sekunden)
    while not Locales[selectedLang] and attempts < 50 do
        Wait(100)
        attempts = attempts + 1
        if attempts % 10 == 0 then
            print(string.format('[WheatFarm %s] Still waiting for locale "%s"... (attempt %d/50)', side, selectedLang, attempts))
        end
    end
    
    if Locales[selectedLang] then
        Lang = Locales[selectedLang]
        print(string.format('[WheatFarm %s] ✅ Language: %s', side, selectedLang))
    else
        -- Fallback to German or English
        Lang = Locales['de'] or Locales['en']
        local fallbackUsed = Locales['de'] and 'de' or 'en'
        print(string.format('^3[WheatFarm %s] WARNING: Language "%s" not found, using %s instead^7', side, selectedLang, fallbackUsed))
    end
end)

-- =====================================================
-- GLOBAL LANG VARIABLE (will be set automatically)
-- =====================================================

Lang = nil -- Will be auto-set based on Config.Language