local CoreName = nil

if Config['CoreSettings']["QBCORE"]["Version"] == "new" then
    CoreName = Config['CoreSettings']["QBCORE"]["Export"]
else
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(10)
            if CoreName == nil then
                TriggerEvent(Config['CoreSettings']["QBCORE"]["Trigger"], function(obj) CoreName = obj end)
                Citizen.Wait(200)
            end
        end
    end)
end



local player = false
local called = false
local x,y,z = nil
local TargetC = nil
local IsSpectating = false
local InGodMode = false
local InNoClipMode = false
local SuperJumpActive = false
local drawable_names = {"face", "masks", "hair", "torsos", "legs", "bags", "shoes", "neck", "undershirts", "vest", "decals", "jackets"}
local firsttime = true

RegisterKeyMapping('+openmenu', 'Open Admin Menu', 'keyboard', 'F5')


RegisterCommand("+openmenu", function()
    CoreName.Functions.TriggerCallback('ethicalpixel-admin:CheckPerms', function(result)
      if(result == true) then
        SendNUIMessage({
            type = "open",
    
        })
        SetNuiFocus(true, true)
    else
        return print('[ethicalpixel-admin] No perms.')
    end
    end)
 
end)

function GetDrawablesTotal()
    drawables = {}
    for i = 0, #drawable_names - 1 do
        drawables[i] = {drawable_names[i+1], GetNumberOfPedDrawableVariations(player, i)}
    end
    return drawables
end

function ToggleClothingToLoadPed()
    local ped = PlayerPedId()
    local drawables = GetDrawablesTotal()

    for num, _ in pairs(drawables) do
        if drawables[num][2] > 1 then
            component = tonumber(num)
            SetPedComponentVariation(ped, component, 1, 0, 0)
            Wait(250)
            SetPedComponentVariation(ped, component, 0, 0, 0)
            break
        end
    end
end

function SetSkin(model, setDefault)
    SetEntityInvincible(PlayerPedId(),true)
    if IsModelInCdimage(model) and IsModelValid(model) then
        RequestModel(model)
        while (not HasModelLoaded(model)) do
            Citizen.Wait(0)
        end
        SetPlayerModel(PlayerId(), model)
        SetModelAsNoLongerNeeded(model)
        player = PlayerPedId()
        FreezePedCameraRotation(player, true)
        SetPedMaxHealth(player, 200)
        ToggleClothingToLoadPed()
        SetPedDefaultComponentVariation(player)
        if setDefault and model ~= nil and (model == `mp_f_freemode_01` or model == `mp_m_freemode_01`) then
            SetPedHeadBlendData(player, 0, 0, 0, 15, 0, 0, 0, 1.0, 0, false)
            SetPedComponentVariation(player, 11, 0, 1, 0)
            SetPedComponentVariation(player, 8, 0, 1, 0)
            SetPedComponentVariation(player, 6, 1, 2, 0)
            SetPedHeadOverlayColor(player, 1, 1, 0, 0)
            SetPedHeadOverlayColor(player, 2, 1, 0, 0)
            SetPedHeadOverlayColor(player, 4, 2, 0, 0)
            SetPedHeadOverlayColor(player, 5, 2, 0, 0)
            SetPedHeadOverlayColor(player, 8, 2, 0, 0)
            SetPedHeadOverlayColor(player, 10, 1, 0, 0)
            SetPedHeadOverlay(player, 1, 0, 0.0)
            SetPedHairColor(player, 1, 1)
        end
    end
    SetEntityInvincible(PlayerPedId(),false)
end


RegisterNetEvent('ethicalpixel-adminmenu:client:OpenBennys')
AddEventHandler('ethicalpixel-adminmenu:client:OpenBennys', function()
    EnterBennys()
end)

RegisterNetEvent('ethicalpixel-adminmenu:client:ChangeModel')
AddEventHandler('ethicalpixel-adminmenu:client:ChangeModel', function(model)
    local hashedModel = GetHashKey(model)
    if not IsModelInCdimage(hashedModel) or not IsModelValid(hashedModel) then return end
    SetSkin(hashedModel, true)
end)

RegisterNetEvent('ethicalpixel-adminmenu:client:OpenClothingMenu')
AddEventHandler('ethicalpixel-adminmenu:client:OpenClothingMenu', function(pid)
    OpenClothing()
end)

