
-- IsFrameNameplate: Checks to see if the frame is a Blizz nameplate
local function IsFrameNameplate(frame)
	local region = frame:GetRegions()
	return region and region:GetObjectType() == "Texture" and region:GetTexture() == "Interface\\TargetingFrame\\UI-TargetingFrame-Flash"
end


local function FindNameplateFrames()
	local children = WorldFrame:GetChildren()
	for i = 1, select("#", children) do
		local frame = select(i, children)
		if IsFrameNameplate(frame) then
			print('found nameplate')
		end
	end
end


FindNameplateFrames()








--[[

local IsNamePlateFrame = function(f)
	local o = select(2,f:GetRegions())
	if not o or o:GetObjectType() ~= "Texture" or o:GetTexture() ~= "Interface\\Tooltips\\Nameplate-Border" then
		f.styled = true --don't touch this frame again
		return false
	end
	return true
end

local lastupdate = 0

local searchNamePlates = function(self,elapsed)
	lastupdate = lastupdate + elapsed

	if lastupdate > 0.33 then
		lastupdate = 0
		local num = select("#", WorldFrame:GetChildren())
		for i = 1, num do
			local f = select(i, WorldFrame:GetChildren())
			if not f.styled and IsNamePlateFrame(f) then
				styleNamePlate(f)
			end
		end

	end
end


PLATES = {}
local plate, curChildren, numChildren


-- IsFrameNameplate: Checks to see if the frame is a Blizz nameplate
local function IsFrameNameplate(frame)
   local region = frame:GetRegions()
   return region and region:GetObjectType() == "Texture" and region:GetTexture() == "Interface\\TargetingFrame\\UI-TargetingFrame-Flash"
end

-- OnWorldFrameChange: Checks for new Blizz Plates
local function OnWorldFrameChange(...)
   for index = 1, select("#", ...) do
      plate = select(index, ...)
      if IsFrameNameplate(plate) then
         table.insert(PLATES, plate)
         print(plate)
      end
   end
end

-- Detect New Nameplates
curChildren = WorldFrame:GetNumChildren()
if (curChildren ~= numChildren) then
   numChildren = curChildren
   OnWorldFrameChange(WorldFrame:GetChildren())
end

SlashCmdList['LuaBrowser']('filter PLATES')



]]

