RegisterServerEvent("guduty:updateDutyStatus")
AddEventHandler("guduty:updateDutyStatus", function()
	TriggerClientEvent("guduty:updateDutyStatus-c", -1, getServerList())
end)

lib.callback.register('guduty:toggleDutyStatus', function(src)
    local dutyStat = GetResourceKvpString("DutyStatus:"..src)
    if dutyStat == "false" then
    	SetResourceKvp("DutyStatus:"..src, "true")
    else
    	SetResourceKvp("DutyStatus:"..src, "false")
    end
    dutyStat = GetResourceKvpString("DutyStatus:"..src)
    return dutyStat
end)
lib.callback.register('guduty:setupDutyStatus', function(src)
    	SetResourceKvp("DutyStatus:"..src, "false")
end)
function getServerList()
	local players = GetPlayers()
	local finalTBL = {}
    for _, id in ipairs(players) do
    	local dutyStat = GetResourceKvpString("DutyStatus:"..id)
	    if not dutyStat then
	    	SetResourceKvp("DutyStatus:"..id, "false")
	    end
	    dutyStat = GetResourceKvpString("DutyStatus:"..id)
	    table.insert(finalTBL, {[id]=dutyStat})
    end
    return finalTBL
end

RegisterCommand("duty", function(src)
	if IsAceAllowed("duty.toggle") then
		TriggerClientEvent("guduty:DutyToggle", src)
	else
		TriggerClientEvent('ox_lib:notify', src, {
		    title = 'GU Permissions',
		    description = 'You are not allowed to use this command.',
		    type = 'error',
		    position = 'top',
		    iconAnimation = "shake",
		})
	end
end)