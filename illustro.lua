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
  v1.5 -- Add support for groups of panels at different locations
]]


require 'cairo'
require 'math'
require 'string'

local rows = nil
local value_cache = {}

local title_font_size = 15.0
local value_font_size = 13.0
local value_line_pad = 0.65
local box_width = 220
local image_scale = 0.75

local xdg_cache_dir = os.getenv("XDG_CACHE_HOME") or (os.getenv("HOME").."/.cache") 
local cache_dir = xdg_cache_dir.."/conky"
local player_cmd = 'playerctl metadata --format \'{{ status }} | {{ title }} | {{ artist }} | {{ album }} | {{ mpris:length }} | {{ position }} | {{ mpris:artUrl }}\'  2>&1'
local current_directory = ""

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

function build_array(...)
  local arr = {}
  for v in ... do
    arr[#arr + 1] = v
  end
  return arr
end

function trim(s)
  if s==nil then return end
  return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
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
	
	
	-- Check that Conky has been running for at least 5s
	if update_num > 5 then
	
		if rows == nil then
			current_directory = debug.getinfo(conky_main).source:sub(2):gsub('/[^/]+$', '')
			package.path = package.path .. ";" .. current_directory .. "/?.lua"
			rows = require('config')
		end
	
		for j in pairs(rows) do
			local row = rows[j]
			local box_x = row.x
			local box_y = row.y
			if row.align == 'right' then
				box_x = box_x - box_width
			end
			for i in pairs(row.boxes) do
				local box = row.boxes[i]
				local box_height = draw_box(cr, box.title, box_x, box_y, box.values)
				box_y = box_height + box_y
			end
		end
	end
	
	
end


function draw_box(cr, title, x, y, values)

	local width         = box_width
	local height        = 200
	local aspect        = 1.0    --/* aspect ratio */
	local corner_radius = 5   --/* and corner curvature radius */

	local top_height = 28
	
	local radius = corner_radius / aspect
	local degrees = math.pi / 180.0
	
	local box_margin = 5
	local box_padding = 5
	
	cairo_select_font_face (cr, "Trebuchet MS", CAIRO_FONT_SLANT_NORMAL,
                               CAIRO_FONT_WEIGHT_BOLD)
	
	local extents = cairo_text_extents_t:create()

	local title_text = string.upper(title)
	cairo_set_font_size (cr, title_font_size)
	cairo_text_extents (cr, title_text, extents)
	top_height = extents.height * 3 --+ (head_y_padding * 2)
	
	width = width - (box_margin * 2)
	value_row_height = get_value_row_height(cr, width)
	mpris_row_height = get_mpris_row_height(cr, width)
	
	local num_value_rows = 0
	local num_mpris_rows = 0
	for i in pairs(values) do
		if values[i].type == 'mpris' then
			num_mpris_rows = num_mpris_rows + 1
		else
			num_value_rows = num_value_rows + 1
		end
	end
	
	height = top_height + (num_value_rows * value_row_height) + (num_mpris_rows * mpris_row_height) + box_padding
	
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
	
	
	local title_x, title_y
	cairo_set_font_size (cr, title_font_size)
	title_x = x + (width/2 -(extents.width/2 + extents.x_bearing))
	title_y = y + (top_height/2-(extents.height/2 + extents.y_bearing))
	
	cairo_set_source_rgba (cr, 1, 1, 1, 205/255)
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
		value_h = draw_row(cr, value_x, value_y, value_h, value_w, value, value_cache[title])
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

function get_value_row_height(cr, avail_width)

	cairo_select_font_face (cr, "Trebuchet MS", CAIRO_FONT_SLANT_NORMAL,
                               CAIRO_FONT_WEIGHT_BOLD)
	cairo_set_font_size (cr, value_font_size)
	
	local extents = cairo_text_extents_t:create()
	
	-- Dummy value to make sure text is aligned
	cairo_text_extents (cr, 'W', extents)
	local text_top = extents.height
	local line_offset =  extents.height + (extents.height * value_line_pad)
	return line_offset * (value_line_pad * 2.2)
end

function get_mpris_row_height(cr, avail_width)

	cairo_select_font_face (cr, "Trebuchet MS", CAIRO_FONT_SLANT_NORMAL,
                               CAIRO_FONT_WEIGHT_BOLD)
	cairo_set_font_size (cr, value_font_size)
	
	local extents = cairo_text_extents_t:create()
	
	-- Dummy value to make sure text is aligned
	cairo_text_extents (cr, 'W', extents) 
	
	return extents.height * 3 + (extents.height * value_line_pad * 4) + (avail_width * image_scale)
end

function draw_row(cr, x, y, height, width, value, cache)
	if value.type == 'mpris' then
		return draw_mpris(cr, x, y, height, width, value, cache)
	end
	return draw_value(cr, x, y, height, width, value, cache)
end

function draw_value(cr, x, y, height, width, value, cache)

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
	cairo_set_font_size (cr, value_font_size)
	
	local extents = cairo_text_extents_t:create()
	
	-- Dummy value to make sure text is aligned
	cairo_text_extents (cr, 'W', extents)
	local text_top = y + extents.height
	local line_offset =  extents.height + (extents.height * value_line_pad)
	
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
	cairo_set_line_width(cr, 1.5);
	cairo_stroke (cr);
	
	cairo_move_to (cr, x, y + line_offset - 0.5)
	cairo_line_to (cr, x + width * value_perc, y + line_offset - 0.5)
	cairo_set_source_rgb (cr, 235/255, 170/255, 0)
	cairo_set_line_width(cr, 1.5);
	cairo_stroke (cr);
	
	return line_offset * (value_line_pad * 2.2)
	
end

function draw_mpris(cr, x, y, height, width, value, cache)
	local currPlayer = os.capture(player_cmd, true)
	local pVals = build_array(string.gmatch(currPlayer, "([^\\|]+)"))
	local pStatus = trim(pVals[1])
	local pTitle = trim(pVals[2])
	local pArtist = trim(pVals[3])
	local pAlbum = trim(pVals[4])
	local pLength = trim(pVals[5])
	local pPosition = trim(pVals[6])
	local pArt = trim(pVals[7])
	local cached_uuid = cache[pArt]
	
	max_image_size = width * image_scale
	
	if pArt ~= nil then
		
		if cached_uuid == nil then
			cached_uuid = trim(os.capture("echo -n \""..pArt.."\" | md5sum | awk '{print $1}'"))
			os.execute("mkdir -p "..cache_dir)
			os.execute(current_directory.."/fetch_and_convert_to_png.sh \""..pArt.."\" "..cache_dir.."/"..cached_uuid..".png")
			cache[pArt] = cached_uuid
		end
		
		local art_path = cache_dir.."/"..cached_uuid..".png"
		
		local tmp_surface = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, width, width)
		local tmp_cr = cairo_create(tmp_surface)
		local image = cairo_image_surface_create_from_png (art_path)
		
		w = cairo_image_surface_get_width (image)
		h = cairo_image_surface_get_height (image)
		
		cairo_scale (tmp_cr, max_image_size/w, max_image_size/h)
		cairo_set_source_surface (tmp_cr, image, 0, 0)
		cairo_paint (tmp_cr)

		cairo_set_source_surface (cr, tmp_surface, x + (width-max_image_size)/2, y)
		cairo_paint(cr)
		
		cairo_destroy(tmp_cr)
		cairo_surface_destroy (tmp_surface)
		cairo_surface_destroy (image)
	
	end
		
	cairo_select_font_face (cr, "Trebuchet MS", CAIRO_FONT_SLANT_NORMAL,
							   CAIRO_FONT_WEIGHT_BOLD)
	cairo_set_font_size (cr, value_font_size)
	
	local extents = cairo_text_extents_t:create()
	
	-- Dummy value to make sure text is aligned
	cairo_text_extents (cr, 'W', extents)
	
	local text_top = y + max_image_size + extents.height + (extents.height * value_line_pad)
	
	cairo_set_source_rgba (cr, 1, 1, 1, 205/255)
	cairo_move_to (cr, x, text_top)
	cairo_show_text (cr, pTitle)
	
	text_top = text_top + extents.height + (extents.height * value_line_pad)
	cairo_move_to (cr, x, text_top)
	cairo_show_text (cr, pArtist)
	
	text_top = text_top + extents.height + (extents.height * value_line_pad)
	cairo_move_to (cr, x, text_top)
	cairo_show_text (cr, pAlbum)
	
	local line_offset = text_top + (extents.height * value_line_pad)
	
	cairo_move_to (cr, x, line_offset - 0.5)
	cairo_line_to (cr, x + width, line_offset - 0.5)
	cairo_set_source_rgba (cr, 1, 1, 1, 15/255)
	cairo_set_line_width(cr, 1.5);
	cairo_stroke (cr);
	
	cairo_move_to (cr, x, line_offset - 0.5)
	if pPosition ~= nil and pLength ~= nil then
		cairo_line_to (cr, x + width * (tonumber(pPosition) / tonumber(pLength)), line_offset - 0.5)
	end
	cairo_set_source_rgb (cr, 235/255, 170/255, 0)
	cairo_set_line_width(cr, 1.5);
	cairo_stroke (cr);
	
	return line_offset * (value_line_pad * 2.2)
end

