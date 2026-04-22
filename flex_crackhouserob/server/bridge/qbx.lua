if GetResourceState(Config.CoreName.qbx) ~= 'started' then return end

function GetPlayer(src)
    return exports.qbx_core:GetPlayer(src)
end

function GetPlayerByCitizenId(identifier)
    return exports.qbx_core:GetPlayerByCitizenId(identifier)
end

function RemoveItem(src, item, amount, info, slot)
    return exports.ox_inventory:RemoveItem(src, item, amount, info, slot or nil)
end

function AddItem(src, item, amount, info, slot)
    if string.find(item, "_blueprint", 1, true) then
        local blueprint = item:gsub("_blueprint", "")
        return exports['nextgenfivem_crafting']:givePlayerBlueprint(src, blueprint)
    end
    return exports.ox_inventory:AddItem(src, item, amount, info, slot or nil)
end

function HasInvGotItem(inv, search, item, metadata, amount)
    if type(amount) == "boolean" then return end
    if amount == 0 then return false end
    if exports.ox_inventory:Search(inv, search, item) >= amount then
        return true
    else
        return false
    end
end

function GetInvItems(inv)
    return exports.ox_inventory:GetInventoryItems(inv)
end

function GetItemBySlot(src, slot)
    local Player = exports.qbx_core:GetPlayer(src)
    return Player.Functions.GetItemBySlot(slot)
end

function AddMoney(src, AddType, amount, reason)
    exports.qbx_core:AddMoney(src, AddType, amount, reason or '')
end

function RegisterStash(id, slots, maxWeight)
    exports.ox_inventory:RegisterStash(id, id, slots, maxWeight)
end

function RegisterTempStash(label, slots, maxWeight, coords, job, items)
    local info = {
        id = label,
        label = label,
        owner = nil,
        name = label,
		slots = slots,
		maxWeight = maxWeight,
		coords = coords,
        groups = nil,
        items = items or {}
    }
    if job ~= nil then
        if type(job) == 'table' then
            info.groups = job
        else
            info.groups = {[job] = 0}
        end
    end
    return exports.ox_inventory:CreateTemporaryStash(info)
end

function ClearStash(id)
    exports.ox_inventory:ClearInventory(id, 'false')
end

function SetJob(src, job, grade)
    local Player = exports.qbx_core:GetPlayer(src)
    exports.qbx_core:SetJob(src, job, grade)
end

function GetJobs()
    return exports.qbx_core:GetJobs()
end

function GetDutyCount(job)
    return exports.qbx_core:GetDutyCountJob(job) or 0
end