RegisterNetEvent('ethicalpixel-adminmenu:client:FixVehicle')
AddEventHandler('ethicalpixel-adminmenu:client:FixVehicle', function()
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, true) then
        local veh = GetVehiclePedIsIn(ped, false)
        TriggerEvent('DoLongHudText', 'Your vehicle has been repaired', 1)
        SetVehicleFixed(veh)
        SetVehicleDirtLevel(veh, 0.0)
    end
end)



RegisterNetEvent('ethicalpixel-adminmenu:client:RemoveStress')
AddEventHandler('ethicalpixel-adminmenu:client:RemoveStress', function()
    RemoveStress()
end)


RegisterNetEvent('ethicalpixel-adminmenu:client:Csay')
AddEventHandler('ethicalpixel-adminmenu:client:Csay', function(msg)
    TriggerServerEvent('ethicalpixel-adminmenu:server:Csay',msg)
end)

function GetPlayers()
    local players = {}

    for i = 0, 255 do
        if NetworkIsPlayerActive(i) then
            players[#players+1]= i
        end
    end

    return players
end

RegisterNetEvent('ethicalpixel-adminmenu:client:RevivePlayer')
AddEventHandler('ethicalpixel-adminmenu:client:RevivePlayer', function(pid)
    Revive(pid)
end)

RegisterNetEvent('ethicalpixel-adminmenu:client:SpawnCar')
AddEventHandler('ethicalpixel-adminmenu:client:SpawnCar', function(model, livery)
    Citizen.CreateThread(function()

        local hash = GetHashKey(model)

        if not IsModelAVehicle(hash) then return end
        if not IsModelInCdimage(hash) or not IsModelValid(hash) then return end
        
        RequestModel(hash)

        while not HasModelLoaded(hash) do
            Citizen.Wait(0)
        end

        local localped = PlayerPedId()
        local coords = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 1.5, 5.0, 0.0)

        local heading = GetEntityHeading(localped)
        local vehicle = CreateVehicle(hash, coords, heading, true, false)
        TaskWarpPedIntoVehicle(PlayerPedId(),vehicle,-1)
        SetVehicleModKit(vehicle, 0)
        SetVehicleMod(vehicle, 11, 3, false)
        SetVehicleMod(vehicle, 12, 2, false)
        SetVehicleMod(vehicle, 13, 2, false)
        SetVehicleMod(vehicle, 15, 3, false)
        SetVehicleMod(vehicle, 16, 4, false)

        local plate = GetVehicleNumberPlateText(vehicle)
        AddVehicleKeys(vehicle,plate)
        SetModelAsNoLongerNeeded(hash)
        
        SetVehicleDirtLevel(vehicle, 0)
        SetVehicleWindowTint(vehicle, 0)

        if livery ~= nil then
            SetVehicleLivery(vehicle, tonumber(livery))
        end
    end)
end)


RegisterNetEvent('ethicalpixel-adminmenu:client:SpawnItem')
AddEventHandler('ethicalpixel-adminmenu:client:SpawnItem', function(name , amount)
    TriggerServerEvent('ethicalpixel-adminmenu:server:SpawnItem' , name , amount)
end)


RegisterNetEvent('ethicalpixel-adminmenu:client:SetTimeWeather')
AddEventHandler('ethicalpixel-adminmenu:client:SetTimeWeather', function(weather, time)
    if time ~= nil then
        TimeEvent(time)
    end
    if weather ~= nil then
        WeatherEvent(weather)
    end
end)





RegisterNetEvent('ethicalpixel-adminmenu:client:GodModeToggle')
AddEventHandler('ethicalpixel-adminmenu:client:GodModeToggle', function()
    if InGodMode then
        SetPlayerInvincible(PlayerId(), false)
        InGodMode = false
    else
        SetPlayerInvincible(PlayerId(), true)
        InGodMode = true
    end
end)


RegisterNetEvent('ethicalpixel-adminmenu:client:NoclipToggle')
AddEventHandler('ethicalpixel-adminmenu:client:NoclipToggle', function()
    if InNoClipMode then
        TriggerEvent("ethicalpixel-adminmenu:noClipToggle", false)
        InNoClipMode = false
    else
        TriggerEvent("ethicalpixel-adminmenu:noClipToggle", true)
        InNoClipMode = true
    end
end)


