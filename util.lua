function has_3darmor()
    if minetest.get_modpath("3d_armor") ~= nil then
       return true
    else
        return false
    end
end    