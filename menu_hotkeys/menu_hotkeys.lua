-- menu_hotkeys.lua
local mod = get_mod("menu_hotkeys")

local Views = require("scripts/ui/views/views")

-- ################## Variables #############################
local valid_lvls = {
	shooting_range = true,
	hub = true,
}

-- Check if SoloPlay is active and the player is in a solo mission
local function is_soloplay_active()
	local soloplay_mod = get_mod("SoloPlay")
	if soloplay_mod and soloplay_mod.is_soloplay then
		return soloplay_mod:is_soloplay()
	end
	return false
end

-- Mapping view name to function name
local view_function_map = {
	barber_vendor_background_view		= "activate_barber_vendor_background_view",
	contracts_background_view			= "activate_contracts_background_view",
	crafting_view						= "activate_crafting_view",
	credits_vendor_background_view		= "activate_credits_vendor_background_view",
	mission_board_view					= "activate_mission_board_view",
	store_view							= "activate_store_view",
	training_grounds_view				= "activate_training_grounds_view",
	social_menu_view					= "activate_social_view",
	cosmetics_vendor_background_view	= "activate_commissary_view",
	penance_overview_view				= "activate_penance_overview_view",
	havoc_background_view				= "activate_havoc_background_view",
	expedition_view						= "activate_expedition_view",
}

-- ############## Internal Functions ########################
local is_in_valid_lvl = function()
	if Managers and Managers.state and Managers.state.game_mode then
		local game_mode = Managers.state.game_mode:game_mode_name()
		valid_lvls["shooting_range"] = mod:get("enable_in_psykhanium")
		if valid_lvls[game_mode] then
			return true
		end
		-- Allow in Solo mode if option is enabled
		if mod:get("enable_in_soloplay") and is_soloplay_active() then
			return true
		end
		return false
	end
end

local can_activate_view = function(ui_manager, view)
	if not is_in_valid_lvl() then return false end
	if ui_manager:chat_using_input() then return false end
	if ui_manager:has_active_view(view) then return false end

	-- Check validation if it is defined for this view
	if Views and Views[view] and Views[view].validation_function then
		local ok, result = pcall(Views[view].validation_function)
		if not ok or not result then
			return false
		end
	end
	return true
end

local close_views = function(view, ui_manager)
	if mod:get("close_menu_with_hotkey") then
		if ui_manager:view_active(view) then
			ui_manager:close_view(view) -- close only this window
			return false
		end
	end
	return true
end

local activate_hub_view = function(view)
	local ui_manager = Managers.ui
	if ui_manager and close_views(view, ui_manager) and can_activate_view(ui_manager, view) then
		local context = { hub_interaction = true }
		ui_manager:open_view(view, nil, nil, nil, nil, context)
	end
end

-- ################## Functions #############################
-- Automatic generation of all functions based on the map
for view_name, func_name in pairs(view_function_map) do
	mod[func_name] = function(self)
		activate_hub_view(view_name)
	end
end
