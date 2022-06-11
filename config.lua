Config = {}

Config['General'] = {
    ["Core"] = "QBCORE", -- This can be ESX , QBCORE , NPBASE
    ["SQLWrapper"] = "oxmysql", -- This can be `| oxmysql or ghmattimysql or mysql-async
}


Config['CoreSettings'] = {
    ["QBCORE"] = {
        ["Version"] = "old", -- new = using export | old = using events
        --["Export"] = exports['qb-core']:GetCoreObject(), -- uncomment this if using new qbcore version
        ["Trigger"] = "XZCore:GetObject",
        ["HasItem"] = "XZCore:HasItem", -- Imporant [ Your trigger for checking has item, default is CORENAME:HasItem ] 
        ["ServerNotificationEvent"] = "XZCore:Notify", 

    }, 
}


Config['Webhooks'] = {
    ['Link'] = '' -- Discord webhoook link when a banned player is trying to connect the server
}


EnterBennys = function()
    TriggerEvent('enter:benny')
end

WeatherEvent = function(weather)
    TriggerEvent("iconic-weathersync:server:setWeather", weather)
end

TimeEvent = function(time)
    TriggerEvent("iconic-weathersync:server:setTime",time)
end

OpenClothing = function()
    TriggerServerEvent('raid_clothes:hasEnough',  GetPlayerServerId(PlayerId()) ,'clothesmenu')
end

RemoveStress = function()
    TriggerEvent("client:updateStress",false, 0)
end

AddVehicleKeys = function(vehicle, plate)
    TriggerEvent("keys:addNew",vehicle,plate)
end

Revive = function()
    -- TriggerServerEvent("reviveGranted", v)
    -- TriggerEvent("Hospital:HealInjuries",true) 
    -- TriggerServerEvent("ems:healplayer", v)
    -- TriggerEvent("heal")
    TriggerEvent("hospital:client:Revive")
end