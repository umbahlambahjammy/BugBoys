AddCSLuaFile("structure_plane.lua")

ENT.Type 			= "anim"
ENT.Base 			= "base_bbentity"
//ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

if !SERVER then return end
------------------------------------------------------------------------------------------------
--all server from now on
------------------------------------------------------------------------------------------------
local angle = Angle( 0, 0, 0 )


function ENT:Initialize()
	self:SpecialInit()
	
	self:ChangePhysicsModel( self.Ref.model, COLLISION_GROUP_WEAPON, self.Ref.mass )
	
	self:SetIfCanGrab( false )

	
	-- Wake our physics
	local phys = self.Entity:GetPhysicsObject()
	
	--correct angles, tire on its side
	phys:SetAngles( Angle(0, 0, 90))
	
	--set to be slidy
	phys:SetMaterial("gmod_ice")
	
	--blimp has no gravity
	//phys:EnableGravity(false)
	
	if (phys:IsValid()) then
		phys:Wake()
	end
	
	
	//self.AttachedPucks = {}
	self.PosTable = 
	{
	Pos1 ={ name = "Pos1", vector = Vector(0,30,0), puckat = nil, boxat = nil, boxvector = Vector(0,55,0),},
	}
	
	self.CheckDir = 1
	self.Upsidedown_Frames = 0
	
	self.ForwardVelocity = 0
end

function ENT:Shoot( aim, pos )
	local obj = ents.Create( "subitem_missile_chopper" )

		obj:SetPos( pos )	
		obj.BBTeam = self.BBTeam
		if IsValid( self.Creator ) then
			obj.Creator = self.Creator
		end
		obj:SetOwner( self.Creator )
		obj:SetAngles( Angle(0,0,0) )
		obj:Spawn()
		
		obj:NoCollideTeam()
		obj:NoCollideEnt( self )
	
	
		
		local phys = obj:GetPhysicsObject()
			phys:SetVelocity(aim * 3500 )
			//phys:ApplyForceCenter( finalang * 15000 )
	
	self:EmitSound( self.Ref.sound_shoot,100,150 )
end

--triggers the bug to attach to the boat
function ENT:RayTrigger( activator )
	if !SERVER then return end

	--if the puck isnt yet attached
	if self:PuckTable_HasThis( activator.Puck ) != true then
		
		--make sure the puck is in range to attach to the boat
		if GetIfInRange( self:GetPos(), self.Ref.radius_attach, activator.Puck ) then
			self:AttachPuck( activator.Puck )
		else
			activator:ChatPrint( "You must stand closer to get on!")
			activator:PlayLocalSound( "Sound_Failed" )
		end
		
		--start the sound if its not already started
		if self.LoopingSound_A == nil then
			self.LoopingSound_A = CreateSound( self, self.Ref.sound_jet )
			self.LoopingSound_A:Play()
		end
	
	--if the puck is already attached
	else
		self:DetachPuck( activator.Puck )

		
	end
end


--make sure the attached players havent died or something
--if they have, remove them from the table
function ENT:MakeSurePucksAlive()
	if self:PuckTable_HasPucks() == true then
		for _, pos in pairs( self.PosTable ) do
			if pos.puckat != nil then
				if IsValid( pos.puckat ) != true then
					pos.puckat = nil
				end
			end
		end
	end
end


