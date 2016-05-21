local popup = {}
 
POPUP_SYMBOL_PRE_PLUS = 0
POPUP_SYMBOL_PRE_MINUS = 1
POPUP_SYMBOL_PRE_SADFACE = 2
POPUP_SYMBOL_PRE_BROKENARROW = 3
POPUP_SYMBOL_PRE_SHADES = 4
POPUP_SYMBOL_PRE_MISS = 5
POPUP_SYMBOL_PRE_EVADE = 6
POPUP_SYMBOL_PRE_DENY = 7
POPUP_SYMBOL_PRE_ARROW = 8

POPUP_SYMBOL_POST_EXCLAMATION = 0
POPUP_SYMBOL_POST_POINTZERO = 1
POPUP_SYMBOL_POST_MEDAL = 2
POPUP_SYMBOL_POST_DROP = 3
POPUP_SYMBOL_POST_LIGHTNING = 4
POPUP_SYMBOL_POST_SKULL = 5
POPUP_SYMBOL_POST_EYE = 6
POPUP_SYMBOL_POST_SHIELD = 7
POPUP_SYMBOL_POST_POINTFIVE = 8

COLOR_MAGICAL_POPUP = Vector(94,239,239)
COLOR_PHYSICAL_POPUP = Vector(240,76,76)
COLOR_PURE_POPUP = Vector(255,14,255)
-- e.g. when healed by an ability
function PopupHealing(target, amount)
    PopupNumbers(target, "heal", Vector(0, 255, 0), 3.0, amount, POPUP_SYMBOL_PRE_PLUS, nil)
end

-- e.g. the popup you get when you suddenly take a large portion of your health pool in damage at once
function PopupDamage(target, amount, color, damageType)
    PopupNumbers(target, "damage", color, 1.5, amount, nil, POPUP_SYMBOL_POST_DROP, damageType)
end

-- e.g. when dealing critical damage
function PopupCriticalDamage(target, amount)
    PopupNumbers(target, "crit", Vector(255, 0, 0), 3.0, amount, nil, POPUP_SYMBOL_POST_LIGHTNING)
end

-- e.g. when taking damage over time from a poison type spell
function PopupDamageOverTime(target, amount)
    PopupNumbers(target, "poison", Vector(215, 50, 248), 3.0, amount, nil, POPUP_SYMBOL_POST_EYE)
end

-- e.g. when blocking damage with a stout shield
function PopupDamageBlock(target, amount)
    PopupNumbers(target, "block", Vector(255, 255, 255), 3.0, amount, POPUP_SYMBOL_PRE_MINUS, nil)
end

-- e.g. when last-hitting a creep
function PopupGoldGain(target, amount)
    PopupNumbers(target, "gold", Vector(255, 200, 33), 2.0, amount, POPUP_SYMBOL_PRE_PLUS, nil)
end

-- e.g. when missing uphill
function PopupMiss(target)
    PopupNumbers(target, "miss", Vector(255, 0, 0), 3.0, nil, POPUP_SYMBOL_PRE_MISS, nil)
end

function PopupExperience(target, amount)
    PopupNumbers(target, "miss", Vector(154, 46, 254), 3.0, amount, POPUP_SYMBOL_PRE_PLUS, nil)
end

function PopupMana(target, amount)
    PopupNumbers(target, "heal", Vector(0, 176, 246), 3.0, amount, POPUP_SYMBOL_PRE_PLUS, nil)
end

function PopupHealthTome(target, amount)
    PopupNumbers(target, "miss", Vector(255, 255, 255), 3.0, amount, nil, POPUP_SYMBOL_POST_LIGHTNING)
end

function PopupStrTome(target, amount)
    PopupNumbers(target, "miss", Vector(255, 0, 0), 3.0, amount, nil, POPUP_SYMBOL_POST_LIGHTNING)
end

function PopupAgiTome(target, amount)
    PopupNumbers(target, "miss", Vector(0, 255, 0), 3.0, amount, nil, POPUP_SYMBOL_POST_LIGHTNING)
end

function PopupIntTome(target, amount)
    PopupNumbers(target, "miss", Vector(0, 176, 246), 3.0, amount, nil, POPUP_SYMBOL_POST_LIGHTNING)
end

function PopupHPRemovalDamage(target, amount)
    PopupNumbers(target, "crit", Vector(154, 46, 254), 3.0, amount, nil, POPUP_SYMBOL_POST_LIGHTNING)
end

function PopupLumber(target, amount)
    PopupNumbers(target, "damage", Vector(10, 200, 90), 3.0, amount, POPUP_SYMBOL_PRE_PLUS, nil)
end

function PopupSpellDamage(target, amount)
    PopupNumbers(target, "spell", Vector(191, 85, 236), 3.0, amount, nil, POPUP_SYMBOL_POST_DROP)
end

-- Customizable version.
function PopupNumbers(target, pfx, color, lifetime, number, presymbol, postsymbol, damagetype)
    local pfxPath = string.format("particles/msg_fx/msg_%s.vpcf", pfx)
    local popupColor = color
    if pfx == "damage" then 
        if damagetype == 1 then
            pfxPath = "particles/custom/system/damage_popup_physical.vpcf"
            popupColor = COLOR_PHYSICAL_POPUP
        elseif damagetype == 2 then
            pfxPath = "particles/custom/system/damage_popup_magical.vpcf"
            popupColor = COLOR_MAGICAL_POPUP
        elseif damagetype == 4 then
            pfxPath = "particles/custom/system/damage_popup_pure.vpcf"
            popupColor = COLOR_PURE_POPUP
        end
    end
    local pidx
    if pfx == "gold" or pfx == "lumber" then
        pidx = ParticleManager:CreateParticleForTeam(pfxPath, PATTACH_ABSORIGIN_FOLLOW, target, target:GetTeamNumber())
    else
        pidx = ParticleManager:CreateParticle(pfxPath, PATTACH_ABSORIGIN_FOLLOW, target)
    end

    local digits = 0
    if number ~= nil then
        digits = #tostring(number)
    end
    if presymbol ~= nil then
        digits = digits + 1
    end
    if postsymbol ~= nil then
        digits = digits + 1
    end

    ParticleManager:SetParticleControl(pidx, 1, Vector(tonumber(presymbol), tonumber(number), tonumber(postsymbol)))
    ParticleManager:SetParticleControl(pidx, 2, Vector(lifetime, digits, 0))
    ParticleManager:SetParticleControl(pidx, 3, popupColor)
end
