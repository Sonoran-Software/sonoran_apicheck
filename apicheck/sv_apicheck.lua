--[[
    Sonaran CAD Plugins

    Plugin Name: apicheck
    Creator: SonoranCAD
    Description: Implements checking if a particular API ID exists

]]

local pluginConfig = Config.GetPluginConfig("apicheck")

if pluginConfig.enabled then

    registerApiType("CHECK_APIID", "general")

    function cadApiIdExists(apiId, callback)
        if apiId == "" or apiId == nil then
            debugLog("cadApiIdExists: No API ID specified, assuming false.")
            callback(false)
        else
            performApiRequest({{["apiId"] = apiId}}, "CHECK_APIID", function(res, exists)
                callback(exists)
            end)
        end
    end

    RegisterCommand("forcecheck", function(source, args, rawCommand)
        performApiRequest({{["apiId"] = args[1]}}, "CHECK_APIID", function(res, exists)
            print("exists: "..tostring(exists))
        end)
    end)

    RegisterServerEvent("SonoranCAD::apicheck:CheckPlayerLinked")
    AddEventHandler("SonoranCAD::apicheck:CheckPlayerLinked", function(player)
        local identifier = GetIdentifiers(player)[Config.primaryIdentifier]
        cadApiIdExists(identifier, function(exists)
            TriggerEvent("SonoranCAD::apicheck:CheckPlayerLinkedResponse", player, identifier, exists)
        end)
    end)

    exports('CadIsPlayerLinked', cadApiIdExists)

    RegisterCommand("apiid", function(source, args, rawCommand)
        local identifiers = GetIdentifiers(source)
        local pid = nil
        if isPluginLoaded("esxsupport") then
            local type = Config.plugins["esxsupport"].identityType
            if identifiers[type] ~= nil then
                if Config.plugins["esxsupport"].usePrefix then
                    pid = ("%s:%s"):format(type, identifiers[type])
                else
                    pid = identifiers[type]
                end
            end
        else
            if identifiers[Config.primaryIdentifier] ~= nil then
                pid = identifiers[Config.primaryIdentifier]
            end
        end
        if pid ~= nil then
            print("Your API ID: "..tostring(pid))
        else
            print("API ID not found")
        end
    end)
end