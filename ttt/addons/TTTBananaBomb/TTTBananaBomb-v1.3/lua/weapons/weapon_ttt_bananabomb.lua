--[[

		TTT Banana Bomb
		
		Created by KyleTurdball and bamq
		
		
			The Drunken T's Server
				Trouble in Terrorist Town
				
]]--




if SERVER then

   AddCSLuaFile()

--   resource.AddFile( "materials/vgui/ttt/icon_bananabomb.vmt" ) -- Add the icon
   
end


SWEP.HoldReady = "grenade"
SWEP.HoldNormal = "slam"
SWEP.LimitedStock = true

if CLIENT then
	SWEP.EquipMenuData = {
		type = "Grenade",
		desc = [[
		A cluster banana bomb.
		Emits 5 bananas that explode.
  
  
		Created by: KyleTurdball and bamq
		]]
	};
end

if CLIENT then

   SWEP.PrintName			= "(T) Banana Bomb"
   SWEP.Instructions		= "When one explosion isn't enough."
   SWEP.Slot				= 3
   SWEP.SlotPos			= 0


   SWEP.Icon = "VGUI/ttt/icon_bananna"
   
   
   
   
       function SWEP:DrawWorldModel()
		--self:DrawModel()
		local ply = self.Owner
		local pos = self.Weapon:GetPos()
		local ang = self.Weapon:GetAngles()
		if ply:IsValid() then
			local bone = ply:LookupBone("ValveBiped.Bip01_R_Hand")
			if bone then
				pos,ang = ply:GetBonePosition(bone)
			end
		else
			self.Weapon:DrawModel() --Draw the actual model when not held.
			return
		end
		if self.ModelEntity:IsValid() == false then
			self.ModelEntity = ClientsideModel(self.WorldModel)
			self.ModelEntity:SetNoDraw(true)
		end
		
		self.ModelEntity:SetModelScale(0.5,0)
		self.ModelEntity:SetPos(pos)
		self.ModelEntity:SetAngles(ang+Angle(0,10,180))
		self.ModelEntity:DrawModel()
	end
	function SWEP:ViewModelDrawn()
		local ply = self.Owner
		if ply:IsValid() and ply == LocalPlayer() then
			local vmodel = ply:GetViewModel()
			local idParent = vmodel:LookupBone("v_weapon.Flashbang_Parent")
			local idBase = vmodel:LookupBone("v_weapon")
			if not vmodel:IsValid() or not idParent or not idBase then return end --Ensure the model and bones are valid.
			local pos, ang = vmodel:GetBonePosition(idParent)	
			local pos1, ang1 = vmodel:GetBonePosition(idBase) --Rotations were screwy with the parent's angle; use the models baseinstead.

			if self.ModelEntity:IsValid() == false then
				self.ModelEntity = ClientsideModel(self.WorldModel)
				self.ModelEntity:SetNoDraw(true)
			end
			
			self.ModelEntity:SetModelScale(0.5,0)
			self.ModelEntity:SetPos(pos-ang1:Forward()*1.25-ang1:Up()*1+2.3*ang1:Right())
			self.ModelEntity:SetAngles(ang1)
			self.ModelEntity:DrawModel()
			
		end
	end
end

SWEP.Base				= "weapon_tttbase"
SWEP.CanBuy = { ROLE_TRAITOR }
SWEP.AutoSpawnable = false
SWEP.Kind = WEAPON_NADE

SWEP.ViewModel			= "models/weapons/v_eq_flashbang.mdl"
SWEP.WorldModel			= "models/props/cs_italy/bananna_bunch.mdl"
SWEP.Weight			= 5

SWEP.ViewModelFlip = false
SWEP.AutoSwitchFrom		= true

SWEP.DrawCrosshair		= false

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Delay = 1.0
SWEP.Primary.Ammo		= "none"
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"
SWEP.Secondary.Delay = 6
SWEP.IsGrenade = true
SWEP.NoSights = true

SWEP.pin_pulled = false
SWEP.throw_time = 0

SWEP.was_thrown = false

SWEP.detonate_timer = 3.5

SWEP.DeploySpeed = 1.5

AccessorFuncDT( SWEP, "pin_pulled", "Pin")
AccessorFuncDT( SWEP, "throw_time", "ThrowTime")

AccessorFunc(SWEP, "det_time", "DetTime")

CreateConVar("ttt_no_nade_throw_during_prep", "0")

function SWEP:SetupDataTables()
   self:DTVar("Bool", 0, "pin_pulled")
   self:DTVar("Int", 0, "throw_time")
end

function SWEP:PrimaryAttack()
   self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

   if GetRoundState() == ROUND_PREP and GetConVar("ttt_no_nade_throw_during_prep"):GetBool() then
      return
   end

   self:PullPin()
end
local bananataunt = Sound("vo/Streetwar/rubble/ba_tellbreen.wav")
function SWEP:SecondaryAttack()
--	self.Weapon:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )
--	self.Weapon:EmitSound( bananataunt )
	if CLIENT then
		print( "Can't secondary attack with TTTBananaBomb sound " ..bananataunt.. "!" )
	end
end

function SWEP:PullPin()
   if self:GetPin() then return end

   local ply = self.Owner
   if not IsValid(ply) then return end

   self.Weapon:SendWeaponAnim(ACT_VM_PULLPIN)

   if self.SetWeaponHoldType then
      self:SetWeaponHoldType(self.HoldReady)
   end

   self:SetPin(true)

   self:SetDetTime(CurTime() + self.detonate_timer)
