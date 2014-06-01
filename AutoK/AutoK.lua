

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
AutoK.deltaTime = 5
AutoK.uniqueId = "AutoK_for_the_win"

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


function AutoKUpdate()
	local currentTime = GetTimeStamp()
	if(GetDiffBetweenTimeStamps(currentTime, AutoK.previousTime) > AutoK.deltaTime ) then
		AutoK.previousTime = currentTime
	
		AutoK.debug("checking ...")
	
		local groupSize = GetGroupSize()
		
		if(groupSize > 0) then
			for id=1,groupSize
			do
				local unitTag = GetGroupUnitTagByIndex(id)
				local isOnline = IsUnitOnline(unitTag)
				local isInAvA = AutoK.isInCyrodiil(unitTag)
							
				if( (not isOnline and AutoK.isActive) 
					or (not isInAvA and AutoK.isAvAOnly) ) then
					GroupKick(unitTag)			
				end
			end
		
		elseif (AutoK.isActive) then
			d("[autoK] Group is now empty, AutoK will be disabled")
			AutoK.setOff()
		end
	end
end

AutoK.debug = function (message)
	if(AutoK.isLogDebug) then
		d("[autoK] debug -- " .. message)
	end
end

AutoK.isInCyrodiil = function (member)
	return GetUnitZone(member) == "Cyrodiil"
end

AutoK.registerEvent = function ()
	EVENT_MANAGER:RegisterForEvent(AutoK.uniqueId,  EVENT_TRACKING_UPDATE , AutoK.update)
end

AutoK.setOn = function ()
	local groupSize = GetGroupSize()
	if(AutoK.isActive) then
		d("[autoK] Already active")
	elseif(groupSize > 0) then
		d("[autoK] Enabling AutoK")
		AutoK.isActive = true
	else
		d("[autoK] Group is empty. Won't enable AutoK")
		AutoK.isActive = false
		AutoK.isAvAOnly = false
	end
end

AutoK.setAvA = function  ()
	local groupSize = GetGroupSize()
	if(groupSize > 0 and IsPlayerInAvAWorld()) then
		d("[autoK] Enabling AutoK in AvA mode")
		AutoK.isActive = true
		AutoK.isAvAOnly = true
	else
		d("[autoK] Group is empty. Won't enable AutoK")
		AutoK.isActive = false
		AutoK.isAvAOnly = false
	end
end

AutoK.setOff = function  ()
	d("[autoK] Disabling AutoK")
	AutoK.isActive = false
	AutoK.isAvAOnly = false
end



AutoK.showHelp = function ()
	d("AutoK Help :")
	d("  '/" .. AutoK.slashCommand .. " on'  - Enable AutoK. Will kick offline players.")
	d("  '/" .. AutoK.slashCommand .. " ava' - Enable AutoK in AvA only mode. Will kick players who are offline, out of Cyrodill.")
	d("  '/" .. AutoK.slashCommand .. " off' - Disable AutoK. Will no longer kick offline players.")
end