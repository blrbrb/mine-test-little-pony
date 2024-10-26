


local pony_def = setmetatable({}, {
	__index = function()
		return setmetatable({
			groups = setmetatable({}, {
				__index = function()
					return 0
				end})
			}, {
			__index = function()
				return 0
			end
		})
	end,
})
minelp = {
    default_model = {
    animation_speed = 30,
visual_size = { x = 6, y = 6 },
textures = { "minelp_skin_base_1.png" },
animations = {
    -- Standard animations.
    stand     = { x = 1, y = 2 },
    lay       = {
        x = 45,
        y = 45,
        eye_height = 0.3,
        override_local = true,
        collisionbox = { -0.6, 0.0, -0.6, 0.6, 0.3, 0.6 },
    },
    walk      = { x = 2, y = 26 },
    run = {x=26, y=39},
    mine      = { x = 0, y = 0 },
    walk_mine = { x = 0, y = 0},
    sit       = {
        x = 43,
        y = 43,
        eye_height = 0.8,
        override_local = true,
        collisionbox = { -0.3, 0.0, -0.3, 0.3, 1.0, 1.3 }
    },
    jump = {x=40, y=41}, 
    sneak = {x=42, y=42}, 
    fly = {x=47, y=47}, 
    fly_right = {x=48, y=48}, 
    fly_left = {x=51,y=51},
    fly_run = {x=53, y=53},
    fly_run_left = {x=55, y=55},
    fly_run_right = {x=57, y=57},
    swim = {x=59, y=77}
},
--almost working for the x axis {0.42, -0.0, -0.5, 0.79, 0.5, 0.1},
-- { x1, y1, z1, x2, y2, z2 }s
--default = {-0.3, 0.0, -0.3, 0.3, 1.7, 0.3}
collisionbox = { -0.3, 0.0, -0.3, 0.3, 1.7, 0.3 },

stepheight = 0.6,
eye_height = 1.12,
is_swimming = false,
unicorn = false,
pegasus = false},

player_states= {},
def = pony_def

}


-- Default player appearance
-- -- animations on model 0-36 idle
-- 37-56 walk 

local toolpath = (minetest.get_modpath(minetest.get_current_modname()) .. "/")

dofile(toolpath .. "util.lua")

-- check and determine wether or not the 3D armor mod is installed
-- manually replace the 3d_armor player mesh with the default pony model 
-- which already has it's own vertex groups for equipped armor 
local amrmor = has_3darmor()

-- pony customization script 
dofile(toolpath .. "ponyeditor.lua")

local function showMeshInfo(player)
    local mesh = player:get_properties().mesh or ""
    minetest.chat_send_player("singleplayer", mesh) 
    end

minetest.register_chatcommand("minelp_mesh_dbg", {
    description = "Print information about the current pony model mesh into the chat .",
    privs = {},
    func = function(name, param) showMeshInfo(minetest.get_player_by_name(name)) end 
})


-- print mesh information for debuggery 

minetest.debug("3d_armor mod? " .. tostring(amrmor))

player_api.register_model("ponybase_java.b3d", minelp.default_model)


dofile(minetest.get_modpath(minetest.get_current_modname()) .. "/animation_step.lua")
-- Update appearance when the player joins
minetest.register_on_joinplayer(function(player)
    player_api.set_model(player, "ponybase_java.b3d")
    player_api.player_attached[player:get_player_name()] = false
    player:set_local_animation({},{},{},{},30)
end)