RegisterNetEvent('ethicalpixel-adminmenu:client:SuperJump')
AddEventHandler('ethicalpixel-adminmenu:client:SuperJump', function()
    if SuperJumpActive then
        SuperJumpActive = false
    else
        SuperJumpActive = true
    end
end)

function Split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

RegisterNetEvent('ethicalpixel-adminmenu:client:TeleportToCoords')
AddEventHandler('ethicalpixel-adminmenu:client:TeleportToCoords', function(coords)
    coordssplit = Split(coords , ',')
    local pos = vector3(tonumber(coordssplit[1]),tonumber(coordssplit[2]),tonumber(coordssplit[3]))
    local ped = PlayerPedId()

    Citizen.CreateThread(function()
        RequestCollisionAtCoord(pos)
        SetPedCoordsKeepVehicle(ped, pos)
        FreezeEntityPosition(ped, true)
        SetPlayerInvincible(PlayerId(), true)

        local startedCollision = GetGameTimer()

        while not HasCollisionLoadedAroundEntity(ped) do
            if GetGameTimer() - startedCollision > 5000 then break end
            Citizen.Wait(0)
        end

        FreezeEntityPosition(ped, false)
        SetPlayerInvincible(PlayerId(), false)
    end)
end)

RegisterNetEvent('ethicalpixel-adminmenu:client:TeleportToMarker')
AddEventHandler('ethicalpixel-adminmenu:client:TeleportToMarker', function()
    local WaypointHandle = GetFirstBlipInfoId(8)
    if DoesBlipExist(WaypointHandle) then
        local waypointCoords = GetBlipInfoIdCoord(WaypointHandle)
        for height = 1, 1000 do
            SetPedCoordsKeepVehicle(PlayerPedId(), waypointCoords["x"], waypointCoords["y"], height + 0.0)

            local foundGround, zPos = GetGroundZFor_3dCoord(waypointCoords["x"], waypointCoords["y"], height + 0.0)

            if foundGround then
                SetPedCoordsKeepVehicle(PlayerPedId(), waypointCoords["x"], waypointCoords["y"], height + 0.0)
                break
            end
            Citizen.Wait(5)
        end
    else
        TriggerEvent("DoLongHudText", 'Failed to find marker.',2)
    end
end)


function DrawPlayerInfo(target)
	drawTarget = target
	drawInfo = true
end

function StopDrawPlayerInfo()
	drawInfo = false
	drawTarget = 0
end


RegisterNetEvent("ethicalpixel-adminmenu:client:sendCoords")
AddEventHandler("ethicalpixel-adminmenu:client:sendCoords", function(coords)
    TargetC = coords
end)

RegisterNetEvent("ethicalpixel-adminmenu:client:Spectate")
AddEventHandler("ethicalpixel-adminmenu:client:Spectate", function(target)
    if not IsSpectating then
        TriggerServerEvent('ethicalpixel-adminmenu:server:GetCoords', target, IsSpectating)
        IsSpectating = true
    else
        TriggerServerEvent('ethicalpixel-adminmenu:server:GetCoords', target, IsSpectating)
        IsSpectating = false
    end
end)

