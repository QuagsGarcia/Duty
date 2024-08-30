bigStatus = "false"
local startup = true
Citizen.CreateThread(function()
    if startup then
        startup = false
        lib.callback('guduty:setupDutyStatus', false, function()
            removeAllBlips()
            TriggerServerEvent("guduty:updateDutyStatus")
        end)
    end
end)
RegisterNetEvent('guduty:DutyToggle')
AddEventHandler('guduty:DutyToggle', function()
    lib.callback('guduty:toggleDutyStatus', false, function(stat)
        if stat == "true" then
            setupWeapons()
            lib.notify({
                title = 'GU Duty',
                description = "You are now on duty.",
                position = 'top',
                type = 'inform',
            })
        else
            removeAllBlips()
            removeWeapons()
            lib.notify({
                title = 'GU Duty',
                description = "You are now off duty.",
                position = 'top',
                type = 'inform',
            })
        end
        bigStatus = stat
        TriggerServerEvent("guduty:updateDutyStatus")
    end)
end)
RegisterNetEvent("guduty:updateDutyStatus-c")
AddEventHandler("guduty:updateDutyStatus-c", function(list)
    updateBlips(list)
end)
local blips = {}
RegisterNetEvent('GUPlayerDied')
AddEventHandler('GUPlayerDied', function(a)
    local ent = GetPlayerPed(GetPlayerFromServerId(a))
    if bigStatus == "true" and GetResourceKvpString("DutyStatus:"..ent) == "true" then
        lib.callback('DiscordAPI:getNick', false, function(name)
            lib.notify({
                title = 'PANIC BUTTON',
                duration = 10000,
                iconAnimation = "shake",
                description = name..' HAS TRIGGERED THEIR PANIC BUTTON',
                position = 'top',
                type = 'error',
            })
        SetBlipColour(blips[ent], 1)
        SetBlipFlashes(blips[ent], true)
        SetBlipFlashInterval(blips[ent], 250)
        local sound = exports["high_3dsounds"]:Play3DEntity(
            NetworkGetNetworkIdFromEntity(PlayerPedId()), -- entity net id
            1.0, -- distance
            "panicbutton", -- sound URL/file name
            1.0, -- volume
            false -- looped
        )
        end, tonumber(a))
    end
end)
function updateBlips(tbl)
    for _, i in pairs(tbl) do
        for m, n in pairs(i) do
            local ent = GetPlayerPed(GetPlayerFromServerId(tonumber(m)))
            if n == "true" then
                removeBlipForEntity(ent)
                if bigStatus == "true" then
                    lib.callback('DiscordAPI:getNick', false, function(name)
                        if ent ~= GetPlayerPed(-1) then
                            setBlipForEntity(ent, 1, 25, name)
                        end
                    end, tonumber(m))
                end
                SetResourceKvp("DutyStatus:"..ent, "true")
            else
                removeBlipForEntity(ent)
                SetResourceKvp("DutyStatus:"..ent, "false")
            end
        end
    end
end
function removeAllBlips()
    for _, i in pairs(blips) do
        RemoveBlip(i)
    end
end
function removeBlipForEntity(entity)
    if DoesBlipExist(blips[entity]) then
        RemoveBlip(blips[entity])
        blips[entity] = nil
    end
end
function setBlipForEntity(entity, blipSprite, blipColor, blipName)
    local blip = AddBlipForEntity(entity)
    SetBlipSprite(blip, blipSprite)
    if IsEntityDead(entity) then
        SetBlipColour(blip, 1)
        SetBlipFlashes(blip, true)
        SetBlipFlashInterval(blip, 250)                    
    else
        SetBlipColour(blip, blipColor)
        SetBlipFlashes(blips[ent], false)
    end
    SetBlipShowCone(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(blipName)
    EndTextCommandSetBlipName(blip)
    blips[entity] = blip
end

weaponTBL = {
    {name="weapon_combatpistol", ammo=1000, attachments={"COMPONENT_AT_PI_FLSH"}},
    {name="weapon_stungun", ammo=1, attachments={}},
    {name="weapon_flashlight", ammo=1, attachments={}},
    {name="weapon_nightstick", ammo=1, attachments={}},
    {name="weapon_pumpshotgun", ammo=250, attachments={"COMPONENT_AT_AR_FLSH"}},
    {name="weapon_carbinerifle", ammo=1000, attachments={"COMPONENT_AT_AR_FLSH", "COMPONENT_AT_SCOPE_MEDIUM", "COMPONENT_AT_AR_AFGRIP"}},
}

function doesPedHaveWeapon(ped, weaponHash)
    return HasPedGotWeapon(ped, weaponHash, false)
end

function setupWeapons()
    for _, i in pairs(weaponTBL) do
        if not doesPedHaveWeapon(GetPlayerPed(-1), GetHashKey(i.name)) then
            GiveWeaponToPed(GetPlayerPed(-1), GetHashKey(i.name), i.ammo, true, false)
            SetPedAmmo(GetPlayerPed(-1), GetHashKey(i.name), i.ammo)
            for j, s in pairs(i.attachments) do
                GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey(i.name), GetHashKey(s))
            end
        end
    end
end
function removeWeapons()
    for _, i in pairs(weaponTBL) do
        if doesPedHaveWeapon(GetPlayerPed(-1), GetHashKey(i.name)) then
            RemoveWeaponFromPed(GetPlayerPed(-1), GetHashKey(i.name))
        end
    end
end