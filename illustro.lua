--[[
Illustro Conky by Amy Nagle

This script is a recreation of the Rainmeter Illustro widget theme

To call this script in Conky, use the following (assuming that you save this script to ~/scripts/illustro.lua):
    lua_load ~/scripts/illustro.lua
    lua_draw_hook_pre conky_main
	update_interval 1
	
IMPORTANT: You must use an update_interval of 1. Individual values
have their own "interval" property you can use to control updates.
    
Changelog:
  v1.0 -- Original release (2015-08-22)
  v1.1 -- Added precision rounding to values (2015-12-29)
  v1.2 -- Added interval to reduce load (2016-01-16)
  v1.3 -- Moved configuration to separate file
  v1.4 -- Support raw commands and cached values
]]


require 'cairo'
require 'math'
require 'string'

local boxes = nil
local value_cache = {}

function rgb_to_r_g_b(colour, alpha)
	return ((colour / 0x10000) % 0x100) / 255., ((colour / 0x100) % 0x100) / 255., (colour % 0x100) / 255., alpha
end

function table_length(T)
	local count = 0
	for _ in pairs(T) do count = count + 1 end
	return count
end

function round(num, idp)
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end

function conky_main()
	

	if conky_window==nil then return end
	local cs = cairo_xlib_surface_create(conky_window.display,
										 conky_window.drawable,
										 conky_window.visual,
										 conky_window.width,
										 conky_window.height)
	local cr=cairo_create(cs)    
	
	local updates=conky_parse('${updates}')
	update_num=tonumber(updates)
	
	local box_offset = 0
	
	-- Check that Conky has been running for at least 5s
	if update_num > 5 then
	
		if boxes == nil then
			local folderOfThisFile = debug.getinfo(conky_main).source:sub(2):gsub('/[^/]+$', '')
			package.path = package.path .. ";" ..folderOfThisFile .. "/?.lua"
			boxes = require('config')
		end
	
		for i in pairs(boxes) do
			local box = boxes[i]
			local box_height = draw_box(cr, box.title, 0, box_offset, box.values)
			box_offset = box_height + box_offset
		end
	end
	
	
end


function draw_box(cr, title, x, y, values)

	local width         = 200
	local height        = 200
	local aspect        = 1.0    --/* aspect ratio */
	local corner_radius = 5   --/* and corner curvature radius */

	local top_height = 28
	
	local radius = corner_radius / aspect
	local degrees = math.pi / 180.0
	
	local box_margin = 5
	local box_padding = 5
	
	width = width - (box_margin * 2)
	height = top_height + (table_length(values) * 20) + box_padding
	
	x = x + box_margin
	y = y + box_margin

	cairo_new_sub_path (cr)
	cairo_arc (cr, x + radius, y + radius, radius, 180 * degrees, 270 * degrees)
	cairo_arc (cr, x + width - radius, y + radius, radius, -90 * degrees, 0 * degrees)
	cairo_rel_line_to (cr, 0, top_height - radius)
	cairo_rel_line_to (cr, 0 - width, 0)
	cairo_close_path (cr)
	
	cairo_set_source_rgba (cr, 0, 0, 0, 175/255)
	cairo_fill (cr)
	cairo_set_source_rgba (cr, 1, 1, 1, 0.5)
	--cairo_set_line_width (cr, 10.0)
	cairo_stroke (cr)
	

	cairo_new_sub_path (cr);
	cairo_line_to (cr, x, y + top_height)
	cairo_rel_line_to (cr, width, 0)
	cairo_arc (cr, x + width - radius, y + height - radius, radius, 0 * degrees, 90 * degrees)
	cairo_arc (cr, x + radius, y + height - radius, radius, 90 * degrees, 180 * degrees)
	cairo_close_path (cr)

	cairo_set_source_rgba (cr, 0, 0, 0, 140/255)
	cairo_fill (cr)
	cairo_set_source_rgba (cr, 1, 1, 1, 0.5)
	--cairo_set_line_width (cr, 10.0)
	cairo_stroke (cr)
	
	cairo_select_font_face (cr, "Trebuchet MS", CAIRO_FONT_SLANT_NORMAL,
                               CAIRO_FONT_WEIGHT_BOLD)
	
	local extents = cairo_text_extents_t:create()

	local title_x, title_y

	local title_text = string.upper(title)
	
	cairo_set_source_rgba (cr, 1, 1, 1, 205/255)
	cairo_set_font_size (cr, 13.0)
	
	cairo_text_extents (cr, title_text, extents)
	title_x = x + (width/2 -(extents.width/2 + extents.x_bearing))
	title_y = y + (top_height/2-(extents.height/2 + extents.y_bearing))
	
	cairo_move_to (cr, title_x, title_y)
	cairo_show_text (cr, title_text)
	
	
	local value_y = y + top_height + box_padding
	local value_x = x + box_padding
	local value_w = width - box_padding * 2
	local value_h = 20
	
	if value_cache[title] == nil then
		value_cache[title] = {}
	end
	
	for i in pairs(values) do
		local value = values[i]
		draw_value(cr, value_x, value_y, value_h, value_w, value, value_cache[title])
		value_y = value_y + value_h
	end
	
	
	
	return height + (box_margin * 2)

