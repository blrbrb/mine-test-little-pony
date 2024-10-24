minetest.register_globalstep(function(dtime)
    for _, player in ipairs(minetest.get_connected_players()) do
        local name = player:get_player_name()
        local pos = player:get_pos() 
        local node = minetest.get_node(pos).name
        
        local mesh = player:get_properties().mesh 
        --dbg 

        local PlayerRef = getmetatable(player)
        if mesh == "ponybase_java.b3d" then 
            -- fetch the animations prop from the player, only if it's a pony model
            -- this is a pretty expensive operation, and it would cause lag if it was done every frame
            
            local anim = player:get_local_animation().x 
            local bones = player:get_properties().bones
        -- Check if the player is in water 
        -- TD add logic to ensure models that are being acted on here are actually from the mine little pony mod, and are not base armature
            
        
            if minetest.registered_nodes[node].liquidtype == "source" and dtime <= 100 then
                --minetest.debug("we are currently standing above a watersource" .. minetest.registered_nodes[node].liquidtype)
                --minetest.debug("registered animations " .. minelp.default_model.animations.jump.x)
               -- minetest.debug(anim)
                player_api.set_animation(player,"swim") -- Replace "swim" with your animation name
                
            else
                -- there's nothing else to do, let luanti decide 
                return 
            end
        end 
       
       
    end
end)
