local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

ftsC = {}
Tunnel.bindInterface("fts_caixaeletronico", ftsC)

NomeSujo = "dinheirosujo" -- NOME DO ITEM QUE O PLAYER IRÁ RECEBER

tempos = {}
CreateThread(function()
    while true do
        Wait(1000)
        for k, v in pairs(tempos) do 
            if v > 0 then 
                tempos[k] = v - 1 
            end 
        end
    end
end)

function ftsC.ChecarRoubo(id,x,y,z)
    local source = source
    local user_id = vRP.getUserId()
    local policia = vRP.getUsersByPermission("policia.permissao")
    if Proibido() then
        if #policia >= 0 then
            if tempos[id] == 0 or not tempos[id] then
                tempos[id] = math.random(700,1200)
                ftsC.ChamarPoliciais(policia,x,y,z)
                return true
            else
                TriggerClientEvent("Notify", source, "negado","Este caixa eletronico já foi roubado, aguarde "..tempos[id].." segundos para roubar novamente. corra para outro")
            end
        else
            TriggerClientEvent("Notify",source,"negado","Não tem policiais suficientes em PTR, minimo 2")
        end
    else
        TriggerClientEvent("Notify",source,"negado","Que errado.. você tem um emprego legal!")
    end
end

function ftsC.ChamarPoliciais(policia,x,y,z)
    for k,v in pairs(policia) do
        PoliciaON = vRP.getUserSource(v)
        TriggerClientEvent("fts:AdicionarCDS",PoliciaON,x,y,z)
        TriggerClientEvent("Notify",PoliciaON,"importante","Houve um roubo em uma loja e o alarme foi ativado, vá até o local!")
    end
end

function ftsC.EfetuarPagamento(QuantidadeSujo)
    local source = source
    local user_id = vRP.getUserId(source)
    vRP.giveInventoryItem(user_id,NomeSujo,QuantidadeSujo)
end

function Proibido()
    local source = source
    local user_id = vRP.getUserId(source)
    return not vRP.hasPermission(user_id,"policia.permissao") or vRP.hasPermission(user_id,"paisanapolicia.permissao") or vRP.hasPermission(user_id,"paramedico.permissao") or vRP.hasPermission(user_id,"paisanaparamedico.permissao") or vRP.hasPermission(user_id,"juiza.permissao") or vRP.hasPermission(user_id,"promotor.permissao") or vRP.hasPermission(user_id,"advogado.permissao")
end