-- ENT:Think - Do our controls & powerups here --
function ENT:Think()
	local MelonPhysObj = self:GetPhysicsObject()

	
	local velo = self:GetVelocity( )
	local velonorm = self:GetVelocity( ):GetNormal()
	local veloxy = Vector(velo.x,velo.y,0)
	local veloxynorm = Vector(velo.x,velo.y,0):GetNormal()
	
	
	local input_thisframe = false
	local turning = false
	local forward_thisframe = false
	

	
	self:MakeSurePucksAlive()
	
	
	local function MovementInput( ply )
		local Aim = ply:EyeAngles()
		local speed = self:GetVelocity( ):Length()
		
		-- Check which key is pressed and move accordingly
		if (ply:KeyDown(IN_FORWARD)) then
			local vec = Vector(0,0,-30)
			local phys = self.Entity:GetPhysicsObject()
				phys:AddAngleVelocity( (-1 * phys:GetAngleVelocity( )) + vec) 
			
			input_thisframe = true
			turning = true
		end
		
		if (ply:KeyDown(IN_BACK)) then
			--[[
			local ang = ply:GetAimVector()
				ang = Vector(ang.x,ang.y,0)
				ang = ang:GetNormal()
				forcepos = self:GetPos() - (ang * 400)
			
			local phys = self:GetPhysicsObject()
				phys:ApplyForceOffset( TICK_FORCE_MULTIPLIER *  Vector(0,0,-50) , forcepos )
			]]--
			local vec = Vector(0,0,30)
			
			local phys = self.Entity:GetPhysicsObject()
				phys:AddAngleVelocity( (-1 * phys:GetAngleVelocity( )) + vec) 
			
			
			input_thisframe = true
			turning = true
		end
		
		
		if (ply:KeyDown(IN_MOVELEFT)) then
			if speed < 3000 then
				local vec = Vector(0,60,0)
				
				local phys = self.Entity:GetPhysicsObject()
					phys:AddAngleVelocity( (-1 * phys:GetAngleVelocity( )) + vec) 
		
			else
				local ang = ply:EyeAngles()
					ang = ang:Right()
					ang = Vector(ang.x,ang.y,0)
					ang = ang:GetNormal()
					forcepos = self:GetPos() - (ang * 400)
				
				local phys = self:GetPhysicsObject()
					phys:ApplyForceOffset( TICK_FORCE_MULTIPLIER *  Vector(0,0,-50) , forcepos )
			end
			
			input_thisframe = true
			turning = true
		end
		
		
		if (ply:KeyDown(IN_MOVERIGHT)) then
			if speed < 3000 then
				local vec = Vector(0,-60,0)
				
				local phys = self.Entity:GetPhysicsObject()
					phys:AddAngleVelocity( (-1 * phys:GetAngleVelocity( )) + vec) 
		
			else
				local ang = ply:EyeAngles()
					ang = -ang:Right()
					ang = Vector(ang.x,ang.y,0)
					ang = ang:GetNormal()
					forcepos = self:GetPos() - (ang * 400)
				
				local phys = self:GetPhysicsObject()
					phys:ApplyForceOffset( TICK_FORCE_MULTIPLIER *  Vector(0,0,-50) , forcepos )
			end
			
			input_thisframe = true
			turning = true
		end
		
		
		if (ply:KeyDown(IN_JUMP)) then
			if self.ForwardVelocity <= 1000 then
				self.ForwardVelocity = self.ForwardVelocity + 3
			end

			input_thisframe = true
			forward_thisframe = true
		end
		
		if (ply:KeyDown(IN_ATTACK)) then
			if self.ShootTimer != nil and CurTime() > self.ShootTimer then
				local aim = ply:GetAimVector():GetNormalized() 
				local pos = ply.Puck:GetPos() + Vector(0,0,60)
				self:Shoot( aim, pos )
				self.ShootTimer = CurTime() + self.Ref.shoot_delay
			end
		end
		
		if (ply:KeyDown(IN_DUCK)) then
			local Aim = -Aim:Up()
				Aim = Vector(0,0,Aim.z)
			MelonPhysObj:ApplyForceCenter( TICK_FORCE_MULTIPLIER *  Aim * self.Ref.force_add_vertical )

			input_thisframe = true
		end
	end
	
	
	--calculate movement input for all bugs which are attached to the boat
	for _, pos in pairs( self.PosTable ) do
		if pos.puckat != nil then
			local ent = pos.puckat
			local ownerply = ent.Owner
			
			MovementInput( ownerply )
		end
	end
	
	
	
	--make the plane go forward
	local newang = self:GetAngles()
	local finalang = newang:Forward()
	local finalangmod = Vector(finalang.x, finalang.y, finalang.z)
	
	MelonPhysObj:SetVelocity( finalang * self.ForwardVelocity )
	
	if forward_thisframe != true and self.ForwardVelocity < 0 then
		self.ForwardVelocity = self.ForwardVelocity - 4
	end
	
	
	
	--keep it upright
	if turning == false then
		local phys = self:GetPhysicsObject()
			phys:AddAngleVelocity( -.02 * phys:GetAngleVelocity( )) 
	end
	
	
	
	
	local speed = self:GetVelocity( ):Length()

	

	
	--
	if speed >= 200 then
		local angle = self:GetAngles()
		local upsidedown = 1
		if angle.z < 0 then
			upsidedown = 1
		elseif angle.z > 0 then
			upsidedown = -1
		end
		
	
		local newang = self:GetAngles()
		local finalang = newang:Right() * upsidedown
		
		--angular force, what up is to the airplane
		MelonPhysObj:ApplyForceCenter( TICK_FORCE_MULTIPLIER *  finalang * (speed * 6) )
		
		--upward force
		MelonPhysObj:ApplyForceCenter( TICK_FORCE_MULTIPLIER *  Vector(0,0,speed * 6) )
	end
	--
	
	
	
	
	--add negative vector to prevent the puck from exceeding the maximum speed which is 300
	--[[
	local movespeed = self.Ref.speed_max
	
	if speed > movespeed then
		//local normalized_velo = veloxy:GetNormal()
		//local neg_vec = -(veloxy - (normalized_velo))
		
		//local neg_vec = -veloxy
		local neg_vec = -velo
		
		MelonPhysObj:ApplyForceCenter( neg_vec * 50 )
	end
	]]--
	

	
	--code that makes the tank's open spot coordinates flip upside down, these are used for placing attached bugs
	local angle = self:GetAngles()
	local upsidedown = false
	
	if self.CheckDir >= 1 then
		if angle.z < 0 then
			upsidedown = true
		end
	elseif self.CheckDir < 1 then
		if angle.z > 0 then
			upsidedown = true
		end
	end
	
	if upsidedown == true then
		self.Upsidedown_Frames = self.Upsidedown_Frames + 1
		
		if self.Upsidedown_Frames >= 25 then
			self:FlipPosTable()
			self.CheckDir = -self.CheckDir
		end
	else
		self.Upsidedown_Frames = 0
	end
	
	


	--if no one is on the blimp, add force downward
	if self:PuckTable_HasPucks() != true then
		local Down = Vector(0,0,-1)
		MelonPhysObj:ApplyForceCenter( TICK_FORCE_MULTIPLIER *  Down * 2000 )
			if self.ForwardVelocity > 0 then
				self.ForwardVelocity = self.ForwardVelocity - 1
			end
			if self.ForwardVelocity < 0 then
				self.ForwardVelocity = self.ForwardVelocity + 1
			end
		
		if self.LoopingSound_A != nil then
			self.LoopingSound_A:Stop()
			self.LoopingSound_A = nil
		end
	end
	
	-- Call the think every frame
	self.Entity:NextThink(CurTime())
	return true