RegisterNetEvent('ethicalpixel-adminmenu:client:attach')
AddEventHandler('ethicalpixel-adminmenu:client:attach', function(tSrc, toggle)
    local ped = PlayerPedId()
    local PlayerPos = GetEntityCoords(ped, false)
    if called == false then
        x,y,z = PlayerPos.x, PlayerPos.y, PlayerPos.z
    end
    Citizen.CreateThread(function()
        if toggle == true then
            called = true
            Citizen.Wait(300)
            if TargetC ~= nil then
                SetEntityVisible(ped, false)
                SetPlayerInvincible(ped, true)
                SetEntityCollision(ped,false,false)
                SetEntityCoordsNoOffset(PlayerPedId(), TargetC.x - 0.5, TargetC.y, TargetC.z, 0, 0, 4.0)
                local startedCollision = GetGameTimer()

                while not HasCollisionLoadedAroundEntity(PlayerPedId()) do
                    if GetGameTimer() - startedCollision > 5000 then break end
                    Citizen.Wait(0)
                end
    
                Citizen.Wait(500)
                SetEntityVisible(ped, false)
                SetPlayerInvincible(ped, true)
                SetEntityCollision(ped,false,false)
                local targId = GetPlayerFromServerId(tSrc)
                local targPed = GetPlayerPed(targId)
                
                DrawPlayerInfo(targId)
                AttachEntityToEntity(ped, targPed, 11816, 0.0, -1.48, 2.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
            else
                print("[ethicalpixel-adminmenu]: No Target Coords")
            end
        else
            TargetC = nil
            called = false
            DetachEntity(ped,true,true)
            SetEntityCollision(ped,true,true)
            SetPlayerInvincible(ped, false)
            SetEntityVisible(ped, true)
            StopDrawPlayerInfo()
            SetEntityCoords(ped, x,y,z)
        end
    end)    
end)


RegisterNetEvent("ethicalpixel-adminmenu:client:bringPlayer")
AddEventHandler("ethicalpixel-adminmenu:client:bringPlayer", function(targPos)
    Citizen.CreateThread(function()
        RequestCollisionAtCoord(targPos.x, targPos.y, targPos.z)
        SetEntityCoordsNoOffset(PlayerPedId(), targPos.x, targPos.y, targPos.z, 0, 0, 2.0)
        FreezeEntityPosition(PlayerPedId(), true)
        SetPlayerInvincible(PlayerId(), true)

        local startedCollision = GetGameTimer()

        while not HasCollisionLoadedAroundEntity(PlayerPedId()) do
            if GetGameTimer() - startedCollision > 5000 then break end
            Citizen.Wait(0)
        end

        FreezeEntityPosition(PlayerPedId(), false)
        SetPlayerInvincible(PlayerId(), false)
    end)    
end)

RegisterNetEvent('ethicalpixel-adminmenu:client:GiveCash')
AddEventHandler('ethicalpixel-adminmenu:client:GiveCash', function(reciever, amount)
    TriggerServerEvent("ethicalpixel-adminmenu:server:GiveCash", reciever, amount)
    
end)

RegisterNetEvent('ethicalpixel-adminmenu:client:KickPlayer')
AddEventHandler('ethicalpixel-adminmenu:client:KickPlayer', function(target, reason)
    if not reason then
        reason = "No Reason Given"
    end
    TriggerServerEvent('ethicalpixel-adminmenu:server:DropPlayer', target, reason)
end)




Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if SuperJumpActive then
            SetSuperJumpThisFrame(PlayerId())
        end

        if drawInfo then
			local text = {}
			local targetPed = GetPlayerPed(drawTarget)
			table.insert(text,"~g~Health:~s~  "..GetEntityHealth(targetPed).." / "..GetEntityMaxHealth(targetPed))
			table.insert(text,"~b~Armor:~s~  "..GetPedArmour(targetPed))
			for i,theText in pairs(text) do
				SetTextFont(0)
				SetTextProportional(1)
				SetTextScale(0.0, 0.30)
				SetTextDropshadow(0, 0, 0, 0, 255)
				SetTextEdge(1, 0, 0, 0, 255)
				SetTextDropShadow()
				SetTextOutline()
				SetTextEntry("STRING")
				AddTextComponentString(theText)
				EndTextCommandDisplayText(0.3, 0.7+(i/30))
			end
		end
    end
end)


RegisterNUICallback("close" , function(data, cb)
    SetNuiFocus(false ,false)
end)


RegisterNUICallback("getOnlinePlayers" , function(data, cb)
    CoreName.Functions.TriggerCallback('ethicalpixel-admin:GetOnlinePlayers', function(result)
        wa = result
        cb(wa)
        print(wa)
    end)
    
end)


RegisterNUICallback("GetPlayerData" , function(data, cb)
    CoreName.Functions.TriggerCallback('ethicalpixel-admin:GetPlayerData', function(result)
        cb(result)
    end)
  
end)

RegisterNUICallback("GetLogs" , function(data, cb)
    CoreName.Functions.TriggerCallback('ethicalpixel-admin:GetLogs', function(result)
        cb(result)
    end)
   
end)

RegisterNUICallback("GetItems" , function(data, cb)
    local data = {}
    for k,v in pairs(CoreName.Shared.Items) do
        table.insert(data , {name = k , displayname = v['label']})
    end
   Citizen.Wait(1000)
   cb(data)
end)

