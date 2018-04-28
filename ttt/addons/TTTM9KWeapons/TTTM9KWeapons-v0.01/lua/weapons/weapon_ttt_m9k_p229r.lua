
if SERVER then

	AddCSLuaFile()
	
	// RESOURCES
--	resource.AddFile( "materials/vgui/ttt/icon_dt_m9k_p229r.vmt" )
--	
--	resource.AddFile( "materials/models/shells/9mm/shell_9mm.vmt" )
--	resource.AddFile( "materials/models/shellz/9mm.vmt" )
--	resource.AddFile( "materials/models/shellz/9mm.vtf" )
--	resource.AddFile( "materials/models/weapons/v_models/hands/sleeve_diffuse.vmt" )
--	resource.AddFile( "materials/models/weapons/v_models/hands/sleeve_diffuse.vtf" )
--	resource.AddFile( "materials/models/weapons/v_models/hands/sleeve_normal.vtf" )
--	resource.AddFile( "materials/models/weapons/v_models/hands/t_phoenix.vmt" )
--	resource.AddFile( "materials/models/weapons/v_models/thanez/p226/frame.vmt" )
--	resource.AddFile( "materials/models/weapons/v_models/thanez/p226/frame.vtf" )
--	resource.AddFile( "materials/models/weapons/v_models/thanez/p226/frame_exponent.vtf" )
--	resource.AddFile( "materials/models/weapons/v_models/thanez/p226/frame_normal.vtf" )
--	resource.AddFile( "materials/models/weapons/v_models/thanez/p226/slide.vtf" )
--	resource.AddFile( "materials/models/weapons/v_models/thanez/p226/slide_exponent.vtf" )
--	resource.AddFile( "materials/models/weapons/v_models/thanez/p226/slide_normal.vtf" )
--	resource.AddFile( "materials/models/weapons/v_models/thanez/p226/slide_st.vmt" )
--	resource.AddFile( "materials/models/weapons/w_models/thanez/p226/frame.vmt" )
--	resource.AddFile( "materials/models/weapons/w_models/thanez/p226/slide.vmt" )
--	resource.AddFile( "models/shells/shell_9mm.mdl" )
--	resource.AddFile( "models/weapons/v_sick_p228.mdl" )
--	resource.AddFile( "models/weapons/w_sig_229r.mdl" )
--	resource.AddFile( "sound/weapons/sig_p228/cloth.mp3" )
--	resource.AddFile( "sound/weapons/sig_p228/magin.mp3" )
--	resource.AddFile( "sound/weapons/sig_p228/magout.mp3" )
--	resource.AddFile( "sound/weapons/sig_p228/magshove.mp3" )
--	resource.AddFile( "sound/weapons/sig_p228/p228-1.wav" )
--	resource.AddFile( "sound/weapons/sig_p228/shift.mp3" )
--	resource.AddFile( "sound/weapons/sig_p228/sliderelease.mp3" )


	
end

if CLIENT then

	SWEP.PrintName = "P229R"
	SWEP.Slot = 1
	
	SWEP.Icon = "vgui/ttt/icon_dt_m9k_p229r"
	
end

SWEP.Category = "TTT M9K Weapons"

SWEP.Base = "weapon_tttbase"

SWEP.HoldType = "pistol"

SWEP.Kind = WEAPON_PISTOL

SWEP.Primary.Damage = 27
SWEP.Primary.Delay = 0.2
SWEP.Primary.Recoil = 1.5
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "pistol"
SWEP.Primary.Cone = 0.023
SWEP.Primary.ClipSize = 12
SWEP.Primary.ClipMax = 24
SWEP.Primary.DefaultClip = 12
SWEP.AutoSpawnable = true
SWEP.AmmoEnt = "item_ammo_pistol_ttt"

SWEP.UseHands = true
SWEP.ViewModelFlip = false
SWEP.ViewModelFOV = 72
SWEP.ViewModel = "models/weapons/v_sick_p228.mdl"
SWEP.WorldModel = "models/weapons/w_sig_229r.mdl"

SWEP.Primary.Sound = Sound( "Sauer1_P228.Single" )

SWEP.IronSightsPos = Vector(-2.655, -2, 1.03)
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