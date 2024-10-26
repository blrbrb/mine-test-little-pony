
local function node_down_fsable(pos,num,type)

    local draw_ta = {"airlike"}
    local draw_tl = {"liquid","flowingliquid"}
    local i = 0
    local nodes = {}
    local result ={}
    local compare = draw_ta
        while (i < num ) do
            table.insert(nodes, minetest.get_node({x=pos.x,y=pos.y-i,z=pos.z}))
            i=i+1
        end
    
        if type == "s" then
            compare = draw_tl
        end
    
        local n_draw
        for k,v in pairs(nodes) do
            local n_draw
    
            if minetest.registered_nodes[v.name] then
                n_draw = minetest.registered_nodes[v.name].drawtype
            else
                n_draw = "normal"
            end
    
                for k2,v2 in ipairs(compare) do
                    if n_draw == v2 then
                          table.insert(result,"t")
                    end
                end
        end
    
        if #result == num then
            return true
        else
            return false
        end
    end

local function get_wasd_state(controls)

        local rtn = false
    
        if controls.up == true or
           controls.down == true or
           controls.left == true or
           controls.right == true then
    
            rtn = true
        end
    
        return rtn
    end


local function table_to_string(tbl)
        local result = "{ "
        for key, value in pairs(tbl) do
            -- Handle string keys
            if type(key) == "string" then
                result = result .. '"' .. key .. '" = '
            else
                result = result .. key .. " = "
            end
            
            -- Handle string values, other types can be handled as needed
            if type(value) == "string" then
                result = result .. '"' .. value .. '", '
            elseif type(value) == "table" then
                result = result .. table_to_string(value) .. ", "
            else
                result = result .. tostring(value) .. ", "
            end
        end
        result = result .. "}"
        return result
    end
    

--overide default player_api animations 
-- this is the only sufficent solution for now 
-- TD: 
-- Factorize all of the logic here and create a basic api for mods to be able to manipulate 
-- add logic for swimming and mining animations 
-- add logic for flying animation 
-- add logic for sleeping 


player_api.globalstep = function()
        for _, player in ipairs(minetest.get_connected_players()) do
        local name  = player:get_player_name()
        local pos = player:get_pos()
        local pmove = player:get_player_control()
        local velocity = player:get_velocity()
        local node = minetest.get_node(pos).name
        local pattached = player:get_attach()
        local mesh = player:get_properties().mesh     
        local pmeta = player:get_meta()
        local cont = get_wasd_state(pmove)
        local phys = player:get_physics_override()
        local privs = minetest.get_player_privs(player:get_player_name())
        --dbg 
        if mesh == "ponybase_java.b3d"  then
            -- fetch the animations prop from the player, only if it's a pony model
            -- this is a pretty expensive operation, and it would cause lag if it was done every frame 
            --initalize the player states, if not already 
            if not minelp.player_states[name] then
                minelp.player_states[name] = {is_swimming = false, action_time = 0}
            end

            --accumulate delta time, and save it to the player state mechanism 
           -- minelp.player_states[name].action_time = minelp.player_states[name].action_time + dtime
             --local speed = math.sqrt(velocity.x^2 + velocity.y^2 + velocity.z^2)
            -- minetest.debug(table_to_string(player_api.get_animation(player)))
           if pmove.sneak then
				player_api.set_animation(player, "sneak", 30)
		   end
           if player:get_hp() == 0 then
				player_api.set_animation(player, "lay")
		   elseif pmove.up or pmove.down or pmove.left or pmove.right then
				if pmove.LMB or pmove.RMB then
					--player_set_animation(player, "walk_mine", animation_speed_mod)
                elseif node_down_fsable(pos,2,"s") and
                    not pattached and cont then
                    player_api.set_animation(player, "swim",30,0,1)
                    minetest.debug(player_api.get_animation(player).name)
				else
					player_api.set_animation(player, "walk", 30)
				end
		   elseif pmove.LMB or pmove.RMB then
				player_api.set_animation(player, "mine", 30)
           elseif privs.fly and node_down_fsable(pos,3,"a") and
           not pattached then 
                player_api.set_animation(player, "fly", 30)
			else
				player_api.set_animation(player, "stand", 30)
			end
          
               
             return
            end

        end
        end


