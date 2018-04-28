
AddCSLuaFile()

local BASE = weapons.GetStored( "weapon_ttt_p90" )

SWEP.HoldType					= BASE.HoldType

if CLIENT then
   SWEP.PrintName				= BASE.PrintName .. " | Red Camo"
   SWEP.Slot					= BASE.Slot
   SWEP.Icon 					= BASE.Icon
end

SWEP.Base						= BASE.Base
SWEP.Spawnable 					= true
SWEP.Skin 						= "drunkent/tttweaponskins/v_models/skin_p90_red"
SWEP.World 						= "drunkent/tttweaponskins/w_models/w_skin_p90_red"

SWEP.Kind 						= BASE.Kind

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
SWEP.ViewModel					= "models/weapons/cstrike/c_smg_p90.mdl"
SWEP.WorldModel					= "models/weapons/w_smg_p90.mdl"

SWEP.Primary.Sound 				= BASE.Primary.Sound
SWEP.Secondary.Sound 			= BASE.Secondary.Sound

SWEP.IronSightsPos      		= BASE.IronSightsPos
SWEP.IronSightsAng      		= BASE.IronSightsAng

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
      self.Owner:SetFOV(self.Owner:GetFOV() * 0.5, 0.5)
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
   self:EmitSound( self.Secondary.Sound )

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

if CLIENT then
   local scope = surface.GetTextureID("sprites/scope")
   function SWEP:DrawHUD()
      if self:GetIronsights() then
         surface.SetDrawColor( 0, 0, 0, 255 )
         
         local x = ScrW() / 2.0
         local y = ScrH() / 2.0
         local scope_size = ScrH()

         -- crosshair
         local gap = 300
         local length = scope_size
		 surface.SetDrawColor( 0, 0, 0, 255 )
         surface.DrawLine( x - length, y, x - gap, y )
         surface.DrawLine( x + length, y, x + gap, y )
         surface.DrawLine( x, y - length, x, y - gap )
         surface.DrawLine( x, y + length, x, y + gap )

         gap = 25
         length = 50
         surface.DrawLine( x - length, y, x - gap, y )
         surface.DrawLine( x + length, y, x + gap, y )
         surface.DrawLine( x, y - length, x, y - gap )
         surface.DrawLine( x, y + length, x, y + gap )
		 
		 gap = 75
		 length = 100
		 surface.DrawLine( x - length, y, x - gap, y )
         surface.DrawLine( x + length, y, x + gap, y )
         surface.DrawLine( x, y - length, x, y - gap )
         surface.DrawLine( x, y + length, x, y + gap )
		 


         -- cover edges
		 surface.SetDrawColor( 0, 0, 0, 255 )
         local sh = scope_size / 2
         local w = (x - sh) + 2
         surface.DrawRect(0, 0, w, scope_size)
         surface.DrawRect(x + sh - 2, 0, w, scope_size)

         surface.SetDrawColor(255, 0, 0, 255)
         
		 surface.DrawLine(x + 3, y + 3, x + 10, y + 10)
		 surface.DrawLine(x + -3, y + -3, x + -10, y + -10)
		 surface.DrawLine(x + 3, y + -3, x + 10, y + -10)
		 surface.DrawLine(x + -3, y + 3, x + -10, y + 10)
		 

         -- scope
         surface.SetTexture(scope)
         surface.SetDrawColor(255, 255, 255, 255)

         surface.DrawTexturedRectRotated(x, y, scope_size, scope_size, 0)

      else
         return self.BaseClass.DrawHUD(self)
      end
   end

   function SWEP:AdjustMouseSensitivity()
      return (self:GetIronsights() and 0.2) or nil
   end
end
