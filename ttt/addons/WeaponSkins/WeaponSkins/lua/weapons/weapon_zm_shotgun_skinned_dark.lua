
AddCSLuaFile()

local BASE = weapons.GetStored( "weapon_zm_shotgun" )

SWEP.HoldType					= BASE.HoldType

if CLIENT then
   SWEP.PrintName 				= BASE.PrintName .. " | Dark"
   SWEP.Slot 					= BASE.Slot
   SWEP.Icon 					= BASE.Icon
   SWEP.IconLetter 				= BASE.IconLetter
end


SWEP.Base						= BASE.Base
SWEP.Spawnable 					= true
SWEP.Skin 						= "drunkent/tttweaponskins/v_models/skin_xm1014_dark"
SWEP.World 						= "drunkent/tttweaponskins/w_models/w_skin_xm1014_dark"

SWEP.Kind 						= BASE.Kind
SWEP.WeaponID 					= BASE.WeaponID

SWEP.Primary.Ammo 				= BASE.Primary.Ammo
SWEP.Primary.Damage 			= BASE.Primary.Damage
SWEP.Primary.Cone 				= BASE.Primary.Cone
SWEP.Primary.Delay 				= BASE.Primary.Delay
SWEP.Primary.ClipSize 			= BASE.Primary.ClipSize
SWEP.Primary.ClipMax 			= BASE.Primary.ClipMax
SWEP.Primary.DefaultClip 		= BASE.Primary.DefaultClip
SWEP.Primary.Automatic 			= BASE.Primary.Automatic
SWEP.Primary.NumShots 			= BASE.Primary.NumShots
SWEP.AutoSpawnable     		 	= false
SWEP.AmmoEnt 					= BASE.AmmoEnt

SWEP.UseHands					= BASE.UseHands
SWEP.ViewModelFlip				= BASE.ViewModelFlip
SWEP.ViewModelFOV				= BASE.ViewModelFOV
SWEP.ViewModel					= "models/weapons/cstrike/c_shot_xm1014.mdl"
SWEP.WorldModel					= "models/weapons/w_shot_xm1014.mdl"
SWEP.Primary.Sound				= BASE.Primary.Sound
SWEP.Primary.Recoil				= BASE.Primary.Recoil

SWEP.IronSightsPos 				= BASE.IronSightsPos
SWEP.IronSightsAng 				= BASE.IronSightsAng

SWEP.reloadtimer 				= 0

function SWEP:SetupDataTables()
   self:DTVar("Bool", 0, "reloading")
	self:NetworkVar( "Entity", 2, "ViewModel" )
	self:NetworkVar( "Bool", 3, "Ironsights" )


end


function SWEP:Reload()

   --if self:GetNetworkedBool( "reloading", false ) then return end
   if self.dt.reloading then return end

   if not IsFirstTimePredicted() then return end

   if self:Clip1() < self.Primary.ClipSize and self.Owner:GetAmmoCount( self.Primary.Ammo ) > 0 then

      if self:StartReload() then
         return
      end
   end

end

function SWEP:StartReload()
   --if self:GetNWBool( "reloading", false ) then
   if self.dt.reloading then
      return false
   end

   self:SetZoom( false )
   self:SetIronsights( false )

   if not IsFirstTimePredicted() then return false end

   self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

   local ply = self.Owner

   if not ply or ply:GetAmmoCount(self.Primary.Ammo) <= 0 then
      return false
   end

   local wep = self

   if wep:Clip1() >= self.Primary.ClipSize then
      return false
   end

   wep:SendWeaponAnim(ACT_SHOTGUN_RELOAD_START)

   self.reloadtimer =  CurTime() + wep:SequenceDuration()

   --wep:SetNWBool("reloading", true)
   self.dt.reloading = true

   return true
end

function SWEP:PerformReload()
   local ply = self.Owner

   -- prevent normal shooting in between reloads
   self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

   if not ply or ply:GetAmmoCount(self.Primary.Ammo) <= 0 then return end

   if self:Clip1() >= self.Primary.ClipSize then return end

   self.Owner:RemoveAmmo( 1, self.Primary.Ammo, false )
   self:SetClip1( self:Clip1() + 1 )

   self:SendWeaponAnim(ACT_VM_RELOAD)

   self.reloadtimer = CurTime() + self:SequenceDuration()
end

function SWEP:FinishReload()
   self.dt.reloading = false
   self:SendWeaponAnim(ACT_SHOTGUN_RELOAD_FINISH)

   self.reloadtimer = CurTime() + self:SequenceDuration()
end

function SWEP:CanPrimaryAttack()
   if self:Clip1() <= 0 then
      self:EmitSound( "Weapon_Shotgun.Empty" )
      self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
      return false
   end
   return true
end

function SWEP:Think()
   if self.dt.reloading and IsFirstTimePredicted() then
      if self.Owner:KeyDown(IN_ATTACK) then
         self:FinishReload()
         return
      end

      if self.reloadtimer <= CurTime() then

         if self.Owner:GetAmmoCount(self.Primary.Ammo) <= 0 then
            self:FinishReload()
         elseif self:Clip1() < self.Primary.ClipSize then
            self:PerformReload()
         else
            self:FinishReload()
         end
         return
      end
   end
end

function SWEP:Deploy()
   self.dt.reloading = false
   self.reloadtimer = 0
   return self.BaseClass.Deploy(self)
end

-- The shotgun's headshot damage multiplier is based on distance. The closer it
-- is, the more damage it does. This reinforces the shotgun's role as short
-- range weapon by reducing effectiveness at mid-range, where one could score
-- lucky headshots relatively easily due to the spread.
function SWEP:GetHeadshotMultiplier(victim, dmginfo)
   local att = dmginfo:GetAttacker()
   if not IsValid(att) then return 3 end

   local dist = victim:GetPos():Distance(att:GetPos())
   local d = math.max(0, dist - 140)

   -- decay from 3.1 to 1 slowly as distance increases
   return 1 + math.max(0, (2.1 - 0.002 * (d ^ 1.25)))
end

-- WeaponSkins


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
   if self.dt.reloading then return end

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



function SWEP:Holster()
   self:ClearMaterial()
   self:SetIronsights(false)
   self:SetZoom(false)
   return true
end

