-- =====================================================
-- LOCALE.LUA - Multi-Language System Engine
-- This is the system that loads translations
-- =====================================================

Locale = {}
Locale.__index = Locale

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
-- GLOBAL LANG VARIABLE (set by locale files)
-- =====================================================

Lang = nil -- Will be set by locales/de.lua or locales/en.lua