end


--turns the slow on or off
function ENT:TankSlow( x )
	self.Slowed = x
end


function ENT:FlipPosTable()
	for _, pos in pairs( self.PosTable ) do
		local oldvec = pos.vector
		local newvec = Vector( oldvec.x, -oldvec.y, oldvec.z )
		pos.vector = newvec
		
		local oldboxvec = pos.boxvector
		local newboxvec = Vector( oldboxvec.x, -oldboxvec.y, oldboxvec.z )
		pos.boxvector = newboxvec
		
		if pos.puckat != nil then
			local puck = pos.puckat
			local phys = self:GetPhysicsObject()
			local vec = phys:LocalToWorld( newvec )
			
			puck:SetParent( nil )
			puck:SetPos( vec )
			puck:SetAngles( self:GetAngles() )
			
			puck:SetParent( self )
			
			--if the puck is holding a box, switch the boxes position
			if pos.boxat != nil then
				local box = pos.boxat
				local vecbox = phys:LocalToWorld( newboxvec )
				
				box:SetParent( nil )
				box:SetPos( vecbox )
				box:SetAngles( self:GetAngles() )
				
				box:SetParent( self )
			end
		end
	end
end





function ENT:AttachPuck( puck )
	self.ShootTimer = CurTime() + 1
	--detach them from their current vehicle, if theyre already on one
	puck:DetachSelfFromVehicle()


	local function SetupPos( puck )
		local spot = nil
		local spot_box = nil
		for _, pos in pairs( self.PosTable ) do
			if pos.puckat == nil then
				pos.puckat = puck
				spot = pos.vector
				
				if IsValid( puck.CurGrabbedEnt ) then
					pos.boxat = puck.CurGrabbedEnt
					spot_box = pos.boxvector
				end
				
				break
			end
		end
		
		if spot == nil then
			return false
		end
	
		local phys = self:GetPhysicsObject()
		local vec = phys:LocalToWorld( spot )
		//local vec_attachments = phys:LocalToWorld( spot + Vector(0,25,0) )
		//local vec_box = phys:LocalToWorld( spot + Vector(0,25,0) )
		
		
		puck:SetJumpEnabled( false )
		puck:SetShootingEnabled( false )
		
		
		--parent whatever is parented to the puck, to the blimp
		if IsValid( puck.CurGrabbedEnt ) then
			local vecbox = phys:LocalToWorld( spot_box )
			puck.CurGrabbedEnt:SetParent( nil )
			puck.CurGrabbedEnt:SetAngles( self:GetAngles() )
			puck.CurGrabbedEnt:SetPos( vecbox )
			puck.CurGrabbedEnt:SetParent( self )
		end
		
		
		puck:SetPos( vec )
		puck:SetAngles( self:GetAngles() )
		puck:SetParent( self )
		//puck:Transparency_Set( 70 )
		
		--make the attached puck immune to damage while attached
		puck.CurTakeDamage = false
		puck.Vehicle = self
	end
	
	
	
	if SetupPos( puck ) == false then
		return false
	else
		return true
	end
