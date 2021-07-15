local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")

ftsC = Tunnel.getInterface("fts_caixaeletronico")

roubando = false
segundos = nil
Blips = {}

CreateThread(function()
    while true do
        sleep = 1000
        for k,v in pairs(Lojinhas) do 
            ped = PlayerPedId()
            direct = v.h
            local pCDS = GetEntityCoords(ped)
            local cds = vector3(v.x,v.y,v.z)
            local distance = #(pCDS - cds)
            if not roubando then
                if distance <= 2 then
                    sleep = 4
                    if distance <= 0.5 then
                        sleep = 4
                        drawText2D("PRESSIONE  ~r~G~w~  PARA ~r~ROUBAR~w~ O CAIXA ELETRONICO",4,0.5,0.93,0.50,255,255,255,180)
                        if IsControlJustPressed(0,47) and not roubando and ftsC.ChecarRoubo(k,v.x,v.y,v.z) then
                            segundos = math.random(13,40)
                            roubando = true
                            RequisitarCancelamento()
                            IniciarRoubo()
                        end
                    end
                end
            end
        end
        Wait(sleep)
    end
end)

function RequisitarCancelamento()
    CreateThread(function()
        while roubando do
            Wait(1)
            if IsControlJustPressed(0, 244) then
                TriggerEvent("Notify","sucesso","Você cancelou sua ação, mas a policia ainda está à caminho!! fuja logo.")
                print('cancelou')
                segundos = -1
            end
        end
    end)
end

function IniciarRoubo()

    CreateThread(function()
        while segundos > 0 do
            Wait(4)
            drawText2D("SUA AÇÃO IRÁ ENCERRAR EM ~r~"..segundos.."~w~ SEGUNDOS, PARA CANCELAR PRESSIONE O ~r~[M]",4,0.5,0.90,0.50,255,255,255,180)
        end
    end)

    CreateThread(function()
        FreezeEntityPosition(ped, true)
        SetPedComponentVariation(ped, 5, 0, 0, 2)
        RequestAnimDict("anim@heists@ornate_bank@grab_cash_heels")
        while not HasAnimDictLoaded("anim@heists@ornate_bank@grab_cash_heels") do
            Wait(1000)
        end
        TaskPlayAnim(ped, "anim@heists@ornate_bank@grab_cash_heels", "grab", 5.0, 5.0, -1, 1, -1, 0.0, 0.0, 0.0)
        SetEntityHeading(ped, direct)
        

        RequestModel(GetHashKey("p_ld_heist_bag_s"))
        while not HasModelLoaded(GetHashKey("p_ld_heist_bag_s")) do
            Wait(1000)
        end

       mochila = CreateObject(GetHashKey("p_ld_heist_bag_s"), 0.0,0.0,0.0, true, true)

       AttachEntityToEntity(mochila, ped, 40269, 0.0, 0.0, 0.12, 0.0, 0.0, 20.0, true, true, false, true, 0.0, false)

        while segundos > 0 do
            Wait(1000)

            local Pagamento = math.random(100,999)
            segundos = segundos -1
            ftsC.EfetuarPagamento(Pagamento)
        end
        DeleteEntity(mochila)
        ClearPedTasks(ped)
        roubando = false
        FreezeEntityPosition(ped, false)
        SetPedComponentVariation(ped, 5, 45, 0, 2)
    end)
end

RegisterNetEvent("fts:AdicionarCDS")
AddEventHandler("fts:AdicionarCDS",function(x,y,z)
    Blips = AddBlipForCoord(x,y,z)
    SetBlipSprite(Blips, 110)
    SetBlipColour(Blips, 1)
    AddTextEntry('Chamar:Policia', 'Ocorrência policial')
    BeginTextCommandSetBlipName('Chamar:Policia')
    EndTextCommandSetBlipName(Blips)
    Wait(50000)
    RemoveBlip(Blips)
end)

function drawText2D(text,font,x,y,scale,r,g,b,a)    
    SetTextFont(font)    
    SetTextScale(scale,scale)    
    SetTextColour(r,g,b,a)    
    SetTextOutline()    
    SetTextCentre(1)    
    SetTextEntry('STRING')    
    AddTextComponentString(text)    
    DrawText(x,y)
end