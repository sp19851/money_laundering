Keys = {
    ['ESC'] = 322, ['F1'] = 288, ['F2'] = 289, ['F3'] = 170, ['F5'] = 166, ['F6'] = 167, ['F7'] = 168, ['F8'] = 169, ['F9'] = 56, ['F10'] = 57,
    ['~'] = 243, ['1'] = 157, ['2'] = 158, ['3'] = 160, ['4'] = 164, ['5'] = 165, ['6'] = 159, ['7'] = 161, ['8'] = 162, ['9'] = 163, ['-'] = 84, ['='] = 83, ['BACKSPACE'] = 177,
    ['TAB'] = 37, ['Q'] = 44, ['W'] = 32, ['E'] = 38, ['R'] = 45, ['T'] = 245, ['Y'] = 246, ['U'] = 303, ['P'] = 199, ['['] = 39, [']'] = 40, ['ENTER'] = 18,
    ['CAPS'] = 137, ['A'] = 34, ['S'] = 8, ['D'] = 9, ['F'] = 23, ['G'] = 47, ['H'] = 74, ['K'] = 311, ['L'] = 182,
    ['LEFTSHIFT'] = 21, ['Z'] = 20, ['X'] = 73, ['C'] = 26, ['V'] = 0, ['B'] = 29, ['N'] = 249, ['M'] = 244, [','] = 82, ['.'] = 81,
    ['LEFTCTRL'] = 36, ['LEFTALT'] = 19, ['SPACE'] = 22, ['RIGHTCTRL'] = 70,
    ['HOME'] = 213, ['PAGEUP'] = 10, ['PAGEDOWN'] = 11, ['DELETE'] = 178,
    ['LEFT'] = 174, ['RIGHT'] = 175, ['TOP'] = 27, ['DOWN'] = 173,
}

local QBCore = exports['qb-core']:GetCoreObject()

---functions---
local  function DrawText3Ds(x, y, z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end
--[[RegisterNetEvent('qb-radialmenu:client:givecashtoplayer')
AddEventHandler('qb-radialmenu:client:givecashtoplayer', function(data)
   

  
end)]]
local function checkStatusMenu(company)
    QBCore.Functions.TriggerCallback('moneyLaundering:server:checkStatus', function(result)
        if result then
            local dialog = exports['qb-input']:ShowInput({
                header = '🧼 "Прачечная"',
                submitText = "Загрузить грязные деньги",
                inputs = {
                {
                        text = "Сумма ($)", -- text you want to be displayed as a place holder
                        name = "cash", -- name of the input should be unique otherwise it might override
                        type = "number", -- type of the input - number will not allow non-number characters in the field so only accepts 0-9
                        isRequired = false -- Optional [accepted values: true | false] but will submit the form if no value is inputted
                    },
                },
            })
            if dialog ~= nil then
                TriggerServerEvent('moneyLaundering:server:loadMoney', company, dialog.cash)
            end
        else
            QBCore.Functions.Notify('Вы не можете запустить отмыв, так как не завершен предыдущий процесс', "error")
        end
    end, company)
end
---events---

---threads---
Citizen.CreateThread(function()
    while not LocalPlayer.state['isLoggedIn'] do
        Wait(5000)
    end
    while true do
        local sleep = 1500
        local pos = GetEntityCoords(PlayerPedId())
        --print(json.encode(Config.Places))
        for i, v in pairs(Config.Places) do 
            local coordMarker = v.coords 
            local dist_to_marker = #(pos-coordMarker)
            local jobName = QBCore.Functions.GetPlayerData().job.name
            if dist_to_marker > 1.5 and dist_to_marker <= 5.0 and jobName == v.job then
                sleep = 0
                DrawText3Ds(coordMarker.x, coordMarker.y, coordMarker.z, '~g~"Прачечная"')
                break
            elseif dist_to_marker <= 1.5 then
                sleep = 0
                DrawText3Ds(coordMarker.x, coordMarker.y, coordMarker.z, '~g~[E] ~w~ для взаимодействия')
                if IsControlJustPressed(0, Keys["E"]) then
                    
                    if QBCore.Functions.GetPlayerData().job.isboss then
                        checkStatusMenu(jobName)
                
                    else
                        QBCore.Functions.Notify('У вас нет доступа к этой функции, обратитесь к лидеру', "error")
                    end
                end
                break
            else
                --sleep = 1500
            end
        end
        
        Citizen.Wait(sleep) 
    end
    
end)