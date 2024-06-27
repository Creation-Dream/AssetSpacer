local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local function createNamespace(name: string, container: Instance)
  assert(RunService:IsServer(), "Cannot create namespaces on client. Is path valid?")
  local newFolder = Instance.new("Folder")
  newFolder.Name = name
  newFolder.Parent = container
end

local function decodePath(path: string, startingPoint: Instance): Instance
  local split = string.split(path, ":")
  if #split > 2 then error("Two or more namespaces in path.") end

  local namespace = split[1]
  local pathTable = string.split(split[2], "/")

  if not startingPoint[namespace] then createNamespace(namespace, startingPoint) end
  local index = startingPoint[namespace]

  for i, pathMember in ipairs(pathTable) do
    if index[pathMember] then index = index[pathMember]; continue end
    assert(i == #pathTable, "No such item found in path: "..path)
    assert(RunService:IsServer(), "Cannot create folders on client. Is path valid?")

    local newFolder = Instance.new("Folder")
    newFolder.Name = pathMember
    newFolder.Parent = index

    index = newFolder
  end
  
  return index
end

local AssetSpacer = {}

function AssetSpacer.getShared(path: string): Instance
  return decodePath(path, ReplicatedStorage)
end

function AssetSpacer.getServer(path: string): Instance
  assert(RunService:IsServer(), "Cannot call getServer() on client.")
  return decodePath(path, ServerStorage)
end

function AssetSpacer.addServer(path: string, item: Instance)
  assert(RunService:IsServer(), "Cannot call addServer() on client.")
  item.Parent = decodePath(path, ServerStorage)
end

function AssetSpacer.addShared(path: string, item: Instance)
  assert(RunService:IsServer(), "Cannot call addShared() on client.")
  item.Parent = decodePath(path, ReplicatedStorage)
end

return AssetSpacer