RegisterNUICallback("GetBannedPlayers" , function(data, cb)
    CoreName.Functions.TriggerCallback('ethicalpixel-admin:GetBannedPlayers', function(result)
        cb(result)
    end)
end)



ShowBlips = false
RegisterNetEvent('ethicalpixel-adminmenu:client:toggleBlips')
AddEventHandler('ethicalpixel-adminmenu:client:toggleBlips', function()
    if not ShowBlips then
        ShowBlips = true
    else
        ShowBlips = false
    end
end)

Citizen.CreateThread(function()
    while true do
        Wait(1000)
        if ShowBlips then
            TriggerServerEvent('ethicalpixel-admin:GetPlayersForBlips')
        end
    end
end)

RegisterNetEvent('ethicalpixel-adminmenu:client:client:ShowBlips')
AddEventHandler('ethicalpixel-adminmenu:client:client:ShowBlips', function(players)
    local playeridx = GetPlayerFromServerId(player.id)
    local ped = GetPlayerPed(playeridx)
    local blip = GetBlipFromEntity(ped)

    for k, player in pairs(players) do
        if ShowBlips then
            if not DoesBlipExist(blip) then -- Blip doesn't exist, make it appear
                blip = AddBlipForEntity(ped)
                SetBlipSprite(blip, 1)
                Citizen.InvokeNative(0x5FBCA48327B914DF, blip, true)
            else -- Blip exist, update it
                local veh = GetVehiclePedIsIn(ped, false)
                local blipSprite = GetBlipSprite(blip)
                if not GetEntityHealth(ped) then -- Check if ped is death
                    if blipSprite ~= 274 then
                        SetBlipSprite(blip, 274)
                        Citizen.InvokeNative(0x5FBCA48327B914DF, blip, false)
                    end
                elseif veh ~= 0 then -- Check if ped is in vehicle
                    local classveh = GetVehicleClass(veh)
                    local modelveh = GetEntityModel(veh)
                    if classveh == 15 then -- Vehicle type 15 Helicopters
                        if blipSprite ~= 422 then
                            SetBlipSprite(blip, 422)
                            Citizen.InvokeNative(0x5FBCA48327B914DF, blip, false)
                        end
                    elseif classveh == 16 then -- Vehicle type 16 Planes
                        if modelveh == `besra` or modelveh == `hydra` or modelveh == `lazer` then   --Check if vehicle is military jet
                            if blipSprite ~= 424 then
                                SetBlipSprite(blip, 424)
                                Citizen.InvokeNative(0x5FBCA48327B914DF, blip, false)
                            end
                        elseif blipSprite ~= 423 then
                            SetBlipSprite(blip, 423)
                            Citizen.InvokeNative (0x5FBCA48327B914DF, blip, false)
                        end
                    elseif classveh == 14 then -- Vehicle type 14 Boat
                        if blipSprite ~= 427 then
                            SetBlipSprite(blip, 427)
                            Citizen.InvokeNative(0x5FBCA48327B914DF, blip, false)
                        end
                    elseif modelveh == `insurgent` or modelveh == `insurgent2` or modelveh == `limo2` then   -- Vehicle is armed car
                        if blipSprite ~= 426 then
                            SetBlipSprite(blip, 426)
                            Citizen.InvokeNative(0x5FBCA48327B914DF, blip, false)
                        end
                    elseif modelveh == `rhino` then -- Vehicle is Rhino
                        if blipSprite ~= 421 then
                            SetBlipSprite(blip, 421)
                            Citizen.InvokeNative(0x5FBCA48327B914DF, blip, false)
                        end
                    elseif blipSprite ~= 1 then -- default blip
                        SetBlipSprite(blip, 1)
                        Citizen.InvokeNative(0x5FBCA48327B914DF, blip, true)
                    end
                    -- Show number in case of passangers
                    passengers = GetVehicleNumberOfPassengers(veh)
                    if passengers then
                        if not IsVehicleSeatFree(veh, -1) then
                            passengers = passengers + 1
                        end
                        ShowNumberOnBlip(blip, passengers)
                    else
                        HideNumberOnBlip(blip)
                    end
                else    -- Ped is on foot
                    HideNumberOnBlip(blip)
                    if blipSprite ~= 1 then
                        SetBlipSprite(blip, 1)
                        Citizen.InvokeNative(0x5FBCA48327B914DF, blip, true)
                    end
                end

                SetBlipRotation(blip, math.ceil(GetEntityHeading(veh)))
                SetBlipNameToPlayerName(blip, playeridx)
                SetBlipScale(blip, 0.85)

                if IsPauseMenuActive() then
                    SetBlipAlpha(blip, 255)
                else
                    local x1, y1 = table.unpack(GetEntityCoords(PlayerPedId(), true))
                    local x2, y2 = table.unpack(GetEntityCoords(GetPlayerPed(playeridx), true))
                    local distance = (math.floor(math.abs(math.sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2))) / -1)) + 900
                    if distance < 0 then
                        distance = 0
                    elseif distance > 255 then
                        distance = 255
                    end
                    SetBlipAlpha(blip, distance)
                end
            end
        else
            RemoveBlip(blip)
        end

    end
