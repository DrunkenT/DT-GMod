
AddCSLuaFile()

SWEP.HoldType = "pistol"


if CLIENT then
   SWEP.PrintName = "Glock | Yellow Camo"
   SWEP.Slot = 1

   SWEP.Icon = "vgui/ttt/icon_glock"
   SWEP.IconLetter = "c"
end

SWEP.Kind = WEAPON_PISTOL
SWEP.WeaponID = AMMO_GLOCK
SWEP.Skin = "drunkent/tttweaponskins/v_models/skin_glock_yellowc"
SWEP.World = "drunkent/tttweaponskins/w_models/w_skin_glock_yellowc"

SWEP.Base = "weapon_tttbase"

local main = weapons.Get( "weapon_ttt_glock" )
SWEP.Primary.Recoil	= main.Primary.Recoil
SWEP.Primary.Damage = main.Primary.Damage
SWEP.Primary.Delay = main.Primary.Delay
SWEP.Primary.Cone = main.Primary.Cone
SWEP.Primary.ClipSize = main.Primary.ClipSize
SWEP.Primary.Automatic = main.Primary.Automatic
SWEP.Primary.DefaultClip = main.Primary.DefaultClip
SWEP.Primary.ClipMax = main.Primary.ClipMax
SWEP.Primary.Ammo = main.Primary.Ammo
SWEP.AutoSpawnable = false
SWEP.AmmoEnt = main.AmmoEnt

SWEP.UseHands			= true
SWEP.ViewModelFlip		= false
SWEP.ViewModelFOV		= 54
SWEP.ViewModel  = "models/weapons/cstrike/c_pist_glock18.mdl"
SWEP.WorldModel = "models/weapons/w_pist_glock18.mdl"

SWEP.Primary.Sound = Sound( "Weapon_Glock.Single" )
SWEP.IronSightsPos = Vector( -5.79, -3.9982, 2.8289 )

SWEP.HeadshotMultiplier = 1.75

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