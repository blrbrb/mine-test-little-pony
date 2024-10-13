print("this file will be run at load time!")
--dofile(minetest.get_modpath(minetest.get_current_modname()) .. "/ponyeditor.lua")
--dofile(minetest.get_modpath(minetest.get_current_modname()) .. "/ponytest.lua")

-- Default player appearance
-- -- animations on model 0-36 idle
-- 37-56 walk 



player_api.register_model("ponybase.b3d", {
    animation_speed = 30,
    visual_size = { x = 8, y = 8 },
    textures = { "minelp_skin_base_1.png" },
    animations = {
        -- Standard animations.
        stand     = { x = 0, y = 36 },
        lay       = {
            x = 162,
            y = 166,
            eye_height = 0.3,
            override_local = true,
            collisionbox = { -0.6, 0.0, -0.6, 0.6, 0.3, 0.6 },
            rotation = { x = 0, y = -90, z = 0 }
        },
        walk      = { x = 37, y = 56, rotation = { x = 0, y = -90, z = 0 } },
        mine      = { x = 189, y = 198, rotation = { x = 0, y = -90, z = 0 } },
        walk_mine = { x = 200, y = 219, rotation = { x = 0, y = -90, z = 0 } },
        sit       = {
            x = 81,
            y = 160,
            eye_height = 0.8,
            override_local = true,
            collisionbox = { -0.3, 0.0, -0.3, 0.3, 1.0, 1.3 },
            rotation = { x = 0, y = -90, z = 0 }
        }
    },
    --almost working for the x axis {0.42, -0.0, -0.5, 0.79, 0.5, 0.1},
    -- { x1, y1, z1, x2, y2, z2 }s
    --default = {-0.3, 0.0, -0.3, 0.3, 1.7, 0.3}
    collisionbox = { -0.3, 0.0, -0.3, 0.3, 1.7, 0.3 },

    stepheight = 0.6,
    eye_height = 1.12,
})



-- Update appearance when the player joins
minetest.register_on_joinplayer(function(player)
    player_api.set_model(player, "ponybase.b3d")
end)
