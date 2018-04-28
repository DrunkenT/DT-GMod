ITEM.Name = 'Katana'
ITEM.Price = 5000
ITEM.Model = 'models/weapons/w_katana.mdl'
--ITEM.Material = 'vgui/ttt/icon_dt_katana.vmt'
ITEM.WeaponClass = 'weapon_ttt_katana'
ITEM.SingleUse = false



function ITEM:OnEquip(ply)
 
        for k,v in pairs(ply:GetWeapons())do
               if v.Kind == weapons.Get(self.WeaponClass).Kind then
                    WEPS.DropNotifiedWeapon(ply,v)
               end
        end
        ply:Give(self.WeaponClass)
        ply:SelectWeapon(self.WeaponClass)
       
end


function ITEM:OnHolster(ply)
	ply:StripWeapon(self.WeaponClass)
end