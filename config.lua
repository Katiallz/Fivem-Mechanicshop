-----------------------------------------------------------------------------------------------------------------------------------------
-- CONFIGURAÇÕES DA LOJA DE MECÂNICA
-----------------------------------------------------------------------------------------------------------------------------------------
Config = {}

-- Permissão necessária para abastecer a loja (Grupo de Mecânicos)
Config.MechanicPermission = "Mechanic01"

-- O baú só pode ser aberto por membros até esse nível de hierarquia.
-- Hierarquia: 1:Chefe, 2:Sub-Chefe, 3:Gerente, 4:Mecânico, 5:Estagiário
-- O número 3 permite apenas: Chefe, Sub-Chefe e Gerente.
Config.MaxHierarchy = 3

-- Coordenadas do baú de estoque dos mecânicos
-- (Mecânicos precisam ir aqui para depositar e retirar os itens diretamente do baú)
Config.StashCoords = vec3(-360.58,-91.68,39.82) -- [ALTERAR ESTA COORDENADA]

-- Coordenadas da vitrine/loja aberta ao público
-- (Qualquer jogador vem aqui e compra o que estiver no estoque do baú)
Config.ShopCoords = vec3(-362.5,-98.67,39.55) -- [ALTERAR ESTA COORDENADA]

-- Preços dos itens (o que não estiver aqui, não aparecerá na loja para ser comprado)
-- O mecânico guarda os itens no baú, e se o item constar nesta lista, fica visível ao comprador.
Config.Prices = {
    ["tyres"] = { price = 500, name = "Pneu", weight = 2.75 },
    ["toolbox"] = { price = 1000, name = "Caixa de Ferramentas", weight = 2.75 },
    ["advtoolbox"] = { price = 3000, name = "Ferramentas Avançadas", weight = 3.75 },
    ["carjack"] = { price = 1500, name = "Elevador Hidráulico", weight = 5.75 },
    ["WEAPON_WRENCH"] = { price = 800, name = "Chave Inglesa", weight = 1.5 }
}
