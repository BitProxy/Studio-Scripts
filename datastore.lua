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
    until Attempts == RetryMax or success == true
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
  for index, player in pairs(Players:GetPlayers()) do
    setupDataStore(player)
  end
  function game.OnClose()
    for index, value in pairs(Players:GetPlayers()) do
      saveDataStore(value)
    end
    wait(1)
  end
  Players.PlayerAdded:Connect(setupDataStore)
  Players.PlayerRemoving:Connect(saveDataStore)
  return DataStoreApi
end
