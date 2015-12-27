modifier_ms_cap = class({})

function modifier_ms_cap:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_MAX,
        MODIFIER_PROPERTY_MOVESPEED_LIMIT,
    }

    return funcs
end

function modifier_ms_cap:GetModifierMoveSpeed_Max( params )
    return 5000
end

function modifier_ms_cap:GetModifierMoveSpeed_Limit( params )
    return 5000
end

function modifier_ms_cap:IsHidden()
    return true
end