end


function SWEP:Think()
   local ply = self.Owner
   if not IsValid(ply) then return end

   -- pin pulled and attack loose = throw
   if self:GetPin() then
      -- we will throw now
      if not ply:KeyDown(IN_ATTACK) then
         self:StartThrow()

         self:SetPin(false)
         self.Weapon:SendWeaponAnim(ACT_VM_THROW)

         if SERVER then
            self.Owner:SetAnimation( PLAYER_ATTACK1 )
         end
      else
         -- still cooking it, see if our time is up
         if SERVER and self:GetDetTime() < CurTime() then
            self:BlowInFace()
         end
      end
   elseif self:GetThrowTime() > 0 and self:GetThrowTime() < CurTime() then
      self:Throw()
   end
end


function SWEP:BlowInFace()
   local ply = self.Owner
   if not IsValid(ply) then return end

   if self.was_thrown then return end

   self.was_thrown = true

   -- drop the grenade so it can immediately explode

   local ang = ply:GetAngles()
   local src = ply:GetPos() + (ply:Crouching() and ply:GetViewOffsetDucked() or ply:GetViewOffset())
   src = src + (ang:Right() * 10)

   self:CreateGrenade(src, Angle(0,0,0), Vector(0,0,1), Vector(0,0,1), ply)

   self:SetThrowTime(0)
   self:Remove()
end

function SWEP:StartThrow()
   self:SetThrowTime(CurTime() + 0.1)
end

function SWEP:Throw()
   if CLIENT then
      self:SetThrowTime(0)
   elseif SERVER then
      local ply = self.Owner
      if not IsValid(ply) then return end

      if self.was_thrown then return end

      self.was_thrown = true

      local ang = ply:EyeAngles()

      -- don't even know what this bit is for, but SDK has it
      -- probably to make it throw upward a bit
      if ang.p < 90 then
         ang.p = -10 + ang.p * ((90 + 10) / 90)
      else
         ang.p = 360 - ang.p
         ang.p = -10 + ang.p * -((90 + 10) / 90)
      end

      local vel = math.min(800, (90 - ang.p) * 6)

      local vfw = ang:Forward()
      local vrt = ang:Right()
      --      local vup = ang:Up()

      local src = ply:GetPos() + (ply:Crouching() and ply:GetViewOffsetDucked() or ply:GetViewOffset())
      src = src + (vfw * 8) + (vrt * 10)

      local thr = vfw * vel + ply:GetVelocity()

      self:CreateGrenade(src, Angle(0,0,0), thr, Vector(600, math.random(-1200, 1200), 0), ply)
	  self:CreateGrenade(src, Angle(0,0,0), thr, Vector(600, math.random(-1200, 1200), 0), ply)
	  self:CreateGrenade(src, Angle(0,0,0), thr, Vector(600, math.random(-1200, 1200), 0), ply)
	  self:CreateGrenade(src, Angle(0,0,0), thr, Vector(600, math.random(-1200, 1200), 0), ply)
	  self:CreateGrenade(src, Angle(0,0,0), thr, Vector(600, math.random(-1200, 1200), 0), ply)


      self:SetThrowTime(0)
      self:Remove()
   end
end

-- subclasses must override with their own grenade ent
function SWEP:GetGrenadeName()

   return "ttt_bananabomb_proj"
end


function SWEP:CreateGrenade(src, ang, vel, angimp, ply)
   local gren = ents.Create(self:GetGrenadeName())
   if not IsValid(gren) then return end

   gren:SetPos(src)
   gren:SetAngles(ang)

   --   gren:SetVelocity(vel)
   gren:SetOwner(ply)
   gren:SetThrower(ply)

   gren:SetGravity(0.4)
   gren:SetFriction(0.2)
   gren:SetElasticity(0.45)

   gren:Spawn()

   gren:PhysWake()

   local phys = gren:GetPhysicsObject()
   if IsValid(phys) then
      phys:SetVelocity(vel)
      phys:AddAngleVelocity(angimp)
   end

   -- This has to happen AFTER Spawn() calls gren's Initialize()
   gren:SetDetonateExact(self:GetDetTime())

   return gren
end

function SWEP:PreDrop()
   -- if owner dies or drops us while the pin has been pulled, create the armed
   -- grenade anyway
   if self:GetPin() then
      self:BlowInFace()
   end
end

function SWEP:Deploy()

   if self.SetWeaponHoldType then
      self:SetWeaponHoldType(self.HoldNormal)
   end

   self:SetThrowTime(0)
   self:SetPin(false)
   return true
end

function SWEP:Holster()
   if self:GetPin() then
      return false -- no switching after pulling pin
   end

   self:SetThrowTime(0)
   self:SetPin(false)
   return true
end

function SWEP:Reload()
   return false
end

function SWEP:Initialize()
   if self.SetWeaponHoldType then
      self:SetWeaponHoldType(self.HoldNormal)
   end

   self:SetDeploySpeed(self.DeploySpeed)

   self:SetDetTime(0)
   self:SetThrowTime(0)
   self:SetPin(false)

   self.was_thrown = false
   
   if CLIENT then
	self.ModelEntity = ClientsideModel(self.WorldModel)
	self.ModelEntity:SetNoDraw(true)
   end
   
end

function SWEP:OnRemove()
   if CLIENT and IsValid(self.Owner) and self.Owner == LocalPlayer() and self.Owner:Alive() then
      RunConsoleCommand("use", "weapon_ttt_unarmed")
   end
end
