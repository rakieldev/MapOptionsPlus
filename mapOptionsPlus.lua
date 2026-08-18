-- MapOptionsPlus: New powerful parameters for Options menu items.
-- Version: 1.1
-- Date: 17/08/2026
-- Author: Rakíel
-- Compatible with: Ikemen GO 1.0
-- Description: This module lets you create Options menu items that set map values for all players when starting a new match.
-- These map values use the item names as their names and can be used to modify in-game behavior (via CNS/ZSS).

-------------------------------------------------------------
-- MapOptionsPlus
-------------------------------------------------------------
local mapOptions = {}
local configPath = 'external/mods/mapOptionsPlus/config.ini'
local config = loadIni(configPath, false)

-- Stores the current value of each MapOption.
local values = {}

-- Stores the parsed definition of each MapOption.
local definitions = {}

-------------------------------------------------------------
-- Helpers
-------------------------------------------------------------
local function trim(value)
	return value:match('^%s*(.-)%s*$')
end

local function parseDefinition(name, params)
	local itemName = name:lower()
	local optionType = params[1]
	local mapName = name
	local offset = 0
	local labels = nil

	-- Optional map name.
	if tonumber(params[2]) == nil then
		mapName = params[2]
		offset = 1
	end

	if optionType == 'int' and type(params[4 + offset]) == 'string' then
		local firstValue, firstLabel = params[4 + offset]:match('^(.-)%s*|%s*(.*)$')

		if firstValue ~= nil then
			params[4 + offset] = tonumber(firstValue)
			labels = {trim(firstLabel)}

			for i = 5 + offset, #params do
				labels[#labels + 1] = trim(params[i])
			end
		end
	end

	if optionType == 'bool' then
		local default = tonumber(params[2 + offset])

		if default == nil then
			default = 0
		end

		default = default ~= 0 and 1 or 0

		definitions[itemName] = {
			name = name,
			mapName = mapName,
			type = 'bool',
			default = default,
		}

		values[itemName] = default

	elseif optionType == 'int' or optionType == 'float' then
		local rangeStart = tonumber(params[2 + offset])
		local rangeEnd = tonumber(params[3 + offset])
		local default = tonumber(params[4 + offset])

		if rangeStart == nil then
			rangeStart = 0
		end

		if rangeEnd == nil then
			rangeEnd = 100
		end

		if default == nil then
			default = rangeStart
		end

		if rangeStart > rangeEnd then
			rangeStart, rangeEnd = rangeEnd, rangeStart
		end

		default = math.max(rangeStart, math.min(rangeEnd, default))

		definitions[itemName] = {
			name = name,
			mapName = mapName,
			type = optionType,
			rangeStart = rangeStart,
			rangeEnd = rangeEnd,
			default = default,
			labels = labels,
		}

		values[itemName] = default
	end
end

-------------------------------------------------------------
-- Option creation
-------------------------------------------------------------
local function createBoolOption(name)
	local itemName = name:lower()

	local function toggle()
		values[itemName] = values[itemName] == 0 and 1 or 0
	end
	options.t_itemname[itemName] = function(t, item, cursorPosY, moveTxt)
		if getInput(-1, motif.option_info.menu.add.key, motif.option_info.menu.subtract.key, motif.option_info.menu.done.key) then
			sndPlay(motif.Snd, motif.option_info.cursor.move.snd[1], motif.option_info.cursor.move.snd[2])
			toggle()
			t.items[item].vardisplay = options.t_vardisplay[itemName]()
			options.modified = true
		end
		return true
	end
	menu.t_itemname[itemName] = function(t, item, cursorPosY, moveTxt, sec)
		if getInput(-1, sec.menu.add.key, sec.menu.subtract.key) then
			sndPlay(motif.Snd, sec.cursor.move.snd[1], sec.cursor.move.snd[2])
			toggle()
			t.items[item].vardisplay = menu.f_vardisplay(itemName)
		end
		return true
	end

	options.t_vardisplay[itemName] = function()
		return options.f_boolDisplay(values[itemName] ~= 0)
	end
end

local function roundFloat(value)
	return math.floor(value * 10 + 0.5) / 10
end

local function createNumberOption(name, definition)
	local itemName = name:lower()
	local step = definition.type == 'float' and 0.1 or 1

	local function changeValue(direction)
		local value = values[itemName] + step * direction

		if value >= definition.rangeStart and value <= definition.rangeEnd then
			values[itemName] = value

			if definition.type == 'float' then
				values[itemName] = roundFloat(values[itemName])
			end

			return true
		end

		return false
	end

	options.t_itemname[itemName] = function(t, item, cursorPosY, moveTxt)
		if getInput(-1, motif.option_info.menu.add.key) then
			if changeValue(1) then
				sndPlay(motif.Snd, motif.option_info.cursor.move.snd[1], motif.option_info.cursor.move.snd[2])
				t.items[item].vardisplay = options.t_vardisplay[itemName]()
				options.modified = true
			end
		elseif getInput(-1, motif.option_info.menu.subtract.key) then
			if changeValue(-1) then
				sndPlay(motif.Snd, motif.option_info.cursor.move.snd[1], motif.option_info.cursor.move.snd[2])
				t.items[item].vardisplay = options.t_vardisplay[itemName]()
				options.modified = true
			end
		end

		return true
	end

	menu.t_itemname[itemName] = function(t, item, cursorPosY, moveTxt, sec)
		if getInput(-1, sec.menu.add.key) then
			if changeValue(1) then
				sndPlay(motif.Snd, sec.cursor.move.snd[1], sec.cursor.move.snd[2])
				t.items[item].vardisplay = menu.f_vardisplay(itemName)
			end
		elseif getInput(-1, sec.menu.subtract.key) then
			if changeValue(-1) then
				sndPlay(motif.Snd, sec.cursor.move.snd[1], sec.cursor.move.snd[2])
				t.items[item].vardisplay = menu.f_vardisplay(itemName)
			end
		end

		return true
	end

	options.t_vardisplay[itemName] = function()
		if definition.type == 'int' and definition.labels ~= nil then
			local index = values[itemName] - definition.rangeStart + 1
			return definition.labels[index] or values[itemName]
		end

		return values[itemName]
	end
end

-------------------------------------------------------------
-- Load MapOptions
-------------------------------------------------------------
local function loadMapOptions()
	if config.MapOptions == nil then
		return
	end

	for name, definition in pairs(config.MapOptions) do
		parseDefinition(name, definition)
		local itemName = name:lower()
		local option = definitions[itemName]

		if option.type == 'bool' then
			createBoolOption(name)
		elseif option.type == 'int' or option.type == 'float' then
			createNumberOption(name, option)
		end
	end
end
-------------------------------------------------------------
-- Save Options
-------------------------------------------------------------
local function saveMapOptions()
	local file = io.open(configPath, 'r')
	if file == nil then
		return
	end

	local lines = {}

	for line in file:lines() do
		local name = line:match('^%s*([%w_]+)%s*=')

		if name ~= nil then
			local itemName = name:lower()
			local option = definitions[itemName]

			if option ~= nil then
				local value = tostring(values[itemName])

				-- Separate the comment from the option definition.
				local definition, comment = line:match('^(.-)(%s*;.*)$')
				if definition == nil then
					definition = line
				else
					comment = comment
				end

				-- Replace the current value while preserving optional labels.
				local prefix, labels = definition:match('^(.-)%s+[^|%s]+(%s*|.*)$')
				if prefix ~= nil then
					line = prefix .. ' ' .. value .. labels .. (comment or '')
				else
					local prefix = definition:match('^(.*,%s*)[^,]+%s*$')
					if prefix ~= nil then
						line = prefix .. value .. (comment or '')
					end
				end
			end
		end

		lines[#lines + 1] = line
	end

	file:close()

	file = io.open(configPath, 'w')
	if file == nil then
		return
	end

	file:write(table.concat(lines, '\n'))
	file:close()
end

-- Pause menu only
local function resetMapOptions()
	for itemName, definition in pairs(definitions) do
		values[itemName] = definition.default
	end
end

menu.t_itemname['mapoptionsdefault'] = function(t, item, cursorPosY, moveTxt, sec)
	if getInput(-1, sec.menu.done.key) then
		sndPlay(motif.Snd, sec.cursor.done.snd[1], sec.cursor.done.snd[2])
		resetMapOptions()

		for _, v in ipairs(menu.t_vardisplayPointers) do
			v.vardisplay = menu.f_vardisplay(v.itemname)
		end
	end
	return true
end
-------------------------------------------------------------
-- Apply maps
-------------------------------------------------------------
function mapOptions.apply()
	local maxPlayer = 12
	for p = 1, maxPlayer do
		if player(p) ~= nil then
			for itemName, definition in pairs(definitions) do
				local value = values[itemName]
				if map(definition.mapName, value) ~= value then
					mapSet(definition.mapName, value)
				end
			end
		end
	end
end
-------------------------------------------------------------
-- Initialization
-------------------------------------------------------------
loadMapOptions()
hook.add('loop', 'mapoptions', mapOptions.apply)
hook.add('options.default', 'mapoptions', resetMapOptions)
hook.add('options.save', 'mapoptions', saveMapOptions)