
if SERVER then

	AddCSLuaFile()
	
	// RESOURCES
--	resource.AddFile( "materials/vgui/ttt/icon_dt_m9k_mp40.vmt" )
--	
--	resource.AddFile( "materials/models/shells/9mm/shell_9mm.vmt" )
--	resource.AddFile( "materials/models/shellz/9mm.vmt" )
--	resource.AddFile( "materials/models/shellz/9mm.vtf" )
--	resource.AddFile( "materials/models/weapons/v_models/hands/sleeve_diffuse.vmt" )
--	resource.AddFile( "materials/models/weapons/v_models/hands/sleeve_diffuse.vtf" )
--	resource.AddFile( "materials/models/weapons/v_models/hands/sleeve_normal.vtf" )
--	resource.AddFile( "materials/models/weapons/v_models/hands/t_phoenix.vmt" )
--	resource.AddFile( "materials/models/weapons/v_models/mp40/mp40_d.vtf" )
--	resource.AddFile( "materials/models/weapons/v_models/mp40/mp40_g.vtf" )
--	resource.AddFile( "materials/models/weapons/v_models/mp40/mp40_n.vtf" )
--	resource.AddFile( "materials/models/weapons/v_models/mp40/mp40_texture.vmt" )
--	resource.AddFile( "materials/models/weapons/w_models/mp40/mp40_texture.vmt" )
--	resource.AddFile( "models/shells/shell_9mm.mdl" )
--	resource.AddFile( "models/weapons/v_mp40smg.mdl" )
--	resource.AddFile( "models/weapons/w_mp40smg.mdl" )
--	resource.AddFile( "sound/weapons/mp40/boltback.mp3" )
--	resource.AddFile( "sound/weapons/mp40/magin.mp3" )
--	resource.AddFile( "sound/weapons/mp40/magout.mp3" )
--	resource.AddFile( "sound/weapons/mp40/mp5-1.wav" )

	
end

if CLIENT then

	SWEP.PrintName = "MP40"
	SWEP.Slot = 2
	
	SWEP.Icon = "vgui/ttt/icon_dt_m9k_mp40"
	
end

SWEP.Category = "TTT M9K Weapons"

SWEP.Base = "weapon_tttbase"

SWEP.HoldType = "ar2"

SWEP.Kind = WEAPON_HEAVY

SWEP.Primary.Damage = 19
SWEP.Primary.Delay = 0.085
SWEP.Primary.Recoil = 1.3
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "smg1"
SWEP.Primary.Cone = 0.035
SWEP.Primary.ClipSize = 32
SWEP.Primary.ClipMax = 64
SWEP.Primary.DefaultClip = 32
SWEP.AutoSpawnable = true
SWEP.AmmoEnt = "item_ammo_smg1_ttt"

SWEP.UseHands = true
SWEP.ViewModelFlip = true
SWEP.ViewModelFOV = 72
SWEP.ViewModel = "models/weapons/v_mp40smg.mdl"
SWEP.WorldModel = "models/weapons/w_mp40smg.mdl"

SWEP.Primary.Sound = Sound( "mp40.Single" )

SWEP.IronSightsPos = Vector(3.89, -2, 1.47)
SWEP.IronSightsAng = Vector(0.3, 0, 0)
SWEP.CanBuy = nil

function SWEP:SetZoom(state)
   if CLIENT then return end
   if not (IsValid(self.Owner) and self.Owner:IsPlayer()) then return end
   if state then
      self.Owner:SetFOV((self.Owner:GetFOV() * 0.75), 1)
   else
      self.Owner:SetFOV(0, 0.5)
   end
end

-- Add some zoom to ironsights for this gun
function SWEP:SecondaryAttack()
   if not self.IronSightsPos then return end
   if self:GetNextSecondaryFire() > CurTime() then return end

   bIronsights = not self:GetIronsights()

   self:SetIronsights( bIronsights )

   if SERVER then
      self:SetZoom( bIronsights )
   end

   self:SetNextSecondaryFire( CurTime() + 0.3 )
end

function SWEP:PreDrop()
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
   self:SetIronsights(false)
   self:SetZoom(false)
   return true
end