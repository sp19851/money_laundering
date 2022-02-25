local QBCore = exports['qb-core']:GetCoreObject()


local function moneyLaundering_automatic_income()
    local companies = exports.oxmysql:fetchSync('SELECT * FROM money_laundering', {})
    if companies ~= nil then
        for i, v in pairs(companies) do
            --print('timmmm',(os.time()-v.time), Config.Period, os.date('%x', v.time))
            print('v.name', v.name)
            if (os.time()-v.time)  >= Config.Period then
                local summa = exports.oxmysql:fetchSync('SELECT * FROM money_laundering where name = ?', {v.name})
                local amount = summa[1].amount - math.ceil((summa[1].amount*0.15))
                print('amount', amount)
                local owner =  exports.oxmysql:fetchSync('SELECT * FROM companies where name = ?', {v.name})
                print('owner', json.encode(owner))
                local Player = QBCore.Functions.GetPlayerByCitizenId(owner[1].owner)
                
                exports.oxmysql:execute('update companies set money = money + ? where name = ?', {amount, v.name})
                exports.oxmysql:execute('delete from  money_laundering where name = ?', {v.name})
                TriggerClientEvent('QBCore:Notify',Player.PlayerData.source,'Процесс отмывки успешно завершенн, на счет вашей компании поступило $' ..amount)    
            end
        end
    end
end

QBCore.Functions.CreateCallback("moneyLaundering:server:checkStatus", function(source, cb, company)
    --print('sv133', company)
    local src = source
    local pData = QBCore.Functions.GetPlayer(src)
    local shopitems = {}
    --print("business:server:GetShopItems", source, cb, company)
   exports.oxmysql:execute('SELECT * FROM money_laundering WHERE name = ?', { company}, function(result)
        if result[1] == nil then
           cb(true)
        else
           cb(false)
        end
    end)
end)

RegisterNetEvent('moneyLaundering:server:loadMoney')
AddEventHandler('moneyLaundering:server:loadMoney', function(company, amount)
    print('moneyLaundering:server:loadMoney', company, amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    local Item = Player.Functions.GetItemByName('markedbills')
    --print(json.encode(Item), Item.amount, ammount)
    if Item.amount >= tonumber(amount) then
        Player.Functions.RemoveItem('markedbills', amount)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['markedbills'], "remove")
        exports.oxmysql:execute('insert into money_laundering (name, amount, time) values (?,?,?)', {company, amount, os.time()}) 
    else
        TriggerClientEvent('QBCore:Notify', src,'У вас нет требуемого количества грязных денег', 'error')
    end
end)



Citizen.CreateThread(function()
    while true do
        local sleep = 5000
        moneyLaundering_automatic_income()
        Citizen.Wait(sleep) 
    end
end)
