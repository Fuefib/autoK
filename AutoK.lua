

local AutoK = {}
AutoK.previousTime = GetTimeStamp()
AutoK.isActive = false
AutoK.isAvAOnly = false
AutoK.isLogDebug = false -- Set at 'true' to show debug informations

AutoK.slashCommand = "autok"
AutoK.paramOn = "on"
AutoK.paramOff = "off"
AutoK.paramAvA = "ava"
AutoK.paramDebug = "debug"

-- Slash Commands handler
SLASH_COMMANDS["/" .. AutoK.slashCommand] = function (param)
	if(param == AutoK.paramOn) then
		AutoK.setOn()
	elseif(param == AutoK.paramOff) then
		AutoK.setOff()
	elseif(param == AutoK.paramAvA) then
		AutoK.setAvA()
	elseif(param == AutoK.paramDebug) then
		AutoK.isLogDebug = true
	else	
		AutoK.showHelp()
	end
end


function AutoKUpdate ()
	local currentTime = GetTimeStamp()
	if(GetDiffBetweenTimeStamps(currentTime, AutoK.previousTime) > 1 ) then
		AutoK.previousTime = currentTime
	
		local groupSize = GetGroupSize()
		local members = ""
		
		if(groupSize > 0) then
			for id=1,groupSize
			do
				local unitTag = GetGroupUnitTagByIndex(id)
				local isOnline = IsUnitOnline(unitTag)
			
				if(AutoK.isLogDebug) then
					members = members .. "    " 
					members = members .. GetUnitName(unitTag)
					members = members .. " (" .. tostring(isOnline) .. ")"
					members = members .. "\n"
				end
				
				if( not isOnline and AutoK.isActive) then
					GroupKick(unitTag)			
				end
			end
		
		else if (AutoK.isActive) then
				d("[autoK] Group is now empty, AutoK will be disabled")
				AutoK.setOff()
			end
		end
		
		if(AutoK.isLogDebug) then
			AutoK.debug(groupSize, members)
		end
	end
end


AutoK.debug = function (groupSize,members) 
	AutoKTime:SetText(string.format("Time: %s", GetTimeString()))
	AutoKPartySize:SetText(string.format("Party Size: %d", groupSize))
	AutoKActive:SetText(string.format("Active: %s ; AvA : %s", tostring(AutoK.isActive), tostring(AutoK.isAvAOnly)))
	AutoKMembers:SetText(string.format("Members: \n%s", members))
end


AutoK.setOn = function ()
	local groupSize = GetGroupSize()
	if(groupSize > 0) then
		d("[autoK] Enabling AutoK")
		AutoK.isActive = true
	else
		d("[autoK] Group is empty. Won't enable AutoK")
		AutoK.isActive = false
	end
end

AutoK.setOff = function  ()
	d("[autoK] Disabling AutoK")
	AutoK.isActive = false
end

AutoK.setAvA = function  ()
	local groupSize = GetGroupSize()
	if(groupSize > 0) then
		d("[autoK] Enabling AutoK in AvA mode")
		AutoK.isActive = true
		AutoK.isAvAOnly = true
	else
		d("[autoK] Group is empty. Won't enable AutoK")
		AutoK.isActive = false
	end
end

AutoK.showHelp = function ()
	d("AutoK Help :")
	d("  '/" .. AutoK.slashCommand .. " on'  - Enable AutoK. Will kick offline players.")
	d("  '/" .. AutoK.slashCommand .. " ava' - Enable AutoK in AvA only mode. Will kick players who are offline, out of Cyrodill, or in another campaign.")
	d("  '/" .. AutoK.slashCommand .. " off' - Disable AutoK. Will no longer kick offline players.")
end