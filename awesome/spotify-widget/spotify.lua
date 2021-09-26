-------------------------------------------------
-- Spotify Widget for Awesome Window Manager
-- Shows currently playing song on Spotify for Linux client
-- More details could be found here:
-- https://github.com/streetturtle/awesome-wm-widgets/tree/master/spotify-widget

-- @author Pavel Makhov
-- @copyright 2020 Pavel Makhov
-------------------------------------------------

local awful = require("awful")
local wibox = require("wibox")
local watch = require("awful.widget.watch")
local helpers = require("helpers")

local GET_SPOTIFY_STATUS_CMD = 'sp status'
local GET_CURRENT_SONG_CMD = 'sp current'

local function ellipsize(text, length)
    return (text:len() > length and length > 0)
        and text:sub(0, length - 3) .. '...'
        or text
end

local spotify_widget = {}

local function worker(user_args)

    local args = user_args or {}

    local play_icon = args.play_icon or '/usr/share/icons/Arc/actions/24/player_play.png'
    local pause_icon = args.pause_icon or '/usr/share/icons/Arc/actions/24/player_pause.png'
    local prev_icon = args.prev_icon
    local next_icon = args.next_icon
    local font = args.font or 'Play 9'
    local dim_when_paused = args.dim_when_paused == nil and false or args.dim_when_paused
    local dim_opacity = args.dim_opacity or 0.2
    local max_length = args.max_length or 15
    local show_tooltip = args.show_tooltip == nil and true or args.show_tooltip
    local timeout = args.timeout or 1
    local max_width = args.max_width or 300
    local separator_text = args.separator_text or ""
    local separator_color = args.separator_color or "#000000"
    local text_color = args.text_color or "#000000"
    local margin_lr = args.margin_lr or 0
    local margin_tb = args.margin_tb or 0
    local bg = args.bg or "#ffffff"
    local border_width = args.border_width or 0
    local border_color = args.border_color or "#000000"
    local shape = args.shape or nil
    local border_radius = args.border_radius or 0
    local tl = args.tl or true
    local tr = args.tr or true
    local bl = args.bl or true
    local br = args.br or true
    local tooltip_bg = args.tooltip_bg or "#ffffff"
    local tooltip_fg = args.tooltip_fg or "#000000"
    local tooltip_width = args.tooltip_width or 300

    local cur_artist = ''
    local cur_title = ''
    local cur_album = ''

    spotify_widget = wibox.widget {
	{
	    id = 'background',
	    {
	        id = 'padding',
	    	{
		    id = 'container',
		    {
	            	id = 'buttons',
	            	layout = wibox.layout.align.horizontal,
	            	{   
	    	    	    id = "prev",
	    	    	    image = prev_icon,
            	    	    widget = wibox.widget.imagebox,
	            	},
                    	{
                    	    id = "icon",
            	    	    widget = wibox.widget.imagebox,
            	    	},
	    	    	{
	    	    	    id = "next",
	    	    	    image = next_icon,
	   	    	    widget = wibox.widget.imagebox,
	    	    	},
	            },
            	    {
	            	{
  	                    {
            	    	    	id = 'artistw',
            	    	    	font = font,
		    	    	widget = wibox.widget.textbox,
                            },
		            {   
		    	    	id = 'separator',
		    	    	text = separator_text,
		    	    	font = font,
		    	    	widget = wibox.widget.textbox,
		    	    },
             	     	    {
                    	    	id = 'titlew',
                    	    	font = font,
                    	    	widget = wibox.widget.textbox
            	    	    },
            	    	    layout = wibox.layout.align.horizontal,
	    	    	},
            	    	layout = wibox.container.scroll.horizontal,
            	    	max_size = max_width,
	    	    	forced_width = max_width,
            	    	step_function = wibox.container.scroll.step_functions.waiting_nonlinear_back_and_forth,
            	    	speed = 60,
            	    },
            	    layout = wibox.layout.align.horizontal,
	    	},
	     	left = margin_lr,
            	right = margin_lr,
            	top = margin_tb,
            	bottom = margin_tb,
	    	widget = wibox.container.margin,
	    },
	    bg = bg,
	    shape_border_width = border_width,
            shape_border_color = border_color,
            shape = shape,
            widget = wibox.container.background,	
	},
	right = 10,  					-- HARDCODED
	widget = wibox.container.margin,

        set_status = function(self, is_playing)
            self.background.padding.container.buttons.icon.image = (is_playing and play_icon or pause_icon) -- this is disastruous 
            if dim_when_paused then
                self:get_children_by_id('icon')[1]:set_opacity(is_playing and 1 or dim_opacity)

                self:get_children_by_id('titlew')[1]:set_opacity(is_playing and 1 or dim_opacity)
                self:get_children_by_id('titlew')[1]:emit_signal('widget::redraw_needed')

                self:get_children_by_id('artistw')[1]:set_opacity(is_playing and 1 or dim_opacity)
                self:get_children_by_id('artistw')[1]:emit_signal('widget::redraw_needed')
            end
        end,
        set_text = function(self, artist, song)
            local artist_to_display = ellipsize(artist, max_length)
            if self:get_children_by_id('artistw')[1]:get_markup() ~= artist_to_display then
                self:get_children_by_id('artistw')[1]:set_markup(helpers.colorize_text(artist_to_display, text_color))
            end
            local title_to_display = ellipsize(song, max_length)
            if self:get_children_by_id('titlew')[1]:get_markup() ~= title_to_display then
                self:get_children_by_id('titlew')[1]:set_markup(helpers.colorize_text(title_to_display, text_color))
            end
            self:get_children_by_id('separator')[1]:set_markup(helpers.colorize_text(separator_text, separator_color))
        end
    }

    local update_widget_icon = function(widget, stdout, _, _, _)
        stdout = string.gsub(stdout, "\n", "")
        widget:set_status(stdout == 'Playing' and true or false)
    end

    local update_widget_text = function(widget, stdout, _, _, _)
        if string.find(stdout, 'Error: Spotify is not running.') ~= nil then
            widget:set_text('','')
            widget:set_visible(false)
            return
        end

        local escaped = string.gsub(stdout, "&", '&amp;')
        local album, _, artist, title =
            string.match(escaped, 'Album%s*(.*)\nAlbumArtist%s*(.*)\nArtist%s*(.*)\nTitle%s*(.*)\n')

        if album ~= nil and title ~=nil and artist ~= nil then
            cur_artist = artist
            cur_title = title
            cur_album = album

            widget:set_text(artist, title)
            widget:set_visible(true)
        end
    end

    watch(GET_SPOTIFY_STATUS_CMD, timeout, update_widget_icon, spotify_widget)
    watch(GET_CURRENT_SONG_CMD, timeout, update_widget_text, spotify_widget)

    --- Adds mouse controls to the widget:
    --  - left click - play/pause
    --  - scroll up - play next song
    --  - scroll down - play previous song
    --[[spotify_widget:connect_signal("button::press", function(_, _, _, button)
        if (button == 1) then
            awful.spawn("sp play", false)      -- left click
        elseif (button == 4) then
            awful.spawn("sp next", false)  -- scroll up
        elseif (button == 5) then
            awful.spawn("sp prev", false)  -- scroll down
        end
        awful.spawn.easy_async(GET_SPOTIFY_STATUS_CMD, function(stdout, stderr, exitreason, exitcode)
            update_widget_icon(spotify_widget, stdout, stderr, exitreason, exitcode)
        end)
    end)]]

    spotify_widget:get_children_by_id('icon')[1]:connect_signal("button::press", function(_, _, _, button)
        if (button == 1) then
            awful.spawn("sp play", false)      -- left click
	end
        
        awful.spawn.easy_async(GET_SPOTIFY_STATUS_CMD, function(stdout, stderr, exitreason, exitcode)
            update_widget_icon(spotify_widget, stdout, stderr, exitreason, exitcode)
        end)
    end)

    
    spotify_widget:get_children_by_id('next')[1]:connect_signal("button::press", function(_, _, _, button)
        if (button == 1) then
            awful.spawn("sp next", false)      -- left click
	end
        
        awful.spawn.easy_async(GET_SPOTIFY_STATUS_CMD, function(stdout, stderr, exitreason, exitcode)
            update_widget_icon(spotify_widget, stdout, stderr, exitreason, exitcode)
        end)
    end)

    
    spotify_widget:get_children_by_id('prev')[1]:connect_signal("button::press", function(_, _, _, button)
        if (button == 1) then
            awful.spawn("sp prev", false)      -- left click
	end
        
        awful.spawn.easy_async(GET_SPOTIFY_STATUS_CMD, function(stdout, stderr, exitreason, exitcode)
            update_widget_icon(spotify_widget, stdout, stderr, exitreason, exitcode)
        end)
    end)


    if show_tooltip then
        local spotify_tooltip = awful.tooltip {
            mode = 'outside',
            preferred_positions = {'bottom'},
            preferred_alignments = {"middle"},
	    shape = helpers.prrect(border_radius, false, false, br, bl),
	    border_width = border_width,
            border_color = border_color,
	    bg = tooltip_bg,
	    fg = tooltip_fg,
	    width = 500,
            margins = 10,
         }

        spotify_tooltip:add_to_object(spotify_widget)

        spotify_widget:connect_signal('mouse::enter', function()
            spotify_tooltip.markup = "<b>Album</b>: " .. cur_album
                .. '\n<b>Artist</b>: ' .. cur_artist
                .. '\n<b>Song</b>: ' .. cur_title
        end)
    end

    return spotify_widget

end

return setmetatable(spotify_widget, { __call = function(_, ...)
    return worker(...)
end })