end





function ENT:DetachAllPucks()
	for _, pos in pairs( self.PosTable ) do
		if pos.puckat != nil then
			local ent = pos.puckat
			
			self:DetachPuck( ent )
		end
	end
end



function ENT:DetachPuck( puck )
	for _, pos in pairs( self.PosTable ) do
		if pos.puckat == puck then
			local ent = pos.puckat
		
			if IsValid( ent.CurGrabbedEnt ) then
				ent.CurGrabbedEnt:SetParent( ent )
			end
		
			ent:SetParent( nil )
			ent:SetPos( ent:GetPos() )
			
			ent:SetJumpEnabled( true )
			ent:SetShootingEnabled( true )
			

			local phys = ent:GetPhysicsObject()
				if IsValid( phys ) then
					phys:Wake()
				end
				//phys:SetVelocity( Vector(0,0,1) * 300 )
			
			ent.CurTakeDamage = true
			ent.Vehicle = nil
				
			pos.puckat = nil
			pos.boxat = nil
			return
		end
	end
end


--returns true if the table has this puck already
function ENT:PuckTable_HasThis( puck )
	for _, pos in pairs( self.PosTable ) do
		if pos.puckat == puck then
			return true
		end
	end
	return false
end


--returns true if there is currently a puck attached
function ENT:PuckTable_HasPucks()
	for _, pos in pairs( self.PosTable ) do
		if pos.puckat != nil then
			return true
		end
	end
	return false
end


function ENT:OnRemove( )
	if !SERVER then return end

	if self.LoopingSound_A != nil then
		self.LoopingSound_A:Stop()
	end
	
	if self.LoopingSound_B != nil then
		self.LoopingSound_B:Stop()
	end
	

	self:DetachAllPucks()
end






-- ENT:PhysicsCollide - We hit stuff, do custom damage functions --
--[[
function ENT:PhysicsCollide(Data, PhysObj)
	-- Play sound, depending on speed
	//if ((Data.DeltaTime >= 0.8) and (Data.Speed > 100)) or (Data.Speed > 250) then
		//self.Entity:EmitSound("physics/rubber/rubber_tire_impact_hard"..math.random(1, 3)..".wav", 100, 100)
	//end
	
	if self:PuckTable_HasPucks() != true then return end
	
	if ((Data.DeltaTime >= 0.8) and (Data.Speed > 100)) or (Data.Speed > 250) then
		self.Entity:EmitSound("physics/metal/metal_grate_impact_hard"..math.random(1, 3)..".wav", 100, 100)
	end
	
	--do force or fall damage

	//if Data.HitEntity:IsWorld() and (Data.Speed > 400) then
		//self:HurtEnt( 20, self, self )
	//end
	
	
	local normx = Data.HitNormal[1]
	local normy = Data.HitNormal[2]
	
	if Data.HitEntity:IsWorld() and normx > .2 or normy > .2 then
		//`print("breaking")
		self:Break()
	end
end
]]--