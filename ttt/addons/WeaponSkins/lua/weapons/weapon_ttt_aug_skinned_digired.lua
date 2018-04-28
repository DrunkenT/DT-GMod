
AddCSLuaFile()

SWEP.HoldType			= "ar2"

if CLIENT then
   SWEP.PrintName			= "Steyr AUG | Digital Red"
   SWEP.Slot				= 2

   SWEP.Icon = "vgui/ttt/icon_aug"

end

SWEP.Base				= "weapon_tttbase"
SWEP.Spawnable = true
SWEP.Skin = "drunkent/tttweaponskins/v_models/skin_aug_red"
SWEP.World = "drunkent/tttweaponskins/w_models/w_skin_aug_red"

SWEP.Kind = WEAPON_HEAVY


local main = weapons.Get( "weapon_ttt_aug" )
SWEP.Primary.Delay			= main.Primary.Delay
SWEP.Primary.Recoil			= main.Primary.Recoil
SWEP.Primary.Automatic = main.Primary.Automatic
SWEP.Primary.Ammo = main.Primary.Ammo
SWEP.Primary.Damage = main.Primary.Damage
SWEP.Primary.Cone = main.Primary.Cone
SWEP.Primary.ClipSize = main.Primary.ClipSize
SWEP.Primary.ClipMax = main.Primary.ClipMax
SWEP.Primary.DefaultClip = main.Primary.DefaultClip
SWEP.AutoSpawnable      = false
SWEP.AmmoEnt = main.AmmoEnt

SWEP.UseHands			= true
SWEP.ViewModelFlip		= false
SWEP.ViewModelFOV		= 64
SWEP.ViewModel			= "models/weapons/cstrike/c_rif_aug.mdl"
SWEP.WorldModel			= "models/weapons/w_rif_aug.mdl"

SWEP.Primary.Sound = Sound( "Weapon_AUG.Single" )
SWEP.Secondary.Sound = Sound( "Default.Zoom" )

SWEP.IronSightsPos = Vector (5, -1.4358, 1.9033)
SWEP.IronSightsAng = Vector (1.3976, 0.4462, 0)


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
		 surface.SetDrawColor( 0, 0, 0, 255 )
         local gap = 300
         local length = scope_size
         surface.DrawLine( x - length, y, x - gap, y )
         surface.DrawLine( x + length, y, x + gap, y )
         surface.DrawLine( x, y - length, x, y - gap )
         surface.DrawLine( x, y + length, x, y + gap )

         gap = 150
         length = 175

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
         surface.DrawLine(x, y, x + 20, y + 20)
		 surface.DrawLine(x, y, x - 20, y + 20)

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