-- Import required Minetest and player_api functions
-- animations on model 0-36 idle
-- 37-56 walk
--
local default_skin = "minelp_skin_base_1.png"
local tail_mesh = "minelp_skin_tail.obj"
local ears_mesh = "minelp_skin_ears.obj"

-- Function to get player customization settings (such as body part choices)
-- Function to get player customization settings (such as body part choices)
local function get_player_customization(player)
    local meta = player:get_meta()
    local customization = minetest.deserialize(meta:get_string("customization")) or {}
    return customization
end

-- Function to save player customization settings
local function set_player_customization(player, customization)
    local meta = player:get_meta()
    meta:set_string("customization", minetest.serialize(customization))
end

-- Function to update player model based on customization
local function update_player_model(player)
    local name = player:get_player_name()
    local customization = get_player_customization(player)

    -- Set default player model and mesh
    local body_mesh = "ponybase.obj"
    local textures = { "character.png" }

    -- Append meshes based on customization
    if customization.tail then
        body_mesh = "minelp_skin_tail.obj"
        table.insert(textures, "tail_texture.png")
    end
    if customization.ears then
        body_mesh = "minelp_skin_ears.obj"
        table.insert(textures, "ears_texture.png")
    end

    -- Set player properties
    player:set_properties({
        mesh = body_mesh,
        textures = textures,
    })
end

-- Function to handle formspec submissions
minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "minelp:customization" then return end

    local customization = get_player_customization(player)

    -- Toggle tail option
    if fields.toggle_tail then
        customization.tail = not customization.tail
    end
    -- Toggle ears option
    if fields.toggle_ears then
        customization.ears = not customization.ears
    end

    -- Save customization and update model
    set_player_customization(player, customization)
    update_player_model(player)
end)

-- Function to show the customization formspec
local function show_customization_formspec(player)
    local customization = get_player_customization(player)

    -- Generate formspec for customization options
    local formspec = "formspec_version[4]size[8,9]" ..
        "tabheader[0,0;tabs;Appearance,Body Parts;2]" ..
        "checkbox[0.5,1;toggle_tail;Add Tail;" .. tostring(customization.tail or false) .. "]" ..
        "checkbox[0.5,2;toggle_ears;Add Ears;" .. tostring(customization.ears or false) .. "]" ..
        "button_exit[2,8;4,1;exit;Done]"

    minetest.show_formspec(player:get_player_name(), "minelp:customization", formspec)
end

-- Command to open the customization interface
minetest.register_chatcommand("customize", {
    description = "Customize your player model",
    func = function(name)
        local player = minetest.get_player_by_name(name)
        if player then
            show_customization_formspec(player)
        end
    end,
})

-- When a player joins, apply their saved model
minetest.register_on_joinplayer(function(player)
    update_player_model(player)
end)
