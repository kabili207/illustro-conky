--[[
Illustro Conky by Andrew Nagle

This script is a recreation of the Rainmeter Illustro widget theme

IMPORTANT: if you are using the 'cpu' function, it will cause a segmentation
fault if it tries to draw a value straight away. The if statement on line 145
uses a delay to make sure that this doesn't happen. It calculates the length
of the delay by the number of updates since Conky started. Generally, a value
of 5s is long enough, so if you update Conky every 1s, use update_num>5 in
that if statement (the default). If you only update Conky every 2s, you
should change it to update_num>3; conversely if you update Conky every 0.5s,
you should use update_num>10. ALSO, if you change your Conky, is it best to
use "killall conky; conky" to update it, otherwise the update_num will not
be reset and you will get an error.

To call this script in Conky, use the following (assuming that you save this script to ~/scripts/illustro.lua):
    lua_load ~/scripts/illustro.lua
    lua_draw_hook_pre conky_main
    
Changelog:
  v1.0 -- Original release (2015-08-22)
]]

boxes = {

	{
		title='System',
		values= {
			{
				title='CPU Usage',
				value='${cpu cpu0}',
				suffix='%',
				max=100
			},
			{
				title='RAM Usage',
				value='${memperc}',
				suffix='%',
				max=100
			},
			{
				title='Swap Usage',
				value='${swapperc}',
				suffix='%',
				max=100
			},
		}
	},

	{
		title='Disks',
		values={
			{
				title='root',
				value='${fs_used_perc /}',
				suffix='%',
				max=100
			},
			{
				title='home',
				value='${fs_used_perc /home}',
				suffix='%',
				max=100
			},
			{
				title='media',
				value='${fs_used_perc /mnt/media}',
				suffix='%',
				max=100
			},
		}
	},

	{
		title='Network',
		values={
			{
				title='Address',
				value='${addr enp4s0}',
				suffix='',
				max=100
			},
			{
				title='Down',
				value='${downspeed enp4s0}',
				suffix='',
				max=100
			},
			{
				title='Up',
				value='${upspeed enp4s0}',
				suffix='',
				max=100
			},
		}
	},

	{
		title='Temperatures',
		values={
			{
				title='CPU Temp',
				value='${hwmon 0 temp 3}',
				suffix=' C', -- conky can't handle °
				max=90
			},
			{
				title='GPU Temp',
				value='${execi 10 nvidia-smi -a | grep "GPU Current Temp" | awk \'{print \$5}\' }',
				suffix=' C',
				max=90
			},
			{
				title='HDD - Linux',
				value='${execi 10 udisks --show-info /dev/sda | grep temperature-celsius-2 | cut -c 52-53}',
				suffix=' C',
				max=60
			},
			{
				title='HDD - Windows',
				value='${execi 10 udisks --show-info /dev/sdb | grep temperature-celsius-2 | cut -c 52-53}',
				suffix=' C',
				max=60
			},
			{
				title='HDD - Games',
				value='${execi 10 udisks --show-info /dev/sdc | grep temperature-celsius-2 | cut -c 52-53}',
				suffix=' C',
				max=60
			},
		}
	},

	{
		title='Fans',
		values={
			{
				title='CPU Fan',
				value='${platform it87.656 fan 1}',
				suffix=' RPM',
				max=3500
			},
			{
				title='Front Fan',
				value='${platform it87.656 fan 4}',
				suffix=' RPM',
				max=2800
			},
			{
				title='Rear Fan',
				value='${platform it87.656 fan 2}',
				suffix=' RPM',
				max=2000
			},
			{
				title='GPU Fan',
				value='${execi 2 nvidia-smi -a | grep Fan | awk \'{print \$4}\' }',
				suffix='%',
				max=100
			},
		}
	},

	{
		title='Portage',
		values={
			{
				title='Last Sync',
				value='${execi 90 /home/kabili/bin/lastsync.pl}',
				suffix='',
				max=100
			},
			{
				title='Progress',
				value='${execi 30 /home/kabili/bin/emerge-progress.sh}',
				suffix='%',
				max=100
			},
		}
	},
}

require 'cairo'
require 'math'
require 'string'

function rgb_to_r_g_b(colour, alpha)
	return ((colour / 0x10000) % 0x100) / 255., ((colour / 0x100) % 0x100) / 255., (colour % 0x100) / 255., alpha
end

function table_length(T)
	local count = 0
	for _ in pairs(T) do count = count + 1 end
	return count
end

function conky_main()
	
	-- Check that Conky has been running for at least 5s

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
	
	if update_num > 5 then
		for i in pairs(boxes) do
			local box = boxes[i]
			local box_height = draw_illustro_box(cr, box.title, 0, box_offset, box.values)
			box_offset = box_height + box_offset
		end
	end
	
	
end


function draw_illustro_box(cr, title, x, y, values)

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
	
	for i in pairs(values) do
		local value = values[i]
		draw_value(cr, value_x, value_y, value_h, value_w, value)
		value_y = value_y + value_h
	end
	
	
	
	return height + (box_margin * 2)

end

function draw_value(cr, x, y, height, width, value)

	--local title_x, title_y
	local line_offset = 12

	local text = value.title
	local value_int = conky_parse(value.value)
	local value_max = conky_parse(value.max)
	local value_perc = (tonumber(value_int) ~= nil and value_int or 0) / value_max
	local value_text = value_int .. value.suffix
	
	
	cairo_select_font_face (cr, "Trebuchet MS", CAIRO_FONT_SLANT_NORMAL,
                               CAIRO_FONT_WEIGHT_BOLD)
	cairo_set_font_size (cr, 11.0)
	
	local extents = cairo_text_extents_t:create()
	
	-- Dummy value to make sure text is aligned
	cairo_text_extents (cr, 'W', extents)
	local text_top = y + extents.height
	
	cairo_set_source_rgba (cr, 1, 1, 1, 205/255)
	cairo_move_to (cr, x, text_top)
	cairo_show_text (cr, text)
	
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
