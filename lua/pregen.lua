local function IsRagdoll(phy)
	if !file.Exists(phy, "GAME") then
		return false
	end

	local F = file.Open(phy, "rb", "GAME")
	F:Seek(8)
	local solid_count = F:ReadLong()
	F:Close()
	return (solid_count and solid_count > 1)
end

local n = 0

local models = {}

local function PreGenerate(path)
	local files, folders = file.Find(path, "GAME")
	path = path:sub(1,-2)
	for _, file_name in ipairs(files) do 
		local mdl = path..file_name
		local F = file.Open(mdl, "rb", "GAME")
		F:Seek(8)
		local checksum = F:Read(4)
		F:Close()
		if (file_name:sub(-4) == ".mdl" and !file.Exists("gibsplat2/model_data/"..util.CRC(mdl..checksum)..".txt", "DATA") and !file.Exists("materials/gibsplat2/model_data/"..util.CRC(mdl..checksum)..".vmt", "GAME") and IsRagdoll(mdl:sub(1,-4).."phy")) then
			if util.IsValidRagdoll(mdl) then
				n = n+1
				models[n] = mdl			
			end
		end
	end
	for _, folder in ipairs(folders) do
		PreGenerate(path..folder.."/*")
	end
end

local list = {
	--"models/humans/*",
	--"models/zombie/*",
	"models/*",
	--"models/player/*",
}

local temp

local key = 1

local function Process()
	if #models == 0 then
		for _, path in ipairs(list) do
			PreGenerate(path)
		end		
	end
	local mdl = models[key]
	if !mdl then
		SafeRemoveEntity(temp)
		return
	end
	
	SafeRemoveEntity(temp)
	
	temp = ents.Create("prop_ragdoll")
	temp:SetModel(mdl)
	temp:Spawn()
		
	key = key + 1
	timer.Simple(0.5, Process)
end

timer.Simple(1, Process)
