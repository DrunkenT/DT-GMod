
AddCSLuaFile()

local BASE						= weapons.GetStored( "weapon_ttt_m16" )

SWEP.HoldType					= BASE.HoldType

if CLIENT then
   SWEP.PrintName				= BASE.PrintName .. " | Stingray"
   SWEP.Slot					= BASE.Slot
   SWEP.Icon 					= BASE.Icon
   SWEP.IconLetter 				= BASE.IconLetter
end

SWEP.Base						= BASE.Base
SWEP.Spawnable 					= true
SWEP.Skin 						= "models/props/de_nuke/fuel_cask"

SWEP.Kind 						= BASE.Kind
SWEP.WeaponID					= BASE.WeaponID

SWEP.Primary.Delay				= BASE.Primary.Delay
SWEP.Primary.Recoil				= BASE.Primary.Recoil
SWEP.Primary.Automatic 			= BASE.Primary.Automatic
SWEP.Primary.Ammo 				= BASE.Primary.Ammo
SWEP.Primary.Damage 			= BASE.Primary.Damage
SWEP.Primary.Cone 				= BASE.Primary.Cone
SWEP.Primary.ClipSize 			= BASE.Primary.ClipSize
SWEP.Primary.ClipMax 			= BASE.Primary.ClipMax
SWEP.Primary.DefaultClip 		= BASE.Primary.DefaultClip
SWEP.AutoSpawnable      		= false
SWEP.AmmoEnt 					= BASE.AmmoEnt

SWEP.UseHands					= BASE.UseHands
SWEP.ViewModelFlip				= BASE.ViewModelFlip
SWEP.ViewModelFOV				= BASE.ViewModelFOV
SWEP.ViewModel					= "models/weapons/cstrike/c_rif_m4a1.mdl"
SWEP.WorldModel					= "models/weapons/w_rif_m4a1.mdl"

SWEP.Primary.Sound				= BASE.Primary.Sound

SWEP.IronSightsPos				= BASE.IronSightsPos
SWEP.IronSightsAng				= BASE.IronSightsAng


-- WeaponSkins

function SWEP:SetupDataTables()

	self:NetworkVar( "Entity", 2, "ViewModel" )
	self:NetworkVar( "Bool", 3, "Ironsights" )
	
end


local ply

function SWEP:ViewModelDrawn( ViewModel )

	ply = self.Owner
	self:SetViewModel( ViewModel )
	self:PaintMaterial( ViewModel )
	
end

function SWEP:PaintMaterial( vm )

	if CLIENT and IsValid( vm ) then
		local Mat = self.Skin or ""
		if IsValid( vm ) and vm:GetModel() == self.ViewModel then
			vm:SetMaterial( Mat )
		end
	end
	
end

function SWEP:DrawWorldModel()

	self:SetMaterial( self.Skin or "" )
	self:DrawModel()
	
end

function SWEP:ClearMaterial()

	if IsValid( ply ) then
		local Viewmodel = ply:GetViewModel()
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



