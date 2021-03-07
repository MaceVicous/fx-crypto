local coin = "dogecoin"
TriggerEvent('RSCore:GetObject', function(obj) RSCore = obj end)

Citizen.CreateThread(function() 
    
    while true do 
            Citizen.Wait((60*(60*1000)) * 4) 
                           
            HandlePriceChance()                   
    end

end)
HandlePriceChance = function()
    local currentValue = Crypto.Worth[coin]
    local prevValue = Crypto.Worth[coin]
    local trend = math.random(0,90) 
    local event = math.random(0, 99)

    if event < 94 then 
        if trend <= 30 then 
            currentValue = currentValue - math.random(1, 49)
        elseif trend >= 60 then 
            currentValue = currentValue + math.random(1, 49)
        end
    else
        if math.random(0, 1) == 1 then 
            currentValue = currentValue + math.random(100, 250)
        else
            currentValue = currentValue - math.random(100, 1000)
        end
    end

    if currentValue <= 1 then 
        currentValue = 1
    end

    table.insert(Crypto.History[coin], {PreviousWorth = prevValue, newWorth = currentValue})
    Crypto.Worth[coin] = currentValue

    RSCore.Functions.ExecuteSql(false, "UPDATE `crypto` SET `worth` = '"..currentValue.."', `history` = '"..json.encode(Crypto.History[coin]).."' WHERE `crypto` = '"..coin.."'")    
    RefreshCrypto()
 
end


RefreshCrypto = function()

    RSCore.Functions.ExecuteSql(true, "SELECT * FROM `crypto` WHERE `crypto` = '"..coin.."'", function(result)
        if result[1] ~= nil then
            
            Crypto.Worth[coin] = result[1].worth
            if result[1].history ~= nil then
                Crypto.History[coin] = json.decode(result[1].history)
                TriggerClientEvent('rs-crypto:client:UpdateCryptoWorth', -1, coin, result[1].worth, json.decode(result[1].history))
            else
                TriggerClientEvent('rs-crypto:client:UpdateCryptoWorth', -1, coin, result[1].worth, nil)
            end
        end
    end)
end


AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
      return
    end
    RefreshCrypto()
    print("Found price of" .. coin .. " with value off ".. Crypto.Worth[coin])
  end)
  
  