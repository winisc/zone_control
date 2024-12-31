-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")

-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
cRP = {}
Tunnel.bindInterface("zone_control",cRP)
vSERVER = Tunnel.getInterface("zone_control")
-----------------------------------------------------------------------------------------------------------------------------------------
-- ZONAS
-----------------------------------------------------------------------------------------------------------------------------------------
Areas = {}

function cRP.CreateZones()
    CreateThread(function()
        for _, v in pairs(Config.zones) do
            local name = v.name
            local type = v.type
            if not Areas[name] then
                if type == "poly" then
                    Areas[name] = lib.zones.poly(v)
                end
            end
        end
    end)
end

function DeleteZones()
    for k, _ in pairs(Areas) do
        Areas[k]:remove()
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHECK PLAYER IN ZONE
-----------------------------------------------------------------------------------------------------------------------------------------
function CheckPlayerInZone(x, y, z)
    for k, _ in pairs(Areas) do
        if Areas[k]:contains(vec3(x, y, z)) and CheckNameZone(Areas[k].name) == "hpilegal" then
            return "hpilegal"
        end
        
        if Areas[k]:contains(vec3(x, y, z)) and CheckNameZone(Areas[k].name) == "airdrop" then
            return "airdrop"
        end

        if Areas[k]:contains(vec3(x, y, z)) and CheckNameZone(Areas[k].name) == "dominacao" then
            return "dominacao"
        end
    end
    return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHECK NAME ZONE
-----------------------------------------------------------------------------------------------------------------------------------------
function CheckNameZone(name)
    local zoneNamesHpIlegal = {"hpilegal1", "hpilegal2", "hpilegal3"}
    local zoneNamesAirdrop = {
        "airdrop1", 
        "airdrop2", 
        "airdrop3", 
        "airdrop4", 
        "airdrop5",
        "airdrop6",
        "airdrop7",
        "airdrop8",
        "airdrop9",
        "airdrop10",
    }
    local zoneNamesDominacao = {"dominacaoZancudo"}

    for _,zoneName in pairs(zoneNamesHpIlegal) do
        if zoneName == name then
            return "hpilegal"
        end
    end

    for _,zoneName in pairs(zoneNamesAirdrop) do
        if zoneName == name then
            return "airdrop"
        end
    end

    for _,zoneName in pairs(zoneNamesDominacao) do
        if zoneName == name then
            return "dominacao"
        end
    end
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIAVEL DE NOTOFICAÇÃO
-----------------------------------------------------------------------------------------------------------------------------------------
local wasInZoneAirdrop = false
local wasInZoneDominacao = false

local wasInZonePraca = false
local praca = false

CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        
        local zone = CheckPlayerInZone(coords.x, coords.y, coords.z)

        if zone == "hpilegal" then
            LocalPlayer.state.HpIlegal = true
        end

        if zone == "airdrop" then
            LocalPlayer.state.InZoneAirDrop = true
            if not wasInZoneAirdrop then
                lib.notify({
                    title = 'Airdrop',
                    description = 'Você entrou na zona de airdrop!',
                    type = 'success'
                })
                wasInZoneAirdrop = true
            end
        end

        if zone == "dominacao" then
            LocalPlayer.state.InZoneDominacao = true
            if not wasInZoneDominacao then
                lib.notify({
                    title = 'Dominacao',
                    description = 'Você entrou na zona de dominacao!',
                    type = 'success'
                })
                wasInZoneDominacao = true
            end
        end

        if zone ~= "hpilegal" then
            LocalPlayer.state.HpIlegal = false
        end

        if zone ~= "airdrop" then
            LocalPlayer.state.InZoneAirDrop = false
            if wasInZoneAirdrop then
                lib.notify({
                    title = 'Airdrop',
                    description = 'Você saiu da zona de airdrop!',
                    type = 'error'
                })
                wasInZoneAirdrop = false
            end
        end

        if zone ~= "dominacao" then
            LocalPlayer.state.InZoneDominacao = false
            if wasInZoneDominacao then
                lib.notify({
                    title = 'Dominacao',
                    description = 'Você saiu da zona de dominacao!',
                    type = 'error'
                })
                wasInZoneDominacao = false
            end
        end

        Wait(500)
    end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- ON RESOURCE START
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        cRP.CreateZones()
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        DeleteZones()
    end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
--ZONAS AIRDROPS
-----------------------------------------------------------------------------------------------------------------------------------------
function cRP.CreateZoneAirDropSelected(name)
    CreateThread(function()
        for _, v in pairs(Config.zones) do
            local type = v.type
            if v.name == name then
                if not Areas[name] then
                    if type == "sphere" then
                        Areas[name] = lib.zones.sphere(v)
                    end
                end
            end
        end
    end)
end

function cRP.DeleteZonesAirDrops()
    for k, _ in pairs(Areas) do
        if _.type == "sphere" then
            Areas[k]:remove()
            Areas[k] = nil
        end
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ZONAS DOMINACAO
-----------------------------------------------------------------------------------------------------------------------------------------
function cRP.CreateZoneDominacao(name)
    CreateThread(function()
        for _, v in pairs(Config.zones) do
            local type = v.type
            if v.name == name then
                if not Areas[name] then
                    if type == "dominacao" then
                        Areas[name] = lib.zones.poly(v)
                    end
                end
            end
        end
    end)
end

function cRP.DeleteZoneSelected(name)
    for k, _ in pairs(Areas) do
        if _.name == name then
            Areas[k]:remove()
            Areas[k] = nil
        end
    end
end

-----------------------------------------------------------------------------------------------------------------------------------------
--BLIS MAP DOMINACAO
-----------------------------------------------------------------------------------------------------------------------------------------   
local Blip = nil
local BlipRadius = nil
function cRP.DominacaoBlipOff()
    if DoesBlipExist(Blip) and DoesBlipExist(BlipRadius) then
        RemoveBlip(Blip)
        RemoveBlip(BlipRadius)
    end
end
function cRP.DominacaoBlipOn(coords)
	if coords then
		Blip = AddBlipForCoord(coords[1],coords[2],coords[3])
		SetBlipSprite(Blip,429)
		SetBlipDisplay(Blip,4)
		SetBlipAsShortRange(Blip,true)
		SetBlipColour(Blip,40)
		SetBlipScale(Blip,0.8)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString("Area de Dominação")
		EndTextCommandSetBlipName(Blip)
		BlipRadius = AddBlipForRadius(coords[1],coords[2],coords[3],500.0)
		SetBlipColour(BlipRadius,49)
		SetBlipAlpha(BlipRadius,70)
	end
end

cRP.checkDomiacaoZone = function()
    return LocalPlayer.state.InZoneDominacao
end