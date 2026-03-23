-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")

-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
vSERVER = Tunnel.getInterface("ryze_mechanicshop")

-----------------------------------------------------------------------------------------------------------------------------------------
-- THREAD START
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
    -- Cria o acesso do Estoque (apenas mecânicos podem abrir para estocar)
    exports["target"]:AddCircleZone("MechanicShop_Stash", Config.StashCoords, 1.0, {
        name = "MechanicShop_Stash",
        heading = 0
    }, {
        shop = "MechanicShop",
        Distance = 1.5,
        options = {
            {
                event = "ryze_mechanicshop:openStash",
                label = "Estoque",
                tunnel = "shop"
            },
            {
                event = "ryze_mechanicshop:managePrices",
                label = "Gerenciar Preços",
                tunnel = "shop"
            }
        }
    })

    -- Cria o acesso da Vitrine/Loja (qualquer um pode comprar)
    exports["target"]:AddCircleZone("MechanicShop_Store", Config.ShopCoords, 1.0, {
        name = "MechanicShop_Store",
        heading = 0
    }, {
        shop = "MechanicShop",
        Distance = 1.5,
        options = {
            {
                event = "ryze_mechanicshop:openShop",
                label = "Comprar",
                tunnel = "shop"
            }
        }
    })
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- EVENTOS
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("ryze_mechanicshop:openStash", function()
    vSERVER.openStash()
end)

AddEventHandler("ryze_mechanicshop:openShop", function()
    local shopItems = vSERVER.getShopItems()
    
    if not shopItems or #shopItems == 0 then
        TriggerEvent("Notify", "amarelo", "ATENÇÃO", "Nossa loja está vazia no momento. Volte mais tarde!", 5000)
        return
    end

    local options = {}

    for _, itemData in ipairs(shopItems) do
        table.insert(options, {
            title = itemData.name,
            description = "Estoque Disponível: " .. itemData.amount .. "\nPreço Fixo: $" .. parseFormat(itemData.price),
            icon = "box",
            onSelect = function()
                local amountInput = lib.inputDialog("Comprar " .. itemData.name, {
                    { type = "number", label = "Quantidade", description = "Máximo em estoque: " .. itemData.amount, default = 1, min = 1, max = itemData.amount }
                })

                if amountInput and amountInput[1] then
                    local buyAmount = tonumber(amountInput[1])
                    if buyAmount and buyAmount > 0 then
                        vSERVER.buyItem(itemData.item, buyAmount)
                    end
                end
            end
        })
    end

    lib.registerContext({
        id = 'mechanic_shop_menu',
        title = 'Loja da Oficina Mecânica',
        options = options
    })

    lib.showContext('mechanic_shop_menu')
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- GERENCIAR PREÇOS
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("ryze_mechanicshop:managePrices", function()
    local adminItems = vSERVER.getAdminShopItems()
    
    if not adminItems or #adminItems == 0 then
        TriggerEvent("Notify", "vermelho", "ATENÇÃO", "Você não tem permissão para gerenciar a loja.", 5000)
        return
    end

    local options = {}

    for _, itemData in ipairs(adminItems) do
        table.insert(options, {
            title = itemData.name,
            description = "Preço Atual: $" .. parseFormat(itemData.currentPrice) .. "\n(Padrão: $" .. parseFormat(itemData.defaultPrice) .. ")",
            icon = "gear",
            onSelect = function()
                local priceInput = lib.inputDialog("Definir Preço: " .. itemData.name, {
                    { type = 'number', label = 'Novo Preço (Dólares)', description = 'Para redefinir, mantenha o valor padrão.', default = itemData.currentPrice, min = 1 }
                })

                if priceInput and priceInput[1] then
                    local newPrice = tonumber(priceInput[1])
                    if newPrice and newPrice > 0 then
                        vSERVER.setShopItemPrice(itemData.item, newPrice)
                    end
                end
            end
        })
    end

    lib.registerContext({
        id = 'mechanic_manage_menu',
        title = 'Gerenciamento de Preços',
        options = options
    })

    lib.showContext('mechanic_manage_menu')
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- FUNÇÕES ÚTEIS CLIENT-SIDE (Para compatibilidade visual)
-----------------------------------------------------------------------------------------------------------------------------------------
function parseFormat(v)
	local string = tostring(v)
	local v,_ = string:gsub("^(-?%d+)(%d%d%d)","%1.%2")
	return v
end
