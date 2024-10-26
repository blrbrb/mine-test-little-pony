-- Edit Skin Mod


local S = minetest.get_translator("minelp_skin")
local color_to_string = minetest.colorspec_to_colorstring

minelp.skin = {
    item_names = { "base", "eye", "bottom", "top", "mane", "ear","tail" },
    tab_names = { "template", "base", "mane", "eye", "ear", "tail" },
    tab_descriptions = {
        template = S("Templates"),
        base = S("Character Bases"),
        eye = S("Eyes"),
        ear = S("Ears"),
        mane = S("Manes"),
        tail = S("Tails")
    },
    pony_earth = {}, -- Stores def skin values for earth pony race
    pony_unicorn = {},  -- Stores def skin values for unicorn race 
    pony_pegasus = {}, -- Stores def skin values for pegasus race
    twi = {}, -- Default character 1 
    rd = {}, -- Default character 2 
    fs = {}, -- Default character 3 
    base = {},  -- List of base textures

    -- Base color is separate to keep the number of junk nodes registered in check
    base_color = { 0xffeeb592, 0xffb47a57, 0xff8d471d,0xffc21c1c,0xffd0672a,0xffc21c1c,0xffae2ad3,0xffebe8e4,0xff449acc,0xff124d87,0xffc0eb3,0xffe3dd26 },
    color = {
        0xff613915, -- 1 Dark brown 
        0xff97491b, -- 2 Medium brown
        0xffb17050, -- 3 Light brown
        0xffe2bc7b, -- 4 Beige
        0xff706662, -- 5 Gray
        0xff151515, -- 6 Black
        0xffc21c1c, -- 7 Red
        0xff178c32, -- 8 Green 
        0xffae2ad3, -- 9 Plum
        0xffebe8e4, -- 10 White
        0xffe3dd26, -- 11 Yellow
        0xff449acc, -- 12 Light blue Steve top
        0xff124d87, -- 13 Dark blue Steve bottom
        0xfffc0eb3, -- 14 Pink
        0xffd0672a, -- 15 Orange 
    },
    eye = {},
    mane = {},
    ears = {},
    headwear = {},
    masks = {},
    tail = {},
    wing = {},
    horn ={},
    preview_rotations = {},
    ranks = {},
    player_skins = {},
    player_formspecs = {},
    restricted_to_player = {},
    restricted_to_admin = {},
}

minetest.register_privilege("minelp_skin_admin", {
    description = S("Allows access to restricted skin items."),
    give_to_singleplayer = true,
    give_to_admin = true,
})

function minelp.skin.register_item(item)
    assert(minelp.skin[item.type], "Skin item type " .. item.type .. " does not exist.")
    local texture = item.texture or "blank.png"
    if item.pony_earth then
        minelp.skin.pony_earth[item.type] = texture
    end

    if item.pony_unicorn then
        minelp.skin.pony_unicorn[item.type] = texture
    end 

    if item.pony_pegasus then 
        minelp.skin.pony_pegasus[item.type] = texture 
    end 

    if item.restricted_to_admin then
        minelp.skin.restricted_to_admin[texture] = true
    end

    if item.for_player then
        minelp.skin.restricted_to_player[texture] = {}
        if type(item.for_player) == "string" then
            minelp.skin.restricted_to_player[texture][item.for_player] = true
        else
            for i, name in pairs(item.for_player) do
                minelp.skin.restricted_to_player[texture][name] = true
            end
        end
    end

    table.insert(minelp.skin[item.type], texture)
    minelp.skin.masks[texture] = item.mask
    minelp.skin.preview_rotations[texture] = item.preview_rotation
    minelp.skin.ranks[texture] = item.rank
end

function minelp.skin.save(player)
    if not player:is_player() then return end
    local skin = minelp.skin.player_skins[player]
    if not skin then return end
    player:get_meta():set_string("minelp:skin", minetest.serialize(skin))
end

minetest.register_chatcommand("skin", {
    description = S("Open skin configuration screen."),
    privs = {},
    func = function(name, param) minelp.skin.show_formspec(minetest.get_player_by_name(name)) end
})

