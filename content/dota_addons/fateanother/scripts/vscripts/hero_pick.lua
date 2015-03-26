function CCustomGameMode:OnPlayerPicked( event )
    local spawnedUnit = event.hero
     -- Attach client side hero effects on spawning players
    for nPlayerID = 0, DOTA_MAX_PLAYERS-1 do
        if ( PlayerResource:IsValidPlayer( nPlayerID ) ) then
            PlayerResource:GetPlayer(nPlayerID):GetAssignedHero():GetAbilityByIndex(1):SetLevel(1)
			PlayerResource:GetPlayer(nPlayerID):GetAssignedHero():GetAbilityByIndex(2):SetLevel(1)
			PlayerResource:GetPlayer(nPlayerID):GetAssignedHero():GetAbilityByIndex(3):SetLevel(1)
			PlayerResource:GetPlayer(nPlayerID):GetAssignedHero():GetAbilityByIndex(4):SetLevel(1)
			PlayerResource:GetPlayer(nPlayerID):GetAssignedHero():GetAbilityByIndex(5):SetLevel(1)
        end
    end
end