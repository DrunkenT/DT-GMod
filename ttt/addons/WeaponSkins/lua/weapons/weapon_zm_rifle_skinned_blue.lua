AddCSLuaFile()

SWEP.HoldType           = "ar2"

if CLIENT then
   SWEP.PrintName          = "Scout | Blue"
   SWEP.Slot               = 2
   SWEP.Icon = "vgui/ttt/icon_scout"
   SWEP.IconLetter = "n"
end

SWEP.Base               = "weapon_tttbase"
SWEP.Spawnable = true

SWEP.Kind = WEAPON_HEAVY
SWEP.WeaponID = AMMO_RIFLE
SWEP.Skin = "drunkent/tttweaponskins/v_models/skin_scout_blue"
SWEP.World = "drunkent/tttweaponskins/w_models/w_skin_scout_blue"

local main = weapons.Get( "weapon_zm_rifle" )
SWEP.Primary.Delay          = main.Primary.Delay
SWEP.Primary.Recoil         = main.Primary.Recoil
SWEP.Primary.Automatic = main.Primary.Automatic
SWEP.Primary.Ammo = main.Primary.Ammo
SWEP.Primary.Damage = main.Primary.Damage
SWEP.Primary.Cone = main.Primary.Cone
SWEP.Primary.ClipSize = main.Primary.ClipSize
SWEP.Primary.ClipMax = main.Primary.ClipMax -- keep mirrored to ammo
SWEP.Primary.DefaultClip = main.Primary.DefaultClip

SWEP.HeadshotMultiplier = 4

SWEP.AutoSpawnable      = false
SWEP.AmmoEnt = main.AmmoEnt

SWEP.UseHands			= true
SWEP.ViewModelFlip		= false
SWEP.ViewModelFOV		= 54
SWEP.ViewModel          = Model("models/weapons/cstrike/c_snip_scout.mdl")
SWEP.WorldModel         = Model("models/weapons/w_snip_scout.mdl")

SWEP.Primary.Sound = Sound(")weapons/scout/scout_fire-1.wav")

SWEP.Secondary.Sound = Sound("Default.Zoom")

SWEP.IronSightsPos      = Vector( 5, -15, -2 )
SWEP.IronSightsAng      = Vector( 2.6, 1.37, 3.5 )

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
      self.Owner:SetFOV(self.Owner:GetFOV() * 0.25, 0.5)
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
         
         local scrW = ScrW()
         local scrH = ScrH()

         local x = scrW / 2.0
         local y = scrH / 2.0
         local scope_size = scrH

         -- crosshair
         local gap = 80
         local length = scope_size
         surface.DrawLine( x - length, y, x - gap, y )
         surface.DrawLine( x + length, y, x + gap, y )
         surface.DrawLine( x, y - length, x, y - gap )
         surface.DrawLine( x, y + length, x, y + gap )

         gap = 0
         length = 50
         surface.DrawLine( x - length, y, x - gap, y )
         surface.DrawLine( x + length, y, x + gap, y )
         surface.DrawLine( x, y - length, x, y - gap )
         surface.DrawLine( x, y + length, x, y + gap )


         -- cover edges
         local sh = scope_size / 2
         local w = (x - sh) + 2
         surface.DrawRect(0, 0, w, scope_size)
         surface.DrawRect(x + sh - 2, 0, w, scope_size)
         
         -- cover gaps on top and bottom of screen
         surface.DrawLine( 0, 0, scrW, 0 )
         surface.DrawLine( 0, scrH - 1, scrW, scrH - 1 )

         surface.SetDrawColor(255, 0, 0, 255)
         surface.DrawLine(x, y, x + 1, y + 1)

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
