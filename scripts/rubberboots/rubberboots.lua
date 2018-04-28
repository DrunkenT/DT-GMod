--Made by s3kshun 61 for The DrunkenT Server

ITEM.Name = 'Rubber Boots'
ITEM.Price = 6500
ITEM.Model = 'models/xqm/helicopterrotorhuge.mdl' --Temporary until boot model is added, this is just for fun.
ITEM.Bone = 'ValveBiped.Bip01_Spine2'
ITEM.Description = 'Reduces fall damage by 70%.'

local ShouldRecieveFallDamage
function ITEM:OnEquip(ply, modifications)
	ply:PS_AddClientsideModel(self.ID)
	ply.ShouldRecieveFallDamage = true
end

function ITEM:OnHolster(ply)
	ply:PS_RemoveClientsideModel(self.ID)
	ply.ShouldRecieveFallDamage = false
end

function ITEM:ModifyClientsideModel(ply, model, pos, ang)
	model:SetModelScale(0, 0)

	return model, pos, ang
end

local function ReduceFallDamage(ent, dmginfo)
		if ent:IsPlayer() and ent.ShouldRecieveFallDamage and dmginfo:IsFallDamage() then
			--if dmginfo:GetDamage() < 300 then
				dmginfo:ScaleDamage(0.3)
			--else
			--	dmginfo:ScaleDamage(0.15)
			--end
		end
	end
hook.Add("EntityTakeDamage", "ReduceFallDamage", ReduceFallDamage)