function minelp.skin.compile_skin(skin)
    if not skin then return "blank.png" end

    local ranks = {}
    local layers = {}
    for i, item in ipairs(minelp.skin.item_names) do
        local texture = skin[item]
        local layer = ""
        local rank = minelp.skin.ranks[texture] or i * 10
        if texture and texture ~= "blank.png" then
            if skin[item .. "_color"] and minelp.skin.masks[texture] then
                local color = color_to_string(skin[item .. "_color"])
                layer = "(" .. minelp.skin.masks[texture] .. "^[colorize:" .. color .. ":alpha)"
            end
            if #layer > 0 then layer = layer .. "^" end
            layer = layer .. texture
            layers[rank] = layer
            table.insert(ranks, rank)
        end
    end
    table.sort(ranks)
    local output = ""
    for i, rank in ipairs(ranks) do
        if #output > 0 then output = output .. "^" end
        output = output .. layers[rank]
    end
    return output
end

function minelp.skin.update_player_skin(player)
    local output = minelp.skin.compile_skin(minelp.skin.player_skins[player])
    minetest.debug(player)
  
     player_api.set_texture(player, 1, output)
  

    -- Set player first person hand node
    local base = minelp.skin.player_skins[player].base
    local base_color = minelp.skin.player_skins[player].base_color
    local node_id = base:gsub(".png$", "") .. color_to_string(base_color):gsub("#", "")
    player:get_inventory():set_stack("hand", 1, "minelp:" .. node_id)

    for i = 1, #minelp.skin.registered_on_set_skins do
        minelp.skin.registered_on_set_skins[i](player)
    end

    local name = player:get_player_name()
    if
        minetest.global_exists("armor") and
        armor.textures and armor.textures[name]
    then
        armor.textures[name].skin = output
        armor.update_player_visuals(armor, player)
    end

    if minetest.global_exists("i3") then i3.set_fs(player) end
end

