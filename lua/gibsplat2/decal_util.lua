local MAT_CACHE = {}

function ApplyDecal(mat, ent, pos, norm, size)
	if !IsValid(ent) then
		return	
	end
	local size = size or 1
		
	MAT_CACHE[mat] = MAT_CACHE[mat] or Material(mat)
	mat = MAT_CACHE[mat]

	util.DecalEx(mat, ent, pos, norm, color_white, 1, 1)
end

local function IsInBox(p, min, max)
	return (p.y >= min.y and p.y <= max.y and p.z >= min.z and p.z <= max.z)
end

local function Overlaps(p1, p2, p3, min, max)
	if (IsInBox(p1, min, max) or IsInBox(p2, min, max) or IsInBox(p3, min, max)) then
		return true
	end
	if (p1.y < min.y) then
		if (p2.y < min.y) then
			if (p3.y < min.y) then
				return false
			end
		end

		local b = p3.z
		local m = (p1.z - p3.z) / (p1.y - p3.y)
		
		local z = min.y * m + b
		
		if (z >= min.z and z <= max.z) then
			return true
		end

		local m = (p2.z - p3.z) / (p2.y - p3.y)
		local z2 = min.y * m + b

		if (z >= min.z and z <= max.z) then
			return true
		end		
	elseif (p1.y > max.y) then
		if (p2.y > max.y) then
			if (p3.y > max.y) then
				return false
			end
		end

		local b = p3.z
		local m = (p1.z - p3.z) / (p1.y - p3.y)
		
		local z = max.y * m + b
		
		if (z >= min.z and z <= max.z) then
			return true
		end

		local m = (p2.z - p3.z) / (p2.y - p3.y)
		local z2 = max.y * m + b

		if (z >= min.z and z <= max.z) then
			return true
		end		
	elseif (p1.z < min.z) then
		if (p2.z < min.z) then
			if (p3.z < min.z) then
				return false
			end
		end

		local b = p3.z
		local m = (p1.z - p3.z) / (p1.y - p3.y)
		
		local y = (min.z - b) / m
		
		if (y >= min.y and y <= max.y) then
			return true
		end

		local m = (p2.z - p3.z) / (p2.y - p3.y)
		local y = (min.z - b) / m
		
		if (y >= min.y and y <= max.y) then
			return true
		end	
	elseif (p1.z > max.z) then
		if (p2.z > max.z) then
			if (p3.z > max.z) then
				return false
			end
		end
		local b = p3.z
		local m = (p1.z - p3.z) / (p1.y - p3.y)
		
		local y = (max.z - b) / m
		
		if (y >= min.y and y <= max.y) then
			return true
		end

		local m = (p2.z - p3.z) / (p2.y - p3.y)
		local y = (max.z - b) / m
		
		if (y >= min.y and y <= max.y) then
			return true
		end	
	end
	return false
end

local table_insert = table.insert

function GetDecalMesh(input, pos, ang, w, h, threshold)
	local tris_in = input.tris
	local tris_out = {}

	threshold = math.abs(threshold or 0)

	local dir = ang:Forward()

	w = w * 2
	h = h * 2

	local s2 = (w + w) ^ 2

	local min = Vector(0, -w, -h)
	local max = -min

	local W2L = Matrix()
	W2L:Translate(pos)
	W2L:Rotate(ang)
	W2L:Invert()

	for _, vert in ipairs(input.vertexes) do
		vert.lpos = nil
		vert.valid = false
		if (vert.normal:Dot(dir) < threshold) then
			if (vert.pos:DistToSqr(pos) < s2) then
				vert.valid = true				
			end
		end		
	end

	for vert_index = 1, #tris_in - 2, 3 do
		local v1 = tris_in[vert_index]
		local v2 = tris_in[vert_index + 1]
		local v3 = tris_in[vert_index + 2]

		if (v1.valid or v2.valid or v3.valid) then
			v1.lpos = v1.lpos or W2L * v1.pos
			v2.lpos = v2.lpos or W2L * v2.pos
			v3.lpos = v3.lpos or W2L * v3.pos

			local lp1 = v1.lpos
			local lp2 = v2.lpos
			local lp3 = v3.lpos

			if Overlaps(lp1, lp2, lp3, min, max) then
				v1.u = 0.5 + lp1.y / w / 2
				v1.v = 0.5 + lp1.z / h / 2

				v2.u = 0.5 + lp2.y / w / 2
				v2.v = 0.5 + lp2.z / h / 2

				v3.u = 0.5 + lp3.y / w / 2
				v3.v = 0.5 + lp3.z / h / 2

				table_insert(tris_out, v1)
				table_insert(tris_out, v2)
				table_insert(tris_out, v3)
			end			
		end
	end

	if (#tris_out != 0) then
		local M = Mesh()
		M:BuildFromTriangles(tris_out)
		return M, tris_out
	end
end