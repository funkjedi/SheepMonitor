

--local WorldFrame = WorldFrame
function FindNameplateFrames()

	for i = 1, select("#", WorldFrame:GetChildren()) do
		local nameplateFrame = select(i, WorldFrame:GetChildren())

		-- REGIONS
		-- 1 = Threat glow, is the mob attacking you, or almost not etc
		-- 2 = Health bar/level border
		-- 3 = Border for the casting bar
		-- 4 = Spell icon for the casting bar
		-- 5 = Glow around the health bar when hovering over
		-- 6 = Name text
		-- 7 = Level text
		-- 8 = Skull icon if the mob/player is 10 or more levels higher then you
		-- 9 = Raid icon when you're close enough to the mob/player to see the name plate
		-- 10 = Elite icon

		local nativeGlowRegion, overlayRegion, highlightRegion, nameTextRegion, levelTextRegion, bossIconRegion, raidIconRegion, stateIconRegion = nameplateFrame:GetRegions()

		-- if the frame is a nameplate then the first region should match the following criteria
		if nativeGlowRegion and nativeGlowRegion:GetObjectType() == "Texture" and nativeGlowRegion:GetTexture() == "Interface\\TargetingFrame\\UI-TargetingFrame-Flash" then

			--local healthBar, castBar = nameplateFrame:GetChildren()
			--local castBarRegion, castBarOverlayRegion, castBarShieldRegion, spellIconRegion = castBar:GetRegions()

			print(nameplateFrame:GetName())
		end
	end
end



--[[


local WorldFrame, numOfChildren = WorldFrame, 0
local onUpdate = function(self)
	local numOfNewChildren = WorldFrame:GetNumChildren()
	if numOfChildren ~= numOfNewChildren then
		for i = numOfChildren + 1, numOfNewChildren do
			local frame = select(i, WorldFrame:GetChildren())
			if IsFrameNameplate(frame) then
				print('found nameplate')
			end
		end
		numOfChildren = numOfNewChildren
	end
end


]]
