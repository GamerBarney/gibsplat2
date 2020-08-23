--[[
	Code borrowed from source sdk with slight modifications
]]

local COLLIDE_CHANCE = 0.005

game.AddDecal("BloodSmall", {
	"decals/flesh/blood1",
	"decals/flesh/blood2",
	"decals/flesh/blood3",
	"decals/flesh/blood4",
	"decals/flesh/blood5"
})

game.AddDecal("YellowBloodSmall", {
	"decals/alienflesh/shot1",
	"decals/alienflesh/shot2",
	"decals/alienflesh/shot3",
	"decals/alienflesh/shot4",
	"decals/alienflesh/shot5"
})

local bit_band = bit.band
local bit_lshift = bit.lshift

function EFFECT:Init(data)
	self.LocalPos = data:GetOrigin()
	self.LocalAng = data:GetAngles()

	self.Body = data:GetEntity()
	self.Color = data:GetColor()
	self.Bone = data:GetHitBox()
	self.Created = CurTime()
	self.DieTime = 5
	self.BloodColor = data:GetColor() or BLOOD_COLOR_RED

	if !IsValid(self.Body) then
		self:Remove()
		return
	end

	local matrix = self.Body:GetBoneMatrix(self.Bone)
	
	if !matrix then
		return
	end

	local bone_pos = matrix:GetTranslation()
	local bone_ang = matrix:GetAngles()

	self.Emitter = ParticleEmitter(bone_pos, false)
end

local function OnCollide(self, pos, norm)
	if (self.BloodColor == BLOOD_COLOR_RED) then
		util.Decal("BloodSmall", pos, norm)
	else
		util.Decal("YellowBlood", pos, norm)
	end
	self:SetDieTime(0)
end

function EFFECT:Think()
	local cur_time = CurTime()
	if !IsValid(self.Emitter) or !IsValid(self.Body) or
	 	cur_time - self.Created > self.DieTime or
	 	bit_band(self.Body:GetNWInt("GS2GibMask", 0), bit_lshift(1, self.Bone)) != 0 then
		return false
	end

	local matrix = self.Body:GetBoneMatrix(self.Bone)

	local bone_pos, bone_ang = LocalToWorld(self.LocalPos, self.LocalAng, matrix:GetTranslation(), matrix:GetAngles())

	local bone_dir = -bone_ang:Forward()

	local right = bone_dir:Cross(Vector(0, 0, 1))
	local up = right:Cross(bone_dir)

	for i = 1, 14 do
		local pos = bone_pos
		 + right * math.Rand(-0.5, 0.5)
		 + up * math.Rand(0.5, 0.5)

		local dir = bone_dir + VectorRand(-0.3, 0.3)

		local vel = dir * math.Rand(4, 40) * 10 * (self.Created + self.DieTime - cur_time) / self.DieTime
		
		--vel = vel * (0.5 + math.sin(self.Created - cur_time) * 0.5)

		local particle = self.Emitter:Add("effects/blood_drop", pos)

		particle:SetGravity(Vector(0, 0, -600))
		particle:SetVelocity(vel)
		particle:SetStartSize(math.Rand(0.2, 0.3) * 5)
		particle:SetStartLength(math.Rand(1.25, 2.75) * 5)
		particle:SetLifeTime(0)
		particle:SetDieTime(math.Rand(0.5, 1))
		if (self.BloodColor == BLOOD_COLOR_RED) then
			particle:SetColor(72, 0, 0)
		else
			particle:SetColor(195, 195, 0)
		end

		particle:SetCollide(true)

		if math.random() < COLLIDE_CHANCE then
			particle.BloodColor = self.BloodColor
			particle:SetCollideCallback(OnCollide)
		end
	end

	for i = 1, 24 do
		local pos = bone_pos
		 + right * math.Rand(-0.5, 0.5)
		 + up * math.Rand(0.5, 0.5)

		local dir = bone_dir + VectorRand(-1, 1)
		--dir.z = dir.z + math.Rand(0, 1)

		local vel = dir * math.Rand(2, 25) * 5 * (self.Created + self.DieTime - cur_time) / self.DieTime
		
		--vel = vel * (1 + math.sin((self.Created - cur_time) * 10))

		local particle = self.Emitter:Add("effects/blood_drop", pos)

		particle:SetGravity(Vector(0, 0, -600))
		particle:SetVelocity(vel)
		particle:SetStartSize(math.Rand(0.025, 0.05))
		particle:SetStartLength(math.Rand(2.5, 3.75))
		particle:SetLifeTime(0)
		particle:SetDieTime(math.Rand(0.5, 1))
		if (self.BloodColor == BLOOD_COLOR_RED) then
			particle:SetColor(72, 0, 0)
		else
			particle:SetColor(195, 195, 0)
		end

		particle:SetCollide(true)

		if math.random() < COLLIDE_CHANCE then
			particle.BloodColor = self.BloodColor
			particle:SetCollideCallback(OnCollide)
		end
	end

	for i = 1, 6 do
		local pos = bone_pos + bone_dir
		 + right * math.Rand(-1, 1)
		 + up * math.Rand(-1, 1)

		local vel = bone_dir * math.Rand(10, 20) + VectorRand(-0.5, 0.5)

		local particle = self.Emitter:Add("effects/blood_puff", pos)

		particle:SetGravity(Vector(0, 0, -600))
		particle:SetVelocity(vel)

		local size = math.Rand(1.5, 2)
		particle:SetStartSize(size)	
		particle:SetEndSize(size * 4)

		particle:SetStartAlpha(math.random(80, 128))
		particle:SetEndAlpha(0)
		particle:SetRoll(math.random(0, 360))
		particle:SetRollDelta(0)

		particle:SetLifeTime(0)
		particle:SetDieTime(math.Rand(0.01, 0.03))

		local colorRamp = math.Rand(0.75, 1.25)

		if (self.BloodColor == BLOOD_COLOR_RED) then
			particle:SetColor(72 * colorRamp, 0, 0)
		else
			particle:SetColor(195 * colorRamp, 195 * colorRamp, 0)
		end

		particle:SetCollide(true)

		if math.random() < COLLIDE_CHANCE then
			particle.BloodColor = self.BloodColor
			particle:SetCollideCallback(OnCollide)
		end
	end

	self:NextThink(cur_time + 1)

 	return true
end

function EFFECT:Render()
	
end