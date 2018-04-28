
ITEM.Name = 'Flak Jacket'
ITEM.Price = 500
ITEM.Material = 'drunkent/psaccessories/dt_flakjacket.vmt'
ITEM.Description = 'Reduces explosion damage by 50%.'

function ITEM:OnEquip( ply )

	ply.DT_ShouldPlayerReduceExplosionDamage = true

end

function ITEM:OnHolster( ply )

	ply.DT_ShouldPlayerReduceExplosionDamage = false

end

local function ReduceExplosionDamage( ent, dmginfo )

	if ent:IsPlayer() and ent.DT_ShouldPlayerReduceExplosionDamage and dmginfo:IsExplosionDamage() then

		dmginfo:ScaleDamage( 0.5 )

	end

end
hook.Add( "EntityTakeDamage", "DT_ReduceExplosionDamage_EntityTakeDamage", ReduceExplosionDamage )

