-- Shortcuts for BitProxy create

local Creation = {};
local Service = (game and game.GetService) or nil;
local Create = (Instance and Instance.new) or nil;

Creation.Enabled = true;

if not Create or not Service then
  error("Something went wrong!", 7);
end;

function setIndex(instance, index, value)
  instance[index] = value;
end;

function creation(className, properties)
  local class = Create(className);
  for index, value in pairs(properties) do
    pcall(setIndex, class, index, value);
  end;
  return class;
end;

function Creation.toggle()
  Creation.Enabled = not Creation.Enabled;
end;

function Creation.createInstance(...)
  if Creation.Enabled == false then return end;
  local success, data = pcall(creation, ...);
  return (success and data) or nil;
end;

function Creation.RemoveInstance(object)
  if Creation.Enabled == false then return end;
  pcall(object.Destroy, object);
end;

function Creation.createRemote(remoteType, remoteFunction, ...)
  if Creation.Enabled == false then return end;
  local remote = "RemoteFunction";
  if not remoteType or remoteType == 1 then
    remote = "RemoteEvent";
  end;
  local Class = Creation.createInstance(remote, {...});
  if remote == "RemoteEvent" then
    Class.OnServerEvent:Connect(remoteFunction);
  else
    Class.OnServerInvoke = remoteFunction;
  end;
  return Class;
end;

return Creation;
