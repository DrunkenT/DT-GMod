
ITEM.Name = 'Sprint Length Boost'
ITEM.Price = 5000
ITEM.Material = 'drunkent/psaccessories/dt_sprintlengthboost'
ITEM.Description = 'Allows the user to sprint for longer.'

function ITEM:OnEquip( ply )

	ply.DT_ShouldPlayerSprintLengthBoost = true
	
end

function ITEM:OnHolster( ply )

	ply.DT_ShouldPlayerSprintLengthBoost = false
	
end


--[[

Snippet from addons/wyozitttadv/lua/autorun/server/advancedttt.lua lines 107-111:

if ply.DT_ShouldPlayerSprintLengthBoost then
	ply:SetNWFloat("w_stamina", math.max(ply:GetNWFloat("w_stamina", 0)-(advttt_sprint_depletion:GetFloat() * 0.001), 0))
else
	ply:SetNWFloat("w_stamina", math.max(ply:GetNWFloat("w_stamina", 0)-(advttt_sprint_depletion:GetFloat() * 0.003), 0))
end

This is what actually does the work.

]]--

