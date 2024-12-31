-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRPC = Tunnel.getInterface("vRP")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
cRP = {}
Tunnel.bindInterface("zone_control",cRP)
vCLIENT = Tunnel.getInterface("zone_control")
-----------------------------------------------------------------------------------------------------------------------------------------
-- ZONE CONTROL
-----------------------------------------------------------------------------------------------------------------------------------------
local zonaDominacao = false
AreasActive = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- CREATE ZONE AIR DROP
-----------------------------------------------------------------------------------------------------------------------------------------   
RegisterServerEvent("zone_control:CreateZoneAirDropSelected")
AddEventHandler("zone_control:CreateZoneAirDropSelected", function(name)
    table.insert(AreasActive, name)
    vCLIENT.CreateZoneAirDropSelected(-1, name)
end)
-----------------------------------------------------------------------------------------------------------------------------------------   
-- DELETE ZONE AIR DROP
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("zone_control:DeleteZoneAirDrops")
AddEventHandler("zone_control:DeleteZoneAirDrops", function()
    AreasActive = {}
    vCLIENT.DeleteZonesAirDrops(-1)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- PLAYER CONNECT
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("playerConnect", function(user, source)
    if zonaDominacao then
        vCLIENT.CreateZoneDominacao(source,"dominacaoZancudo")
        vCLIENT.DominacaoBlipOn(source,{-2256.64,3082.13,32.97}) 
    end
    vCLIENT.CreateZones(source)
    for k, v in pairs(AreasActive) do
        vCLIENT.CreateZoneAirDropSelected(source, v)
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CREATE DOMINATION
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('createdominacao',function(source,args)
    if not zonaDominacao then
        vCLIENT.CreateZoneDominacao(-1,"dominacaoZancudo")
        vCLIENT.DominacaoBlipOn(-1,{-2256.64,3082.13,32.97}) 
        TriggerClientEvent('Notify',-1,'important','<b>Zona de Dominação</b><br>A dominação iniciou.')
        zonaDominacao = true
    else
        TriggerClientEvent('Notify',source,'aviso','<b>Zona de Dominação</b><br>Já existe uma zona de dominação ativa.')
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- DELETE DOMINATION
-----------------------------------------------------------------------------------------------------------------------------------------   
RegisterCommand('deletedominacao',function(source,args)
    if zonaDominacao then
        vCLIENT.DeleteZoneSelected(-1,"dominacaoZancudo")
        vCLIENT.DominacaoBlipOff(-1)
        TriggerClientEvent('Notify',-1,'important','<b>Zona de Dominação</b><br>A dominação acabou.')
        zonaDominacao = false
    else
        TriggerClientEvent('Notify',source,'aviso','<b>Zona de Dominação</b><br>Não existe uma zona de dominação ativa.')
    end
end)