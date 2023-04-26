-- // Scripted by HTTPRequester(BitProxy)
error("This isn't completed yet!", 7)

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

return function(dataSetting)
  local DataStoreApi = {}
  local ServerData = {}
  local DataStore = DataStoreService:GetDataStore(dataSetting.DATA_NAME)
  local RetryMax = dataSetting.DATA_RETRY_ATTEMPTS
  local function DataStoreFunction(func)
    local success, data = pcall(func)
    local Attempts = 0
    repeat
      if success then break end
      wait(1)
      Attempts = Attempts + 1
      success, data = pcall(func)
    until success == true or Attempts == RetryMax
    if not success then
      error("DataStoreService is not working for now, please Enable Studio Access to API Services.", 7)
    end
    return data
  end
  local function setupDataStore(plr)
    local Data = DataStoreFunction(function()
      return DataStore:GetAsync(dataSetting.DATA_KEY .. plr.UserId)
    end)
    if not Data then
      Data = dataSetting.DATA_STARTER
    end
    ServerData[plr] = Data
  end
  local function saveDataStore(plr)
    DataStoreFunction(function()
      return DataStore:UpdateAsync(dataSetting.DATA_KEY .. plr.UserId, function()
        return ServerData[plr]
      end)
    end)
  end
  local function FetchError(str)
    local TypeErrors = {
      ["429"] = "Too many requests incoming!",
    }
    for index, err in pairs(TypeErrors)do
      if string.find(index, string.lower(str)) then
        return err
      end
    end
    return "DataStore returned as nil / error."
  end
  for index, player in pairs(Players:GetPlayers()) do
    setupDataStore(player)
  end
  function game.OnClose()
    for index, value in pairs(Players:GetPlayers()) do
      saveDataStore(value)
    end
    wait(1)
  end
  function DataStoreApi:SetStatData(player, statName, any)
    ServerData[player][statName] = any
  end
  function DataStoreApi:AddToData(player, statName, statValue)
    if ServerData[player][statName] == nil then ServerData[player][statName] = 0 end
    ServerData[player][statName] = ServerData[player][statName] + statValue
  end
  function DataStoreApi:SetData(player, any)
    ServerData[player] = any
  end
  function DataStoreApi:GetData(player)
    if ServerData[player] == nil then repeat wait() until ServerData[player] ~= nil end
    return ServerData[player]
  end
  function DataStoreApi:GetDataAsyncByUserId(userId)
    local datastore = DataStoreFunction(function() return DataStore:GetAsync(dataSetting.DATA_KEY .. userId) end)
    if datastore then return datastore end
    return FetchError(datastore)
  end
  Players.PlayerAdded:Connect(setupDataStore)
  Players.PlayerRemoving:Connect(saveDataStore)
  return DataStoreApi
end







