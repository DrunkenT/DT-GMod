
AddCSLuaFile()

SWEP.HoldType			= "ar2"

if CLIENT then
   SWEP.PrintName			= "AK-47 | Digital Red"
   SWEP.Slot				= 2

   SWEP.Icon = "vgui/ttt/icon_ak47"

end

SWEP.Base				= "weapon_tttbase"
SWEP.Spawnable = true
SWEP.Skin = "drunkent/tttweaponskins/v_models/skin_ak47_red"
SWEP.World = "drunkent/tttweaponskins/w_models/w_skin_ak47_red"

SWEP.Kind = WEAPON_HEAVY





local main = weapons.Get( "weapon_ttt_ak47" )
SWEP.Primary.Delay = main.Primary.Delay
SWEP.Primary.Recoil = main.Primary.Recoil
SWEP.Primary.Automatic = main.Primary.Automatic
SWEP.Primary.Ammo = main.Primary.Ammo
SWEP.Primary.Damage = main.Primary.Damage
SWEP.Primary.Cone = main.Primary.Cone
SWEP.Primary.ClipSize = main.Primary.ClipSize
SWEP.Primary.ClipMax = main.Primary.ClipMax
SWEP.Primary.DefaultClip = main.Primary.DefaultClip



--[[
SWEP.Primary.Delay			= 0.1
SWEP.Primary.Recoil			= 1.55
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "Pistol"
SWEP.Primary.Damage = 19
SWEP.Primary.Cone = 0.03
SWEP.Primary.ClipSize = 30
SWEP.Primary.ClipMax = 60
SWEP.Primary.DefaultClip = 30]]


SWEP.AutoSpawnable      = false
SWEP.AmmoEnt = main.AmmoEnt

SWEP.UseHands			= true
SWEP.ViewModelFlip		= false
SWEP.ViewModelFOV		= 64
SWEP.ViewModel			= "models/weapons/cstrike/c_rif_ak47.mdl"
SWEP.WorldModel			= "models/weapons/w_rif_ak47.mdl"

SWEP.Primary.Sound = Sound( "Weapon_AK47.Single" )

SWEP.IronSightsPos = Vector( -6.59, -5, 2.1 )
SWEP.IronSightsAng = Vector( 2.7, 0, 0.1 )


-- WeaponSkins

function SWEP:SetupDataTables()

	self:NetworkVar( "Entity", 2, "ViewModel" )
	self:NetworkVar( "Bool", 3, "Ironsights" )
	
end


local OG

function SWEP:ViewModelDrawn( ViewModel )

	OG = self.Owner
	self:SetViewModel( ViewModel )
	self:PaintMaterial( ViewModel )
	
end

function SWEP:PaintMaterial( vm )

	if ( CLIENT ) and IsValid( vm ) then
		local Mat = ( self.Skin or "" )
		if IsValid( vm ) and vm:GetModel() == self.ViewModel then
			vm:SetMaterial( Mat )
		end
	end
	
end

function SWEP:DrawWorldModel()

	self:SetMaterial( self.World or "" )
	self:DrawModel()
	
end

function SWEP:ClearMaterial()

	if IsValid( OG ) then
		local Viewmodel = OG:GetViewModel()
		if IsValid( Viewmodel ) then
			Viewmodel:SetMaterial( "" )
		end
	end
  
end

function SWEP:OwnerChanged()
	self:ClearMaterial()
	return true
end

function SWEP:OnRemove()
	self:ClearMaterial()
	return true
end


function SWEP:SetZoom(state)
   if CLIENT then return end
   if not (IsValid(self.Owner) and self.Owner:IsPlayer()) then return end
   if state then
      self.Owner:SetFOV(self.Owner:GetFOV() * 0.75, 0.5)
   else
      self.Owner:SetFOV(0, 0.2)
   end
end

-- Add some zoom to ironsights for this gun
function SWEP:SecondaryAttack()
   if not self.IronSightsPos then return end
   if self:GetNextSecondaryFire() > CurTime() then return end

   local bIronsights = not self:GetIronsights()

   self:SetIronsights( bIronsights )

   if SERVER then
      self:SetZoom( bIronsights )
   end

   self:SetNextSecondaryFire( CurTime() + 0.3 )
end

function SWEP:PreDrop()
   self:ClearMaterial()
   self:SetZoom(false)
   self:SetIronsights(false)
   return self.BaseClass.PreDrop(self)
end

function SWEP:Reload()
    if (self:Clip1() == self.Primary.ClipSize or
        self.Owner:GetAmmoCount(self.Primary.Ammo) <= 0) then
       return
    end
    self:DefaultReload(ACT_VM_RELOAD)
    self:SetIronsights(false)
    self:SetZoom(false)
end

function SWEP:Holster()
   self:ClearMaterial()
   self:SetIronsights(false)
   self:SetZoom(false)
   return true
end