end)

entityselected = nil

RegisterNetEvent('ethicalpixel-adminmenu:client:SelectEnity')
AddEventHandler('ethicalpixel-adminmenu:client:SelectEnity', function()
    local coordA = GetEntityCoords(PlayerPedId(), false)
    local coordB = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 5.0, 0.0)

    local offset = 0
    local rayHandle
    local entity

    for i = 0, 100 do
        rayHandle = CastRayPointToPoint(coordA.x, coordA.y, coordA.z, coordB.x, coordB.y, coordB.z + offset, 10, PlayerPedId(), -1)    
        a, b, c, d, entity = GetRaycastResult(rayHandle)
        offset = offset - 1
        if entity and Vdist(GetEntityCoords(entity, false), coordA) < 150 then break end
    end

    if entity then entityselected = entity end
    if entityselected and DoesEntityExist(entityselected) then
        x, y, z = table.unpack(GetEntityCoords(entityselected, true))
        SetDrawOrigin(x, y, z, 0)
        RequestStreamedTextureDict("helicopterhud", false)
        DrawSprite("helicopterhud", "hud_corner", -0.01, -0.01, 0.05, 0.05, 0.0, 0, 255, 0, 200)
        DrawSprite("helicopterhud", "hud_corner", 0.01, -0.01, 0.05, 0.05, 90.0, 0, 255, 0, 200)
        DrawSprite("helicopterhud", "hud_corner", -0.01, 0.01, 0.05, 0.05, 270.0, 0, 255, 0, 200)
        DrawSprite("helicopterhud", "hud_corner", 0.01, 0.01, 0.05, 0.05, 180.0, 0, 255, 0, 200)
        ClearDrawOrigin()
    end
end)


RegisterNetEvent('ethicalpixel-adminmenu:client:DeleteEntity')
AddEventHandler('ethicalpixel-adminmenu:client:DeleteEntity', function()
    if not entityselected then return end
    if not DoesEntityExist(entityselected) then return end

    Citizen.CreateThread(function()
        local timeout = 0

        while true do
            if timeout >= 3000 then return end
            timeout = timeout + 1

            NetworkRequestControlOfEntity(entityselected)

            local nTimeout = 0

            while not NetworkHasControlOfEntity(entityselected) and nTimeout < 1000 do
                nTimeout = nTimeout + 1
                NetworkRequestControlOfEntity(entityselected)
                Citizen.Wait(0)
            end

            SetEntityAsMissionEntity(entityselected, true, true)

            DeleteEntity(entityselected)
            if GetEntityType(entityselected) == 2 then DeleteVehicle(entityselected) end

            if not DoesEntityExist(entityselected) then cmd.vars.ent = nil return end

            Citizen.Wait(0)
        end
    end)
end)

RegisterNetEvent('ethicalpixel-adminmenu:client:tSay')
AddEventHandler('ethicalpixel-adminmenu:client:tSay', function(message)
    TriggerServerEvent('ethicalpixel-admin:server:tSay', message)
end)

RegisterNUICallback("bringPlayer" , function(data, cb)
    TriggerServerEvent("ethicalpixel-adminmenu:server:bringPlayer" , data.PlayerID , GetEntityCoords(GetPlayerPed(-1)))
end)


RegisterNUICallback("setFav" , function(data, cb)
    TriggerServerEvent("ethicalpixel-adminmenu:server:setFav" , data.fav)
end)

