-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")

-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
RyzeMechanicShop = {}
Tunnel.bindInterface("ryze_mechanicshop", RyzeMechanicShop)

-----------------------------------------------------------------------------------------------------------------------------------------
-- ABRIR ESTOQUE MÚTUO
-----------------------------------------------------------------------------------------------------------------------------------------
function RyzeMechanicShop.openStash()
    local source = source
    local Passport = vRP.Passport(source)
    if not Passport then return end

    if vRP.HasGroup(Passport, Config.MechanicPermission, Config.MaxHierarchy) then
        -- Abre um "chest" forçado via trigger padrão do resources/chest
        TriggerEvent("chest:forceOpen", source, {
            name = "LojaMecanica", -- Key no SrvData
            slots = 50,            -- Tamanho do Baú
            weight = 2000,         -- Peso Máximo do Baú
            logs = "MecanicaShop", -- Logs no banco
            save = true
        })
    else
        TriggerClientEvent("Notify", source, "vermelho", "NEGADO", "Você não tem permissão para acessar o estoque.", 5000)
    end
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- OBTER OS ITENS PARA O CIDADÃO COMPRAR
-----------------------------------------------------------------------------------------------------------------------------------------
function RyzeMechanicShop.getShopItems()
    local source = source
    local chestData = vRP.GetSrvData("LojaMecanica")
    local customPrices = vRP.GetSrvData("LojaMecanica:Prices") or {}
    local items = {}

    if chestData then
        for slot, data in pairs(chestData) do
            local itemKey = data.item
            local shortName = splitString(itemKey, "-")[1] or itemKey

            local info = Config.Prices[shortName]
            
            if info then
                local currentPrice = customPrices[shortName] and parseInt(customPrices[shortName]) or info.price
                table.insert(items, {
                    item = itemKey,
                    short = shortName,
                    name = info.name,
                    amount = parseInt(data.amount),
                    price = currentPrice
                })
            end
        end
    end

    -- Organiza por nome pra ficar bonito
    table.sort(items, function(a, b) return a.name < b.name end)
    
    return items
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- COMPRAR ITEM DA VITRINE
-----------------------------------------------------------------------------------------------------------------------------------------
function RyzeMechanicShop.buyItem(targetItemKey, amount)
    local source = source
    local Passport = vRP.Passport(source)
    if not Passport then return end

    amount = parseInt(amount)
    if amount <= 0 then return end

    local chestData = vRP.GetSrvData("LojaMecanica")
    local customPrices = vRP.GetSrvData("LojaMecanica:Prices") or {}
    local foundSlot = nil
    local currentAmount = 0
    local shortName = ""

    -- Procura o item e o slot correspondente no baú
    if chestData then
        for slot, data in pairs(chestData) do
            if data.item == targetItemKey then
                foundSlot = slot
                currentAmount = parseInt(data.amount)
                shortName = splitString(data.item, "-")[1] or data.item
                break
            end
        end
    end

    -- Se o item existe no baú e a quantidade desejada é igual ou menor ao estoque
    if foundSlot and currentAmount >= amount then
        local info = Config.Prices[shortName]
        if info then
            local currentPrice = customPrices[shortName] and parseInt(customPrices[shortName]) or info.price
            local totalPrice = currentPrice * amount
            local itemPeso = info.weight * amount

            -- Checa se o player tem vaga na mochila
            if (vRP.InventoryWeight(Passport) + itemPeso) <= vRP.GetWeight(Passport) then
                
                -- Checa se tem dólares e remove
                if vRP.PaymentFull(Passport, totalPrice) then
                    
                    -- REMOVE o item do bau
                    chestData[foundSlot].amount = currentAmount - amount
                    if chestData[foundSlot].amount <= 0 then
                        chestData[foundSlot] = nil
                    end
                    vRP.SetSrvData("LojaMecanica", chestData)

                    -- DA O ITEM PARA O PLAYER
                    vRP.GenerateItem(Passport, targetItemKey, amount, true)

                    -- DINHEIRO PRA SOCIEDADE
                    local identity = vRP.Identity(Passport)
                    local buyerName = identity and (identity.name .. " " .. identity.name2) or "Desconhecido"
                    local logText = "Venda: " .. amount .. "x " .. info.name .. " (" .. buyerName .. " - ID:" .. Passport .. ")"

                    vRP.Query("panel/UpgradeBank", { name = Config.MechanicPermission, Value = totalPrice })
                    vRP.Query("panel/InsertTransaction", { name = Config.MechanicPermission, Type = string.sub(logText, 1, 250), Value = totalPrice })
                    
                    TriggerClientEvent("Notify", source, "verde", "SUCESSO", "Você comprou <b>" .. amount .. "x " .. info.name .. "</b> por <b>$" .. parseFormat(totalPrice) .. "</b>.", 5000)
                else
                    TriggerClientEvent("Notify", source, "vermelho", "NEGADO", "Dólares insuficientes.", 5000)
                end
            else
                TriggerClientEvent("Notify", source, "amarelo", "ATENÇÃO", "Espaço insuficiente na mochila.", 5000)
            end
        else
            TriggerClientEvent("Notify", source, "vermelho", "ATENÇÃO", "Item não configurado corretamente.", 5000)
        end
    else
        TriggerClientEvent("Notify", source, "amarelo", "ATENÇÃO", "O estoque da loja acabou de alterar ou não há itens suficientes.", 5000)
    end
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- METODOS DA GERENCIA PARA EDITAR PREÇOS
-----------------------------------------------------------------------------------------------------------------------------------------
function RyzeMechanicShop.getAdminShopItems()
    local source = source
    local Passport = vRP.Passport(source)
    if not Passport then return false end

    if not vRP.HasGroup(Passport, Config.MechanicPermission, Config.MaxHierarchy) then
        return false
    end

    local customPrices = vRP.GetSrvData("LojaMecanica:Prices") or {}
    local adminItems = {}

    for shortName, info in pairs(Config.Prices) do
        local customP = customPrices[shortName]
        table.insert(adminItems, {
            item = shortName,
            name = info.name,
            defaultPrice = info.price,
            currentPrice = customP and parseInt(customP) or info.price
        })
    end

    table.sort(adminItems, function(a, b) return a.name < b.name end)
    return adminItems
end

function RyzeMechanicShop.setShopItemPrice(shortName, newPrice)
    local source = source
    local Passport = vRP.Passport(source)
    if not Passport then return end

    if not vRP.HasGroup(Passport, Config.MechanicPermission, Config.MaxHierarchy) then
        TriggerClientEvent("Notify", source, "vermelho", "NEGADO", "Você não possui permissão de gerência.", 5000)
        return
    end

    if not Config.Prices[shortName] then
        TriggerClientEvent("Notify", source, "vermelho", "ERRO", "Item inválido.", 5000)
        return
    end

    local customPrices = vRP.GetSrvData("LojaMecanica:Prices") or {}
    local actualNewPrice = parseInt(newPrice)

    if actualNewPrice <= 0 then actualNewPrice = Config.Prices[shortName].price end

    customPrices[shortName] = actualNewPrice
    vRP.SetSrvData("LojaMecanica:Prices", customPrices)

    TriggerClientEvent("Notify", source, "verde", "SUCESSO", "O preço de <b>" .. Config.Prices[shortName].name .. "</b> foi ajustado para <b>$" .. parseFormat(actualNewPrice) .. "</b>.", 5000)
end