minetest.register_on_joinplayer(function(player)
    local function table_get_random(t)
        return t[math.random(#t)]
    end
    local skin = player:get_meta():get_string("minelp:skin")
    if skin then
        skin = minetest.deserialize(skin)
    end
    if skin then
        minelp.skin.player_skins[player] = skin
    else
        if math.random() > 0.5 then
            skin = table.copy(minelp.skin.pony_earth)
        else
            skin = table.copy(minelp.skin.pony_unicorn)
        end
        minelp.skin.player_skins[player] = skin
        minelp.skin.save(player)
    end

    minelp.skin.player_formspecs[player] = {
        active_tab = "template",
        page_num = 1,
        has_admin_priv = minetest.check_player_privs(player, "minelp_skin_admin"),
    }

    player:get_inventory():set_size("hand", 1)

    minelp.skin.update_player_skin(player)

    if minetest.global_exists("inventory_plus") and inventory_plus.register_button then
        inventory_plus.register_button(player, "minelp_skin", S("Edit Skin"))
    end

    -- Needed for 3D Armor + sfinv
    if minetest.global_exists("armor") then
        minetest.after(0.01, function()
            if player:is_player() then
                minelp.skin.update_player_skin(player)
            end
        end)
    end
end)

minetest.register_on_leaveplayer(function(player)
    player:get_inventory():set_size("hand", 0)
    minelp.skin.player_skins[player] = nil
    minelp.skin.player_formspecs[player] = nil
end)

minetest.register_on_shutdown(function()
    for _, player in pairs(minetest.get_connected_players()) do
        player:get_inventory():set_size("hand", 0)
    end
end)

minelp.skin.registered_on_set_skins = {}

function minelp.skin.register_on_set_skin(func)
    table.insert(minelp.skin.registered_on_set_skins, func)
end

function minelp.skin.show_formspec(player)
    local formspec_data = minelp.skin.player_formspecs[player]
    local has_admin_priv = minetest.check_player_privs(player, "minelp_skin_admin")
    if has_admin_priv ~= formspec_data.has_admin_priv then
        formspec_data.has_admin_priv = has_admin_priv
        for i, name in pairs(minelp.skin.item_names) do
            formspec_data[name] = nil
        end
    end
    local active_tab = formspec_data.active_tab
    local page_num = formspec_data.page_num
    local skin = minelp.skin.player_skins[player]
    local formspec = "formspec_version[3]size[14.2,11]"
    
    for i, tab in pairs(minelp.skin.tab_names) do
        if tab == active_tab then
            formspec = formspec ..
                "style[" .. tab .. ";bgcolor=green]"
        end

        local y = 0.3 + (i - 1) * 0.8
        formspec = formspec ..
            "style[" .. tab .. ";content_offset=16,0]" ..
            "button[0.3," .. y .. ";4,0.8;" .. tab .. ";" .. minelp.skin.tab_descriptions[tab] .. "]" ..
            "image[0.4," .. y + 0.1 .. ";0.6,0.6;minelp_skin_icons.png^[verticalframe:9:" .. i - 1 .. "]"
    end

    local mesh = player:get_properties().mesh or ""
    local textures = player_api.get_textures(player)
    textures[2] = "blank.png" -- Clear out the armor

    formspec = formspec ..
        "model[11,0.3;3,7;player_mesh;" .. mesh .. ";" ..
        table.concat(textures, ",") ..
        ";0,180;false;true;0,0]"

    if active_tab == "template" then
        formspec = formspec ..
            "model[5,2;2,3;player_mesh;" .. mesh .. ";" ..
            minelp.skin.compile_skin(minelp.skin.pony_earth) ..
            ",blank.png,blank.png;0,180;false;true;0,0]" ..

            "button[5,5.2;2,0.8;pony_earth;" .. S("Earth Pony") .. "]" ..

            "model[7.5,2;2,3;player_mesh;" .. mesh .. ";" ..
            minelp.skin.compile_skin(minelp.skin.pony_unicorn) ..
            ",blank.png,blank.png;0,180;false;true;0,0]" ..

            "button[7.5,5.2;2,0.8;pony_unicorn;" .. S("Unicorn") .. "]"
        
    else
        formspec = formspec ..
            "style_type[button,image_button;border=false;bgcolor=#00000000]"

        if not formspec_data[active_tab] then minelp.skin.filter_active_tab(player) end
        local textures = formspec_data[active_tab]
        local page_start = (page_num - 1) * 16 + 1
        local page_end = math.min(page_start + 16 - 1, #textures)

        for j = page_start, page_end do
            local i = j - page_start + 1
            local texture = textures[j]
            local preview = minelp.skin.masks[skin.base] .. "^[colorize:gray^" .. skin.base
            local color = color_to_string(skin[active_tab .. "_color"])
            local mask = minelp.skin.masks[texture]
            if color and mask then
                preview = preview .. "^(" .. mask .. "^[colorize:" .. color .. ":alpha)"
            end
            preview = preview .. "^" .. texture

            local mesh = "ponybase.b3d"
            if active_tab == "footwear" then
                mesh = "ponybase.b3d" -- TD export object meshes for individual preview_rotations 
              elseif active_tab == "mane" then 
                mesh = "ponybase_hat.obj" -- hair preview_rotations 
            elseif active_tab == "eye" then 
                mesh = "ponybase_head.obj" -- face preview_rotations 
            elseif active_tab == "tails" then 
                
            end

            local rot_x = -180
            local rot_y = 20 
            if minelp.skin.preview_rotations[texture] then
                rot_x = minelp.skin.preview_rotations[texture].x
                rot_y = minelp.skin.preview_rotations[texture].y
            end

            i = i - 1
            local x = 4.5 + i % 4 * 1.6
            local y = 0.3 + math.floor(i / 4) * 1.6
            formspec = formspec ..
                "model[" .. x .. "," .. y ..
                ";1.5,1.5;" .. mesh .. ";" .. mesh .. ";" ..
                preview ..
                ";" .. rot_x .. "," .. rot_y .. ";false;false;0,0]"

            if skin[active_tab] == texture then
                formspec = formspec ..
                    "style[" .. texture ..
                    ";bgcolor=;bgimg=minelp_skin_select_overlay.png;" ..
                    "bgimg_pressed=minelp_skin_select_overlay.png;bgimg_middle=14,14]"
            end

            formspec = formspec .. "button[" .. x .. "," .. y .. ";1.5,1.5;" .. texture .. ";]"
        end
    end

    if skin[active_tab .. "_color"] then
        local colors = minelp.skin.color
        if active_tab == "base" then colors = minelp.skin.base_color end

        local tab_color = active_tab .. "_color"
        local selected_color = skin[tab_color]
        for i, colorspec in pairs(colors) do
            local color = color_to_string(colorspec)
            i = i - 1
            local x = 4.6 + i % 6 * 0.9
            local y = 8 + math.floor(i / 6) * 0.9
            formspec = formspec ..
                "image_button[" .. x .. "," .. y ..
                ";0.8,0.8;blank.png^[noalpha^[colorize:" ..
                color .. ":alpha;" .. colorspec .. ";]"

            if selected_color == colorspec then
                formspec = formspec ..
                    "style[" .. color ..
                    ";bgcolor=;bgimg=minelp_skin_select_overlay.png;bgimg_middle=14,14]" ..
                    "button[" .. x .. "," .. y .. ";0.8,0.8;" .. color .. ";]"
            end
        end

        if not (active_tab == "base") then
            -- Bitwise Operations !?!?!
            local red = math.floor(selected_color / 0x10000) - 0xff00
            local green = math.floor(selected_color / 0x100) - 0xff0000 - red * 0x100
            local blue = selected_color - 0xff000000 - red * 0x10000 - green * 0x100
            formspec = formspec ..
                "container[10.2,8]" ..
                "scrollbaroptions[min=0;max=255;smallstep=20]" ..

                "box[0.4,0;2.49,0.38;red]" ..
                "label[0.2,0.2;-]" ..
                "scrollbar[0.4,0;2.5,0.4;horizontal;red;" .. red .. "]" ..
                "label[2.9,0.2;+]" ..

                "box[0.4,0.6;2.49,0.38;green]" ..
                "label[0.2,0.8;-]" ..
                "scrollbar[0.4,0.6;2.5,0.4;horizontal;green;" .. green .. "]" ..
                "label[2.9,0.8;+]" ..

                "box[0.4,1.2;2.49,0.38;blue]" ..
                "label[0.2,1.4;-]" ..
                "scrollbar[0.4,1.2;2.5,0.4;horizontal;blue;" .. blue .. "]" ..
                "label[2.9,1.4;+]" ..

                "container_end[]"
        end
    end

    local page_count = 1
    if minelp.skin[active_tab] then
        page_count = math.ceil(#formspec_data[active_tab] / 16)
    end

    if page_num > 1 then
        formspec = formspec ..
            "image_button[4.5,6.7;1,1;minelp_skin_arrow.png^[transformFX;previous_page;]"
    end

    if page_num < page_count then
        formspec = formspec ..
            "image_button[9.8,6.7;1,1;minelp_skin_arrow.png;next_page;]"
    end

    if page_count > 1 then
        formspec = formspec ..
            "label[7.3,7.2;" .. page_num .. " / " .. page_count .. "]"
    end

    minetest.show_formspec(player:get_player_name(), "minelp:minelp_skin", formspec)
end

function minelp.skin.filter_active_tab(player)
    local formspec_data = minelp.skin.player_formspecs[player]
    local active_tab = formspec_data.active_tab
    local admin_priv = formspec_data.has_admin_priv
    local name = player:get_player_name()
    formspec_data[active_tab] = {}
    local textures = formspec_data[active_tab]
    for i, texture in pairs(minelp.skin[active_tab]) do
        if admin_priv or not minelp.skin.restricted_to_admin[texture] then
            local restriction = minelp.skin.restricted_to_player[texture]
            if restriction then
                if restriction[name] then
                    table.insert(textures, texture)
                end
            else
                table.insert(textures, texture)
            end
        end
    end
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "minelp:minelp_skin" then return false end

    local formspec_data = minelp.skin.player_formspecs[player]
    local active_tab = formspec_data.active_tab

    -- Cancel formspec resend after scrollbar move
    if formspec_data.form_send_job then
        formspec_data.form_send_job:cancel()
    end

    if fields.quit then
        minelp.skin.save(player)
        return true
    end

    if fields.pony_unicorn then
        minelp.skin.player_skins[player] = table.copy(minelp.skin.pony_unicorn)
        minelp.skin.update_player_skin(player)
        minelp.skin.show_formspec(player)
        return true
    elseif fields.pony_earth then
        minelp.skin.player_skins[player] = table.copy(minelp.skin.pony_earth)
        minelp.skin.update_player_skin(player)
        minelp.skin.show_formspec(player)
        return true
    elseif fields.twi then
        minelp.skin.player_skins[player] = table.copy(minelp.skin.twi)
        minelp.skin.update_player_skin(player)
        minelp.skin.show_formspec(player)
        return true
    elseif fields.rd then
        minelp.skin.player_skins[player] = table.copy(minelp.skin.rd)
        minelp.skin.update_player_skin(player)
        minelp.skin.show_formspec(player)
        return true
    end

    for i, tab in pairs(minelp.skin.tab_names) do
        if fields[tab] then
            formspec_data.active_tab = tab
            formspec_data.page_num = 1
            minelp.skin.show_formspec(player)
            return true
        end
    end

    local skin = minelp.skin.player_skins[player]
    if not skin then return true end

    if fields.next_page then
        local page_num = formspec_data.page_num
        page_num = page_num + 1
        local page_count = math.ceil(#formspec_data[active_tab] / 16)
        if page_num > page_count then
            page_num = page_count
        end
        formspec_data.page_num = page_num
        minelp.skin.show_formspec(player)
        return true
    elseif fields.previous_page then
        local page_num = formspec_data.page_num
        page_num = page_num - 1
        if page_num < 1 then page_num = 1 end
        formspec_data.page_num = page_num
        minelp.skin.show_formspec(player)
        return true
    end

    if
        skin[active_tab .. "_color"] and (
            fields.red and fields.red:find("^CHG") or
            fields.green and fields.green:find("^CHG") or
            fields.blue and fields.blue:find("^CHG")
        )
    then
        local red = fields.red:gsub("%a%a%a:", "")
        local green = fields.green:gsub("%a%a%a:", "")
        local blue = fields.blue:gsub("%a%a%a:", "")
        red = tonumber(red) or 0
        green = tonumber(green) or 0
        blue = tonumber(blue) or 0

        local color = 0xff000000 + red * 0x10000 + green * 0x100 + blue
        if color >= 0 and color <= 0xffffffff then
            -- We delay resedning the form because otherwise it will break dragging scrollbars
            formspec_data.form_send_job = minetest.after(0.2, function()
                if player and player:is_player() then
                    skin[active_tab .. "_color"] = color
                    minelp.skin.update_player_skin(player)
                    minelp.skin.show_formspec(player)
                    formspec_data.form_send_job = nil
                end
            end)
            return true
        end
    end

    local field
    for f, value in pairs(fields) do
        if value == "" then
            field = f
            break
        end
    end

    -- See if field is a texture
    if field and minelp.skin[active_tab] then
        for i, texture in pairs(formspec_data[active_tab]) do
            if texture == field then
                skin[active_tab] = texture
                minelp.skin.update_player_skin(player)
                minelp.skin.show_formspec(player)
                return true
            end
        end
    end

    -- See if field is a color
    local number = tonumber(field)
    if number and skin[active_tab .. "_color"] then
        local color = math.floor(number)
        if color and color >= 0 and color <= 0xffffffff then
            skin[active_tab .. "_color"] = color
            minelp.skin.update_player_skin(player)
            minelp.skin.show_formspec(player)
            return true
        end
    end

    return true
end)

local function init()
    local f = io.open(minetest.get_modpath("minelp") .. "/list.json")
    assert(f, "Can't open the file list.json")
    local data = f:read("*all")
    assert(data, "Can't read data from list.json")
    local json, error = minetest.parse_json(data)
    assert(json, error)
    f:close()

    for _, item in pairs(json) do
        minelp.skin.register_item(item)
    end
    --minelp_skin.pony_earth.base_color = minelp_skin.base_color[1]
    minelp.skin.pony_earth.mane_color = minelp.skin.color[1] 
    minelp.skin.pony_earth.mane_color2 = minelp.skin.color[2]
    minelp.skin.pony_earth.tail_color = minelp.skin.color[1] 
    minelp.skin.pony_earth.base_color = minelp.skin.color[12]
    minelp.skin.pony_earth.bottom_color = minelp.skin.color[13] 
    

    -- formspec uses regular expression logic that checks for the presence of "_color" when deciding wether or not show a color seletion 
    -- colorspec on the tab. These must be named properly 
    minelp.skin.pony_unicorn.base_color = minelp.skin.base_color[1]
    minelp.skin.pony_unicorn.mane_color = minelp.skin.color[15]
    minelp.skin.pony_unicorn.top_color = minelp.skin.color[8]
    minelp.skin.pony_unicorn.bottom_color = minelp.skin.color[1]

    -- Register junk first person hand nodes
    local function make_texture(base, colorspec)
        local output = ""
        if minelp.skin.masks[base] then
            output = minelp.skin.masks[base] ..
                "^[colorize:" .. color_to_string(colorspec) .. ":alpha"
        end
        if #output > 0 then output = output .. "^" end
        output = output .. base
        return output
    end
    local hand_def = minetest.registered_items[""]
    local range = hand_def and hand_def.range
    for _, base in pairs(minelp.skin.base) do
        for _, base_color in pairs(minelp.skin.base_color) do
            local id = base:gsub(".png$", "") .. color_to_string(base_color):gsub("#", "")
            minetest.register_node("minelp:" .. id, {
                drawtype = "mesh",
                groups = { not_in_creative_inventory = 1 },
                tiles = { make_texture(base, base_color) },
                use_texture_alpha = "clip",
                range = range,
            })
        end
    end

    if minetest.global_exists("i3") then
        i3.new_tab("minelp_skin", {
            description = S("Edit Skin"),
            --image = "minelp_skin_button.png", -- Icon covers label
            access = function(player, data) return true end,

            formspec = function(player, data, fs) end,

            fields = function(player, data, fields)
                i3.set_tab(player, "inventory")
                minelp.skin.show_formspec(player)
            end,
        })
    end
    if minetest.global_exists("sfinv_buttons") then
        sfinv_buttons.register_button("minelp_skin", {
            title = S("Edit Skin"),
            action = function(player) minelp.skin.show_formspec(player) end,
            tooltip = S("Open skin configuration screen."),
            image = "minelp_skin_button.png",
        })
    elseif minetest.global_exists("sfinv") then
        sfinv.register_page("minelp_skin", {
            title = S("Edit Skin"),
            get = function(self, player, context) return "" end,
            on_enter = function(self, player, context)
                sfinv.contexts[player:get_player_name()].page = sfinv.get_homepage_name(player)
                minelp.skin.show_formspec(player)
            end
        })
    end
    if minetest.global_exists("unified_inventory") then
        unified_inventory.register_button("minelp_skin", {
            type = "image",
            image = "minelp_skin_button.png",
            tooltip = S("Edit Skin"),
            action = function(player)
                minelp.skin.show_formspec(player)
            end,
        })
    end
    if minetest.global_exists("armor") and armor.get_player_skin then
        armor.get_player_skin = function(armor, name)
            return minelp.skin.compile_skin(minelp.skin.player_skins[minetest.get_player_by_name(name)])
        end
    end
    if minetest.global_exists("inventory_plus") then
        minetest.register_on_player_receive_fields(function(player, formname, fields)
            if formname == "" and fields.minelp.skin then
                minelp.skin.show_formspec(player)
                return true
            end
            return false
        end)
    end
    if minetest.global_exists("smart_inventory") then
        smart_inventory.register_page({
            name             = "skin_edit",
            icon             = "minelp_skin_button.png",
            tooltip          = S("Edit Skin"),
            smartfs_callback = function(state) return end,
            sequence         = 100,
            on_button_click  = function(state)
                local player = minetest.get_player_by_name(state.location.rootState.location.player)
                minelp.skin.show_formspec(player)
            end,
            is_visible_func  = function(state) return true end,
        })
    end
end

init()