RegisterNUICallback("selectEntity" , function(data, cb)
    TriggerEvent("ethicalpixel-adminmenu:client:SelectEnity")
end)



RegisterNUICallback("deleteEntity" , function(data, cb)
    TriggerEvent("ethicalpixel-adminmenu:client:DeleteEntity")
end)



RegisterNUICallback("GiveCash" , function(data, cb)
    TriggerEvent("ethicalpixel-adminmenu:client:GiveCash" , data.Target , data.amount)
end)
RegisterNUICallback("Noclip" , function(data, cb)
    TriggerEvent("ethicalpixel-adminmenu:client:NoclipToggle")
end)

RegisterNUICallback("Kick" , function(data, cb)
    TriggerEvent("ethicalpixel-adminmenu:client:KickPlayer" , data.Target , data.reason)
end)

RegisterNUICallback("toggleBlips" , function(data, cb)
    TriggerEvent("ethicalpixel-adminmenu:client:toggleBlips")
end)




RegisterNUICallback("FixVehicle" , function(data, cb)
    TriggerEvent("ethicalpixel-adminmenu:client:FixVehicle")
end)

RegisterNUICallback("ChangeModel" , function(data, cb)
    TriggerEvent("ethicalpixel-adminmenu:client:ChangeModel" , data.model)
end)

RegisterNUICallback("RevivePlayer" , function(data, cb)
    TriggerEvent("ethicalpixel-adminmenu:client:RevivePlayer" , data.Target )
end)

RegisterNUICallback("SpawnCar" , function(data, cb)
    TriggerEvent("ethicalpixel-adminmenu:client:SpawnCar" , data.carmodel , data.livery)
end)

RegisterNUICallback("GodModeToggle" , function(data, cb)
    TriggerEvent("ethicalpixel-adminmenu:client:GodModeToggle")
end)

RegisterNUICallback("Csay" , function(data, cb)
    TriggerEvent("ethicalpixel-adminmenu:client:Csay" , data.text)
end)

RegisterNUICallback("tSay" , function(data, cb)
    TriggerEvent("ethicalpixel-adminmenu:client:tSay" , data.text)
end)


RegisterNUICallback("setWeather" , function(data, cb)
    TriggerEvent("ethicalpixel-adminmenu:client:SetTimeWeather" ,data.weather, data.time)
end)



RegisterNUICallback("SuperJump" , function(data, cb)
    TriggerEvent("ethicalpixel-adminmenu:client:SuperJump")
end)


RegisterNUICallback("TeleportToCoords" , function(data, cb)
    TriggerEvent("ethicalpixel-adminmenu:client:TeleportToCoords" , data.coords)
end)

RegisterNUICallback("TeleportToMarker" , function(data, cb)
    TriggerEvent("ethicalpixel-adminmenu:client:TeleportToMarker")
end)

RegisterNUICallback("Spectate" , function(data, cb)
    TriggerEvent("ethicalpixel-adminmenu:client:Spectate" , data.target)
end)




RegisterNUICallback("BanPlayer" , function(data, cb)
    TriggerServerEvent("ethicalpixel-admin:BanPlayer", data.Target, data.reason, data.length)
end)


RegisterNUICallback("SpawnItem" , function(data, cb)
    TriggerEvent("ethicalpixel-adminmenu:client:SpawnItem" , data.item , data.amount)
end)

RegisterNUICallback("OpenBennys" , function(data, cb)
    TriggerEvent("ethicalpixel-adminmenu:client:OpenBennys")
end)

RegisterNUICallback("OpenClothingMenu" , function(data, cb)
    TriggerEvent("ethicalpixel-adminmenu:client:OpenClothingMenu")
end)

RegisterNUICallback("RemoveStress" , function(data, cb)
    TriggerEvent("ethicalpixel-adminmenu:client:RemoveStress")
end)




devmode = false
RegisterNetEvent('ethicalpixel-adminmenu:client:DevModeToggle')
AddEventHandler('ethicalpixel-adminmenu:client:DevModeToggle', function()
    if devmode then
        devmode = false
    else
        devmode = true
    end
end)

RegisterNUICallback('DevmodeToggle' , function()
    TriggerEvent("ethicalpixel-adminmenu:client:DevModeToggle")
end)

RegisterNUICallback('DevmodeStatus' , function(data , cb)
    cb(devmode)
end)
