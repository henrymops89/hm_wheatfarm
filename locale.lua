-- =====================================================
-- LOCALE.LUA (Helper Class)
-- =====================================================

Locale = {}
Locale.__index = Locale

function Locale:new(options)
    local self = setmetatable({}, Locale)
    self.phrases = options.phrases or {}
    self.warnOnMissing = options.warnOnMissing or false
    return self
end

function Locale:t(key, ...)
    local phrase = self.phrases[key]
    
    if not phrase then
        if self.warnOnMissing then
            print(('[WheatFarm] ^3WARNUNG: Übersetzung fehlt für Key: %s^7'):format(key))
        end
        return key
    end
    
    -- Wenn Parameter übergeben wurden, formatiere den String
    if ... then
        return string.format(phrase, ...)
    end
    
    return phrase
end