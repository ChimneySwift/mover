mover = {}
mover.version = "0.1.0"

-- Takes node meta and creates a serialized string readable by mover.deserialize_meta
mover.serialize_meta = function(meta)
    local nmt = meta:to_table()
    if nmt.inventory then
        for l in pairs(nmt.inventory) do
            for s in pairs(nmt.inventory[l]) do
                nmt.inventory[l][s] = nmt.inventory[l][s]:to_string()
            end
        end
    end
    return minetest.serialize(nmt)
end

-- Takes string given from mover.serialize_meta and converts it to a node meta table usable by from_table
mover.deserialize_meta = function(nms)
    local nmt = minetest.deserialize(nms)
    if nmt.inventory then
        for l in pairs(nmt.inventory) do
            for s in pairs(nmt.inventory[l]) do
                nmt.inventory[l][s] = ItemStack(nmt.inventory[l][s])
            end
        end
    end
    return nmt
end

-- Check both minetest.is_protected and owner metadata (for locked chests etc)
mover.can_modify_node = function(pos, player)
    local meta = minetest.get_meta(pos)
    local name = player:get_player_name()
    if (minetest.is_protected(pos, name) or (meta:get_string("owner") ~= "" and meta:get_string("owner") ~= name)) and not minetest.check_player_privs(player, "protection_bypass") then
        return false
    end
    return true
end

minetest.register_tool("mover:move_tool", {
    description = "Node Move Tool (empty)",
    inventory_image = "moveroff.png",
    on_place = function(itemstack, player, pointed_thing)
        if pointed_thing.type ~= "node" then return end
        minetest.chat_send_player(player:get_player_name(), "You must first save a node!")
    end,
    on_use = function(itemstack, player, pointed_thing)
        if pointed_thing.type ~= "node" then return end
        local meta = itemstack:get_meta()
        local pos = minetest.get_pointed_thing_position(pointed_thing)

        -- If player can modify the node, save the meta and node and remove it, else send an error
        if mover.can_modify_node(pos, player) then
            local node = minetest.get_node_or_nil(pos)
            local node_meta = minetest.get_meta(pos)
            meta:set_string("node", minetest.serialize(node))
            meta:set_string("node_meta", mover.serialize_meta(node_meta))

            minetest.remove_node(pos)

            -- Return a full tool
            local item_table = itemstack:to_table()
            item_table.name = "mover:move_tool_full"
            return ItemStack(item_table)
        else
            minetest.chat_send_player(player:get_player_name(), "Failed to save protected node")
        end
    end,
})

minetest.register_tool("mover:move_tool_full", {
    description = "Node Move Tool (loaded)",
    inventory_image = "moveron.png",
    groups = {not_in_creative_inventory = 1},
    on_place = function(itemstack, player, pointed_thing)
        if pointed_thing.type ~= "node" then return end
        local meta = itemstack:get_meta()
        local pos = minetest.get_pointed_thing_position(pointed_thing)

        -- Make sure there is actually something to place (in case of metadata corruption)
        if meta:get_string("node") ~= "" then
            -- Get stored values and meta
            local to_node = minetest.deserialize(meta:get_string("node"))
            local to_meta = mover.deserialize_meta(meta:get_string("node_meta"))

            if to_meta.fields.owner and to_meta.fields.owner ~= player:get_player_name() and not minetest.check_player_privs(player, "protection_bypass") then
                minetest.chat_send_player(player:get_player_name(), "Failed to place locked node. (owned by "..to_meta.fields.owner..")")
                return itemstack
            end

            -- if not buildable_to, get the above position
            local node = minetest.get_node(pos)
            if not minetest.registered_items[node.name].buildable_to then
                pos = minetest.get_pointed_thing_position(pointed_thing, true)
            end
            local node_meta = minetest.get_meta(pos)

            -- Place node using on_place function in the node def to avoid problems with special nodes
            local stack, success = minetest.registered_items[to_node.name].on_place(ItemStack(to_node), player, pointed_thing)

            -- Set metadata
            node_meta:from_table(to_meta)

            if success then
                -- Delete meta from itemstack
                meta:set_string("node")
                meta:set_string("node_meta")
            else
                return itemstack
            end
        end

        -- Return an empty tool
        local item_table = itemstack:to_table()
        item_table.name = "mover:move_tool"
        return ItemStack(item_table)
    end,
    on_use = function(itemstack, player, pointed_thing)
        if pointed_thing.type ~= "node" then return end
        minetest.chat_send_player(player:get_player_name(), "You must first place the saved node!")
    end,
})

if minetest.get_modpath("default") then
    minetest.register_craft({
        output = "mover:move_tool",
        recipe = {
            {"default:obsidian_shard", "default:obsidian_shard", "default:obsidian_shard"},
            {"default:obsidian_shard", "default:diamond",        "default:obsidian_shard"},
            {"default:obsidian_shard", "default:obsidian_shard", "default:obsidian_shard"},
        }
    })
end