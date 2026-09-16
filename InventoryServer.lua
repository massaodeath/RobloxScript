local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local inventorySystem = ReplicatedStorage:WaitForChild("InventorySystem")
local remotes = inventorySystem:WaitForChild("RemoteEvents")

local inventoryAction = remotes:WaitForChild("InventoryAction")
local inventoryUpdate = remotes:WaitForChild("InventoryUpdate")

local ItemConfig = require(inventorySystem:WaitForChild("ItemConfig"))

local MAX_SLOTS = 10

local inventories = {}

-- CRIA INVENTÁRIO

local function createInventory(player)

	inventories[player] = {}

	for i = 1, MAX_SLOTS do
		inventories[player][i] = nil
	end

end

-- ENCONTRA ITEM

local function findItem(player, itemName)

	local inventory = inventories[player]

	if not inventory then
		return nil
	end

	for slot = 1, MAX_SLOTS do

		local item = inventory[slot]

		if item and item.Name == itemName then
			return slot
		end

	end

	return nil
end

-- ADICIONAR ITEM

local function addItem(player, itemName, amount)

	local config = ItemConfig[itemName]

	if not config then
		return false
	end

	local inventory = inventories[player]

	if not inventory then
		return false
	end

	amount = amount or 1

	-- Primeiro tenta colocar em uma pilha existente
	for slot = 1, MAX_SLOTS do

		local item = inventory[slot]

		if item and item.Name == itemName then

			local space = config.MaxStack - item.Amount

			if space > 0 then

				local added = math.min(space, amount)

				item.Amount += added
				amount -= added

				if amount <= 0 then
					return true
				end

			end

		end

	end

	-- Depois procura um slot vazio
	for slot = 1, MAX_SLOTS do

		if inventory[slot] == nil then

			local added = math.min(config.MaxStack, amount)

			inventory[slot] = {
				Name = itemName,
				Amount = added
			}

			amount -= added

			if amount <= 0 then
				return true
			end

		end

	end

	return false
end

-- REMOVER ITEM

local function removeItem(player, slot, amount)

	local inventory = inventories[player]

	if not inventory then
		return false
	end

	local item = inventory[slot]

	if not item then
		return false
	end

	amount = amount or 1

	item.Amount -= amount

	if item.Amount <= 0 then
		inventory[slot] = nil
	end

	return true
end

-- ENVIA INVENTÁRIO PARA O CLIENTE


local function updateInventory(player)

	local inventory = inventories[player]

	if not inventory then
		return
	end

	inventoryUpdate:FireClient(player, inventory)

end

-- DROPAR ITEM

local function dropItem(player, slot)

	local inventory = inventories[player]

	if not inventory then
		return
	end

	local item = inventory[slot]

	if not item then
		return
	end

	local character = player.Character

	if not character then
		return
	end

	local root = character:FindFirstChild("HumanoidRootPart")

	if not root then
		return
	end

	local dropFolder = workspace:FindFirstChild("ItemDrops")

	if not dropFolder then

		dropFolder = Instance.new("Folder")
		dropFolder.Name = "ItemDrops"
		dropFolder.Parent = workspace

	end

	local part = Instance.new("Part")

	part.Name = item.Name
	part.Size = Vector3.new(1.5, 1.5, 1.5)
	part.Position = root.Position + root.CFrame.LookVector * 4 + Vector3.new(0, 1, 0)

	part.Anchored = false
	part.CanCollide = true

	part.Color = ItemConfig[item.Name].Color

	part:SetAttribute("ItemName", item.Name)
	part:SetAttribute("Amount", item.Amount)

	part.Parent = dropFolder

	local prompt = Instance.new("ProximityPrompt")

	prompt.ActionText = "Pegar"
	prompt.ObjectText = ItemConfig[item.Name].DisplayName

	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = 10

	prompt.Parent = part

	prompt.Triggered:Connect(function(pickingPlayer)

		local droppedItemName = part:GetAttribute("ItemName")
		local droppedAmount = part:GetAttribute("Amount")

		if not droppedItemName then
			return
		end

		if addItem(pickingPlayer, droppedItemName, droppedAmount) then

			updateInventory(pickingPlayer)

			part:Destroy()

		end

	end)

	removeItem(player, slot, item.Amount)

	updateInventory(player)

end

-- EQUIPAR

local function equipItem(player, slot)

	local inventory = inventories[player]

	if not inventory then
		return
	end

	local item = inventory[slot]

	if not item then
		return
	end

	local character = player.Character

	if not character then
		return
	end

	-- Remove ferramenta antiga
	local oldTool = character:FindFirstChild("InventoryTool")

	if oldTool then
		oldTool:Destroy()
	end

	-- Criar ferramenta
	local tool = Instance.new("Tool")

	tool.Name = "InventoryTool"
	tool.RequiresHandle = false
	tool.CanBeDropped = false

	tool:SetAttribute("ItemName", item.Name)

	tool.Parent = character

end

-- AÇÕES DO CLIENTE

inventoryAction.OnServerEvent:Connect(function(player, action, data)
	
	if action == "Pickup" then

		if typeof(data) ~= "string" then
			return
		end

		if not ItemConfig[data] then
			return
		end

		if addItem(player, data, 1) then

			updateInventory(player)

		end

	end
	
	if action == "Equip" then

		if typeof(data) ~= "number" then
			return
		end

		equipItem(player, data)

	elseif action == "Drop" then

		if typeof(data) ~= "number" then
			return
		end

		dropItem(player, data)

	end

end)

-- PLAYER ENTRA

Players.PlayerAdded:Connect(function(player)

	createInventory(player)

	-- Itens iniciais para teste
	addItem(player, "Apple", 3)
	addItem(player, "Wood", 5)

	task.wait(1)

	updateInventory(player)

end)


-- PLAYER SAI

Players.PlayerRemoving:Connect(function(player)

	inventories[player] = nil

end)