end

function os.capture(cmd, raw)
	local f = assert(io.popen(cmd, 'r'))
	local s = assert(f:read('*a'))
	f:close()
	if raw then return s end
	
	s = string.gsub(s, '^%s+', '')
	s = string.gsub(s, '%s+$', '')
	s = string.gsub(s, '[\n\r]+', ' ')
	
	return s
end

function parse_value(value)
	if value.v_type == nil or value.v_type == 'conky' then
		return conky_parse(value.value)
	elseif value.v_type == 'cmd' then
		return os.capture(value.value, true)
	end
end

function draw_value(cr, x, y, height, width, value, cache)

	--local title_x, title_y
	local line_offset = 12
	local title = value.title

	local cached_values = cache[title]
	
	local value_int
	local value_max
	local value_perc = 0
	local value_string
	
	local updates = tonumber(conky_parse("${updates}"))
	local interval = value.interval or 1
	
	--	print(title, updates, updates % interval)
	if (updates % interval) == 0 or cached_values == nil then
	
		value_string = parse_value(value)
		value_int = tonumber(value_string)
		
		if value_int ~= nil then
			value_max = tonumber(conky_parse(value.max))
			value_int = value_int ~= nil and value_int or 0
			value_perc = value_int / value_max
		
			if value.precision ~= nil then
				value_int = round(value_int, value.precision)
			end
			
			if value_perc > 1 then
				value_perc = 1
			end
			
			value_string = tostring(value_int)
		
		end
		
		cache[title] = { string=value_string, int=value_int, max=value_max, perc=value_perc }
	
	else
		value_int = cached_values.int
		value_max = cached_values.max
		value_perc = cached_values.perc
		value_string = cached_values.string
	end
	
	local value_text = value_string .. value.suffix
	
	
	cairo_select_font_face (cr, "Trebuchet MS", CAIRO_FONT_SLANT_NORMAL,
                               CAIRO_FONT_WEIGHT_BOLD)
	cairo_set_font_size (cr, 11.0)
	
	local extents = cairo_text_extents_t:create()
	
	-- Dummy value to make sure text is aligned
	cairo_text_extents (cr, 'W', extents)
	local text_top = y + extents.height
	
	cairo_set_source_rgba (cr, 1, 1, 1, 205/255)
	cairo_move_to (cr, x, text_top)
	cairo_show_text (cr, title)
	
	cairo_text_extents (cr, value_text, extents)
	
	cairo_set_source_rgba (cr, 1, 1, 1, 205/255)
	cairo_move_to (cr, x + width - extents.width, text_top)
	cairo_show_text (cr, value_text)
	
	
	cairo_move_to (cr, x, y + line_offset - 0.5)
	cairo_line_to (cr, x + width, y + line_offset - 0.5)
	cairo_set_source_rgba (cr, 1, 1, 1, 15/255)
	cairo_set_line_width(cr, 1);
	cairo_stroke (cr);
	
	cairo_move_to (cr, x, y + line_offset - 0.5)
	cairo_line_to (cr, x + width * value_perc, y + line_offset - 0.5)
	cairo_set_source_rgb (cr, 235/255, 170/255, 0)
	cairo_set_line_width(cr, 1);
	cairo_stroke (cr);
	
end
